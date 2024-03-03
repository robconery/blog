---
title: 'Virtual, Computed Columns in PostgreSQL 12'
date: '2019-10-24'
image: /img/2019/10/screenshot_202.jpg
layout: post
summary: "PostgreSQL 12 introduced a feature I've long wished for: computed columns that are indexable and stored on disk! They're amazing and in this post I'll show you how they work and how things kind of go..."
categories:
  - Database
  - Postgres
  - Syndication
---

The PostgreSQL team has been jamming out updates on a regular basis, adding some amazing features that I hope to go into over time but one of these features made me extremely excited! [Generated columns](https://www.postgresql.org/docs/current/ddl-generated-columns.html):

> A generated column is a special column that is always computed from other columns. Thus, it is for columns what a view is for tables.
> 
> Yay!

What this means is that you can have a managed "meta" column that will be created and updated whenever data changes in the other columns.

Too bad [Dee didn't know about](https://bigmachine.io/products/a-curious-moon/) this when she was working with the Cassini data! Setting up those search columns would have been much easier!

## An Example: A Fuzzy Search for a Document Table

Let's say you have a table where you store JSONB documents. For this example, I'll store conference talks in a table I'll call "NDC", since I was just there and did just this:

```
create table ndc(
  id serial primary key,
  body jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

Here's an example of a talk - a real one I scraped from the NDC site, which happens to be [Heather Downing's](https://www.quorralyne.com/) amazing keynote:

```
{
  "title": "Keynote: The Care and Feeding of Software Engineers",
  "name": "Heather Downing",
  "location": "Room 1",
  "link": "https://ndcsydney.com/talk/keynote-the-care-and-feeding-of-software-engineers/",
  "tags": ["agile", "people", "soft-skills", "ethics"],
  "startTime": {
    "hour": 9,
    "minutes": 0
  },
  "endTime": {
    "hour": 10,
    "minutes": 0
  },
  "day": "wednesday"
}
```

This wad of JSON will get stored happily in our new table's `body` field but querying it might be a pain. For instance - I might remember that Heather's talk is the Keynote, but it's a long title so remembering the whole thing is a bummer. I _could_ query like this:

```
select * from ndc where body ->> 'title' ilike 'Key%';
```

Aside from being a bit of an eyesore (the `body ->> 'title'` stuff is a bit ugly), the `ilike 'Key%'` has to run a full table scan, loading up the entire JSON blob just to make the comparison. Not a huge deal for smaller tables, but as a table grows this query will start sucking resources.

We can fix this easily using the new `GENERATED` syntax when creating our table:

```
alter table ndc
add column title text 
generated always as (body ->> 'text');
```

Run this and the generated column is created and then populated as well! Check it:

![](https://blog.bigmachine.io/img/screenshot_201.jpg)

title is now a relational column

_**But wait, there's more**_. If we tried to run our search query with the fuzzy match on title we'd still have to do a full table scan. Generated columns _actually store the data_ as opposed to computing it at query time, which means we can...

```
create index idx_title on ndc(title);
```

BAM! What used to require a few triggers and an occassionally pissed off DBA is now handled by PostgreSQL.

Also - just to be sure this is clear - we could also have declared this in the orginal definition if we wanted:

```
create table ndc(
  id serial primary key,
  body jsonb not null,
  title text generated always as (body ->> 'title') stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index idx_title on ndc(title);
```

## Into the Weeds: The Search Field

Adding a full text search index would seem to be the obvious use of `GENERATED` don't you think? I decided to wait on that because, for now, it's not exactly straightforward.

If all I wanted to do was to search on the title of a talk then we're in business... _sort of_:

```
alter table ndc
add search tsvector
generated always as (to_tsvector('english', body ->> 'title')) stored;
```

This works really well, as you can see:

![](https://blog.bigmachine.io/img/screenshot_202.jpg)

But it took me about 2 hours (seriously) to figure this out as I kept getting a really annoying error, which I'll go into in a minute:

```
ERROR:  generation expression is not immutable
```

Long story short, if you don't add the _english_ language definition to the `ts_vector` function than things will fail. The expressions that you use to define a generated column must be immutable, as the error says, but understanding which functions are and are not can be a bit of a slog.

## Deeper Into the Weeds: Using Concat

Let's keep going and break things shall we? We've got a lot of lovely textual information in our JSON dump, including `tags` and `name`. This is where we earn our keep as solid PostgreSQL brats because _we know, ohhh do we know_ that a blanket full text indexing that tokenizes everything evenly is pure crap :).

We'll want to be sure to weight the `tags` and maybe suppress the tokenization of names - I'll get to that in a later post - right now I just want to take the next step, which is to add other fields to our search column. All we have at the moment is the `title` - let's add name:

```
alter table ndc drop search;
alter table ndc
add search tsvector
generated always as (
  to_tsvector('english', 
    concat((body ->> 'name'), ' ', (body ->> 'title'))
  )
) stored;
```

I formatted this so it reads better - hopefully it's clear what I'm trying to do? I'm using the `concat` function to, well, concatenate the name with a blank space and then a title. I need that blank space in there otherwise the name and title will be rammed together making it useless.

```
ERROR:  generation expression is not immutable
```

Crap! What? This is a concatenation!?!?! How is this not immutable? Turns out it's the `concat` function that's causing the problem, and I'm not sure why (if you know please leave me a comment). This, however, does work:

```
alter table ndc drop search;
alter table ndc
add search tsvector
generated always as (
  to_tsvector('english', 
    (body ->> 'name') || ' ' || (body ->> 'title')
  )
) stored;
```

That, my friends, is super hideous - but it gets the job done. I'll get more into full text indexes in a later post as I've had some really good fun with them recently.

## Summary

I've had a lot of fun goofing around with the generated bit. If you're wondering, the actual update goes off right after the `before` trigger would normally go off - so if you do have a `before` trigger on your table, you can use whatever values are generated there.

You also might be wondering about the `stored` keyword you see here? Right now it's the only option: the generated bits are stored on disk next to your data. In future releases you'll be able to specify `virtual` for just in time computed bits... but not now.
