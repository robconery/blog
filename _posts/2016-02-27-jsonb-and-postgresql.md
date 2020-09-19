---
layout: post
title: 'JSONB and PostgreSQL: Work Faster By Ditching Migrations'
image: 'pooh-jsonb.jpg'
comments: false
categories: Postgres
summary: "I am not a fan of migrations - never have been and probably never will be. They were interesting when Rails first came out, but now they're pure friction."
---

Migrations are a simple mechanism whereby you script out some change commands for your ORM, and that ORM then builds your database for you. To me, this is pure insanity. I dislike ORMs (accept, of course, for [LLBLGenPro](https://www.llblgen.com), which is astoundingly good). Trusting your ORM to build a proper database is ... kind of weird to me. SQL is terser, more expressive and (as it turns out) just right for the job.

## What About Change Management?

That's a question I get asked constantly when I start ranting on ORMs, favoring SQL instead. The answer I always give remains the same:

> Know your SQL, use change scripts, get a reliable DIFFing tool

This answer usually elicits some laughs. I can see why - migrations are really, really powerful when you're getting your database off the ground. When your Majestic Monstrosity moves past it's 3rd or 4th year of life, however, those 40 or so migration files start to look rather ridiculous.

Creating, altering, dropping, reloading a few times over. Kinda like...

<img src="/img/airport_queue.jpg" class="img-responsive" />

I suppose you can deal with this during one of the [Majestic Rewrites](https://twitter.com/dhh/status/695272044024487936) - "rebasing" your migrations if you will. That's some lovely extra work isn't it :).

I think there's an easier way.

## Lean On JSONB

As I'm sure you're aware, PostgreSQL supports binary JSON (like MongoDB does). This means you can treat your lovely relational engine like a document database. You just need [a data tool](https://github.com/robconery/massive-js) that [supports JSONB at the top level](https://github.com/robconery/moebius).

A document is, basically, "schema-less". This means that you can save whatever JSON structure you want, and change it as you need. **Ideal for getting your app off the ground**. It's OK if you're a big fan of relational systems! This is something to work toward if you want.

In fact, I'll go so far as to suggest that *normalization is optimization*. Well sort of. It's optimization in terms of data structure and "good database design" - not always for speed (joins can be costly). For large transactional systems you'll probably want some tight rules in there with constraints, checks, indexes - all the nutritious stuff an growing database needs.

But not right away. Write the code, design the experience - *nail the idea first*.

I'm a big believer that applications take on a life of their own and, after a while, start to write themselves. It's a birthing process where you get inspired, write some code and watch it work, become even more inspired which makes you write more ... and boom! Here's a new baby app for you.

Want a sure-fire way to drain that enthusiasm? **Add in some needless friction in the form of migrations**. Not only do you need to think through the normalization rules (does that foreign key ensure against nulls?) - you also get to wrestle with the migration tool, it's syntax, and version conflicts in the database.

Oh yeah did you run the migration on the test database too?

Let it go. Use JSONB to freely design your storage and when the time is right, **normalize that shit**. Or don't - it's up to you.

## Preaching What I Practice

Here's why I'm writing this post: I'm [building up a groovy eCommerce store with Elixir](http://rob.conery.io/category/redfour/) that I plan to use in the wild. I have changed direction, refined, tweaked, prodded and tossed entire aspects of the application into the bin. I have thought about data access perhaps three times - yet I'm storing everything I need, exactly as I need it.

This could change. It will change... and that's my point. *I'm letting it change without my needing to micro-manage it*. I'm letting it grow, die, and grow again without having to orchestrate each step becasue if I did... I would have given up.

It's why I'm writing this post. I'm having fun and thought I would share :).
