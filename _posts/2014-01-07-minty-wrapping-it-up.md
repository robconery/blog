---
layout: post
title: 'Minty: Wrapping It Up'
image: '/img/Minty_Fresh_Vector.png'
comments: true
categories: Node
summary: I'm building out a Node application - in this case a Blogging engine - and these posts are my adventures building this thing. This is part 10.
---

## So, What Do We Have Here?

In [the last post](http://rob.conery.io/2013/12/16/minty-working-the-evented-pattern/) I used Node's event library to help me unwind the callback Pyramid of Pain. I then used eventing to wire different modules together, just the way I wanted.

There are a lot of questions that come of this, specifically:

 - We have modules within modules - how do you structure each one's events?
 - Is this event stuff really necessary when working with Node?
 - How do you test this stuff anyway?


These are the questions I asked myself, at least, and I'm assuming you'll have similar ones. Let's drill through them.

## Modules and Events

The role of a module is, like any module, to encapsulate functionality. Our CMS module will encapsulate everything related to publishing content. Inside of that module we have a Writer and a Publisher - which encapsulate what they do, respectively.

This is not unique to Node/Javascript - have some level of extensibility in your library code is simply a Good Idea - how you express it is up to you. I could write forever on how to construct an effective API - but hopefully you already know this, and I've simply showed you how to express your API in Node (which was my goal).

## EventEmitters Are Interesting, Not Required

I like using Node's EventEmitter because I'm familiar with evented programming with Javascript in the browser using tools like Backbone, Angular, Knockout, Ember, etc. So it doesn't freak me out to "program backwards".

That said - there are a number of different ways to wire up program flow:

 - Using promises [with the Q library](https://github.com/kriskowal/q)
 - Explicitly declaring flow structures [with the node-async library](https://github.com/caolan/async). I personally LOVE this library and use it often
 - Just going with Callbacks and not worrying.

To many this suggests that Javascript is flawed - that you need these 3rd party libraries to keep your code from becoming a mess. There's some truth to that - but most often I find that you go through an adjustment period and it simply takes time to get used to asynchronous programming.

Once you embrace it and get your mind used to it - it becomes quite fun!

## Testing

I don't test events - but it's [definitely possible with sinon](http://sinonjs.org). This is a simple spy that will tell you if a certain callback or function was fired. I don't find this necessary because, ultimately, you're testing to see if Node's event library actually works.

Instead I find it easier to test things as you've seen me do - individual units and then an overall "acceptance test" that makes sure everything gets fired.

## Wrapping It Up

I've really enjoyed diving into these posts - but I think here is a good place to stop. [This all started](http://rob.conery.io/2013/11/19/hello-minty/) because of my interactions with the Ghost team - and I thought it would be a nice idea to explain my thoughts in depth.

I don't really want to create a blog engine - but if you want to use my code I say go for it! I'll [keep the code up on Github](https://github.com/robconery/minty-cms) so fork away if you find it useful!

Thanks so much for reading along!




