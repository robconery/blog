---
layout: post
title: Moving The Philosophy Into Machinery
summary: "The Alt.Tekpub site is coming together... all the pieces are starting to play nicely. But I still don't have an API. I have an *idea* what I want to do - but I'm waiting on a few more opinions."
image: "/img/cyclops.jpeg"
date: "2012-03-03"
uuid: "qEfhTwCF-qIAs-vyAy-cvYO-UwzUhECiqYYx"
slug: "moving-the-philosophy-into-machinery"
categories: Tekpub JavaScript
---

## An Invitation
I admire people who stick their neck out and offer to help others. In my case, with this whole REST kerfuffle - that would be[ Glenn Block (aka "2Cs")](http://codebetter.com/glennblock/2012/02/28/why-are-there-2-controllers-in-the-asp-net-web-api-contactmanager-example-rest-has-nothing-to-with-it-2/). He has been patient and kind and I very much appreciate it.

I'm also stubborn. Like you. I do see the merits in understanding concept and theory - but **until it's road-tested and battle-hardened it's still just that: vaporous theory** that sounds good in the lips, reads well on the blog, falls to pieces in reality.

Please note, once again: _**I am no stranger to RESTful design**_ and I'm not asking for a tutorial ([despite advice so freely given](https://twitter.com/#!/hhariri/status/175499544535109632)).

## What I am Asking For
I would like to invite the [good people](https://twitter.com/#!/gblock) who have engaged with me over the last few days to jump in and write me up an API - and by way of explanation - show how their ideas can be translated into reality. I have a pretty solid idea of what I want to do for Alt.Tekpub's API signature - but before I lay it out there I would like to see what "those in the know" suggest.

Specifically: I would love some comments (in the form of URLs) from:

- [Glenn Block (more abuse!)](https://twitter.com/#!/gblock)
- [Kelly Sommers](http://twitter.com/kellabyte)
- [Darrel Miller](https://twitter.com/#!/darrel_miller)
- [Ian Cooper](https://twitter.com/#!/icooper)

I promise the discussion will remain civil (I'mwieldingthe ban hammer - even on myself!).

Here are your Use Cases - they're simple and straightforward. **I realize your time is valuable**, but I think the readers here would enjoy seeing how you put things together given your deep knowledge.

## Use Cases
This is step one: simple authentication and then consumption of basic data. The client will be HTML, JS, and Mobile.

1. **Logging In**. Customer comes to the app and logs in with email and password. A token is returned by the server upon successful authentication and a message is also received (like "thanks for logging in").
2. **Productions**. Joe User is logged in and wants to see what he can watch. He chooses to browse all productions and can see on the app which ones he is aloud to watch and which ones he isn't. He then chooses to narrow his selection by category: Microsoft, Ruby, JavaScript, Mobile. Once a production is selected, a list of Episodes is displayed with summary information. Joe wants to view Episode 2 of Real World ASP.NET MVC3 - so he selects it. The video starts.
3. **Episodes**. Kelly User watches our stuff on her way to work every day, and when she gets on the train will check and see if we've pushed any new episodes recently. A list of 5 episodes comes up - she chooses one, and watches it on her commute.

OK - that's it! What I would specifically love is less guidance and postulation, more URLs.Thanks so much for your time - hopefully this will be a good learning experience for all.



