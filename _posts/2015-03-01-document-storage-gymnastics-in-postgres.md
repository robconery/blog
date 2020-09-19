---
layout: post
title: "Document Storage Gymnastics with Postgres"
slug: document-storage-gymnastics-in-postgres
summary: ""
comments: false
image: /img/2015/03/pg_parkour.jpg
categories: Postgres
---

With the release of Postgres 9.4 came the additional datatype `jsonb`. This is binary JSON, the same type of thing that MongoDB uses for internal storage. Postgres has had the `json` data type for a while, but `jsonb` allows you to do something lovely: **document indexing** and specialized queries.

Mongo is currently rewriting it's storage engine so what I'm about to say might not could be viewed as arguable, however: [Postgres blows MongoDB away in terms of speed and space on disk](http://blogs.enterprisedb.com/2014/09/24/postgres-outperforms-mongodb-and-ushers-in-new-developer-reality/). 

But benchmarks like the one above can be argued forever - specifically that Mongo excels at "scale out" and if you scale out enough you can turn the tables. Postgres tends to "scale up" so... yeah. But, for single-node deployments Postgres is pretty much the clear winner.

Just take from this that we have a pretty hot bit of competition! Oh and **Postgres also has a full, standards-based, ACID-compliant engine that you can use too!**.

With that complete, let's play with `jsonb`.

## Turning Records Into JSON

I'm playing with the Tekpub database again. Here I want to push the invoices into a document structure, and I can do this with a Common Table Express (CTE) and Windowing function, with some built-in JSON functions in Postgres:

```sql
with invoice_docs as (
  select invoices.*,
  json_agg(invoice_items) over (partition by invoices.id) as items
  from invoices 
  inner join invoice_items on invoice_items.invoice_id = invoices.id 
)
select row_to_json(invoice_docs) from invoice_docs;
```

I don't strictly need to use a CTE here, it just makes things nice and readable. I'm using `json_agg` to wrap up the joined invoice_items and parse them into a JSON array. Then I'm using `row_to_json` to squeeze the result into a full JSON document.

Simple stuff... but it's kind of slow. I have 40,000 or so records here and it takes about 7 seconds to complete on my machine - so this isn't something you'll want to run all the time.

I'll create a table to store this stuff in:

```sql
create table invoice_documents(
  id serial primary key,
  body jsonb
)
```

Since I'm using `jsonb` I'll want to index these documents so I can have some fast queries:

```sql
create index idx_invoice_docs on invoice_docs using GIN(body jsonb_path_ops)
```

I'm using the specialized `GIN` index for this. [Postgres has a number of different index types](http://www.postgresql.org/docs/9.4/static/indexes-types.html) that are worth getting to know - `GIN` however is a special index for values with multiple keys (arrays, json, xml, and tokenized text like you find in the `tsvector` search field). The `jsonb_path_ops` argument simply says "index all the keys" - this can be wasteful in big documents, however.

Now let's pump those documents in:

```sql
with invoice_docs as (
  select invoices.*,
  json_agg(invoice_items) over (partition by invoices.id) as items
  from invoices 
  inner join invoice_items on invoice_items.invoice_id = invoices.id 
)
insert into invoice_docs(body)
select row_to_json(invoice_docs) from invoice_docs;
```

We know have a document database. Let's play with it!

## Querying Our Documents

There are a number of ways you can query `jsonb` and it takes a bit to get used the syntactic sugar Postgres gives you. Let's have a look:

```sql
select body -> 'id' as id,
(body ->> 'amount_due')::money as price, 
(body->> 'created_at')::timestamptz as created_at
from invoice_docs;

  id   |   price   |          created_at
-------+-----------+-------------------------------
 1     |    $18.00 | 2012-08-15 03:59:17.762872+02
 2     |    $12.00 | 2012-08-15 04:02:44.965786+02
 3     |    $12.00 | 2012-08-15 04:06:32.67401+02
 4     |    $12.00 | 2012-08-18 01:39:31.938155+02
 5     |   $200.00 | 2012-09-20 00:53:17.858894+02
 10    |    $28.00 | 2012-07-28 07:28:21.922092+02
```

There is a lot going on here. First, the syntax for selecting a document value is a bit whacky: `body -> 'key'` (the parens are optional). The `->` operator says "give me jsonb" and Postgres does what it can, inferring what type is held there.

For `amount_due` and `created_at` we get something completely different. You can see this if we rerun the query:

```sql
select pg_typeof(body -> 'amount_due') as one_arrow,
pg_typeof(body ->> 'amount_due') as two_arrows
from invoice_docs limit 1;
 one_arrow | two_arrows
-----------+------------
 jsonb     | text
(1 row)
```

Here I'm using `pg_typeof` to know what types I'm dealing with - this is massively important when you're dealing with these functions, as you'll see. The `->` operator returns `jsonb` (which PG will do it's best to interpret for you), the `->>` operator returns the JSON text itself.

## Using Where with JSONB

Let's find a particular invoice - ones where I bought something from myself:

```sql
select body -> 'id' as id,
(body ->> 'email') as email,
(body ->> 'amount_due')::money as price,
(body->> 'created_at')::timestamptz as created_at
from invoice_docs
where body @> '{"email" : "rob@wekeroad.com"}';

  id   |      email       |  price  |          created_at
-------+------------------+---------+-------------------------------
 197   | rob@wekeroad.com | $200.00 | 2012-10-10 03:20:46.412831+02
 15562 | rob@wekeroad.com |  $18.00 | 2011-12-16 09:07:26.04932+01
 18589 | rob@wekeroad.com |  $28.00 | 2012-05-25 08:13:27.211351+02
 19135 | rob@wekeroad.com |   $0.00 | 2012-10-14 19:16:47.198226+02
(4 rows)
```

This syntax: `where body @> '{"email" : "rob@wekeroad.com"}'` is really not fun to write, but it works pretty well. The `@>` is "has the following key/value pair". You can also check for basic existence:

```sql
select body -> 'id' as id,
(body ->> 'email') as email,
(body ->> 'amount_due')::money as price, 
(body->> 'created_at')::timestamptz as created_at
from invoice_docs
where (body -> 'email') ?  'rob@wekeroad.com';

  id   |      email       |  price  |          created_at
-------+------------------+---------+-------------------------------
 197   | rob@wekeroad.com | $200.00 | 2012-10-10 03:20:46.412831+02
 15562 | rob@wekeroad.com |  $18.00 | 2011-12-16 09:07:26.04932+01
 18589 | rob@wekeroad.com |  $28.00 | 2012-05-25 08:13:27.211351+02
 19135 | rob@wekeroad.com |   $0.00 | 2012-10-14 19:16:47.198226+02
(4 rows)
```

Same thing, a little easier to write. So what's the difference? The latter query here is just checking for the existence of a value for a given `jsonb` element in the document - *it's kind of a dumb query* if you will. We can see this if we use `EXPLAIN`:

```sql
explain select body -> 'id' as id,
(body ->> 'email') as email,
(body ->> 'amount_due')::money as price,
(body->> 'created_at')::timestamptz as created_at
from invoice_docs
where (body -> 'email') ?  'rob@wekeroad.com';
                            QUERY PLAN
-------------------------------------------------------------------
 Seq Scan on invoice_docs  (cost=0.00..5754.99 rows=32 width=1206)
   Filter: ((body -> 'email'::text) ? 'rob@wekeroad.com'::text)
```

A Sequential Scan is not what you want - the query executes over each row in your database and evaluates each row individually. Here you can see that for each row, a Filter is being applied. It's a simple one and you won't see a problem on small datasets, but when things get big, your DBA will kill you for this.

Now let's do the same with our `@>` operator:

```sql
explain select body -> 'id' as id,
(body ->> 'email') as email,
(body ->> 'amount_due')::money as price,
(body->> 'created_at')::timestamptz as created_at
from invoice_docs
where body @> '{"email" : "rob@wekeroad.com"}';

                                   QUERY PLAN
---------------------------------------------------------------------------------
 Bitmap Heap Scan on invoice_docs  (cost=16.25..137.81 rows=32 width=1206)
   Recheck Cond: (body @> '{"email": "rob@wekeroad.com"}'::jsonb)
   ->  Bitmap Index Scan on idx_invoice_docs  (cost=0.00..16.24 rows=32 width=0)
         Index Cond: (body @> '{"email": "rob@wekeroad.com"}'::jsonb)
```

Ahhhh... much better. Remember the `GIN` index I created? The first query was ignoring it, but the one using `@>` uses it fully. If you only remember ONE THING from this article, remember this: **favor `@>` queries for indexed tables**.

The great thing about this is that it *indexes the whole document*. This means we can do deep queries like this flexing the same index:

```sql
select body -> 'number' as knockouts                                       
from invoice_docs                                                                   where body @> '{"items" : [{"sku" : "knockout"}] }' limit 1;
      
      knockouts
----------------------
 "someinvoicenumber"
(1 row)
```

By now hopefully you're seeing that querying a `jsonb` document, while different from typical SQL, uses the same SQL structures you (hopefully) already know. For instance I'm setting a `limit` here as well as aliasing the column. This is a big advantage over other document databases.

## Document Gymnastics

Astute readers will be wondering what good it is to put these things into documents when you might need to do some kind of rollup on them. Too true.

Specifically: we might need to query the items buried inside our invoice document so we can get some sales intelligence. 

Hopefully you're not running analytics on your live system - you really should be exporting your data into something good at crunching numbers like Excel or Numbers or whatever spreadsheet you use.

So let's how you can export this goodness from our `invoice_docs` table. First, you can grab the items directly using a select as we've been doing:

```sql
select body -> 'items'
from invoice_docs;

[{"id": 1, "sku": "ft_speaker"...}]
[{"id": 2, "sku": "knockout", ...}]
```

What data type does it return? Let's find out:

```sql
select pg_typeof(body -> 'items') 
from invoice_docs limit 1                ;
 pg_typeof
-----------
 jsonb
(1 row)
```

It's `jsonb` - or more specifically an array of JSON items. This is important. We need to be sure we're using `jsonb` exclusively so we can a) take advantage of indexing an b) use some amazing built-in functions.

