---
layout: post
title: "Creating a Full Text Search Engine in PostgreSQL, 2022"
image: "https:/images.unsplash.com/photo-1572375992501-4b0892d50c69"
date: "Sun Jul 17 2022 16:55:00 GMT-0700 (Pacific Daylight Time)"
categories: postgres
summary: Writing a full text index in PostgreSQL is an art form. You need to know what your users are looking so you can build the right index AND you need to understand how they write their search terms. Thankfully, Postgres is here to help.      
---

A few years ago I wrote about [how to “fine tune” a full text index in PostgreSQL](https://file+.vscode-resource.vscode-cdn.net/2019/10/29/fine-tuning-full-text-search-with-postgresql-12/) 12, but that was a few years ago and things have changed a bit. The current version of PostgreSQL is 14 and Postgres just keeps getting better and better.

In this video I show you how the process a DBA might take when creating a full text index in Postgres. It’s not enough to throw a `tsvector` field onto a table, create a trigger and call it a day. You have to know what your users are searching for and how they’re searching for it.

These days we have `generated` columns and don’t need triggers. We also have `websearch_to_query` instead of the old `plainto_tsquery` or it’s languagy big brother, `phrase_to_tsquery`.

We can use this power to do all we need without having to use a third-party system like Sphinx or Elastic (as good as they are).

Hope you enjoy the video!

## The Code and data

If you want to play along you can download the data set here. It’s about 3Mb and is a single SQL file that contains the table definition and structure. To run it, unzip the file and pop it into a database:

```bash
createdb scifi
psql scifi < questions.sql
```

There’s a lot of code in the video, but the main bits are:

```sql
--add the search index
alter table questions
add search tsvector
generated always as (
  setweight(to_tsvector('simple',tags), 'A')  || ' ' ||
  setweight(to_tsvector('english',title), 'B') || ' ' ||
  setweight(to_tsvector('english',body), 'C') :: tsvector

) stored;

-- add the index
create index idx_search on questions using GIN(search);

-- the search query
select title, body,
  ts_rank(search, websearch_to_tsquery('english','vader tie fighter star-wars')) + 
  ts_rank(search, websearch_to_tsquery('simple','vader tie fighter star-wars')) as rank
from questions
where search @@ websearch_to_tsquery('english','vader tie fighter star-wars')
or search @@ websearch_to_tsquery('simple','vader tie fighter star-wars')
order by rank desc;

-- turning it into a function
create or replace function search_questions(term text) 
returns table(
  id int,
  title text,
  body text,
  rank real
)
as
$$

select id, title, body,
  ts_rank(search, websearch_to_tsquery('english',term)) + 
  ts_rank(search, websearch_to_tsquery('simple',term)) as rank
from questions
where search @@ websearch_to_tsquery('english',term)
or search @@ websearch_to_tsquery('simple',term)
order by rank desc;

$$ language SQL;
```