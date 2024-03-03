---
layout: post
title: "The First Draft of Anything Is Shit"
image: "https:/images.unsplash.com/photo-1517917822086-6988b4ca9b31"
date: "Sat Dec 24 2022 18:54:40 GMT-0800 (Pacific Standard Time)"
categories: frontend
summary: I'm allergic to crappy, non-sensical, faked up demos that try to convey highly technical concepts. Yet I find myself falling into that lazy trap constantly. This requires intervention.      
---

The title of this post is from Ernest Hemingway and it **describes the last 24 hours of my creative life**. I really enjoy writing and making videos, and I also hate it. The process is fulfilling and torturous at the same time - a battle between my desire to share fun things and **my inner perfectionist calling me a hack**.

One of my goals for my holiday break was to wrap up and ship out my next book/video production. I really liked this one! **It's all about Vue, Nuxt (the opinionated Vue framework) and Firebase** and is based entirely on my experience building my publishing site from scratch:

[![](https://blog.bigmachine.io/img/2022/12/bip_1316.jpg)](https://bigmachine.io)

I built this site during my vacation in August, _over a 3 week period_. I don't want to mislead you: **I know Nuxt very, very well** as I've built and shipped about 15 sites with it to date. Some for me, some for others - either way putting my site together was straightforward.

But that site was built using Nuxt 2.x. **Nuxt 3.0 was released a few weeks ago** so naturally that's what I was going to spend this holiday vacation doing: _rolling my site over to Nuxt 3._

This time, however, I was going to document the journey.

## A Simple, One Hour Video, Right?

That's where I started: _how I rolled my Nuxt 2 site to Nuxt 3_. I decided I was going to do everything in a little book and then do a video based on that. I figured it would be 150 or so pages and I could probably knock it out in a week. I'm a very fast writer.

As I started writing, however, I realized that there was a bit more of a story to tell...

![](/2022/12/bip_1317.jpg)

That's my manuscript, which I created with Ulysses. Each chapter is about 1200 words on average and what you see here is roughly 2/3 of the total size of the manuscript. _For reference: 100 pages is about 25,000 to 30,000 words, depending on layout and font size, etc_.

The point is: I kind of got carried away.

## Telling a Real Story That's Not Boring

This is the worst part about writing: where's the line between Hemingway and Neal Stephenson? Hemingway is famous for his brevity:

> To be successful in writing, use short sentences.

Neal Stephenson... not so much. I'm a _huge_ Stephenson fan and will read (actually listen) to anything he writes. Every novel is an adventure buy MY GOD he is merciless in weaving his words. Story threads explode from the page and demand you pay attention!

These people write fiction and I'm trying to write a technical tutorial - yet the same mechanics are at play.   _I need to create a story that moves things along_ so you don't get bored but I also need to make sure there's enough detail in there so you understand how things work.

This is tough to do, and yesterday I was haunted by yet [another Hemingway quote](https://www.goodreads.com/quotes/52073-the-first-draft-of-anything-is-shit) which is so spot on that it had to be the title of this post:

![](/2022/12/bip_1318.jpg)

Spinning this in a more positive way: _you can always improve your first effort at anything_. For this book and video, that's absolutely true.

## There's Always More To Say With Fewer Words

In this first draft I cover 80% of the moving parts of Vue and Nuxt that you would likely need to understand if you're going to build an application. But, as we all know, the details are where the fun is.

For instance: we build an entire site with Nuxt and Tailwind, including a checkout page that looks pretty groovy:

![](/2022/12/bip_1319.jpg)

This checkout page looks pretty good for a demo or tutorial, but it's nothing that I would ever ship in the real world! That, friends, is the problem. I need to keep things as real as I can and **creating a page that I wouldn't ever use is just... _shit_**.

I also show you how I do content management using Nuxt CMS but not how I hook up full text search or blog posts. I hook up Firebase for deployment too, **showing how you can deploy a full server-backed Nuxt application using a single Firebase function** \- which is crazy by the way - but I don't show you how to wire up Stripe to your API.

**I feel bad about that**. In fact I woke up at 3:22 am the other night and simply said "shit, I can't send this out like this".

There is so much already there, which is also a problem. I have to manage myself very carefully as I tend to find little rabbit holes everywhere with a need to fall into them. This is where careful editing comes in: _staying on track, omitting needless words (and code), delivering a coherent story_.

There's a solid story here and it needs care in the telling, so I'm going to give it the time and care it needs.

## The Next Steps

You can't have an ecommerce site without some type of gateway, so **I'll show you how to wire up Stripe** _and_ the strategies I use for storing that data in Firestore, the "next-gen" Firebase database. But once a charge goes through, then what?

You have to give the people what they bought, so **I'm also going to show you how to fulfill digital goodies** with a reactive function and expiring URLs with Firebase Storage. But even then we're not done...

My #1 support item, by a massive margin, comes from people losing their downloads and wanting access to them again. How do we do that? There are a few ways, and I'll show them all to you:

* Create a serverless function that sends an email with a link based on a form input.
* Create an email auto responder that does the same thing, triggered by an email receipt.
* Allow customers to login, easily, to your application using Firebase Authentication and then find their orders for them.

Just writing these things out is freaking me out. _That's a lot of work_. But it just wouldn't make sense otherwise, would it? So I'm going to divert my freaky energy into _just doing it_ and hopefully it's helpful to you.

## Great... So When, Then?

I'm back to writing now and will continue until I'm done. I'm pretty rigorous with my writing schedule (weekends and evenings and whenever I can fit it in) so ... hopefully I'll be through this in a month or two. I'll be making the videos at the same time.

You might be wondering why I chose to do all of this in the first place? The main reason is described briefly above: _it's a real thing I did last summer_. I think that if you build something interesting you should show people how you did it, rather than fabricating some nonsense for a Udemy video.

Oh, also: Nuxt is a lot of fun and it's changed the way I think about creating web sites! Fun is a good thing, don't you think?

Right - back to work with me!