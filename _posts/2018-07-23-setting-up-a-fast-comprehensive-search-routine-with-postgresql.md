---
title: 'Setting Up a Fast, Comprehensive Search Routine With PostgreSQL'
date: '2018-07-23'
image: /img/2018/07/maze-2264_1280.jpg
layout: post
summary: "One of the joys of working with PostgreSQL is the ability to run full-text searches right out of the box. But how do you set this up? Better yet: when should you use full-text indexing and how would..."
categories:
  - Database
  - Postgres
  - Syndication
---

One of the joys of working with PostgreSQL is the ability to run full-text searches right out of the box. But how do you set this up? Better yet: when should you use full-text indexing and how would you get it working across your entire site?

I've implemented this a number of times for myself and also my clients. I'll show you two strategies I've used, both spanning multiple tables.

## Annie Admin Needs To Find Something

Let's use the typical ecommerce database for this example. Shopify is a grand example: they have a search bar across the top of the admin site that will search all kinds of information based on what you enter, including customers, orders, help, etc:

![](https://blog.bigmachine.io/img/shopify_search.png)

It's kind of neat. As you can see, I triggered this search by entering the letter "t" in the search box. Kind of meaningless, really, and not something that will work well with a full-text index.

This is where we get to refine our search requirements.

### Use Case 1: Annie Needs to Find Joe User

Let's work with this use case:

> Annie gets an email from Joe User who wants to know where his downloads are. He doesn't have an order number, just a name/email. He doesn't know if the email is the same one he used when placing the order.

There's nothing fancy that needs to happen here, just a fuzzy search. But over what? Annie is a crafty data person as well and knows that she could run afoul of her database admin friend M. Sullivan, so she wonders how she can execute this search using an index.

### Solution 1: Simple Regex with a UNION Query

Annie's right to be worried about index usage, _in general_, but in her case, she's just one person executing a crappy query, and not very often at that. She can get away with a true fuzzy search here.

To do this right, she needs to search over:

- The Customers table, in case she wants to see all the information about Joe
- The Orders table, so she can see all of Joe's orders at a glance
- The Invoices table, which has the delivery information so she can send an email if needed, or correct an errant email address

There could be more, but let's start here.

The first step is to decide the structure of our search _result_. This is going to be the shape of the information returned from the UNION query. For now, I'll keep it simple:

- `id`, the PK of the thing found
- `key`, an identifier of some kind, like order number, email, or the like
- `description`, some kind of longer bit of information, such as a user's name, order number and date, etc
- `type`, this will identify what the resource is (order, customer, etc)
- `blob`, this is a blob of text we'll be searching over

Here's what that query might look like for the orders table:

```sql
select
id,
number as key,
concat('Order ', number, ' placed on ',created_at) as description,
concat(number,' ',email,' ', name) as blob,
'order' as type
from orders;
```

Here's what that returns, using real data from my site (with bits blurred out):

![](https://blog.bigmachine.io/img/screenshot_922-1.jpg)

Great. Now we need to query the other tables, making sure to follow the same structure:

```sql
select
id,
number as key,
concat('Order ', number, ' placed on ',created_at) as description,
concat(number,' ',email,' ', name) as blob,
'order' as type
from orders
UNION
select
id,
email as key,
name as description,
concat(name,' ',email) as blob,
'customer' as type
from customers
UNION
select
id,
number as key,
concat('Invoice ', number, ' created on ',created_at) as description,
concat(number,' ',email,' ', name) as blob,
'invoice' as type
from invoices
```

Ahh joy, an unbounded UNION query that's likely to get Annie fired. Let's fix that.

### Using a Materialized View for Speed and Excitement

If we had to run this query against a live data set, we'd make our DBA mad. Even if it's just "every now and again", we're pulling a giant amount of data into a query and it hurts. How bad does it hurt? Of course Annie has done an EXPLAIN/ANALYZE so she knows how much trouble she'll be if she doesn't optimize:

![](https://blog.bigmachine.io/img/screenshot_923.jpg)

You don't know my data, but I'll just tell you that this is doing not just one, not two, but **three full table scans** and a bunch of other crappy bad things. We can't do this, so we'll turn to one of the greatest things in PostgreSQL: _the materialized view_. It's basically a query that is cached for you, in memory, that you can also throw an index on (which we'll do in a bit):

```sql
create materialized view admin_search as
-- big UNION query here
```

That's it. Now we can run a _much faster_ and simpler query:

![](https://blog.bigmachine.io/img/screenshot_925.jpg)

Annie doesn't like simply trusting her eyes, she want's PostgreSQL to tell her if this query is indeed faster so she uses EXPLAIN/ANALYZE:

![](https://blog.bigmachine.io/img/screenshot_926.jpg)

There is a sequential scan, but the query is much more efficient than before.

### The Downside of a Materialized View

A materialized view is a cached set of data that you can query instead of querying the tables themselves. That cache doesn't get reloaded unless you:

```sql
refresh materialized view admin_view;
```

This will reload our cached data into memory. You can also do this concurrently if you have a long-running view and you don't want to lock the view from use:

```sql
refresh materialized view concurrently admin_view;
```

This will run in the background and is great if you're hitting the view often. There are [some exceptions](https://www.postgresql.org/docs/9.4/static/sql-refreshmaterializedview.html), however:

- This option is only allowed if there is at least one UNIQUE index on the materialized view which uses only column names and includes all rows; that is, it must not index on any expressions nor include a WHERE clause.
    
- This option may not be used when the materialized view is not already populated.
    
- Even with this option only one REFRESH at a time may run against any one materialized view.
    

In Annie's case, an hourly cron should do the trick. Not the most elegant solution, but it serves her purpose.

## Use Case 2: Annie Gets In Trouble Anyway and Needs an Index

Annie got in trouble anyway, which is a bummer. The refresh on the materialized view wasn't that big of a deal, but the sequential scan over 10s of thousands of records made the DBA twitch violently.

### Solution 2: Use Full Text Indexing with a GIN Index

With just a few tweaks, Annie can fix this issue. Instead of using a regex operation (`~*`) in the where clause, she can use the rocket-fueled full-text engine that ships with PostgreSQL.

This is done with a simple tweak, using `to_tsvector` on the `blob` field and then popping a GIN index on that `ts_vector`ed goodness:

```sql
drop materialized view admin_view;
drop index if exists idx_search;
create materialized view admin_view as
select
id,
number as key,
concat('Order ', number, ' placed on ',created_at) as description,
to_tsvector(concat(number,' ',email,' ', name)) as search,
'order' as type
from orders
UNION
select
id,
email as key,
name as description,
to_tsvector(concat(name,' ',email)) as search,
'customer' as type
from customers
UNION
select
id,
number as key,
concat('Invoice ', number, ' created on ',created_at) as description,
to_tsvector(concat(number,' ',email,' ', name)) as search,
'invoice' as type
from invoices;

create index idx_search on admin_view using GIN(search);
```

This creates a materialized view as before, but adds the tokenized full-text bits that PostgreSQL needs in order to run a full-text query:

```sql
select id,key,description,type
from admin_view
where search @@ to_tsquery('joe')
order by ts_rank(search,to_tsquery('joe')) desc;
```

This comes back at lightning speed with the following results:

![](https://blog.bigmachine.io/img/screenshot_927.jpg)

Dig that! Ranked search results that identify 3 customers named "Joe" right at the top. Much more useful and incredibly efficient. Dig this:

![](https://blog.bigmachine.io/img/screenshot_928.jpg)

This loose text term is using a Bitmap scan (which is a good thing) and executes _in under a millisecond_. That's **winning, people**.

Annie gets a promotion and everyone's happy.

### The Downside of a Full Text Index

To be honest, it's not really made for small, loose searches like this and it's really easy to generate a false positive. Full-text indexing really shines over things like blog posts, comment searches, and so on.

It worked pretty dang well here though, didn't it?
