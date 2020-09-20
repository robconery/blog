---
layout: post
title: PostgreSQL Rising
summary: "Postgres is gaining more and more attention - deservedly so. Open database systems like Postgres are standing up squarely against the massive, sprawling (and expensive) \"Enterprise\" systems like SQL Server and Oracle - usually with feature parity that works better. Of all these systems, Postgres is the smartest, fastest, and most capable."
image: /img/pg.jpg
date: "2012-07-19"
uuid: "tuuZPthn-Gxaz-lHM9-zyfq-KucbgaHbnUsr"
slug: "postgresql-rising"
categories: Postgres
---

## Postgres.app
Some buzz going around the web today about [Postgres.app](http://postgresapp.com/). Most people don't understand why it's interesting - so here's a quick explanation.

Postgres can be configured with a lot of interesting options - the ability to run Geospatial indexing (PostGIS), creating functions with Ruby and JavaScript, and extending the query engine to go up against remote sources like GMail. These features need to be compiled with the core code - something that can be a bit of a pain even when using Homebrew on your Mac.

Homebrew simply grabs the source and compiles it based on common usage patterns replicated in the "recipe". Postgres.app is precompiled and runs as a little daemon that you can turn on and off when needed. Just download it, drag it into your Applications directory and you're done.

Compare that with a SQL Server or Oracle installation.

It's lovely, and you should use it. If you're running a Mac you'll also want [to use Navicat](http://www.navicat.com/en/products/navicat_pgsql/pgsql_detail_mac.html). There's a free version up there, but you can also just grab the demo to play around.

## Say Hello to an Old New Friend
PostgreSQL has been around forever. If you've read this far the one thing that's probably sticking in your brain is **WTF with the name?**. [Tom Lane explains](http://archives.postgresql.org/pgsql-novice/2006-07/msg00063.php):

> The name is PostgreSQL or postgres not postgre... Arguably, the 1996 decision to call it PostgreSQL instead of reverting to plain Postgres was the single worst mistake this project ever made. It seems far too late to change now, though

Postgres was adapted from a very old database system [Ingres](http://en.wikipedia.org/wiki/Ingres_(database)) with the goal of producing a pluggable, scalable, fast database system that was (for the time) user friendly and smart. The name (POSTgres) was supposed to be a reflection of the former project - "After Ingres" - but ... well you get it.

## Who Cares?
That's the thing - not many people. With the rise of PHP the friendlier MySQL platform was adopted much faster than the stricter, rules-based Postgres platform. And by "friendlier" I mean "stupider".

That's a heavy word. Let's back up that statement. [This is a video](http://www.youtube.com/watch?v=1PoFIohBSM4) that I put together for Tekpub called "The Perils of MySQL":

<iframe width="640" height="360" src="http://www.youtube.com/embed/1PoFIohBSM4" frameborder="0" allowfullscreen></iframe>

If you don't want to watch the whole thing, here's a summary:

* MySQL will happily ignore your defaults and constraints as an effort to "help you" by not being terribly strict
* It will insert "" into non-nullable columns if nullable values are disallowed
* It will insert nonsense dates (0000-00-00) into date columns if nullable values are disallowed
* It returns NULL for 1/0
* It returns NULL for "THIS IS NOT A NUMBER"/0
* If you try to insert 1000 into a column that only allows a length of 2, it will round that number down to 99

This is why you should care about using MySQL. It doesn't safeguard your data by default - it tries to help you out by bending data integrity. Which in my mind is stupid.

If none of that freaks you out, then I have one word for you: **Oracle**.

## Fast, Scalable, Fun
Postgres is packed full of features - many of which people don't know about. The system is full of syntactic niceties such as:

* The keyword "infinity" - which means "bigger than any value entered here". This works for numbers and dates and can be set positive or negative
* Sensible date keywords like "today", "tomorrow", "yesterday". In Postgres 9.2 this gets even better.
* Amazing data types like Arrays, IP addresses which understand IPV6. Spatial types like lines, squares and circles.
* **Table Inheritance** which is a freaky feature which allows you to have one table, literally, inherit from another.
* Natural Language Full Text searching - out of the box

These features are meaningless unless the system is fast and scalable. Which Postgres very much is. My DBA friend [Rob Sullivan](http://datachomp.com) and I put Postgres to the test - loading in a StackOverflow data dump with 6 million text records.

We fired up our query tools and started optimizing our system against SQL Server (which had the exact same data load). Not only did Postgres stand right up to the speed of SQL Server - in many cases it eclipsed it (again - based on our measurements - both db's on a Windows box).

**Indexing wasn't the only story here**. We were able to partition the tables using inheritance (you can partition SQL Server too - but it's ad-hoc and you have to pay an enterprise license) and squeeze out even **better performance** due to reduced index size.

As if that's not enough - Postgres comes (out of the box) with TOAST tables - which is a weird name for "Automatic Table Compression". I show this in a demo (see the end of the post) but essentially Postgres will compress your data on disk - reducing RAM usage as well as disk space. 

This reduced our SO data dump from 24 gigs down to 6 - which is a huge savings. This feature is free and included with Postgres. With SQL Server it costs an Enterprise License.

## 5 More Things You Didn't Know
There's so much more to write about what Postgres can do -  instead I'll just link to a presentation I gave at NDC 2012 - [5 Things You Didn't Know About PostgreSQL](https://vimeo.com/43536445). I cover things like:

* Querying Twitter with Foreign Data Wrappers
* Writing Functions in JavaScript using Google's V8 Engine
* Dumb MySQL tricks
* Avoiding locks with Postgres default, built-in snapshotting
* Table Inheritance
* Crazy Datatypes

Hope you enjoy it:

<iframe src="http://player.vimeo.com/video/43536445" width="680" height="382" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>


