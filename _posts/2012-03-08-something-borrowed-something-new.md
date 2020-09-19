---
layout: post
title: "Something Borrowed, Something New"
summary: "Tekpub just pushed its latest production: Hello PostgreSQL - and I invite you to take a look at some of the very compelling and interesting features this Open Source system has. No seriously - it's worth a look."
image: "/img/postgresql_logo-555px.png"
date: "2012-03-08"
uuid: "TCLvvNJY-1nzK-80nA-5t5o-bD4TOK5KTier"
slug: "something-borrowed-something-new"
categories: Tekpub Postgres
---

## 30 Seconds. Just 30 Seconds.
I always say - if you can't give me the pitch in a single sentence, in 30 seconds, your idea isn't worth what you think it is. So here's what I got for you:> PostGres will blow your mind; given its Enterprise features (Compression, partitioning, Full Text indexing, etc) , ease of use and configuration, and intelligent feature set - it's likely you'll want to use it tomorrow.

I'm not trying to sell you anything - [I just want you to consider what's out there besides your DB of choice](http://tekpub.com/productions/pg).** I'm doing what Tekpub is here to do: open your mind** to new ideas and ways of doing things. The rest, as they say, is up to you.If you're still interested: read on.

## Lack of Tooling
In the very first video **I put Entity Framework on top of the "world" sample database in PostGreSQL using the EF designer**. I'm using the [DevArt "dotConnect" ](http://www.devart.com/dotconnect/postgresql/)driver to do this which isn't free - but if you use EF it's likely you won't have read this far anyway.**Massive, PetaPoco, NHibernate, OrmLite - most data access tools can work directly with PostGreSQL** no problem. PostGres also comes with pgAdminIII which is functional and works just fine. I like Navicat and use it for Tekpub.com - worth every penny.There's lots of tooling. It's not SQL Server -[ but it's worth a look](http://tekpub.com/productions/pg). Stay with me.

## Enterprise
Developing a web site is easy. For .NET developers it usually involves some flavor of SQL Express or SQLite/CE and "my company has licenses to SQL Server". That's fine - SQL Server is an amazingly capable database.The nice thing about PostGres is that it come with enterprise features right out of the box:

- **Compression** - large tables are automatically compressed to save you disk space and RAM
- **Partitioning** - another SQL Server Enterprise Edition feature: comes ready to roll with PostGreSQL
- **Full Text Indexing** - try using this on Azure. You can't.
- **Memory/File Caps** - none
- **Replication** - yep

It's easy to disregard this stuff when you're starting out a project. When you grow quickly and hire a [dickhead DBA](http://datachomp.com) - that's when you start paying the Big Bucks. Many times it's worth it if you know and are comfortable with SQL Server - but there are all alternatives - this is my only point.

## Not Just My Opinion
We just launched [our latest production at Tekpub](http://tekpub.com/productions/pg). It didn't start out as a PostGreSQL tutorial - but it turned into that because I couldn't keep [Rob Sullivan](http://datachomp.com) from foaming at the mouth during every single recording - the dude was tweaking over the moon about PostGreSQL.

Rob S. is a SQL Server DBA. He thought PostGres was "non-existent" and "who cares" - like most .NET/Microsoft folks. I asked him to look into it since we'd be working on a production about Mono/ASP.NET and... he lost himself.

## Christmas Presents
That was the way Rob described working with the administrative/DBA features of PostGres.** It just does things - intelligently** - that you wouldn't expect. One that I really liked was Table Inheritance.

The first time I heard about it I thought "neat trick - don't think I want OOP in my database though". Turns out that PostGreSQL doesn't use Inheritance just to make the Gang of Four happy - they use it to keep your database performant and lean.

When your database grows rather large (think Stack Overflow) - indexes become difficult to maintain. At this point you need to partition your tables - literally "break the big tables apart" along some lines in order to maximize indexing.

StackOverflow, for instance, has one massive "posts" table - and a lookup that describes a post as a Question or an Answer. This works out well until you have 500 million rows - then your indexing goes into orbit.

PostGreSQL, on the other hand, allows you to setup an inheritance scheme that is backed by table partitioning. You can do this, literally:

```sql Table Inheritance with Postgres
create table posts(id serial primary key, body text, created_at timestamp);
create table questions(question_id serial primary key, owner_id integer, answered boolean)
  inherits(posts);
create table answers(answerer_id serial primary key, question_id integer)
  inherits(posts);
```

Look weird? I thought so too - until you consider that each of those tables are full-blown tables with their own primary keys and indexing - yet they have common data between them (body ) - which can be Full Text indexed.I know many people will be thinking - "why the hell would I do this?". The answer, as it turns out, comes from the real world.

## Performance.
PostGreSQL is fast. Very fast. This wasn't always the case but with version 8.0 they devoted everything to speed - getting away from disk space consideration as disk storage became very, very cheap.

StackOverflow keeps everything in a Posts table - so [on their home page how many answers do you see](http://stackoverflow.com/)? Answer: 0. All you see are questions. As it turns out, there is (roughly) a 4:1 ration between answers and questions (meaning there are, on average, 4 answers per question).

If they used an inheritance scheme as above - this would mean an instant 75% reduction in what the indexer has to crawl in order to serve that main page. It also makes the query more semantic - which is a nice bonus.

In addition to that - we're saving disk space! We don't have empty rows in our denormalized posts table taking up space (answercount doesn't matter on answers!). This is a win for everyone.We were pleasantly surprised by the performance we saw on Windows - that said [it doesn't run as quickly as it does on Linux](http://stackoverflow.com/questions/1162206/why-is-postgresql-so-slow-on-windows). 

It's not nearly as slow as MySQL on Windows and Rob and I were able to pull just as good (and in many cases better!) performance in a side-by-side comparison with SQL Server (using the SO data dump).

All of that said - running your database on a Linux box offers some nice scaling alternatives if you're sensitive to cost.

## Doing Our Job
Tekpub's job is to show you what's out there - not to talk you into things or sell you on a concept. This post might come across as a sales pitch - **but these are the lengths it's necessary to go to to get people to even think about alternatives** to what their tooling (VS and SQL Server) allows them to do.

I invite you to set aside your allegiances and what you're familiar with - and just have a look at what is quickly becoming a favorite data storage tool for many, many developers. Even if you're never going to use PostGreSQL - you should know what it does and how, just in case you run into a Neck Beard somewhere and want to show off.

Rob and I had a great time making this production - I hope you enjoy it.
