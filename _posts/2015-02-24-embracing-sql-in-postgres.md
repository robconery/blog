---
layout: post
title: "Embracing SQL In Postgres"
slug: embracing-sql-in-postgres
summary: ""
comments: false
image: /img/2015/02/jordan_sql.jpg
categories: Postgres Database
---

One thing that drives me absolutely over the cliff is how ORMs try so hard (and fail) to abstract the power and expressiveness of SQL. Before I write further let me say that <a href="https://twitter.com/fransbouma">Frans Bouma</a> reminded me yesterday there's a difference between ORMs and the people that use them. They're just tools (the ORMs) - and I agree with that in the same way I agree that crappy fast food doesn't make people fat - it's the people that eat too much of it.

Instead of ripping ORMs apart again - I'd like to be positive and tell you <em>just why</em> I have stopped using their whack-ass OO abstraction on top of my databases :). In short: <em>it's because SQL can expertly help you express the value of your application in terms of the data</em>. That's really the only way you're going to know whether your app is any good: <strong>by the data it generates</strong>.

So give it a little of your time - it's fun once you get rolling with the basics and how your favorite DB engine accentuates the SQL standard. Let's see some examples (by the way all of what I'm using below is <a href="http://www.postgresql.org/docs/9.4/static/functions.html">detailed here in the Postgres docs</a> - have a read, there's a lot of stuff you can learn - my examples below barely even scratch the surface).

<h2>Postgres Built-in Fun</h2>

Right from the start: <em>Postgres sugary SQL syntax is really, really fun</em>. SQL is an ANSI standardized language - this means you can roughly expect to have the same rules from one system to the next (which means you can't expect it at all).

Postgres follows the standards almost to the letter - but it goes beyond with some very fun additions. Let's take a look!

<h3>Regex</h3>

At some point you might need to run a rather complicated string matching algorithm. Many databases (<a href="https://msdn.microsoft.com/en-us/magazine/cc163473.aspx">including SQL Server</a> - sorry for the MSDN link) allow you to use Regex patterning through a function or some other construct. With Postgres it works in a lovely, simple way (using PSQL for this with the old Tekpub database):

<pre><code class="sql">select sku,title from products where title ~* 'master';
    sku     |              title
------------+---------------------------------
 aspnet4    | Mastering ASP.NET 4.0
 wp7        | Mastering Windows Phone 7
 hg         | Mastering Mercurial
 linq       | Mastering Linq
 git        | Mastering Git
 ef         | Mastering Entity Framework 4.0
 ag         | Mastering Silverlight 4.0
 jquery     | Mastering jQuery
 csharp4    | Mastering C# 4.0 with Jon Skeet
 nhibernate | Mastering NHibernate 2
(10 rows)
</code></pre>

The <code>~*</code> operator says "here comes a POSIX regex pattern that's case insensitive". You can make it case sensitive by omitting the <code>*</code>.

Regex can be a pain to work with but if you wanted you could ramp this query up by using Postgres' built-in Full Text indexing:

<pre><code class="sql">select products.sku,
products.title
from products
where to_tsvector(title) @@ to_tsquery('Mastering');
    sku     |              title
------------+---------------------------------
 aspnet4    | Mastering ASP.NET 4.0
 wp7        | Mastering Windows Phone 7
 hg         | Mastering Mercurial
 linq       | Mastering Linq
 git        | Mastering Git
 ef         | Mastering Entity Framework 4.0
 ag         | Mastering Silverlight 4.0
 jquery     | Mastering jQuery
 csharp4    | Mastering C# 4.0 with Jon Skeet
 nhibernate | Mastering NHibernate 2
(10 rows)
</code></pre>

This is a bit more complicated. Postgres has a built-in data type specifically for the use of Full Text indexing - <code>tsvector</code>. You can even have this as a column on a table if you like, which is great as it's not hidden away in some binary index somewhere.

I'm converting my title on the fly to <code>tsvector</code> using the <code>to_tsvector()</code> function. This tokenizes and prepares the string for searching. I'm then shoving this into the <code>to_tsquery()</code> function. This is a query built from the term "Mastering". The <code>@@</code> bits simply say "return true if the <code>tsvector</code> field matches the <code>tsquery</code>". The syntax is a bit wonky but it works really well and is quite fast.

You can use the <code>concat</code> function to push strings together for use on additional fields too:

<pre><code class="sql">select products.sku,
products.title
from products
where to_tsvector(concat(title,' ',description)) @@ to_tsquery('Mastering');
    sku     |              title
------------+---------------------------------
 aspnet4    | Mastering ASP.NET 4.0
 wp7        | Mastering Windows Phone 7
 hg         | Mastering Mercurial
 linq       | Mastering Linq
 git        | Mastering Git
 ef         | Mastering Entity Framework 4.0
 ag         | Mastering Silverlight 4.0
 jquery     | Mastering jQuery
 csharp4    | Mastering C# 4.0 with Jon Skeet
 nhibernate | Mastering NHibernate 2
(10 rows)
</code></pre>

This combines <code>title</code> and <code>description</code> into one field and allows you to search them both at the same time using the power of <a href="http://www.postgresql.org/docs/9.4/static/textsearch.html">a kick-ass full text search engine</a>. I could spend multiple posts on this - for now just know you can do it inline.

<h3>Generating a Series</h3>

One really fun function that's built in is <code>generate_series()</code> - it outputs a sequence that you can use in your queries for any reason:

<pre><code class="sql">select * from generate_series(1,10);
 generate_series
-----------------
               1
               2
               3
               4
               5
               6
               7
               8
               9
              10
</code></pre>

If sequential things aren't what you want, you can order by another great function - <code>random()</code>:

<pre><code class="sql">select * from generate_series(1,10,2)
order by random();
 generate_series
-----------------
               3
               5
               7
               1
               9
(5 rows)
</code></pre>

Here I've added an additional argument to tell it to skip by 2.

It also works with dates:

<pre><code class="sql">select * from generate_series(
         '2014-01-01'::timestamp,
         '2014-12-01'::timestamp,
         '42 days');

   generate_series
---------------------
 2014-01-01 00:00:00
 2014-02-12 00:00:00
 2014-03-26 00:00:00
 2014-05-07 00:00:00
 2014-06-18 00:00:00
 2014-07-30 00:00:00
 2014-09-10 00:00:00
 2014-10-22 00:00:00
(8 rows)
</code></pre>

Here I'm telling it to output the dates in 2014 in 42 day intervals. You can do this backwards to, you just have to use a negative interval.

Why is this useful? You can alias this function and plug in the number from the series generation into whatever calculation you want:

<pre><code class="sql">select x as first_of_the_month from                                                                                                 generate_series('2014-01-01'::timestamp,'2014-12-01'::timestamp,'1 month') as f(x);                                                           first_of_the_month
---------------------
 2014-01-01 00:00:00
 2014-02-01 00:00:00
 2014-03-01 00:00:00
 2014-04-01 00:00:00
 2014-05-01 00:00:00
 2014-06-01 00:00:00
 2014-07-01 00:00:00
 2014-08-01 00:00:00
 2014-09-01 00:00:00
 2014-10-01 00:00:00
 2014-11-01 00:00:00
 2014-12-01 00:00:00
(12 rows)
</code></pre>

Aliasing functions like this allows you to use the resulting row inline with your SQL call. This kind of thing is nice for analytics and spot-checks on your data. Also, notice the <code>month</code> specification? That's an interval in Postgres - something you'll use a lot with data stuff. Speaking of dates...

<h3>Date Math Fun</h3>

Intervals are brilliant shortcuts for working with dates in Postgres. For instance, if you want to know the date 1 week from today...

<pre><code class="sql">select '1 week' + now() as a_week_from_now;
        a_week_from_now
-------------------------------
 2015-03-03 10:08:12.156656+01
(1 row)

</code></pre>

Postgres sees <code>now()</code> as a <code>timestamp</code> and uses the <code>+</code> operator to infer the string '1 week' as an interval. Brilliant. But do you notice the result <code>2015-03-03 10:08:12.156656+01</code>? This is a very interesting thing!

It's telling me the current date and time all the way down to milliseconds... and also the timezone (+1 as I'm currently in Italy).