So, the first thing we need to do is unwrap the result from an array into a simple `jsonb` object:

```sql
select jsonb_array_elements(body -> 'items') as items
from invoice_docs limit 2

{"id": 1, "sku": "ft_speaker"...}
{"id": 2, "sku": "knockout"...}
```

I'm using `jsonb_array_elements` to do this for me, and it returns a `jsonb` object that I can play with. Now I can wrap the select query above using a CTE:

```sql
with unwrapped as (
	select jsonb_array_elements(body -> 'items') as items
	from invoice_docs
), invoice_lines as (
	select x.* from unwrapped, jsonb_to_record(items) as 
	x(
		id int,
		sku varchar(50), 
		name varchar(255),
		price decimal(10,2)
	)
)
select * from invoice_lines limit 5;

id |    sku     |                 name                 | price
----+------------+--------------------------------------+--------
  1 | ft_speaker | The Art of Speaking: Scott Hanselman |  18.00
  2 | knockout   | Practical KnockoutJS                 |  12.00
  3 | knockout   | Practical KnockoutJS                 |  12.00
  4 | knockout   | Practical KnockoutJS                 |  12.00
  5 | yearly     | Tekpub Annual Subscription           | 200.00
(5 rows)
```

OK, I just hit you with a lot of stuff. Let's walk through this.

