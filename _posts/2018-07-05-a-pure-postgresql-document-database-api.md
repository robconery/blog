---
title: A Pure PostgreSQL Document Database API
date: '2018-07-05'
image: /img/2018/07/lamp-3121677_1280.jpg
layout: post
summary: "Another day, another database project in my repo! This time it's a pure PostgreSQL JSONB document storage API that you can drop in and get going with right away!"
categories:
  - Postgres
  - Syndication
---

One of the great things about PostgreSQL is its support for JSON document storage. I've [written](/2016/02/26/jsonb-and-postgresql/) about it [quite](/2015/08/19/designing-a-postgresql-document-api/) a [few](/2015/08/21/postgresql-document-api-part-2-full-text-search-and-bulk-save/) [times](/2015/08/24/postgresql-document-api-part-3-finding-things/), and here I am writing about it once again! I think it's probably the most underrated feature of PostgreSQL, and for a simple reason: _the API is a bit clunky_.

With a little work, however, that can be changed.

## A Typical Document Database API

There are a few things I'd like to see supported right "out of the box", so to speak:

- Creation of a document table on the fly
- Support for upsert
- A simple CRUD scenario
- A find routine that matches on document criteria
- Support for grouping/mapping/reducing
- Support for full-text search

Seems reasonable, doesn't it? This kind of thing is basic for MongoDB, CouchDB, and RethinkDB... aside from full-text search, which isn't supported. I've implemented these things in code before, with [MassiveJS](https://github.com/dmfay/massive-js), [Moebius](https://github.com/robconery/moebius) and lately, [MassiveRB](https://github.com/robconery/massive-rb). I do this for fun, mostly, but also because I use these things in production and I really like the document abstraction.

## Why Would You Do This To Lovely, Relational PostgreSQL?

It's a good question. If you pick Postgres it's likely you want to go with the relational model. If you want a document system, you'll probably go with MongoDB or something similar. The crazy thing is: _PostgreSQL is unreal fast/scalable with document storage_. [Have a Google](https://www.google.com/search?q=postgres+jsonb+vs+mongodb&oq=postgres+jsonb+vs+mongodb) and see what others have come to know: _Postgres document storage is crazy good_. The only problem is the API, which we've already discussed. We're here to figure out _why_ you would do such a thing.

The simple reason is design/development time speed (among other things). Ditch migrations altogether and just store things as documents. When you're ready, move into a relational model you feel good about. This is exactly what I did with the last 3 projects I worked on and it was amazingly helpful.

## First Pass at a Pure PostgreSQL API

A few months ago I spent the weekend putting together a set of functions that extend PostgreSQL and embrace document storage using the API specification above. The first thing I did was to create a schema to keep all of the bits together in one place:

```sql
drop schema if exists dox cascade;
create schema dox;
```

Yes, I decided to call it `dox` because... just because. The next thing was to create a save routine, the CRUD bits, and to implement full-text indexing. Rather than walk you through all of the code, you can just [have a look at it right here](https://github.com/robconery/dox).

It's not a "true" extension written in C or anything; just a set of PostgreSQL functions written in PLPGSQL. To use it, you invoke the functions directly:

```sql
select * from dox.save(table => 'customers', doc => '[wad of json]');
```

The "fat arrow" syntax you see here is using the named argument syntax for PostgreSQL functions, which (to me) makes things much more readable than positional arguments. The `save` function will create the `customers` table for you on the fly if it doesn't exist and save the JSON you pass to it.

Your document will be indexed using GIN indexing, which means you can run queries like this incredibly efficiently:

```sql
select * from dox.find_one(collection => 'customers', term => '{"name": "Jill"}');
select * from dox.find(collection => 'customers', term => '{"company": "Red:4"}');
```

The queries above are flexing the containment and existence operators, which in turn use the GIN index on your document table. You get all of the lovely speed of PostgreSQL with a bit of a nicer API.

## Full Text Search

One thing that other systems don't have which PostgreSQL has built in is full-text indexing. This means you can do fuzzy searches on simple terms with an index rather than a full table scan, which will make your DBA quite happy.

There's nothing you need to do to enable this, aside from following a simple convention. Every document table comes with a `tsvector` search field:

```sql
create table customers(
  id serial primary key not null,
  body jsonb not null,
  search tsvector, --this one here
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

When you save a document with a "descriptive key", it will automatically get dropped into the `tsvector` search field and indexed:

```sql
-- the save function
search text[] = array['name','email','first','first_name','last','last_name','description','title','city','state','address','street', 'company']
```

You can, of course, change any of this. I thought about putting these terms in a table for lookup but decided that was too slow. It's simple enough to change this `text[]` to have the terms you want.

To use it, all you need to do is call it:

```sql
select * from dox.search(collection => 'customers', term => 'jill');
```

## Is This Production Ready?

Sure - it's just SQL and PostgreSQL. I've been using it and haven't had any issues, but your data/data needs are different than mine and you might find some areas for improvement. If you fork/download the repo, you'll see a `test.sh` file, which you just need to load using `source ./test.sh` and it will run, assuming you have PostgreSQL installed locally with admin rights.

Or, as I'm a fan of doing, just run `make test`, which will use the Makefile in the project.

## Would I Use This Over Mongo, Couch, Database X?

Hell yes. I am a giant PostgreSQL fan and I love the idea that I can "flip relational" at any time. I love the idea that I can do a simple `select * from dox.get(1)` and I'll know it's using a primary key index. I super love the full text indexing too.

## How Do I Install It?

As I mentioned, there's a Makefile in the root of the project. If you run `make`, it will concatenate the `.sql` files into a `build.sql` file. You can then run `psql` to load that into your database:

```
psql -d my_db -f ./scripts/build.sql
```

## Questions? Issues?

If you're up for having a look and want to ask questions, [go for it](https://github.com/robconery/dox/issues). Mostly: play around and see what kind of performance gain you get when you go with PostgreSQL!