If you've ever had to wrestle with dates and UTC - well it's a major pain. Postgres has a built-in <code>timestamptz</code> data type - timestamp with time zone - that will account for this when doing date calculations.

This is really fun to play with. For instance I can ask Postgres what time it is in California:

<pre><code class="sql">SELECT now() AT TIME ZONE 'PDT' as cali_time;
         cali_time
----------------------------
 2015-02-24 02:16:57.884518
(1 row)
</code></pre>

2am - best not call Jon Galloway and tell him his SQL Server is on fire. This returns an <code>interval</code> - the difference between two timestamps (edited).

How many hours behind me is Jon? Let's see...

<pre><code class="sql">select now() - now() at time zone 'PDT' as cali_diff;
 cali_diff
-----------
 08:00:00
(1 row)
</code></pre>

Notice the return value is a <code>timestamp</code> of 8 hours, not an integer. Why is this important? Time is a relative thing and it's incredibly important to know <em>which time zone</em> your server is in when you calculate things based on time.

For instance - in my Tekpub database I recorded when orders were placed. If 20 orders came in during that "End of the Year Sale" my accountant would very much like to know if they came in before, or after, midnight on January 1st, 2013. My server is in New York, my business is registered in Hawaii...

This is important stuff and Postgres handles this and many other date functions quite nicely.

<h3>Aggregates</h3>

Working with rollups and aggregates in Postgres can be tedious precisely because it's so very, very standards-compliant. This always leads to having to be sure that whatever you GROUP BY is in your SELECT clause.

