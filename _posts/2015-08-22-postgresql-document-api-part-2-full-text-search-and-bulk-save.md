---
layout: post
title: "PostgreSQL Document API Part 2: Full Text Search and Bulk Save"
slug: postgresql-document-api-part-2-full-text-search-and-bulk-save
summary: ""
comments: true
image: /img/2015/08/pg_doc_search.jpg
categories: Postgres
---

In [part 1 of this series](http://rob.conery.io/2015/08/20/designing-a-postgresql-document-api/) I setup a nice save function, as well as another function to create an opinionated document storage table on the fly.
This works well and does what's needed, but we can do so much more. Specifically: *I want Full Text Indexing on the fly and bulk saves within a transaction*.

Let's do it.

## Full Text Search

Our document table has a search field in it that's of type `tsvector`, which is indexed using the GIN index for speed. I want to update that field whenever I save the document, and I don't want to have a lot of API noise when doing it.

So I'll use some convention.

Typically, when creating a Full Text Index, you'll store fields with fairly specific names. Things like:

 - First or Last name, maybe email
 - a Title or Description of something
 - Address Information

I'd like to scan my document when it gets saved to see if it has any keys I might want indexed, and then I want to save them in my `search` field. I can do that with a function which I'll call `update_search`:

```sql
create function update_search(tbl varchar, id int)
returns boolean
as $$
  //get the record
  var found = plv8.execute("select body from " + tbl + " where id=$1",id)[0];
  if(found){
    var doc = JSON.parse(found.body);
    var searchFields = ["name","email","first","first_name",
                       "last","last_name","description","title",
                       "street", "city", "state", "zip", ];
    var searchVals = [];
    for(var key in doc){
      if(searchFields.indexOf(key.toLowerCase()) > -1){
        searchVals.push(doc[key]);
      }
    };

    if(searchVals.length > 0){
      var updateSql = "update " + tbl + " set search = to_tsvector($1) where id =$2";
      plv8.execute(updateSql, searchVals.join(" "), id);
    }
    return true;
  }else{
    return false;
  }

$$ language plv8;
```

Again, I'm using Javascript to do this (PLV8) and I'm pulling out a document based on ID. I'm then looping over the keys to see if there are any that I might want to store, if there are, I'm pushing to an array.

If we have any hits in that array I'm concatenating the values and saving in the `search` field of the document using `to_tsvector`, which is a built-in Postgres function that takes loose text and turns it into indexable values.

And that's it! Running this, we get the following:

<a href="http://rob.conery.io/img/2015/08/update_search.png"><img src="http://rob.conery.io/img/2015/08/update_search-1024x383.png" alt="update_search" width="1024" height="383" class="alignnone size-large wp-image-530" /></a>

That's perfect - now I can just pop this into my `save_document` function right at the end, and it gets called transactionally whenever I save something:

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

  //run the search indexer
  plv8.execute("perform update_search($1, $2)", tbl,id);
  return result[0] ? result[0].body : null;

$$ language plv8;
```

## Bulk Saves

Right now I can pass in a single document to `save_document`, but I'd also like to be able to pass in an Array. I can do this by checking the type of the argument, and then pulling things out in a loop:

```sql
create function save_document(tbl varchar, doc_string jsonb)
returns jsonb
as $$
  var doc = JSON.parse(doc_string);

  var exists = plv8.execute("select table_name from information_schema.tables where table_name = $1", tbl)[0];
  if(!exists){
    plv8.execute("select create_document_table('" + tbl + "');");
  }

  //function that executes our SQL statement
  var executeSql = function(theDoc){
    var result = null;
    var id = theDoc.id;
    var toSave = JSON.stringify(theDoc);

    if(id){
      result=plv8.execute("update " + tbl + " set body=$1, updated_at = now() where id=$2 returning *;",toSave, id);
    }else{
      result=plv8.execute("insert into " + tbl + "(body) values($1) returning *;", toSave);

      id = result[0].id;
      //put the id back on the document
      theDoc.id = id;
      //resave it
      result = plv8.execute("update " + tbl + " set body=$1 where id=$2 returning *;",JSON.stringify(theDoc),id);
    }
    plv8.execute("select update_search($1,$2)", tbl, id);
    return result ? result[0].body : null;
  }
  var out = null;

  //was an array passed in?
  if(doc instanceof Array){
    for(var i = 0; i &lt; doc.length;i++){
      executeSql(doc[i]);
    }
    //just report back how many documents were saved
    out = JSON.stringify({count : i, success : true});
  }else{
    out = executeSql(doc);
  }
  return out;
$$ language plv8;
```

The nice thing about working with Javascript here is that the logic required for this kind of routine is fairly straightforward (as opposed to using PLPGSQL). I've pulled out the actual save routine into its own function - this is Javascript after all - so I can avoid duplication.

Then I check to see if the passed-in argument is an Array. If it is, I loop over it and call `executeSql`, returning a rollup of what happened.

If it's not an Array, I just execute things as I have been, returning the entire document. The result:

<a href="http://rob.conery.io/img/2015/08/bulk_save.png"><img src="http://rob.conery.io/img/2015/08/bulk_save-1024x413.png" alt="bulk_save" width="1024" height="413" class="alignnone size-large wp-image-527" /></a>

Nice! The best thing about this is that **it happens in a transaction**. I love that!

## Node Weirdness

If only this could work perfectly from Node! I've tried in both .NET and Node and, with .NET, things just work (oddly) using the Npgsql library. With Node, not so much.

Long story short: *the node_pg driver does some weird serialization when it sees an object or array coming in as a parameter*. Consider the following:

```js
var pg = require("pg");
var run = function (sql, params, next) {
  pg.connect(args.connectionString, function (err, db, done) {
    //throw if there's a connection error
    assert.ok(err === null, err);

    db.query(sql, params, function (err, result) {
      //we have the results, release the connection
      done();
      pg.end();
      if(err){
        next(err,null);
      }else{
        next(null, result.rows);
      }
    });
  });
};

run("select * from save_document($1, $2)", ['customer_docs', {name : "Larry"}], function(err,res){
  //works just fine
}
```

This is fairly typical Node/PG code. At the bottom, the run function is set to call my `save_document` function and pass along some data. When PG sees the object come in, it will serialize it to a string and the save will happen fine.

If I send an array, however...

```js
run("select * from save_document($1, $2)",
         ['customer_docs', [{name : "Larry"}, {name : "Susie"}],
         function(err,res){
  //crashes hard
}
```

I'll get an error back saying that I have invalid JSON. The error message (from Postgres) will say it's due to this poorly formatted JSON:

```
{"{name : "Larry"}, ...}
```

Which ... yeah is hideous. I've tried to figure out what's going on, but basically it looks like the node_pg driver is stripping out the outer array - perhaps calling Underscores `flatten` method? I don't know. To get around this you need to change your call to this:

```js
run("select * from save_document($1, $2)",
         ['customer_docs', JSON.stringify([{name : "Larry"}, {name : "Susie"}]),
         function(err,res){
  //Works fine
}
```

## Onward!

This save routine is pretty slick, and it makes me happy. In the next post I'll tackle the finders, and also create a Full Text Search function.
