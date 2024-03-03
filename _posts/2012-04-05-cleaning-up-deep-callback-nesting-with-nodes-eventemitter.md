---
layout: post
title: "Cleaning Up Deep Callback Nesting With Node's EventEmitter"
summary: "One problem people face when starting out with Node (and JavaScript in general) is handling the asynchronous, deep callback nesting issue. EventEmitters help fix that."
image: "/img/ChristmasTree.png"
date: "2012-04-05"
uuid: "j8GfvmSg-WKfU-jbah-ywcf-RZ6KOwqPNApy"
slug: "cleaning-up-deep-callback-nesting-with-nodes-eventemitter"
categories: JavaScript Node
---

## The Registration Problem
Consider this: you want customers to register with your site. When they do, a number of things need to happen:

1. The information needs to be validated
2. The customer record inserted
3. An email sent to say "thank you"

In a typical scenario, there's probably more - but let's use this for now.

You might know straight away how to do this in Ruby or C# - but how would you handle this with Node and JavaScript?## O Christmas Tree

This is some code that you might see in a Customers module:

![](https://blog.bigmachine.io/img/Screen-Shot-2012-04-05-at-11.22.43-AM.png)

Yuck. 

This code is not only hideous-looking, it's also synchronous and a nightmare to maintain.
Node allows you to do this much better with EventEmitters. Let's see how to use Events to clean this code up.

## Emit It
There are two ways to do this: encapsulate the eventing, or make your entire object an EventEmitter through inheritance. I'll do the latter.

The first thing to do is reference Node's event module and the util module as well - it has some helpers we'll need. Then we rewire the module to handle the events - I'll explain in a second, but here's the final code:

![](https://blog.bigmachine.io/img/Screen-Shot-2012-04-05-at-11.28.17-AM.png)

So what's going on here? Well first - there are no more callbacks - we don't need them! We have events to listen to.

I'm using Node's built-in EventEmitter object to "graft" on some functionality to my Customer object. JavaScript doesn't have inheritance, per se, but you can take the prototype of one function and pop it on another.

Node helps you with this using the "util" library. On line 42 we're telling the util to push the prototype from events.EventEmitter onto our Customer function. Notice that this is a function, not an instance of a function as I had in the first example above.

Next, on line 7, I had to invoke the "base" constructor to be sure that I don't miss any internal instancing or setting of values. Turns out for EventEmitters you don't need to do that and you can omit this line - but it's safe to just do it, no matter what.

In the body of each method I'm simply "emitting" an event to all listeners (there's obviously some code missing here - pretend that I have an insert routine and so on). I can emit an event for whatever happens along the way - a successful validation fires "validated", a failure might fire "validationFailed". This frees up our code to do what it needs to do and no more, making it much cleaner and clearer.

On line 29 I've added a final event trigger if everything works out: "successfulRegistration". This is what calling code will really be interested in the most - either that or "failedRegistration" - and we pass along the customer record (more on that in a second).

On lines 35 through 38 we've implemented a bit of workflow. This doesn't need to be inside the Customer function - you can arrange these events wherever and however you like. The calling code can remove every event listener and replace it with its own if it wanted to reorganize the flow here.Speaking of calling code, here's what it might look like:

![](https://blog.bigmachine.io/img/Screen-Shot-2012-04-05-at-11.40.12-AM.png)

You hook into the events, then run register() and respond as needed.

## All Over The Place
Node is built on top of EventEmitters - you'll find them everywhere. Understanding them is key to writing cleaner code that's more functional and maintainable - and it also helps keep things asynchronous.

n the first example, we had a synchronous drop all the way down - even though we were using callbacks. Our code above isn't synchronous at all - we've hooked into an event and when Node is ready, it will process the emitted event callback.

Neat stuff!