Meaning, if I want to look at sales for the month, grouped by week I'd need to run a query like this:

<pre><code class="sql">select sku, sum(price),
date_part('month',created_at) from invoice_items
group by sku,date_part('month',created_at)
having date_part('month',created_at) = 9
</code></pre>

That's a bit extreme and a bit of a PITA to write (and remember the syntax!). Let's use a better SQL feature in Postgres: <em>windowing functions</em>:

<pre><code class="sql">select distinct sku, sum(price) OVER (PARTITION BY sku)
from invoice_items
where date_part('month',created_at) = 9
</code></pre>

Same data, less noise (windowing functions are also available in SQL Server). Here I'm doing set-based calculations by specifying I want to run a <code>SUM</code> over a partition of data for a given row. If I didn't specify <code>DISTINCT</code> here the query would have spit out all sales as if it we just a normal <code>SELECT</code> query.

The nice thing about using windowing functions is that I can pair aggregates together:

<pre><code class="sql">select distinct sku, sum(price) OVER (PARTITION BY sku) as revenue,
count(1) OVER (PARTITION BY sku) as sales_count
from invoice_items
where date_part('month',created_at) = 9
</code></pre>

This gives me a monthly sales count per sku as well as revenue. I can also output total sales for the month in the very next column:

<pre><code class="sql">select distinct sku,
sum(price) OVER (PARTITION BY sku) as revenue,
count(1) OVER (PARTITION BY sku) as sales_count,
sum(price) OVER (PARTITION by 0) as sales_total
from invoice_items
where date_part('month',created_at) = 9
</code></pre>

I'm using <code>PARTITION BY 0</code> here as a way of saying "just use the entire set as the partition" - this will rollup all sales for September.

... and combine this with the power of <a href="http://rob.conery.io/2015/02/09/inserting-using-new-record-postgres/">a Common Table Expression</a> I can run some interesting calcs:

<pre><code class="sql">with september_sales as (
    select distinct sku,
    sum(price) OVER (PARTITION BY sku) as revenue,
    count(1) OVER (PARTITION BY sku) as sales_count,
    sum(price) OVER (PARTITION by 0) as sales_total
    from invoice_items
    where date_part('month',created_at) = 9
)

select sku,
    revenue::money,
    sales_count,
    sales_total::money,
    trunc((revenue/sales_total * 100),4) as percentage
from september_sales
</code></pre>

In the final select I'm casting <code>revenue</code> and <code>sales_total</code> as <code>money</code> - which means it will be formatted nicely with a currency symbol.

A pretty comprehensive sales query - I get a total per sku, a sales count and a percentage of monthly sales with (what I promise becomes) fairly straightforward SQL.

I'm using <code>trunc</code> in the CTE here to round to 4 significant digits as the percentages can be quite long.

<h3>Strings</h3>

I showed you some fun with Regex above, but there is more you can do with strings in Postgres. Consider this query, which I used quite often (again, the Tekpub database):

<pre><code class="sql">select products.sku,
    products.title,
    downloads.list_order,
    downloads.title  as episode
from products
inner join downloads on downloads.product_id = products.id
order by products.sku, downloads.list_order;
</code></pre>

This fetched all of my videos and their individual episodes (I called them downloads). I would use this query on display pages, which worked fine.

But what if I just wanted an episode summary? I could use some aggregate functions to this. The simplest first - just a comma-separated string of titles:

<pre><code class="sql">select products.sku,
    products.title,
    string_agg(downloads.title, ', ') as downloads
from products
inner join downloads on downloads.product_id = products.id
group by products.sku, products.title
order by products.sku
</code></pre>

<code>string_agg</code> works like String.join() in your favorite language. But we can do one better, let's concatenate and send things down in an array for the client:

<pre><code class="sql">select products.sku,
    products.title,
    array_agg(concat(downloads.list_order,') ',downloads.title)) as downloads
from products
inner join downloads on downloads.product_id = products.id
group by products.sku, products.title
order by products.sku
</code></pre>

Here I'm using <code>array_agg</code> to pull in the <code>list_order</code> and <code>title</code> from the joined downloads table and output them inline as an array. I'm using the <code>concat</code> function to concatenate a pretty title using the <code>list_order</code> as well.

If you're using Node, this will come back to you as an array you can iterate over.

If you're using Node, you'll probably want to have this JSON'd out, however:

<pre><code class="sql">select products.sku,
    products.title,
    json_agg(downloads) as downloads
from products
inner join downloads on downloads.product_id = products.id
group by products.sku, products.title
order by products.sku
</code></pre>

Here I'm shoving the related downloads bits (aka the "Child" records) into a field that I can easily consume on the client - an array of JSON.

<h2>Summary</h2>

If you don't know SQL very well - particularly how your favorite database engine implements and enhances it - take this week to get to know it better. It's so very powerful for working the gold of your application: <em>your data</em>.
