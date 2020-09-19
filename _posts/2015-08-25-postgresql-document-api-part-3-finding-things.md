---
layout: post
title: "PostgreSQL Document API Part 3: Finding Things"
slug: postgresql-document-api-part-3-finding-things
summary: ""
comments: true
image: /img/2015/08/pg_press.jpg
categories: Postgres
---

In parts 1 and 2 of this little series I showed various ways to [save a document](http://rob.conery.io/2015/08/20/designing-a-postgresql-document-api/) and then [update its search field](http://rob.conery.io/2015/08/21/postgresql-document-api-part-2-full-text-search-and-bulk-save/). I also showed how to do a Bulk Saves of many documents transactionally. In this post I'll explore options for running queries.

## A Better Way To Find Documents

In part 1 we designed a bit of an opinionated table, which looks like this:

```sql
create table my_docs(
  id serial primary key,
  body jsonb not null,
  search tsvector,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
)
```

Since we have control over how the data is stored, we can write our own functions to pull that data out in various fun ways! The hard stuff is behind us (saving, updating, etc) - let's have some fun.

## Pulling A Document By ID

Every document has an `id` field associated with that's managed entirely by the `save_document` function. This is still postgres so every row needs a primary key - and we're planting that key in the document itself. I've set mine up to be an integer key, but you can also do [a Twitter Snowflake `bigint`](http://rob.conery.io/2014/05/29/a-better-id-generator-for-postgresql/) if you want; for now: we go with a serial int.

The function for this is pretty straightforward:

```sql
create function find_document(tbl varchar, id int, out jsonb)
as $$
  //find by the id of the row
  var result = plv8.execute("select * from " + tbl + " where id=$1;",id);
  return result[0] ? result[0].body : null;

$$ language plv8;

select * from find_document('customers',20);
```

*BTW: my syntax highlighter is completely thrown by the SQL/JS stuff, sorry for the weird formatting here*

This is the simplest possible function - it takes the name of the table and the ID you're looking for and does the fastest query possible (which we like!): **a search by primary key**. Speed: *we like it*.

Now lets add one for a *containment* query. For this I want to enter some criteria and have it return the first match to me. This is only valid if *I also order the results*, so I'll do that too and default the `ORDER BY` parameter to be the ID:

```sql
create function find_document(
  tbl varchar,
  criteria varchar,
  orderby varchar default 'id'
)
returns jsonb
as $$
  var valid = JSON.parse(criteria); //this will throw if it invalid
  var results = plv8.execute("select body from " +
                tbl +
                " where body @> $1 order by body ->> '" +
                orderby + "' limit 1;",criteria);
  return results[0] ? results[0].body : null
$$ language plv8;

select * from find_document('customers','{"last": "Conery"}', 'first');
```

There's a bit more to this, and you'll have weird behavior depending on the driver you use. The first thing to notice is that I'm overloading `find_document` because Postgres allows this. This means that the only difference between our first function, which finds by id, and this function is the argument list.

For the Npgsql driver this is no problem. For the node_pg driver, it's a big one. Because I'm defaulting the `orderby` parameter, some confusion creeps in when selecting which function to run. As far as I can tell, the node_pg driver doesn't worry about the types of function arguments, **only the amount of them**. So, if you try to run the "find by id" function above, our second function here will fire.

Again: Npgsql (the .NET driver) doesn't have this issue. So if you have problems just rename one of the functions, or take off the default for the parameter.

Another thing to notice is that I specified the `criteria` parameter as `varcher`. I did this because, while technically incorrect, it makes the API a bit nicer. If I specified it as `jsonb` you would have to run the query thus:

```sql
select * from find_document('customers','{"last": "Conery"}'::jsonb, 'first');
```

Not a huge deal really, since we'll be using this API mostly from code (which I'll go into in the next post).

## Filtering

Let's do the same thing now, but for multiple document returns:

