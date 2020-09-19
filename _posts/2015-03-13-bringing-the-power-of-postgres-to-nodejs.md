---
layout: post
title: "Bringing The Power of Postgres to NodeJS"
slug: bringing-the-power-of-postgres-to-nodejs
summary: ""
comments: false
image: /img/2015/03/massive-title.jpg
categories: Node Postgres
---

I'm building out an idea I have and, as you may have guessed from the last few blog posts I've written - I'm using Postgres to do it.

[I like SQL a lot](http://rob.conery.io/2015/02/24/embracing-sql-in-postgres/) - but that doesn't mean I'm going to drop SQL statements all over my application (despite what some of my commenters have suggested). I *do* like a little abstraction - but for the life of me I couldn't find a tool out there that **got the abstraction right** - in other words:

 - Take care of the mundane `select * from` and `insert into` bits
 - Let me use SQL where and how I wanted and (this is the most important)
 - **help me use SQL where and how I wanted**

In addition there's nothing out there in the Node space that's working directly with [Postgres' radical `jsonb` document capabilities](http://rob.conery.io/2015/03/01/document-storage-gymnastics-in-postgres/). Not that I've seen anyway.

[So I built it](https://github.com/robconery/massive-js). You can install it today with `npm install massive`.

## MassiveJS 2.0: Rebuilt To Embrace Postgres

Over the last 3 weeks I've been working with [Jon Atten](http://twitter.com/xivsolutions) to build out something that I wish existed: **a dedicated Postgres data tool**. Something that didn't give a flying fuck about "database portability" and instead let you dive face-first into all that a database can do.

So, here you go. Let's take a look at some of the fun features I threw in there.

### SQL Files as Functions

This one is my favorite. You create a file with a query in it - just regular old SQL with a `.sql` extension - and on spin-up Massive will read that file and let you execute it.

By default massive looks in a `/db` directory, but you can override as you need. So let's say you have a query - `select * from users where id=$1` that you want to be able use with massive. You put that query into `/db/userById.sql` and then...

```js
var massive = require("massive");
massive.connect({db : "my_db"}, function(err,db){
  db.userById(1, function(err,res){
   //you've got your data in res
  });
});
```

That's it. You can put whatever the hell you want in there - to play with the full power that Postgres offers, and we'll execute it for you cleanly.

### Full JSONB Support

Remembering the syntax for working with `jsonb` is tricky with Postgres. Not only do you need to remember `(thing) -> 'key'` syntax, you also need to remember the symbols to use (and when to use them). There are existence queries, contains, and then straight up matching that the engine allows you to do.

It's not hard, but it could do with some abstraction :). So I built it:

```js
var massive = require("massive");
massive.connect({db : "my_db"}, function(err,db){
  db.saveDoc("planets", {name : "Arrakis"}, function(err,planet){
   //you've got your planet here  
  });
});
```

This query did two very important things:

 - created a table on the fly for you called "planets" with an `id` key, and a `body` field that's `jsonb`
 - created a `GIN` index on that `jsonb` field so it's properly indexed

You can now query with it...

```js
db.planets.findDoc({name : "Arrakis"}, function(err,planet){
  //your planet sir
});
```

When massive is connected it scans the tables in your database as well as the SQL queries in your `/db` directory - and attaches them to the root namespace (in this case `db`. More on tables down below.

This query is smart enough to know that it's a straight up match, so it will use a `@>` matcher, flexing the index we created for you. You can do other queries, however...

```js
db.planets.searchDoc({
  keys : "name",
  term : "Arr"
}, function(err,results){
  //full text search on the fly
});
```

This query builds a full-text index on the fly for you, over a JSON document. And it's really, really fast.

### Good Old Relational Support

Massive is at version 2.0 now, which means it came from a version 1.0. This tool was around for a while and I liked using it, but I didn't like how watered down I had to make it so that you could work with MySQL and Postgres. I wanted a tool that would rock Postgres - so I booted MySQL support (a horrible database in my mind).

You can query your tables directly:

```js
db.users.find(1, function(err,res){
  //user with id 1
});

db.users.find({"id >" : 10}, function(err,res){
  //all users with id > 10
});

db.users.search({
  columns : ["first", "last"],
  term : "rob"
}, function(err,users){
  //full text on the fly
});
```

The syntax is pretty rudimentary - you can see more [on the README up at github](http://github.com/robconery/massive-js).

### REPL

We're building out a REPL as well as some command-line fun - the idea being that Massive is all about helping you build on top of Postgres. Right now if you run the REPL:

```
node bin/massive -d my_db
```

You'll connect Massive directly to your DB and you can have a play (the `-d` flag tells Massive which local database to connect to).

Massive will load up and you can have some fun. Here I just want to have a look at the root namespace, `db`, so I enter "db":

```
db > db
{ scriptsDir: '/Users/rob/Projects/massive-js/db',
  connectionString: 'postgres://localhost/massive',
  query: [Function],
  executeSqlFile: [Function],
  tables:
   [ { albums: [Object], artists: [Object], docs: [Object] },
     { schema: 'public',
```

One of my tables is named `products`, so I can run a query to see what happens:

```js
db> db.products.find(1);
db > { id: 1,
  name: 'Product 1',
  price: '12.00',
  description: 'Product 1 description',
  in_stock: true,
  created_at: Fri Mar 13 2015 10:07:24 GMT+0100 (CET) }
```

Notice that I didn't enter a callback here? Massive does that for you (in any case) - if the callback is missing for a query, we'll add one that outputs the result to the console.

The REPL is still in very early stages, and we're tweaking some ideas with it - but it's fun enough (and useful enough for me, anyway) that I'm keeping it in there.

## Rob, Don't You Hate ORMs?

Yep, sure do. This isn't an ORM, not by any stretch. To me it's **Goldilocks Abstraction** - *just right*.

Hope you like it.
