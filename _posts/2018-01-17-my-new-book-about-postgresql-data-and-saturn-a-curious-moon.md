---
title: 'My New Book About PostgreSQL, Data and Saturn: A Curious Moon'
date: '2018-01-17'
image: /img/pg_saturn.png
layout: post
summary: "I just released a new book about PostgreSQL, Saturn, and Cassini! Quite possibly the most fun I've had writing about data and databases."
categories:
  - Postgres
  - Syndication
  - Writing
---

About 2 weeks ago I did a "quiet release", if you will, of [my new book](https://goo.gl/tWF5HE): _A Curious Moon_. It's kind of a funky little venture, blending a bit of scifi with the real world concerns of a database administrator/analyst.

Ultimately, **it's a book about data**. How working with it on a daily basis requires you to be an intuitive sleuth as well as a pragmatic engineer, and how it can be _quite fun_ as well!

## An Icy Moon That Might Have Life

![](https://blog.bigmachine.io/img/7796_PIA21346-full.jpg)

I started writing this book in September 2017 as a quick tutorial on PostgreSQL, my favorite database. I intended it to be about 100 pages or so, designed to be a highly-focused, quick read that you could do on moderate plane flight.

I wanted to focus on building a database that you could actually use, so I of course thought "ECOMMERCE!" because... why not. After a few weeks that grew rather boring, so I decided to have a look at a better data set.

It was right around this time that [Cassini plunged into Saturn](https://saturn.jpl.nasa.gov/mission/grand-finale/cassini-end-of-mission-timeline/) and I was reading article after article about the amazing things that Cassini discovered. One of those things was Enceladus, a freaky little moon that very well could be harboring life under its icy shell.

The [story of the Enceladus investigation is astounding](https://www.scientificamerican.com/article/excitement-builds-for-the-possibility-of-life-on-enceladus/) and I was quickly wrapped up in what the Cassini team described as "the greatest cosmic detective story of all time". I just had to use this as the backbone of the PostgreSQL book... but how?

## Inspired By The Martian

Every bit of data from Cassini is public domain. NASA has 24 hours to release whatever they find, so all the data from Cassini is there for the taking. I downloaded about 200G of delicious space data, and I set about trying to figure out how to structure a basic PostgreSQL tutorial using it. Needless to say: _I was overwhelmed_.

**There is over 20 years of data** from Cassini. TONS of readings from its 12 different instruments! In short: it just wasn't possible.

![](https://blog.bigmachine.io/img/10.jpg)

I then recalled an interview with Andy Weir, where [he talked about](http://uk.businessinsider.com/andy-weir-the-martian-science-crowdsourcing-2015-10?r=US&IR=T) how he put together the story for _The Martian_:

> My research created interesting plot points. Like when I researched potatoes and found out how much water he'd (Watney) need in the soil. Then I realized he'd have to make water. And that led to one of the coolest plots in the book...

Basically: _he solved one problem at a time_ and let the science drive the storyline. I figured I could do the same thing! Treat this as an investigation - the detective story that it truly is. Start at the beginning and let the data drive.

Doing this necessitated something more than me telling you all about Enceladus and Cassini - so I decided to create some fictional characters that work at my fictional startup, Red:4.

My main character, Dee Yan, is a newly-promoted DBA who has to assemble and normalize loads of Cassini data relative to Enceladus. She uses PostgreSQL to do this, and shares her code with you journal style.

She has some big wins and a few massive failures, but most importantly she learns how to spot her biases and focus clearly on what the data is telling her.

## The Most Fun I've Ever Had

I'm not a fiction writer and this is the first time I've ever tried something like this. So far the feedback has been incredibly positive! People enjoy reading about PostgreSQL, shell scripting and so on, having it all wrapped up in a fun story.

I've been telling people about it while I'm here at NDC London, and quite a few had no idea that I wrote a new book! I announced it (sort of) [on Medium](https://medium.com/@robconery/adding-some-scifi-fun-to-a-book-about-databases-82825aca0b14), but decided to pop it here as well, with a little more detail as to the content.

It was easily the most fun I've ever had creating something. I hope that comes through! Working with data (especially using PostgreSQL) is so rewarding at times - it's quite different from writing code and building apps. You have to have some really solid detective skills to sniff out inconsistencies and also solid database skills to make sure the data is correct.

Hopefully that all comes across in the book, and if you're interested [you can pick it up here](https://goo.gl/tWF5HE).

![](https://blog.bigmachine.io/img/image-20170411-26720-1avikn7.jpg)