```sql
create function filter_documents(  
  tbl varchar,
  criteria varchar,
  orderby varchar default 'id'
)
returns setof jsonb
as $$
  var valid = JSON.parse(criteria);//this will throw if it invalid
  var results = plv8.execute("select body from " +
                tbl +
                " where body @> $1 order by body ->> '" +
                orderby +
                "'",criteria);

  var out = [];
  for(var i = 0;i &lt; results.length; i++){
    out.push(results[i].body);
  }
  return out;
$$ language plv8;

select * from find_document('customer_docs','{"last": "Conery"}');
```

This one is a bit funkier. My result here is a `setof jsonb`, which means I need to return a bunch of rows of `jsonb`. It's not directly clear how you do this with PLV8, and there may be a better way than I'm doing it - but this is what I found that works.

Once I get the results (which are rows from our document table), I need to loop over that set and push the `jsonb` body field into an array, which I then return.

This works because the `body` field is `jsonb` which, essentially, is text. It's not a Javascript object because, if it was, I'd get an error (the old [Object object] parsing silliness).

## SQL Injection

Many of you will notice the `orderby` parameter here is concatenated directly in. If you let your clients write SQL in your database then **yes**, there's a problem. But, hopefully, you'll be executing this function from a driver that will parameterize your queries for you so that, something like this:

```js
db.filter("customers", {
  last : "Conery",
  orderBy : "a';DROP TABLE test; SELECT * FROM users WHERE 't' = 't"
}, function(err, res){
  console.log(err);
  console.log(res);
});
```

... won't work. Why not? Because ideally you're making the call like this:

```sql
select * from filter_documents($1, $2, $3);
```

If not, you get what you deserve :).

## Full Text Query

Let's finish this up with a Full Text search on our docs, shall we. This one's my favorite:

```sql
create function search_documents(tbl varchar, query varchar)
returns setof jsonb
as $$
  var sql = "select body, ts_rank_cd(search,to_tsquery($1)) as rank from " +
             tbl +
            " where search @@ to_tsquery($1) " +
            " order by rank desc;"

  var results = plv8.execute(sql,query);
  var out = [];
  for(var i = 0; i &lt; results.length; i++){
    out.push(results[i].body);
  }
  return out;
$$ language plv8;

select * from search_documents('customers', 'jolene');
```

This one is straightforward if you know how Full Text Indexing works with Postgres. Here, we're simply querying the `search` field (which is GIN indexed for speed), which we've updated on every save. This query is lightning fast, and very easy to use.

## Flexing Indexes

In the two functions that take criteria (find and filter), I'm using the [Containment operator](http://www.postgresql.org/docs/current/static/datatype-json.html) (scroll down to section 8.14.3). It's the little `@>` symbol.

This operator is specific to `jsonb` and allows us to use the GIN index we put on the `body` field. This index looks like this:

```sql
create index idx_customers on customers using GIN(body jsonb_path_ops);
```

The special sauce here is the `jsonb_path_ops`. This tells the indexer to optimize for `jsonb` containment operations (basically: *does this bit of jsonb exist in this other bit of jsonb*). This means the index is faster and smaller.

Now, see this is where I would link to a bunch of benchmarks and articles about how PostgreSQL walks all over MongoDB etc when it comes to writes/reads. But that's entirely misleading.

## Read and Write Speed

If you put a single Postgres server up against a single MongoDB server, MongoDB will look rather silly and Postgres will smoke it on almost every metric. This is because that is how Postgres was designed - a "scale up" database, basically.

If you optimize MongoDB and add some servers to handle the load, things start to balance out but then you also get to deal with a horizontal system that [might not do what you think it's supposed to do](https://aphyr.com/posts/322-call-me-maybe-mongodb-stale-reads). This whole thing is highly arguable, of course, but I it's worth pointing out that:

 - Indexing in Postgres slows things down. So if it's slamming write performance you want, you might want to tweak the index to target only what you want indexed (by specifying `(body -> my_field)` in the GIN specification.
 - If you query on something very often (like email), just replicate it to its own column and throw a `UNIQUE` on it. You can handle the synchronization in code or your own function.

In the next post I'll dive into ways you can call this stuff from code!
