---
layout: post
title: Avoiding Messy Situations With KnockoutJS and JavaScript
summary: "Any tool can create a mess. <a href=\"http://wekeroad.com/2011/08/18/my-eyes-please-youre-killing-javascript-kitties/\">Some seem more prone to messes then others</a> - that's what I thought of <a href=\"http://knockoutjs.com\">KnockoutJS</a> until recently when I had a chance to catch up with <a href=\"http://blog.stevensanderson.com\">Steve Sanderson</a> - Knockout's creator. We talked, I tried some different things. I've changed my mind."
image: /img/knockout_slide.png
date: "2012-08-12"
uuid: "7PM5bCn7-Owx7-9gPt-XbCm-0AqrwGqOyJtW"
slug: "avoiding-messy-situations-with-knockoutjs-and-javascript"
categories: Node JavaScript
---

## Steve, Jabber, and Changing My Mind
I went to [NDC 2012](http://www.ndcoslo.com) in June, 2012 and as I drove from my brother's house in San Diego, CA to Los Angeles to catch my flight to Europe, I listened to [JavaScript Jabber](http://javascriptjabber.com/013-jsj-knockout-js-with-steven-sanderson/) - the one with Steve on, who was there to basically defend Knockout's existence in the face of a tidal wave of JavaScript snottiness.

Like the amazing English gentleman that he is - Steve remained polite, self-effacing, and utterly brilliant as he dismanted the wave of condescenscon coming in from the "panel". Listen to it. You'll know what I mean.

It was such a brilliant interview that I found myself feeling very badly about my existing opinions on Knockout. Frankly: I don't think Knockout is used (primarily) by devs that care much about keeping their javascript clean. It's a simple tool - plug it in, run up some bindings, and you're done.

Simple tools are fun but simple tools are the simplest to abuse. That **is not Knockout's fault**.

So, as it turned out, I had a 2 day layover in London so I sent Steve an email and asked if I could buy him a Chiswick's... and he agreed. I know that, with some discipline, I can keep my Knockout code clean - but there were a few things that were still bugging me.

## Taking about Models in Bath
I took a train to Bath (amazing area) and met Steve in an old, creeky pub that I think was built by the Romans. I had a lot questions to ask - and we got right to it. One thing that I've felt was "left out" from Knockout was the concept of the "model". There isn't one - yet it's one of the "Ms" in MVVM! 

So I asked him:

> Where's my model!

Steve thinks for a moment, then says:

> Yes I spose you might call Knockout a "VVM" since we don't have much in the way of a model. Personally, I like to think of the model living on the server. Why should you have to duplicate that logic on the client?

**Clang.** That... makes... a whole ton of great sense.

I've been comparing Knockout to what I know of other frameworks like Backbone and Ember - and **of course it doesn't make sense**. That's not what Knockout does! It doesn't manage your URLs and routes, it doesn't fetch or update data; it's focus is clear: help you manage data in your DOM effectively.

If I let the whole client MVC idea go... Knockout all of a sudden started making a load of sense.

## Try Again
I went home and opened up the app that I was working on with [Sam Saffron - Tekpub's Speed Series](http://tekpub.com/productions/speedmvc) and put together an Order Fulfillment page that did all kinds of stuff.

My goal: **use Knockout without creating Yet Another Crappy Knockout Example.**

[I daresay it worked](https://github.com/tekpub/mvcmusic/blob/master/MvcMusicStore/assets/js/order_editor.js). 

Many people don't care much for the data-binding approach - and I understand that. In my opinion however, the data-binding solution is much, MUCH more elegant than using a templating system like Handlebars or jQuery templates. I can't see how using templates is less... "aesthetically offensive" than having an HTML5-compliant data-bind tag.

I don't dislike JavaScript templating solutions - not at all. I just like Knockout's DOM templating better.

## See The Results
I know many people might have some strong opinions about this... I would just ask you to take a look at what we've put together. If you don't want to watch the video, [have a look at the code and let me know what objections you have](https://github.com/tekpub/mvcmusic/blob/master/MvcMusicStore/assets/js/order_editor.js).

I recorded everything I did and pushed the result today: [Tekpub's latest series: Practical KnockoutJS](http://tekpub.com/productions/knockout). The focus is two-fold:
- I show how to use Knockout to do some very compelling User Experience stuff
- I take the time to **not make a huge mess**. At the end I ask [Derick Bailey](http://lostechies.com/derickbailey/) to review what I've done - and together we tighten things up really nicely.

I'm immensely proud of what we put together for Knockout, and I'm happy to say that I've completely changed my point of view after having spent some time with the tool - using good habits and keeping the focus on a clean solution.

Hope you enjoy it!

