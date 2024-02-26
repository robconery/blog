---
layout: post
title: "The Subtle Arts of Logging and Testing"
image: "/img/2023/12/screenshot_411.png"
date: "Fri Dec 29 2023 19:05:25 GMT-0800 (Pacific Standard Time)"
categories: software-design
summary: I'm a big fan of testing, but I get lazy sometimes and it ends up costing me money, directly.       
---

I'm writing the Testing Strategies chapter of **a book I've been working** on for the last 2 years: _The Imposter's Playbook_, and I dove into **a bug I had in production** that plagued me for longer than it should have. 

I'll describe the bug in a second, but let me say that it took me almost 2 hours to figure it out, which is horrible. The main reason it took so long is that I kept writing more tests to isolate the issue, thinking it was a logic one (it wasn't). I'm curious if I suck at testing or this is just "one of those things".

## Take My Damned Money

I found out about this problem in the worst way possible: **a customer told me**. They sent me an email that said:

> I'm trying to buy your book right now but your site keeps crashing.

At the time, about 8 years ago, my site was a simple Node/Express application using PostgreSQL. A simple commerce setup that I had used before and I had a load of tests for it too... especially when it came to the "commerce flow" - find a product, add it to the cart, checkout.

I had a look at the logs and instantly felt a chill run down my spine (summarizing here):

```json
{"message": "Item added to cart", "sku":"imposter", "level": "info"},
{"message": "Item added to cart", "sku":"imposter", "level": "info"},
{"message": "Item added to cart", "sku":"imposter", "level": "info"},
{"message": "Product doesn't exist!", "sku":"imposter", "level": "error"},
```

There was obviously a lot more in the logs (requests, etc), but this is the important stuff. My logs were telling me that a product that used to exist didn't exist any more.

**Oh crap**.

## Dropping Prod?

My first thought was that I dropped the production tables. I had been working on the app all week, tweaking things locally without deploying. I don't mind hitting the database during testing because... well I have my reasons... and I make sure to drop/rebuild the test database with every test run. It takes milliseconds to do so, and my "fixtures", if you will, are all in a single SQL statement that is run using Make.

It's how I work, OK? It's fast enough for me and I like the speed of using `psql` before a test run.

Normally I hard code the connection string for testing to be ultra super whammadyne double-secret-probation sure that the only database that gets the drop/reload treatment is my test one. But if, somehow, through some combination of dumb-assery the production connection string got substituted... _oh no_.

It took 10 minutes to verify, three times over, that this was not the case. My production system was fine, and when I peeped at the production database, there was my `products` table with my little book, _The Imposter's Handbook._

So it existed. But my app thinks it doesn't? WTF?

## Thanks, Logs

**I was sloppy with my logging**. Over the years I've created my own personal strategy which feels verbose, at first, but has helped many times:

* Log any application error (in addition to runtime), and keep them focused.
* Log any state change to any model (as `info`).
* Log any `status` change, if a model has a `status` field, as a `warning`.
* Don't `try/catch` at the controller level unless no choice, only in service classes.
* Know what you're `catch`ing!

Logging errors is kind of an art form, and it can be difficult to interrogate every possible error thrown, but your future self will thank you if you can be as complete as possible. When I worked at Microsoft back in 2008 I was given a pretty hard time because I kept catching `InvalidOperationException`s everywhere, and my boss at the time said something snarky:

> So your code only throws InvalidOperationExceptions?

So I went back and, in my service classes, tested every assumption I made. My approach to this is to let models throw their own validation exceptions - that's it. Let a model be a model, if you will.

Service classes handle "business stuff" and is typically where my `try/catch` stuff goes. The problem is: _where do you put these blocks?_

My answer to that question is to challenge every assumption I make in these classes. Like "if the result of my query is null, a product doesn't exist". If I would have challenged that assumption I _might_ have caught this bug before it bit me.

Oh well.

I learned the `status` trick from an old lead I had long ago. The idea is that when something's `status` has changed, it's quite possible that it will have a ripple effect on your application... thus the warning. For instance: a user's status going from "subscribed" to "unsubscribed" changes the application 

This is particularly true with my problem!

