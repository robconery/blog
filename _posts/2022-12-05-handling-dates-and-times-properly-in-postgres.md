---
layout: post
title: "Handling Dates and Times Properly in Postgres"
image: "/img/2022/12/08-title.jpg"
date: "Mon Dec 05 2022 17:55:11 GMT-0800 (Pacific Standard Time)"
categories: postgres
summary: Handling dates properly is delicate business and, thankfully, Postgres gives you many tools to help make sure you store date information correctly. But that only works if you know what's going on!      
---

We've all had to deal with storing date information in a database, and I'm sure most of us follow the guidance of "**just use UTC**" - which I think is great advice for the most part. **Until it isn't**.

But when would it _not_ be the right thing to do? This, unfortunately, is something you only figure out when your ass is on fire... let me explain.

## Phantom Sales

When I ran Tekpub.com back in 2012, we had been in business for 4 years and our customer base was starting to take off. This, of course, was exciting so, for the holiday season, I put on a big Holiday Sale at 50% off.

I did _not_ expect the response! **We had a _six-figure sales month_**. This blew my mind completely! I was excited for our business, of course, but also very happy for the authors earning royalties from us - they were in for a nice bump.

Anyway, it was great fun until I got a call from my accountant when he was **trying to reconcile my books with my bank statements**. We were off by a significant amount.

A week later I was able to unsnarl my books, and I learned a valuable lesson when it comes to storing dates and times.

## When UTC Strikes Back

Here's the thing: **storing dates as UTC only works if you know how to pull those dates back out properly**, and have them mean something. The platform I was using at the time stored date values as `timestamp` in Postgres, which is a UTC time stamp without a time zone designation. Sounds good, right?

Unfortunately, reading those values back out causes all kinds of pain unless, of course, your business is located in England near GMT. Consider the following:

* You make a sale on December 31, 2012 at 23:59 PST. It goes into your `timestamp` date field as such.
* You query that value later on and see the value as you entered it. Your accountant reminds you, however, that your business is incorporated on the east coast of the US, so all sales must be relative to that. Meaning that your sale actually happened at January 1st, 2013 EST and belongs in next year's books.
* "No problem", you think, because you remember that you can add `at time zone 'America/New_York'` to your query to cast your date to east coast time.
* You start to cry when you see the query result is December 31, 2012 18:59\. Why... is that happening?

The answer to this problem is that Postgres (and I'm sure other platforms too) is very literal when it comes to storing dates at UTC using `timestamp`. Postgres thinks it literally happened at that time, GMT. When you ask for a conversion to EST from GMT, it will give it to you.

In our case, the date stored is _incorrect_ and off by 8 or so hours. Ouch. This would throw off every sales report, which might be a small amount and not matter so much in sales meetings - but it matters to book keepers and accountants!

## Storing Time Zone Information

We could, of course, store dates using `timestamptz`, which is a time stamp with a time zone offset. If I had done that, I would have been able to read the dates back out with the correct time stamp.

**Maybe**.

See **this only works if you know what time zone your server is in**. Do you? When working locally and using local Postgres, your server's time zone is the same as your local machine, which is wherever you're located in the world.

If your database is in the cloud, however, that's not the case, and it's likely your server is set to UTC, _even if your data center is located at us-west, us-east, asia, or whatever_. This is true for AWS, GCP, Azure and Digital Ocean. Might be worth confirming yours...

The worst part, however, is that you only realize the mess you're in when it comes time to generate reports, specifically sales reports, and the sales differ from your bank.

So, what should you do then? _Good question_. The first step is to be aware of the problem. The second step is to store the dates with the right offset for your business.

That's the subject of this week's video - dates and date handling in Postgres. Enjoy!