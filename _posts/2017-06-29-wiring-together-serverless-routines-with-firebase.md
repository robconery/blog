---
title: Wiring Serverless Routines With Firebase
date: '2017-06-29'
summary: "Do we use a lot of smaller routines with Firebase Functions? Or one big one? We'll explore the options in this post."
image: /img/register.jpg
layout: post
categories:
  - Firebase
---

In [the previous post](http://rob.conery.io/2017/06/22/thinking-in-events-with-firebase/) we sent Stripe Checkout information to an HTTPS-triggered function - basically an API endpoint. Now we need to execute the charge and we can do that with Database-triggered functions.

## Evented Functions: What Goes Where?

One of the most underutilized tools of Node, in my opinion, is the `EventEmitter`. There's [a lot of good stuff](http://rob.conery.io/2012/04/04/cleaning-up-deep-callback-nesting-with-nodes-eventemitter/) you can do with the thing, but to use it you need to shift the way you typically write code. In short: you don't orchestrate logic, you _respond to events_. Orchestration is a side effect, in a way.

The same is true with Firebase Functions. Our goal is to have small, concise little functions that do a thing based on some criteria. For instance:

- The `stripe_capture` function might get triggered by a write to the `sales` path
- A `fulfill_order` function would be triggered when a `transaction` is written
- A `notify_customer` function might get triggered when an `invoice` is written

This all makes sense, logically, but is it the "right thing to do"? Theory often clashes with reality, so let's have a think.

### Invocations and Timing

You don't want your customer to wait while your routines are queued and triggered. If we divide up everything we need to do (capture the charge, generate invoices, rights to downloads, account creation, notification, etc) into little functions, each of those will need to fire in order to complete the order. Are those invocations instant?

Probably not. There is a triggering mechanism that works from a queue, the more we involve this mechanism (as fast as it is), the longer things _might_ take. From my experience, the invocations happen rather quickly but, as I mention a few posts ago: _Akamai_. Let's not introduce a possible problem if we can avoid it.

### What Needs To Happen When?

One of the problems with doing event-based programming is that you often need to do things in a serial fashion. For instance: you don't want to send an email to a customer before their invoice (and fulfillment) is generated; that would introduce a race condition.

If we divide everything into "micro routines" then we'll need to think a lot about what happens when and where. This begs the question: _why are we doing event-based stuff in the first place?_

This line of thinking opens the door to a couple of options we should consider fully.

### Option 1: Everything Needs To Happen Now

Some businesses consider the entire sale to be a transaction. From the moment you're handed the money to the point where you notify the customer and write the reporting entry - it all needs to happen inside of a transaction. If _any of it fails_, it all needs to fail.

If this is the case, then one function with ordered steps is what we need. The minute money comes in the door we do the things we need to do, in order, and we're done. We'll need a rollback mechanism of some kind (which could be a simple delete command) which we could use a simple `try/catch` block for:

```
exports.sale = functions.database.ref("sales/{id}/checkout").onWrite(ev => {
  return co(function*(){
    //capture the charge
    try{
      const transaction = yield stripe.charges.create(...);

      //generate the invoice

      //fulfill the order

      //notify the customer

      //save to reporting

      //update the sale record and close the order

      return {success: true} //whatever you need
    }catch(err){
      //rollback everything
      return {success: false, error: err};
    }
  });
});
```

I'm using `co` with generator functions to orchestrate the serial stuff, but you could use whatever tool you like (such as `async`). With `co`, you can use a `try/catch` block to handle async errors, which is what we're doing here.

This works and has the benefit of being _fast_ - but it also means that you can't _gracefully recover_. Any error in the chain here will cause the sale to fail, which to me is a really bad idea.

### Option 2: Synchronous Little Chunks

Errors happen and I think it's better to build a system that let's you recover if there's a problem. For instance: the customer might have accidentally entered an invalid email. Let them know that right at sale time so they can fix it!

Maybe they entered there name as 👻 and your database isn't setup to handle that kind of string encoding - does that mean you should lose a sale? No way! Fix the problem on your end and resume the sale.

But what are these little chunky functions supposed to be? For me, I have a rule: _take the money and run_... the rest of the functions :). Here are my functions:

```
exports.stripe_charge = functions.https.onRequest((req, res) => {
  //captures the charge
  //updates as sale record with a transaction:
  //sales/{id}/transaction
  //update progress
});
exports.fulfill_order = functions.database.ref("sales/{id}/transaction").onWrite(ev => {
  //create deliverables
  //set the access rights
  //create an invoice and write it to /sales/{id}/invoice
  //update progress
});
exports.notify_customer = functions.database.ref("sales/{id}/invoice").onWrite(ev => {
  //email the customer their invoice and a link to downloads
  //update progress, close order
});
exports.update_reporting = functions.database.ref("sales/{id}/invoice").onWrite(ev => {
  //email the customer their invoice and a link to downloads
  //update progress
});
```

A number of things are going on here, so let's step through it.

First, I'm making sure that the sale gets recorded when the transaction is captured by Stripe. This is something you don't want to forget about :). When the transaction record is captured I write it to the `sales/{id}/transaction` path in Firebase. Doing this triggers the next function: `fulfillment`.

The `fulfillment` function does a lot of stuff. This might rub a few of you the wrong way as it violates SOLID, but I really don't care :). Divide it out into smaller functions if you like, I prefer simplicity. When this function completes, I write the `invoice` to the `sales/{id}` path, which triggers the final two functions.

At this point the order is complete, as far as the customer is concerned. They've paid us, we've generated their invoice - let's not make them wait until we send off an email and create a reporting entry.

But how do we do this? All of these functions are happening "in the background" if you will; how do we let the customer know what's happening?

**Firebase is a realtime database**. The client SDK can listen to any changes in the data at any path! We know the order id because we generated it on the client – this means that we can listen to the progress of the order, and when the deliveries are ready we can let our client access them directly. _Even if the order hasn't finished processing_.

I'll tackle that next time.

* * *

## [See this series as a video](https://goo.gl/pPpemy)

Watch how I built a serverless ecommerce site using Firebase. Over 3 hours of tightly-edited video, getting into the weeds with Firebase. We'll use the realtime database, storage, auth, and yes, functions. I'll also integrate Drip for user management. I detest foo/bar/hello-world demos; I want to see what's really possible. That's what this video is.
