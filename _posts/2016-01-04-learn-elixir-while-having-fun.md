---
layout: post
title: "Learn Elixir The Fun Way"
slug: learn-elixir-while-having-fun
summary: ""
comments: true
image: /img/2016/01/splash.jpg
categories: Elixir
---

About 3 years ago I had an idea for creating a different kind of tutorial. Something that would combine the problem-solving of a video game, the immersion of a sci-fi story and the joy of learning something new. A tutorial you *wanted to finish* in the same way you want to finish a good book or fun video game.

[I finally got around to doing just that](https://goo.gl/zvMHWK)... *sort of*. Let me explain.

## Not Quite a Book, Not Quite a Tutorial

This is an Elixir tutorial. It's a downloadable application which uses the [Electron Shell](http://electron.atom.io) (from Github - the thing that powers Slack and the Atom text editor). It's divided into chapters like a book is, but you are actively involved in the content - it's not something you just sit back and experience.

I wrapped it around the idea that you work for me at a startup (Red:4) and I'm on the hot seat trying to get some demos ready. We've been asked to help the Science Team with some basic calculations they need for the probe they're about to launch. We have a serious case of NIH here at Red:4.

This is where the "fun problem solving thing" starts. Rather than write `def foo` and `bar = x`, I make you:

 - Calculate escape velocity for each of the planets
 - Calculate orbital acceleration and term for our prototype orbiter
 - Create a solar flare warning system using real flare data
 - Store that solar flare information in Mnesia (the Erlang DB) as well as PostgreSQL
 - Refactor my rushed attempt at creating a planet library
 - Blow up PostgreSQL using OTP


<img src="http://rob.conery.io/img/2016/01/calcs_1.png" alt="calcs_1" width="400" height="401" class="aligncenter size-full wp-image-740" />

That last item is the fun part. We play around with asynchronous patterns and the OTP library for Erlang - carefully managing a barrage of queries so PostgreSQL doesn't get DDoS'd... and then unleashing the hounds.

## An Elixir Expert, Are You?

Hardly. I'm not an expert in anything - I'm just a rabidly obsessive person who likes to figure things out. Yes you likely read about new things here on my blog and you should expect nothing less! Occasionally, however, something sticks.

Elixir is that something for me. When I learn something new I want to tell everyone about it - that's just me. I like the way [Derek Sivers](http://sivers.org) puts it:

> Right after you learn something, teach it to someone! Do it before you forget what *not knowing it was like*

I've woven this idea into my little Elixir tutorial thingy and tried to infuse the joy I felt learning this language, OTP, and the Erlang VM. There's still so much to learn - and that's the exciting part.

But excitement only gets you so far - you also have to be sure what you've created isn't garbage :). To that end I asked [José Valim](http://twitter.com/josevalim) and [Johnny Winn](https://twitter.com/johnny_rugger) (curator of [The Elixir Fountain](https://twitter.com/elixirfountain)) to do the tech review for me.

Anyway - I had a ton of fun creating this thing and I'd love to do more like it. I still do videos for Pluralsight - this is just a fun side venture.

You can [read more about it here](https://goo.gl/zvMHWK/) or if you want to buy it right now you can do that too! Here's a small introduction video:

<div class="embed-responsive embed-responsive-16by9">
<iframe src="https://player.vimeo.com/video/149825791" width="800" height="455" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
</div>
