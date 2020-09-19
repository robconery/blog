---
layout: post
title: "Designing a PostgreSQL Document API"
slug: designing-a-postgresql-document-api
summary: ""
comments: true
image: /img/2015/08/pg_api_1.jpg
categories: Postgres
---

PostgreSQL as many know, supports JSON as a storage type and with the release of 9.4, Postgres now supports storing JSON as `jsonb` - a binary format.

This is great news for people who want to move beyond simple "store JSON as text". `jsonb` supports indexing now using the GIN index, and also has a special query operator that takes advantage of the GIN index.

## Who Cares?
[It's been fun to explore `jsonb` in Postgres](http://rob.conery.io/2015/03/01/document-storage-gymnastics-in-postgres/) and to see what's possible. Which is kind of the problem: *it's only an exploration and some musing*, to get any work done leaves a little to be desired.

What I mean is that other systems (like [RethinkDB](http://rethinkdb.com)) have a ton of functionality already built in to help you save documents, query documents, and optimize things. Postgres has some interesting abilities this way - but out of the box querying is pretty ... lacking to be honest.

Consider this query:

```sql
select document_field -> 'my_key' from my_docs
where document_field @> '{"some_key" : "some_value"}';
```

It surfaces a bit of weirdness when it comes to JSON and Postgres: *it's all strings*. Obviously SQL has no understanding of JSON, so *you have to format it as a string*. Which means **working directly with JSON in SQL is a pain.** Of course [if you have a good query tool](https://github.com/robconery/massive) that problem is lessened to a degree... but it still exists.

In addition, the storage of a document is a little free-for-all. Do you have a single column that's `jsonb`? Or Multiple columns in a larger table structure? It's up to you - which is nice but too many choices can also be paralyzing.

So why worry about all of this? If you want to use a document database then *use a document database*. I agree with that... but there's one really compelling reason to use Postgres (for me at least)...

<a href="http://rob.conery.io/img/2015/08/iu.gif"><img src="http://rob.conery.io/img/2015/08/iu.gif" alt="iu" width="500" height="333" class="alignnone size-full wp-image-478" /></a>

Postgres is ACID-compliant. That means you can rely on it to write your data and, hopefully, [not lose it](http://hackingdistributed.com/2013/01/29/mongo-ft/).

Postgres is also *relational*, which means that if you want to graduate to a stricter schema as time goes on *you can*. There are a number of reasons you might want to choose Postgres - for now let's say you have made that choice and want to start working with Documents and `jsonb`.

## A Better API

Personally, I'd love to see more functions that support the notion of working with documents. Right now we have built-ins that support working with the JSON types - but nothing that supports a higher level of abstraction.

That doesn't mean we can't build such an API ourselves. Which I did :). Here goes...

## A Document Table

I want to store documents in a table that has some meta information as well as additional ways I can query the information, specifically: Full Text Search.

The structure of the table can be opinionated - why not we're building out this abstraction! Let's start with this:

```sql
create table my_docs(
  id serial primary key,
  body jsonb not null,
  search tsvector,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
)
```

There will be some duplication here. The document itself will be stored in the `body` field, including the id, which is also stored as a primary key (we need this because this is still Postgres). I'm embracing duplication, however, because:

 - I'll own this API and I'll be able to make sure everything is synced up
 - That's just the way it is in document systems

## Saving a Document

What I'd like in a `save_document` function is the ability to...

 - Create a table on the fly
 - Create the necessary indexes
 - Create timestamps and a searchable field (for Full Text indexing)

I can do this by creating my own function `save_document` and, for fun I'll use PLV8 - *Javascript in the database*. In fact I'll create two functions - one that specifically creates my table, and another that saves the document itself.

First, `create_document_table`:

```sql
create function create_document_table(name varchar, out boolean)
as $$
  var sql = "create table " + name + "(" +
    "id serial primary key," +
    "body jsonb not null," +
    "search tsvector," +
    "created_at timestamptz default now() not null," +
    "updated_at timestamptz default now() not null);";

  plv8.execute(sql);
  plv8.execute("create index idx_" + name + " on docs using GIN(body jsonb_path_ops)");
  plv8.execute("create index idx_" + name + "_search on docs using GIN(search)");
  return true;
$$ language plv8;
```

This function creates a table and appropriate indexes - one for the `jsonb` field in our document table, the other for the `tsvector` full text index. You'll notice that I'm building SQL strings on the fly and executing with `plv8` - that's the way you do it with Javascript in Postgres.

Next, let's create our `save_document` function:

```sql
create function save_document(tbl varchar, doc_string jsonb)
returns jsonb
as $$
  var doc = JSON.parse(doc_string);
  var result = null;
  var id = doc.id;
  var exists = plv8.execute("select table_name from information_schema.tables where table_name = $1", tbl)[0];

  if(!exists){
    plv8.execute("select create_document_table('" + tbl + "');");
  }

  if(id){
    result = plv8.execute("update " + tbl + " set body=$1, updated_at = now() where id=$2 returning *;",doc_string,id);
  }else{
    result = plv8.execute("insert into " + tbl + "(body) values($1) returning *;", doc_string);
    id = result[0].id;
    doc.id = id;
    result = plv8.execute("update " + tbl + " set body=$1 where id=$2 returning *",JSON.stringify(doc),id);
  }

  return result[0] ? result[0].body : null;

$$ language plv8;
```

I'm sure this function looks a bit strange, but if you read through each line you should be able to figure out a few things. But why the `JSON.parse()` call?

This is because the Postgres `jsonb` type is not really JSON here - it's a string. Outside our PLV8 bits is still Postgres World and it works with JSON as a string (storing it in `jsonb` in a binary format). So, when our document is passed to our function it's as a string, which we need to parse if we want to work with it as a JSON object in Javascript.

In the insert clause you'll notice that I have to synchronize the ID of the document with that of the primary key that was just created. A little cumbersome, but it works fine.

Finally - you'll notice that in the original insert call as well as the update, I'm just passing the `doc_string` argument right into the `plv8.execute` call as a parameter. That's because you need to treat JSON values as strings in Postgres.

This can be really confusing. If I try to send in `doc` (our JSON.parsed object) it will get turned into `[Object object]` by plv8. Which is weird.

Moreover if I try to return a Javascript object from this function (say, our `doc` variable) - I'll get an error that it's an invalid format for the type JSON. Which is *ultra confusing*.

For our result I'm simply returning the body from our query result - and it's a string, believe it or not, and I can just pass it straight through as a result. I should note here as well that all results from `plv8.execute` return an Array of items that you can work with as Javascript objects.

## The Result

It works really well! And it's fast. If you want to try it out you'll need to install the PLV8 extension and then write your query accordingly:

```sql
create extension plv8;
select * from save_document('test_run', '{"name" : "Test"}');
```

You should see a new table and a new record in that table:

<a href="http://rob.conery.io/img/2015/08/save_document_1.png"><img src="http://rob.conery.io/img/2015/08/save_document_1.png" alt="save_document_1" width="650" height="208" class="alignnone size-full wp-image-520" /></a>

## More To Do

In the next post I'll add some additional features, specifically:

 - Automatically updating the `search` field
 - Bulk document insert using arrays

This is a good start!
