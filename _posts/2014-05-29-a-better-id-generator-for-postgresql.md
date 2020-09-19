---
layout: post
title: 'A Better ID Generator For PostgreSQL'
image: '/img/bullet-proof-glass..jpg'
comments: false
categories: Postgres
summary: "For most tables in a database you can get away with an auto-incrementing integer primary key. This, however, is a scaling headache if you ever have to shard your database. This is a common problem with a Users table, and there are better ways to fix this issue than with the ever-present UUID/GUID"
---

## The GUID Problem

When developers think about a globally-unique identifier, [they usually think of UUIDs (or GUIDs)](http://blog.codinghorror.com/primary-keys-ids-versus-guids/) and will then create a table with a GUID as a primary key. This is problematic if your system grows or your writes/second increase.

The first reason is that GUIDs are large string blobs and take up more space than a typical integer (althoug both can be up to 16 bytes). The larger problem, however, is the default behavior of most databases is to set the primary key to _also be the clustering key_ - in other words the default key upon which the table is sorted.

The Primary Key and Clustering Key are two very different things. Primary Keys normalize your data and help you uniquely identify a row - a Clustering Key is the mechanism by which your server organizes and accesses data on disk.

Hopefully you can see the issue - sorting GUIDs (arbitrary strings) [can lead to poor data organization under the hood in terms of page and index fragmentation ](http://www.sqlskills.com/blogs/kimberly/guids-as-primary-keys-andor-the-clustering-key/) - precisely because the GUID data is so random.

SQL Server has some fixes for this with the `uniqueidentifier` data type and the `newsequentialid()` default value (which creates sortable GUIDs) - and that helps, but it still requires a lot more work then using a simple integer-based, auto-incrementing key. Which is precisely why so many developers like to use them.

## Enter Twitter Snowflake

Twitter [started out with MySQL as their storage medium and then moved to Cassandra](https://blog.twitter.com/2010/announcing-snowflake) to deal with the insane scaling issues they were facing. Cassandra doesn't do auto-incrementing keys and doesn't do UUIDs either - so Twitter was left to create its own system:

> Unlike MySQL, Cassandra has no built-in way of generating unique ids – nor should it, since at the scale where Cassandra becomes interesting, it would be difficult to provide a one-size-fits-all solution for ids. Same goes for sharded MySQL.

> Our requirements for this system were pretty simple, yet demanding:

> We needed something that could generate tens of thousands of ids per second in a highly available manner. This naturally led us to choose an uncoordinated approach.

> These ids need to be roughly sortable, meaning that if tweets A and B are posted around the same time, they should have ids in close proximity to one another since this is how we and most Twitter clients sort tweets.

> Additionally, these numbers have to fit into 64 bits. We’ve been through the painful process of growing the number of bits used to store tweet ids before. It’s unsurprisingly hard to do when you have over 100,000 different codebases involved.

Twitter's solution became [Twitter Snowflake](https://github.com/twitter/snowflake) a "network service for generating unique ID numbers at high scale with some simple guarantees". Its worked very well for them and similar solutions. In fact Eric Lindvall of Papertrail said [exactly this in PeepCode's great "Scaling Up" video](http://pluralsight.com/training/courses/TableOfContents/scaling-up-lindvall) - wherein he talks about simple ways to avoid database problems when scaling:

> Move ID generation out of the database to an ID generation service outside of the database... As soon as a piece of work enters their system, an ID gets assigned to it... and that ID generated in a way that is known to be globally unique within their system... and they can then take that message and [drop it in a queue]

This is the first database issue that Eric discusses - it's one of the primary scaling concerns! **Creating a sortable, globally-unique ID for all bits of data in your system** which allows you to shard/cluster your database without worrying about colliding IDs.

This is an understandable hurdle for a key/value system like Cassandra which can't generate it's own unique keys - but can't we do this with MySQL or Postgres?

## A Functional Snowflake Equivalent for PostgreSQL

There are Snowflake-style systems out there for generating unique ids, but the problem is that these systems become a bottleneck! They better be fast - and if they go down your entire system grinds to a halt.

[This was Instagram's concern](http://instagram-engineering.tumblr.com/post/10853187575/sharding-ids-at-instagram):

> With more than 25 photos & 90 likes every second, we store a lot of data here at Instagram. To make sure all of our important data fits into memory and is available quickly for our users, we’ve begun to shard our data—in other words, place the data in many smaller buckets, each holding a part of the data.

> Our application servers run Django with PostgreSQL as our back-end database. Our first question after deciding to shard out our data was whether PostgreSQL should remain our primary data-store, or whether we should switch to something else. We evaluated a few different NoSQL solutions, but ultimately decided that the solution that best suited our needs would be to shard our data across a set of PostgreSQL servers.

> Before writing data into this set of servers, however, we had to solve the issue of how to assign unique identifiers to each piece of data in the database (for example, each photo posted in our system). The typical solution that works for a single database—just using a database’s natural auto-incrementing primary key feature—no longer works when data is being inserted into many databases at the same time. The rest of this blog post addresses how we tackled this issue.

The author, Mark Krieger goes on to discuss these options: using UUIDs/GUIDs, a Snowflake-style service, or writing a routine specifically for Postgres.

Instagram ultimately decides that they don't want to rely on app code to create the id, nor do they want to introduce complexity with a Snowflake-style system. Instead, they cracked open Postgres and created their own Function:

```sql
CREATE OR REPLACE FUNCTION insta5.next_id(OUT result bigint) AS $$
DECLARE
    our_epoch bigint := 1314220021721;
    seq_id bigint;
    now_millis bigint;
    shard_id int := 5;
BEGIN
    -- there is a typo here in the online example, which is corrected here
    SELECT nextval('insta5.table_id_seq') % 1024 INTO seq_id;

    SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
    result := (now_millis - our_epoch) << 23;
    result := result | (shard_id << 10);
    result := result | (seq_id);
END;
$$ LANGUAGE PLPGSQL;
```

A really neat idea! Sharding Postgres logically using schemas is a very interesting way to speed up reads and writes - but it obviously messes up id generation. This solution, however, seems pretty elegant!

I gave this function a spin and slightly tweaked it for a project I'm working on - here's a full script you can run right now:

```sql
create schema shard_1;
create sequence shard_1.global_id_sequence;

CREATE OR REPLACE FUNCTION shard_1.id_generator(OUT result bigint) AS $$
DECLARE
    our_epoch bigint := 1314220021721;
    seq_id bigint;
    now_millis bigint;
    -- the id of this DB shard, must be set for each
    -- schema shard you have - you could pass this as a parameter too
    shard_id int := 1;
BEGIN
    SELECT nextval('shard_1.global_id_sequence') % 1024 INTO seq_id;

    SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
    result := (now_millis - our_epoch) << 23;
    result := result | (shard_id << 10);
    result := result | (seq_id);
END;
$$ LANGUAGE PLPGSQL;

select shard_1.id_generator();
```

Running that you should see a nice, clean `bigint` that you can use for a key with any table. Speaking of - here's how you can declare a Users table to use this function to automatically generate your key:

```sql
create table shard_1.users(
  id bigint not null default id_generator(),
  email varchar(255) not null unique,
  first varchar(50),
  last varchar(50)
)
```

## When Do You Face This Problem?

That's something that's up to you and your company. Over-engineering from the get-go is a problem in our industry, but at the same time you can at least plan for a year out. With a system like Twitter, a year's growth could easily cause write problems for a MySQL database - same with a logging system like Papertrail.

If you run ExpiredFoods.com, however, you might never need to deal with a scaling issue like this.

Either way, it's nice to know the options are out there.
