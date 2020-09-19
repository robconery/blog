---
title: Transactional Data Operations in PostgreSQL Using Common Table Expressions
date: '2018-08-13'
image: /img/2018/08/gear-2291916_1280.jpg
layout: post
summary: "Working with Common Table Expressions in PostgreSQL is easy and straightforward. You can insert, update and delete data easily, all in one operation, within a single transaction."
categories:
  - Database
  - Postgres
  - Syndication
---

PostgreSQL has a ton of amazing features, often overlooked by developers who prefer to use abstractions to work with SQL and their database. This is a big topic and obviously can spark a ton of debate. If you've read my blog before [you know I dislike ORMs tremendously](/2015/02/20/its-time-to-get-over-that-stored-procedure-aversion-you-have/) ... aside from LLBLGenPro because Frans is my friend and he doesn't like it when I trash ORMs.

One of the great features of PostgreSQL is [Common Table Expressions, or CTEs](https://www.postgresql.org/docs/10/static/queries-with.html), otherwise known as "WITH queries". These are simply chained SQL expressions that allow you to pass the result of one query into another, functional style.

I use them a lot for reporting, but I also use them for creating orders when someone [buys something from me](https://bigmachine.io/products). Let's see how.

## Setting Up The Database

Let's create the core of my database. These tables are simplified, but the core of what they're supposed to do is present:

```sql
create extension if not exists pgcrypto;

create table orders(
  id serial primary key, 
  key uuid unique default gen_random_uuid(),
  email text not null, 
  total decimal(10,2),
  created_at timestamptz default now()  
);

create table order_items(
  id serial primary key,
  order_id int not null references orders(id) on delete cascade,
  sku text not null,
  price decimal(10,2) not null,
  quantity int not null default 1,
  discount decimal(10,2) not null default 0
);

create table downloads(
  id serial primary key,
  key uuid unique not null default gen_random_uuid(),
  order_id int not null references orders(id) on delete cascade,
  order_item_id int not null references order_items(id) on delete cascade,
  times_downloaded int not null default 0
);

create table products(
  id serial primary key not null,
  sku text unique not null,
  name text not null,
  price decimal(10,2) not null,
  created_at timestamptz not null default now()
);
```

I'm showing you this code for a few reasons:

1. If you want to play along (which I encourage), you can
2. The defaults and structure make working with CTEs much simpler
3. SQL is straightforward and easy if you take the time to learn it

All of that said, there are a few things I'd love to call out about this design:

- I'm using `on delete cascade` for the foreign keys to ensure that I don't have orphans
- I'm ensuring that null values don't creep into my database
- Whenever I have a `not null` constraint, I try to make sure I set a `default`
- Finally, `gen_random_uuid` comes from the `pgcrypto` extension

OK, let's add some data to our products table:

```sql
insert into products(sku, name, price)
values
('imposter-single','The Imposter''s Handbook', 30.00),
('mission-interview','Mission:Interview',49.00);
```

Great. Now let's get to the good stuff.

## Problem 1: Saving Order Data Transactionally

When a new order comes in, I need to create an `order` record and then an `order_items` record. This _must_ be done in a transaction or Bad Things will happen. This is simple to do with a CTE, **because CTEs execute within a single transaction**:

```sql
with new_order as(
  insert into orders(email, total) 
  values ('rob@bigmachine.io',100.00) 
  returning *
), new_items as (
  insert into order_items(order_id, sku, price)
  select new_order.id, 'imposter-single',30.00
  from new_order
  returning *
)
select * from new_items;
```

When you insert a new record with PostgreSQL, you can ask for it right back with `returning *`. If you just want the `id`, you can add `returning id`. The first query inserts the new `order` and then returns it, which I can then use in the second query. Obviously: hard-coding values isn't a good idea, but I'll fix that in a moment.

The result:

```
 id | order_id |       sku       | price | quantity | discount 
----+----------+-----------------+-------+----------+----------
  1 |        1 | imposter-single | 30.00 |        1 |     0.00
(1 row)

```

Perfect.

## Problem 2: Creating Downloads From Our New Order

I'm starting simple, making sure things work as intended, then moving forward. My next step is to create downloads so that users can download what they've bought immediately. For that, I can chain a new query:

```sql
with new_order as(
  insert into orders(email, total) 
  values ('rob@bigmachine.io',100.00) 
  returning *
), new_items as (
  insert into order_items(order_id, sku, price)
  select new_order.id, 'imposter-single',30.00
  from new_order
  returning *
), new_downloads as (
  insert into downloads(order_id, order_item_id)
  select new_order.id, new_items.id 
  from new_order, new_items
  returning *
)

select * from new_downloads;
```

I tack on a `returning *` from my insert statement for `order_items` and then I can use that to generate the downloads in a third query, this time using a `select` for the insert.

The result:

```sql
 id |                 key                  | order_id | order_item_id | times_downloaded 
----+--------------------------------------+----------+---------------+------------------
  1 | 1fa7c369-94c4-4220-83ba-78e35cfc7377 |        1 |             1 |                0
(1 row)
```

Great! The best part of all of this, so far, is that I can feel good about the data going into my database because of my constraints and design, and I can have faith that it's been added correctly because **a CTE is wrapped in a single transaction**.

## Problem 3: Inserting Multiple Order Items

One of the minor drawbacks of a CTE is that you can only execute a single statement with each clause. If you think of this in functional programming terms, it's a bit like _currying_ in that you have a single argument (the result of the previous query) and a single function body that returns a single value.

How, then, would you insert multiple `order_items`? This is where things could get a little tricky, especially if you're not a fan of SQL. I like using it, so what you're about to see doesn't freak me out:

```sql
with new_order as(
  insert into orders(email, total) 
  values ('rob@bigmachine.io',100.00) 
  returning *
), new_items as (
  insert into order_items(order_id, sku, price)
  (
    select new_order.id, sku,price
    from products, new_order
    where sku in('imposter-single','mission-interview')
  )
  returning *
), new_downloads as (
  insert into downloads(order_id, order_item_id)
  select new_order.id, new_items.id 
  from new_order, new_items
  returning *
)

select * from new_downloads;
```

I'm getting around the problem by using a simple `select` statement for the insert. It's going to the `products` table to insert whatever SKUs are given to it. Let's run the query and see what happens:

```
 id |                 key                  | order_id | order_item_id | times_downloaded 
----+--------------------------------------+----------+---------------+------------------
  1 | 6e695533-dd8d-407d-bdca-d71f81c666fb |        1 |             1 |                0
  2 | 31f81049-d08a-4f4c-b30c-565169178268 |        1 |             2 |                0
(2 rows)
```

It works! Sort of. We have one last problem...

## Hard Coding, Data Integrity, and Validation?

I'm hard-coding the email address as well as the SKUs, which isn't a Good Thing, obviously. This is where we brush up against what your ORM wants to do for your vs. what you might want to do as a coder. Put another way: _would you really write this SQL in your code?_. **I certainly wouldn't**.

Here are some possible solutions to these issues.

### The SKU Problem

What if a SKU is passed to this SQL that is not in our product's table? The short answer is non-compelling: _nothing_. If a SKU isn't found in the `products` table, it will simply be ignored. This is _sub-optimal_ because we can end up adding crap data to our system!

How can we fix this? My first inclination would be to wrap this routine in a function, passing in the email, SKUs and everything else in a `jsonb` variable called `cart`. In my function, I would make sure the cart totals matched and that the SKUs were present in the database.

This is where you rip me apart for putting business logic in a database. I can understand why people think that, however I can also understand **why I do it anyway**. The answer is simple: I'm more likely to change my platform/ORM than I am PostgreSQL. To me, this kind of thing belongs as close to your data as possible. It's a simple data operation that's not exactly unique to my business, is it?

The other solution is to make sure the cart is validated before it gets pushed to this query. If we can trust the inputs, then we're good to go.

### Blobs of SQL In Your Code

I think SQL is a beautiful thing, but that's _my_ problem. Yours is trying to figure out where to put this stuff! One thing you could do is to store this as a [prepared statement](https://www.postgresql.org/docs/10/static/sql-prepare.html), which offers quite a few benefits. Let's see the code, then we'll dive into the benefits:

```sql
prepare new_order(text, decimal(10,2), text[]) as
with new_order as(
  insert into orders(email, total) 
  values ($1,$2) 
  returning *
), new_items as (
  insert into order_items(order_id, sku, price)
  (
    select new_order.id, sku,price
    from products, new_order
    where sku = any($3)
  )
  returning *
), new_downloads as (
  insert into downloads(order_id, order_item_id)
  select new_order.id, new_items.id 
  from new_order, new_items
  returning *
)
select * from new_downloads;
```

Whenever you write a SQL statement for PostgreSQL, the engine needs to parse the SQL, analyze it, and then optimize/rewrite it for execution. You can skip a number of those steps if you tell PostgreSQL the query you plan on running ahead of time, so it can parse and analyze it **once**. You can do this with the `prepare` statement.

The downside is that you need to use positional arguments, as you see I'm doing here with `$1, $2` etc, which means you lose a little readability. If you can get over that, executing this statement means that you can call it by name using `execute` and some parameters:

```sql
execute new_order('rob@bigmachine.io',100.00, '{imposter-single,mission-interview}')
```

You'll notice the funky `{imposter-single}` syntax - that's how you work with arrays in PostgreSQL. Since I've switched to working with arrays, I've opted to use the `any` keyword, which works like `in` but is specifically for array values.

## Summary

Long post, but I encourage you to explore and see what's possible with your database, even if it's not PostgreSQL. The SQL I wrote above would likely replace 100s of (total) lines of ORM code and orchestration, but yes there is a learning curve.
