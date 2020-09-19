---
layout: post
title: "PostgreSQL Document API Part 4: Complex Queries"
slug: postgresql-document-api-part-4-complex-queries
summary: ""
comments: true
image: /img/2015/09/pg_querying.jpg
categories: Postgres
---

Storing documents in PostgreSQL is a little easier, now that we have some [solid save routines](http://rob.conery.io/2015/08/20/designing-a-postgresql-document-api/), a way to run [Full Text searches](http://rob.conery.io/2015/08/21/postgresql-document-api-part-2-full-text-search-and-bulk-save/), and some basic [Find and Filter routines](http://rob.conery.io/2015/08/25/postgresql-document-api-part-3-finding-things/).

This is only half the story, of course. Rudimentary finds might serve application needs, but they'll never work over the long term, where we need to ask some deep questions.

## The Source Document

Document storage is a huge subject. How you store a document (and what you store), for me, resolves itself into three areas:

 - Document/Domain Model. Kind of a developer point of view on this, but if you're a DDD fan, this makes sense.
 - The Real World. Invoices, Purchase Lists, Sales Orders - businesses run on these things, let's reflect that.
 - Transaction/Process Result/Event Source. Basically, when "something happens" to your application you track everything that went into that event and store it.

I tend to favor the latter. I'm an information hoarder and when things happen I want to know what/why/when to the *nth* degree.

Here's what I've done in the past to store information about people buying something from Tekpub. This is a document design that I was about to put into production using RethinkDB but never got there (due to the Pluralsight sale).

```json
{
  "id": 1,
  "items": [
    {
      "sku": "ALBUM-108",
      "grams": "0",
      "price": 1317,
      "taxes": [],
      "vendor": "Iron Maiden",
      "taxable": true,
      "quantity": 1,
      "discounts": [],
      "gift_card": false,
      "fulfillment": "download",
      "requires_shipping": false
    }
  ],
  "notes": [],
  "source": "Web",
  "status": "complete",
  "payment": {
    //...
  },
  "customer": {
    //...
  },
  "referral": {
    //...
  },
  "discounts": [],
  "started_at": "2015-02-18T03:07:33.037Z",
  "completed_at": "2015-02-18T03:07:33.037Z",
  "billing_address": {
    //...
  },
  "shipping_address": {
    //...
  },
  "processor_response": {
    //...
  }
}
```

This is a **huge document**. I *love* huge documents! This document is the exact result of all the information moving around during the checkout process:

 - Customer addresses (billing, shipping)
 - Payment info and what was bought
 - How they got here and basic info that happened along the way (in the form of notes)
 - The exact response from the processor (which itself is a big document)

I want this document to be a standalone, actionable item that *requires no other document* to be complete. In other words - from here I want to be able to:

 - Fulfill the order
 - Run some reports
 - Notify the customer of changes, fulfillment, etc
 - Take further steps if required (refunding, voiding)

This document is complete unto itself, and it's lovely!

OK, enough of that, let's right some reports.

## Shaping The Data: The Fact Table

When running analytics it's important to remember two things:

 - **Never run these things on a live system**
 - Denormalization is the norm

Running huge queries over joined tables takes forever, and it amounts to nothing anyway. You should be running reports on *historical* data that doesn't change (or changes very, very little) over time. Denormalizing helps with speed, and speed is your friend with reports.

Given that, we need to use some PostgreSQL goodness to shape our document into a **Sales Fact Table**. A "Fact" table is simply a denormalized bit of data that represents a *fact* in your system - the smallest digestible bit of information about a *thing*.

For us, that *thing* is a sale and we want our fact to look something like this:

<a href="http://rob.conery.io/img/2015/09/fact_result.png"><img src="http://rob.conery.io/img/2015/09/fact_result.png" alt="fact_result" width="755" height="320" class="alignnone size-full wp-image-548" /></a>

*I'm using the [Chinook sample database](https://chinookdatabase.codeplex.com) with some randomized sales data in there that I generated with [Faker](https://github.com/marak/Faker.js/)*.

Each of these records is a single *fact* that I want to rollup on, and all the *dimension* information I want to roll it up with is included (time, vendor). I can add more (category, etc) but this will do for now.

This data is tabular, which means we needed to transform it from the document above. Not an easy task - but much simpler since we're using PostgreSQL:

```sql
with items as (
  select body -> 'id' as invoice_id,
  (body ->> 'completed_at')::timestamptz as date,
  jsonb_array_elements(body -> 'items') as sale_items
  from sales
), fact as (
  select invoice_id,
  date_part('quarter', date) as quarter,
  date_part('year', date) as year,
  date_part('month', date) as month,
  date_part('day', date) as day,
  x.*
  from items, jsonb_to_record(sale_items) as x(
    sku varchar(50),
    vendor varchar(255),
    price int,
    quantity int
  )
)

select * from fact;
```

This is a set of Common Table Expression (CTEs), chained together *in a functional* way (more on this below). If you've never used CTEs they can look a little weird... until you squint and you realize you're just chaining things together with a name.

In the first query above, I'm pulling the `id` of the sale out and calling it `invoice_id`, and then pulling out the timestamp and converting it to a `timestamptz`. Simple stuff for the most part.

The thing that's a bit tricky here is `jsonb_array_elements` - this is pulling the items array out of the document and creating a record for each item. So, if we had only a single sales document in our database with three items and we ran this query:

```sql
select body -> 'id' as invoice_id,
(body ->> 'completed_at')::timestamptz as date,
jsonb_array_elements(body -> 'items') as sale_items
from sales
```

Instead of one record representing the sale, we'd get 3:

<a href="http://rob.conery.io/img/2015/09/jsonb_array_elements.png"><img src="http://rob.conery.io/img/2015/09/jsonb_array_elements.png" alt="jsonb_array_elements" width="518" height="108" class="alignnone size-full wp-image-549" /></a>

Now that we've "elevated" the items, we need to "spread them out" into their own columns. This is where the next bit of trickery comes in with `jsonb_to_record`. We can use this function along with a type definition on the fly:

```sql
select * from jsonb_to_record(
  '{"name" : "Rob", "occupation": "Hazard"}'
) as (
  name varchar(50),
  occupation varchar(255)
)
```

In this simple example I'm converting some `jsonb` into a table - I just have to tell PostgreSQL how to do it. That's what we're doing in the second CTE ("fact") above. We're also using `date_part` to transform dates.

This give us a fact table, which we can save to a view if we like:

```sql
create view sales_fact as
-- the query above
```

You might be wondering if this query is *dog slow*. In fact it's quite fast. This isn't supposed to be some kind of benchmark or anything - just a relative result to show you that this query, is in fact, rather speedy. I have 1000 test documents in my database, running this query on all the documents comes back in about a 10th of a second:

<a href="http://rob.conery.io/img/2015/09/fact_speed.png"><img src="http://rob.conery.io/img/2015/09/fact_speed.png" alt="fact_speed" width="723" height="432" class="alignnone size-full wp-image-550" /></a>

PostgreSQL. Cool stuff.

Now we're ready for some rollups!

## Sales Reports

From here it's mostly gravy. You just rollup on what you like, and if you forget something add it to your view - best part is you don't have to worry about joins! It's just transformation of data, *which is really fast*.

Let's see our top 5 sellers:

```sql
select sku,
  sum(quantity) as sales_count,
  sum((price * quantity)/100)::money as sales_total
from sales_fact
group by sku
order by salesCount desc
limit 5
```

This one comes back in 0.12 seconds. Pretty fast for a 1000 records.


## CTEs and Functional Querying

One of the things I really like about RethinkDB is its query language, ReQL. It's inspired by Haskell (according to the team) and is all about *composition* (emphasis mine):

> To grok ReQL, it helps to understand functional programming. Functional programming falls into the declarative paradigm in which the programmer aims to describe the value he wishes to compute rather than prescribe the steps necessary to compute this value. Database query languages typically aim for the declarative ideal since this style gives the query execution engine the most freedom to choose the optimal execution plan. But while SQL achieves this using special keywords and specific declarative syntax, ReQL is able to **express arbitrarily complex operations through functional composition**.

As you've seen above, we can approximate this by using CTEs chained together, each transforming the data in a specific way.

## Summary

There's a lot more I could write - but let's just wrap this up by saying that you can do *everything other document systems can do* and a whole lot more. [PostgreSQL's querying abilities are very powerful](http://rob.conery.io/2015/02/24/embracing-sql-in-postgres/) - there's very little you can't do and, as you've seen, the ability to transform your documents into a tabular structure greatly helps things.

And with that this little series of posts is complete.