So, no, I didn't use my typical logging plan for my own application because I was being lazy and didn't have the threat of a client/boss getting cranky with me. I would have found out the problem much quicker.

Do you have a personal logging strategy? If so, share!

## The Problem

I pulled as much information as I could from my logs, which wasn't much, to help me try and debug this situation. I wrote as many additional edge-case tests that I could think of, but it still didn't help. _I couldn't find this damned bug_.

I finally grabbed a dump from my production system and tested against _that_ (without dropping things, of course), and found the problem quickly. This is embarrassing.

**I created my database to handle physical products** as well as digital. I had it in my head that I might also sell physical copies of my books, and that they would be in my garage in boxes that I could send to people.

That meant I needed to handle inventory, which means inventory logic, which went like this:

* If inventory > 0, add to cart is OK, otherwise show error.
* If inventory >= 0, set `status` to "in-stock".
* If inventory <= 0, set `status` to "backorder".
* If product `status` is "backorder", don't show it.

To be honest, I didn't spend too much time thinking this through because **all my products, up to that point, were digital**. The books-in-garage thing was kind of a Big Idea that may or may not happen, so I kind of ignored the tests I needed for this process because, you know, YAGNI.

The exact problem came when the reporting customer had added the book to their cart, went to checkout, and then got distracted for a few hours. When they went to checkout, the inventory had gone to 0 because someone else checked out (debiting the inventory) and because I didn't test this situation, my product query returned `null` (because of my assumption above) when loading the checkout page and threw an error.

Laziness. Gets you every time! 

## A Question: Would TDD Have Caught This?

I debated this a few years ago with a friend. We were at NDC London discussing TDD and how it was actually fun if you did it in pairs, and I told them the particulars of this problem.

His answer was "you have to be disciplined and find the edge cases", to which I responded "this case shouldn't have existed... I don't think."

TDD is only as good as your ability to break things, and that last statement I made there blinded me to something that is all too real a possibility: admins (me) might screw things up.

The _real_ problem here is that **I mistakenly set _The Imposter's Handbook_, which is digital, to be a physical product with inventory**. And because I wasn't paying enough attention, I had a default value of 100 set for `stock_level`. This should never have happened... _but it did_.

I suppose TDD _should_ have caught me on this but, in my mind, that functionality wasn't ready to go anyway so why bother testing it? 🤦🏼‍♂️.

## Would Love Your Feedback

The book I'm writing_, The Imposter's Playbook,_ is a variation on one of my most favorite books, _Coder to Developer_ by Mike Gunderloy. That book was basically "here are the skills you need to cultivate if you want to become a pro", and I loved it no end.

I wanted to do a modern version of that, but taking it up a notch and framing it for self-taught people wanting to move into a senior position. It covers things like:

* Principles of interface design
* Commonly used project management things (Agile, Scrum, Lean, etc.)
* Using GitHub like a Pro (GitFlow, Trunk-based, etc.)
* Configuring GitHub for a team
* Intro to Docker and Docker Compose
* Basic "DevOps"
* Kubernetes
* Common Architectural Patterns (Monolith, MonoRepo, Microservices, Evented, SOA, etc.)
* Testing Strategies
* The Art of Debugging
* Logging and Monitoring
* Disaster Planning
* Benchmarking and Scaling
* Making sure you're recognized

That's the working TOC, not a complete list, and I'm about 66% through it, though there is a lot of work needed - and there's also asking y'all if you have any thoughts!

If you'd like to see a topic covered, hit reply and let me know. I'm having a blast getting into the details on each of these topics - especially Kubernetes. I've wanted to learn that to a deeper level and this last holiday I did!

You can also let me know if TDD would have prevented the problem above, which resulted in a customer not being able to buy something.

## Just Added an Old, New Short Video

When writing this chapter, I figured it would be a good idea to see what my friend [Brad Wilson](https://mastodon.social/@bradwilson?ref=bigmachine.io) might have done. I recorded an hour-long TDD video with him, where I challenged him to implement a subscription billing system, keeping things as real as he possibly could.

I also threw him a few curveballs. You can watch it here:


Thanks for reading!