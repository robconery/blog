---
layout: post
title: "Big O Notation"
image: "/img/2020/07/screenshot_65.jpg"
date: "Wed Feb 09 2022 23:51:00 GMT-0800 (Pacific Standard Time)"
categories: theory
summary: Understanding Big O has many real world benefits, aside from passing a technical interview. In this post I'll provide a cheat sheet and some real world examples.      
---

When I started writing __[The Imposter’s Handbook](//products/the-imposters-handbook/)_, this was the question that was in my head from the start: __what the f\*\*\* is Big O and why should I care?_ I remember giving myself a few weeks to jump in and figure it out but, fortunately, I found that it was pretty straightforward after putting a few smaller concepts together. 

__**Big O is conceptual**_. Many people want to qualify the efficiency of an algorithm based on the number of inputs. A common thought is _if I have a list with 1 item it can’t be O(n) because there’s only 1 item so it’s O(1)_. This is an understandable approach, but **Big O is a __technical adjective_**, it’s not a benchmarking system. It’s simply using math to describe the efficiency of what you’ve created.

__**Big O is worst-case**_, always. That means that even if you think you’re looking for is the very first thing in the set, Big O doesn’t care, a loop-based find is still considered O(__n_). That’s because Big O is just a descriptive way of thinking about the code you’ve written, not the inputs expected.

## THERE YOU HAVE IT

I find myself thinking about things in terms of Big O a lot. The cart example, above, happened to me just over a month ago and I needed to make sure that I was flexing the power of Redis as much as possible.

I don’t want to turn this into a Redis commercial, but I will say that it (and systems like it) have a lot to offer when you start thinking about things in terms of __time complexity_, which you should! ****It’s not premature optimization to think about Big O upfront, it’s** __****programming**_ and I don’t mean to sound snotty about that! If you can clip an O(__n_) operation down to O(__log n_) then you should, don’t you think?

So, quick review:

* Plucking an item from a list using an index or a key: O(1)
* Looping over a set of __n_ items: O(__n_)
* A nested loop over __n_ items: O(__n^2_)
* A divide and conquer algorithm: O(__log n_)

---

## Learn The Core CS Concepts Every Programmer Should Know - Free 

In this **free, 52 page PDF** I'll share with you some of the skills and techniques I use on a daily basis. 

Send me the free book!

We respect your privacy. Unsubscribe at any time.