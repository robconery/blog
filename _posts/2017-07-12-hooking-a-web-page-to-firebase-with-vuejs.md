---
title: Hooking A Web Page To Firebase With VueJS
date: '2017-07-12'
summary: "We can checkout and execute an order, but what does the client see? Firebase gives us a unique ability that way: a realtime update powered by VueJS."
image: /img/skitterphoto-1161-default.jpg
layout: post
categories:
  - Firebase
---

In the [the last post](http://rob.conery.io/2017/06/29/wiring-together-serverless-routines-with-firebase/) in [this series](http://rob.conery.io/tag/firebase/) I set up a bunch of functions that go off in response to a set of events. This is dandy, but how will the client know when the transaction is completed? What does "completed" even mean?

## Defining Done

At a high level, here are the things that we need to do when an order comes in:

- capture the customer's money
- create a sales order, which is our record of sale
- fulfill the order (digital downloads)
- create an invoice which is the client's record of sale
- email the customer with links to their downloads and the invoice
- create reporting entries _somewhere_
- optionally notify the store owner

There could be more or less than this, but I think this is a good start.

To a store owner, "done" might be when the customer is notified and they download the goods; at that point the order status might be sent to "closed" or something.

To the customer, "done" means _I paid now gimmeh_. In an old school ecommerce site things are typically synchronous, so there's no joy for the customer until all things are done. If there's an error along the way, support is going to get a call and we're not going to look very good.

In an evented/asynchronous/realtime system we can do better.

## Charting The Progress

If you recall, every function that we're firing is updating a `progress` record on our sale:

```
exports.stripe_charge = functions.https.onRequest((req, res) => {  
  //captures the charge
  //updates as sale record with a transaction:
  //sales/{id}/transaction
  //update progress
});
```

That record is a literal one, as you see here:

![](https://blog.bigmachine.io/img/progress-1.jpg)

**This is the key**: if our functions keep updating this `progress` field, we'll be able to listen to it and react realtime on the client. We can then decide when the order is "done" from the customer's perspective.

## Hooking Up VueJS

Time to jump back over to our static site, which I'm building out with [middleman](http://middlemanapp.com). Again: you can use whatever static app you like, or none at all! To me this is one of the best aspects of working with Firebase (the entire suite): _I'm not tied to a single framework to do everything_. I can build my website however I damnwell please.

So let's plug in VueJS along with a plugin for Firebase called [VueFire](https://github.com/vuejs/vuefire):

```
  <!-- Vue -->
  <script src="https://unpkg.com/vue/dist/vue.js"></script>
  <!-- VueFire -->
  <script src="https://unpkg.com/vuefire/dist/vuefire.js"></script>
```

### Initializing Firebase

The next step is to initialize Firebase from the client. It's triple-important to remember _that this is the client SDK_, not the admin one we've been using. All of the rules will be applied that we've created previously.

To get a quick script for our setup, we can go to the Firebase console for our app, click "Authentication" in the nav menu, and then "WEB SETUP" which is in the top right. This will pop the code you need:

![](https://blog.bigmachine.io/img/credentials.png)

Put that at the top of the page.

### Initializing The App

I already made a checkout page that I like, and you can [see it here](https://app.redfour.io/order/). The easiest thing is to view source on the page if you want to see it all. The first thing to notice is this bit of markup at the very top:

```
<div id="order" class="ui container">
  <div class="ui horizontal divider">
    <h2 class="ui header">Your Order</h2>
  </div>
```

I'm wrapping everything in a `div` tag with the id of `order`. I'm doing this so I can initialize VueJS thus:

```
<script>
Vue.use(VueFire);
var db = firebase.database();
var app = new Vue({
  el: "#order"
});
</script>
```

Like Angular, Vue will now treat this `div` as a template wrapper. In addition I've hooked up VueFire and created a reference to the root of my Firebase database.

## Listening To The Order Progress

Now we get to the good stuff! If you recall, I'm creating the order's ID on the client. I could use a GUID for this, but I decided to do something a bit more meaningful using [MomentJS](https://momentjs.com) and a random string generator:

```
function shortid(length) {
  return Math.random().toString(36).substring(2, 4) + Math.random().toString(36).substring(2, 4);
};
generateId : function(){
  const formattedDate = moment().format('YYYYMMDD-HHmm');
  const key = shortid(4);
  const id =  `RED4-${formattedDate}-${key}`;
  this.orderId = id;
}
```

This will give me an ID like `RED4-20170520-1016-zgb6` that is a bit more meaningful. At a glance I can tell which store this order is from and the date/time. There's also a good bit of entropy at the end there so order numbers aren't guessable. I suppose it could be better, but I like this.

The important thing is that _I know the order number on the client_. Doing this will allow me to listen to the progress of that order, **even though it doesn't exist yet in the database**. To do so, I have to tell VueFire what to listen to:

```
var app = new Vue({
  el: "#order",
  firebase : {
    progress: {
      source: db.ref(`sales/${Cart.orderId}/progress`),
      asObject: true
    }
  }
}
```

Before this will work, however, we have to make sure we've set the rules so we can listen:

![](https://blog.bigmachine.io/img/rules.png)

Firebase rules aren't the easiest thing to get used to, but once you write a few of them they get easier to understand. Here I'm saying "for every sale, the `progress` field can be read but not written to".

Now comes the fun part!

## A Realtime Checkout UI

There are probably better ways to do this! I'm not a CSS expert nor am I graphically inclined; so feel free to have some fun! I decided to use [Semantic UI](https://semantic-ui.com), specifically the [steps bits](https://semantic-ui.com/elements/step.html) to show what's happening when.

There are four total steps (order received, payment received, order fulfilled, emailed) that I want to show to the customer and I can do that by changing the CSS according to what's happening with the `progress` field at Firebase. Here's the HTML/VueJS snippet for doing that:

```
<div v-bind:class="{completed: progress.captured, active: true, step: true}">
  <i class="hand peace icon"></i>
  <div class="content">
    <div class="title">Payment Received</div>
    <div class="description">Processing...</div>
  </div>
</div>
```

I won't go too deeply into VueJS in this post, just know that that it's toggling the `completed` class based on whether `progress.captured` is true. VueJS knows what `progress` is because we bound it above, in our app initialization.

The really nice part about all of this is that we can show a download button once the order is fulfilled; the customer doesn't have to wait for the email to be sent: hooked up to Stripe, but no emails will go through (I disabled that part).

```
<div v-if="progress.invoiced" class="ui container" style="margin-top:52px">
  <h3 class="ui centered header">Order Number: {{orderId}}</h3>
  <p>Thank you for your order! The downloads are below, please note that they are limited. We also ask you
  kindly to not share.
  You will receive an email shortly with your download information. Please hang on to it as it is your record of sale.
  </p>
</div>
```

Here's a checkout that's complete, as far as the client is concerned, but has not yet completed as far as we're concerned (no email sent or reporting created):

![](https://blog.bigmachine.io/img/sale_complete.png)