The first query in the CTE is using `jsonb_array_elements` to unwrap the items from an array into a simple `jsonb` document. The second query is using `jsonb_to_record` which is a bread and butter function that takes a `jsonb` object and turns it into a record.

The only way this will work, however is if I give Postgres a column definition list. I do this by aliasing the function (here it's `x`) and defining a column list. 

If this is all new to you, use it a few times - it starts to make sense. The function `jsonb_to_record` returns a `record` and that record needs to be reported as something - and you can do that using plain old SQL.

You can [read more about various JSON functions here](http://www.postgresql.org/docs/9.4/static/functions-json.html) - perhaps you can improve what I did above.

## Analytical Output

The last thing I'll do here is create an extraction query for export. In the analytics world this is the second thing you need to do: *shape your query for export*. The first is to make sure it's correct - but let's assume I've done that already.

I want to export this data in denormalized fashion for use in [what's called a "fact" table](http://en.wikipedia.org/wiki/Fact_table). This means I'll need to add a few columns of derived data. I can use an additional CTE to do this:

```sql
with unwrapped as (
	select jsonb_array_elements(body -> 'items') as items
	from invoice_docs
), invoice_lines as (
	select x.* from unwrapped, jsonb_to_record(items) as 
	x(
		id int,
		sku varchar(50), 
		name varchar(255),
		price decimal(10,2),
		quantity int,
		created_at timestamptz
	)
), fact_ready as (
  select sku,
	price::money,
	(quantity * price)::money as line_total,
	date_part('year', created_at) as year,
	date_part('month', created_at) as month,
	date_part('quarter', created_at) as quarter
  from invoice_lines
)
select * from fact_ready limit 5;

    sku     |  price  | line_total | year | month | quarter
------------+---------+------------+------+-------+---------
 ft_speaker |  $18.00 |     $18.00 | 2012 |     8 |       3
 knockout   |  $12.00 |     $12.00 | 2012 |     8 |       3
 knockout   |  $12.00 |     $12.00 | 2012 |     8 |       3
 knockout   |  $12.00 |     $12.00 | 2012 |     8 |       3
 yearly     | $200.00 |    $200.00 | 2012 |     9 |       3
(5 rows)
```

*(I've limited this to 5 records for readability)*.

Not bad for using a document! As I mention above - **we certainly don't have to do things this way**, but it's a fun mental exercise to see what's possible with Postgres and tweaked SQL.

## Full Text Search

Let's flex our CTEs for one last thing - finding invoices that involve [Scott Hanselman](http://hanselman.com). I could do this in a number of ways but since we're having so much fun with `jsonb` let's see what kind of silliness we can do on the fly.

Like creating a Full Text index:

```sql
with unwrapped as (
	select jsonb_array_elements(body -> 'items') as items
	from invoice_docs
), invoice_lines as (
	select x.* from unwrapped, jsonb_to_record(items) as 
	x(
		id int,
		sku varchar(50), 
		name varchar(255),
		price decimal(10,2),
		quantity int,
		created_at timestamptz
	)
), searchable as (
	select id,
	name,
	to_tsvector(concat(sku,' ',name)) as search_vector
	from invoice_lines
)

select id, name from searchable
where search_vector @@ to_tsquery('Hanselman')
limit 5;

 id |                 name
----+--------------------------------------
  1 | The Art of Speaking: Scott Hanselman
 14 | The Art of Speaking: Scott Hanselman
 14 | The Art of Speaking: Scott Hanselman
 28 | The Art of Speaking: Scott Hanselman
 43 | The Art of Speaking: Scott Hanselman
(5 rows)
```

The first two CTEs are exactly the same - unwrapping the invoice items. The last one (called `searchable`) is concatenating the `sku` and `name` fields of the invoice item and then indexing it on the fly for full text searching using `to_tsvector`.

In the final query I just need to use that `ts_vector` and search for Hanselman's name.

As you can see, `jsonb` is a great data type to work with, but it takes some fiddling. Hopefully this post can get you off to a good start.