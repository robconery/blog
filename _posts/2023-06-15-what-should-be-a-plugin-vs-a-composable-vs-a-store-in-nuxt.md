---
layout: post
title: "What Should Be a Plugin vs a Composable vs a Store in Vue?"
image: "https:/images.unsplash.com/photo-1512209840695-c9b154d2a2aa"
date: "Thu Jun 15 2023 18:31:03 GMT-0700 (Pacific Daylight Time)"
categories: frontend
summary: Vue is a very powerful framework that I love a lot, but understanding some of the builtin machinery can be extremely confusing. Here's how I deal with that.      
---

One of the things that has confused the hell out of me as [I work with Vue 3 (and Nuxt 3)](//frontend/trying-something-different-a-real-world-tutorial-for-frontend-programming/) is when I should be using a Composable, Plugin, or Pinia Store for centralized "stuff".

The reasonable thing to do, when confused like this, is to RTFM, which I have. Here's how the docs explain what these things are.

We'll start with [plugins](https://vuejs.org/guide/reusability/plugins.html):

> Plugins are self-contained code that usually add app-level functionality to Vue.

Seems pretty obvious, I suppose. I've also read that plugins "extend" Vue (and Nuxt), which I guess is another way of saying "app-level functionality".

Next up, [composables](https://vuejs.org/guide/reusability/composables.html):

> In the context of Vue applications, a "composable" is a function that leverages Vue's Composition API to encapsulate and reuse **stateful logic**.

I think the keyword here is "stateful" but I'll admit that I have no idea what "stateful logic" means. The documentation explains it this way:

> When building frontend applications, we often need to reuse logic for common tasks. For example, we may need to format dates in many places, so we extract a reusable function for that. This formatter function encapsulates **stateless logic**: it takes some input and immediately returns expected output. There are many libraries out there for reusing stateless logic - for example [lodash](https://lodash.com/) and [date-fns](https://date-fns.org/), which you may have heard of.

> By contrast, stateful logic involves managing state that changes over time. A simple example would be tracking the current position of the mouse on a page. In real-world scenarios, it could also be more complex logic such as touch gestures or connection status to a database.

I still don't see how there's a qualitative change in the idea of _logic_ here. Dates change in the same way a mouse location changes or, for that matter, the state of a database connection (open vs. closed). Moreover: I don't see how changing data should dictate whether I use a composable.

I've reread this page many times and have never come away feeling that I understood what it is the Vue team wants me to understand. I know they have a plan, it's just not getting through my thick head.

Finally, let's [dig in to Pinia](https://pinia.vuejs.org/introduction.html):

> Pinia is a store library for Vue, it allows you to share a state across components/pages.

Nice and concise! The only place where this gets weird is `actions`, which are described thus:

> Actions are the equivalent of [methods](https://v3.vuejs.org/guide/data-methods.html#methods) in components. They can be defined with the `actions` property in `defineStore()` and **they are perfect to define business logic**

Logic and state... would that be _stateful logic?_ I am genuinely confused on all of this and I'll cut to it: **over the last few years working with Vue 3, I've never understood (clearly) what goes where**.

So I came up with what I think make sense.

## A Case Study: Using Firebase

My confusion really flared when I needed to integrate Firebase into a Nuxt app I was creating for my main site, [bigmachine.io](https://bigmachine.io). I used to use a package for this but I had enough custom needs that I decided to just pop it in myself.

But where? Would this be a plugin, extending Vue and my application? Or is it a simple set of composable functions? Firebase _is_ a database, you know, and it also handles authentication so you _could_ argue that it's a state store. I'll take that last bit further: _Firebase **is**_ _your state store when working with Vue_. In my experience, that's the best way of working with it.

Confused? Me too. But it gets worse.

When using Firebase with Nuxt you have to consider what Vite (the server powering Nuxt and building Vue) is going to do. Unless you're running a static application, you'll have server-side "stuff" going on behind the scenes. _Firebase is a not a server-side thing_. If you try to use the client SDK on the server, you'll get an error as it looks for `window`.

I could descend into the details but I won't. Here are the basic constraints we need to live with:

* We need to initialize the client SDK on the client _only_
* Anything `auth` related needs to wait for initialization to happen so we can know the state of our `user`

Here's how I solved this problem.

### Plugins Are Out

Plugins are initialized on the server when using Nuxt (which I was using) which means our SDK will bonk on start. Yes, there are ways to mark plugins as "client only" which will work, but, to me, that's a code smell telling you "this isn't the right place, mate".

### Composables Could Be Made To Work, I Guess

If we thought of Firebase as a completely separate service and something our application talks to as needed, then yes a composable might work OK. I tried this as I like simpler approaches to things but I quickly found that trying to work with events (such as when the `user` is recognized and authenticated) was causing me to write a bunch of workarounds.

Listener functions that planted stuff in a Pinia store, for instance, that would then change the `currentUser` which would then ripple out throughout the application... it felt wrong and I hated it.

### Firebase is a Store, Treat It That Way

This is what I ultimately came to. I hated the idea of having two separate state stores running - one in the cloud and one in my app - that I had to synchronize. When I tossed out my `authStore` (with a few others) and just went with a general `firebaseStore` everything seemed to click.

I'm not entirely certain this is the way to do things, but it worked for me. I have an `init` method that I call `onmounted` in the `app.vue` component and everything works from there.

There are too many details to go into here, but I will be making a video case study on this as part of the [Frontend Accelerator production](%5F%5FGHOST%5FURL%5F%5F/frontend-accelerator/) so if you're curious - keep an eye out for that.

## In Summary: Rob's Way

I won't say that this is _The Way_, but it's helped me when trying to figure out what goes where, so here goes:

* **Plugins are generic, reusable bits of logic** you can use from project to project or open source. They extend Vue (or Nuxt) and make it easy to "drop in" something you need.
* **Composables are like Helpers** in Rails: reusable functionality that does a thing within the scope of a function. I have one I really like called `useSeo` which will build the header in Vue to have an image, twitter info, open graph and more. Simple, straightforward and reusable.
* **Stores deal with data across the app** but, to me, in the cloud as well. This could be from Firebase or wrapping an API.

I think my take on composables could use some detail, so here's the `useSeo` one I was mentioning and that you['ll also see in action in the Accelerator production](%5F%5FGHOST%5FURL%5F%5F/frontend-accelerator/):

```js
export default function({title, description, image}){
  const config = useAppConfig();
  const route = useRoute();
  const meta = [
    {hid: "title", name: "title", content: title},
    {hid: "description", name: "description", content: description},
    {hid: "og:title", name: "og:title", content: title},
    {hid: "og:description", name: "og:description", content: description},
    {hid: "og:image", name: "og:image", content:  `${config.siteRoot}/images/${image}`},
    {hid: "og:url", name: "og:url", content: `${config.siteRoot}${route.path}`},
    {hid: "twitter:title", name: "twitter:title", content: title},
    {hid: "twitter:description", name: "twitter:description", content: description},
    {hid: "twitter:image", name: "twitter:image", content: `${config.siteRoot}/images/${image}`},
    {hid: "twitter:creator", name: "twitter:creator", content: config.twitterHandle},
    {hid: "twitter:site", name: "twitter:site", content: config.twitterHandle},
    {hid: "twitter:card", name: "twitter:card", content: "summary_large_image"}
  ];
  useHead({
    title: `${title} | ${config.title}`,
    description: description,
    meta
  })
}
```

Two things to know if you want to use this:

* `useAppConfig` is a Nuxt thing which pulls in global data. If you're using straight Vue you could have a `siteStore` which has things your site title, email, twitter handle, etc.
* `useHead` is from the [unjs crew](https://github.com/unjs/unhead) and you'll need it installed in order to inject the `head` with this stuff

Hopefully you can see how this is a helper function as opposed to a store or plugin? It seems that way to me so... I'm going with it.

Have some counter thoughts or different ideas? Leave a comment! I'm not sold on any of this entirely - it's just what has made sense to me over the years and I'd love to hear from you.

Hope this helps!