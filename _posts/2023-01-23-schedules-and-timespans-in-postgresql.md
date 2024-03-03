---
layout: post
title: "Using Constraints to Protect Calendar Data in PostgreSQL"
image: "/img/2023/01/bip_1545.jpg"
date: "Mon Jan 23 2023 04:48:43 GMT-0800 (Pacific Standard Time)"
categories: postgres
summary: Think about the lines of code you would have to write in order to manage a scheduling system. Duration checks, start and end time requirements as well as checking for overlap! You could spend a few days writing all that code or you could let PostgreSQL do it better with 5 lines of SQL.      
---

It's a lovely sunny day here in Northern CA (where I am currently in the world) and I was doodling in my journal about today's events when memories of a fun project came flooding in. 

I (currently) work at Microsoft as a developer advocate and part of our job is to help out where help is needed. I have a lot of experience doing front end "stuff", specifically with Vue and Nuxt (I've shipped quite a few apps), so I was asked to chip in and **lead the engineering effort behind LearnTV**, a video streaming service that Microsoft wanted to use for streaming events, news, and videos from the Channel 9 archives:

![](https://blog.bigmachine.io/img/2023/01/bip_1547.jpg)

I had a ton of fun with this project - mostly because I got to work with PostgreSQL and do some very interesting scheduling problems with it!

## The Scheduler Problem

We wanted to present our users with a "guide" like you see on any TV: a grid of programs divided out by the time of day. These programs included conference talks, live streams and recorded video presentations. The conference videos were almost _always_ 30 to 60 minutes apiece, with some stretching to 120 minutes. The archived video stuff (old Channel 9 videos) were completely random in terms of duration and the live streams would start on time but could end whenever they chose. Putting these things together into a guide was a challenge. 

This is what the old "guide" looked like:

![](https://blog.bigmachine.io/img/2023/01/bip_1546-1.jpg)

Hopefully you see the problem: weird start and end times that weren't very TV-like. To solve this problem, we created programming `slots` and filled them as best we could - sort of like TV guide Tetris. 

A `slot` would be a block of time 30, 60, 90 or 120 minutes in length and in an ideal world you could fit a live event (like a conference talk) in there perfectly. But that was rarely the case so we had plenty of small videos (between 1 and 15 minutes in length) that we could pack in to fill the extra time so we didn't have dead air. We wanted those small videos to be relevant to the talk (as much as possible) so we ended up creating a fun bin-packing problem for ourselves.

Thankfully we had PMs 😹 so we made them deal with the bin-packing thing - but _I_ needed to be sure the data that got entered was as correct as possible. I don't know if you've ever worked with PMs under stress but let's just say that they have this weird ability to circumvent rules and pump crappy data into any system, which usually involves Excel somehow.

Anyway, I couldn't have that, so I decided to flex Postgres, implementing the following rules and _building it right into the table schema:_

* Start and end times had to happen at **the top or the bottom of the hour**, just like TV.
* The **duration of the program needed to be 30, 60, 90 or 120 minutes**
* **No overlaps**! We only had one broadcast so having overlapping times would flip out our streamer (OBS) and the system would crash.

Sure, I could have used code to do this, but that would have left my scheduling table unprotected! No - I needed to be _sure._ Besides: the code for this stuff would have been lengthy and messy, abusing ORMs by using callbacks, voodoo and bourbon.

**Yuck**. I'd rather use Postgres.

For instance: I can ensure that a program starts at the top or bottom of the hour using a very simple `check`:

```sql
create table programs(
  id serial primary key,
  name text not null,
  start_at timestamptz not null 
  	check(date_part('minute', start_at) in (00,30)),
  ends_at timestamptz not null 
  	check(date_part('minute', ends_at) in (00,30))
);
```

Oh but this is only the start - I should be using a range for the time data (a `tstzrange` to be specific) and I should also have `duration` field in there, which also has a `check` on it to be sure it's 30, 60, 90 or 120 minutes. Oh yeah - no overlapping slots! 

This is _not_ a simple problem! Unless we're...

## Using Constraints Like a Boss

**I can do all of these things with a kickass set of constraints**, guaranteeing my data is correct, letting me sleep at night.

That's what we're going to do in this video: freak out with Postgres, flexing built-in data types and some valuable date functions.

Enjoy!