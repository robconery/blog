---
layout: post
title: "Five Things I Learned Building Bigmachine.io Using Nuxt and Firebase"
image: "/img/2022/11/bigmachine.jpg"
date: "Tue Nov 08 2022 17:37:15 GMT-0800 (Pacific Standard Time)"
categories: frontend
summary: I like to change my publishing site regularly - it's fun and it keeps me sharp. This iteration is with Nuxt and Firebase, and I learned a ton.      
---

I have the habit of rebuilding [my publishing site](https://bigmachine.io) every six months, and it's annoying. **There's always _something_ that goes wrong** and requires a "drop everything and fix this" moment. I've bounced between Shopify, WordPress, SendOwl, Jekyll, Sinatra, and even Ghost at one point!

There are a lot of reasons for the changes, but it mostly comes down to flexibility and service charges. Sometimes complete service failures too.

Anyway: 5 months ago I decided to redo it again, but this time I would take my time, _do it just the way I wanted_. **I decided to use Nuxt 2.0 and Firebase** as I had been a Firebase customer since 2013 and I know and love the service and all of my data is over there too.

I learned a lot along the way, and I thought I would share it with you. Oh, before I forget, **I'm writing a book and hopefully going to create a video thing** based on what I learned - I'll post about it here in the next few months.

## Thing One: I Should Have Used Nuxt 3

I was trying to decide between using Nuxt 2 and Nuxt 3, which wasn't released but was getting very, very close. I figured things would be changing a lot and I knew Nuxt 2... so I just did that.

The reason I should have used Nuxt 3 is that it uses Vue 3 under the hood, which has a devotion to _terseness_. For instance, this code here is old school Vue 2:

![](https://blog.bigmachine.io/img/2022/11/bip_931.jpg)

Here's Vue 3 :

![](/2022/11/bip_1137.jpg)

**Note**: _I don't have the `app` declaration in the Vue 3 sample, but hopefully you get the idea_.

Vue 3 is all about **composition vs. declaration**. In Vue 2, you created an object and sent that declaration to Vue, which would know how to use it. With Vue 3 you import the functions you need to use and that's it.

The real magic, however, comes from `script setup`, which will automatically "lift" your variables to your template, whether they're simple values or full functions. You don't have to use `script setup`, but I love it.

## Thing 2: Pinia is Delightfully Simple

I really should have used Nuxt 3, and as of a week or so ago: _I am!_ I'm rolling my site over and it's been a fun process - especially using Pinia.

Every multi-page app needs a state store of some kind and, if I'm honest, using Vuex (the Vue 2 state store) was... _wonky_. I know they were following the Redux pattern blah blah blah but it just seemed so... _ceremonial_.

Pinia is delighfully terse:

![](/2022/11/bip_1138.jpg)

That's my `sales` store, which is responsible for loading things from Nuxt Content. I'm using `ref`, which is a built-in function which allows you to compose reactive data when you need it. _I love this_. State was automatically reactive in Vuex (aka "two-way binding"), here I can dictate which things are and which are not.

When you `defineStore`, the functions and values you return are what the store "does". Each function is turned into an action, each value is loaded into the state. Clean!

## Thing 3: Nuxt Content is Radical

As I mention: I've moved sites a lot over the years and one of the major headaches I had was dealing with the damned content! Copy, paste, copy, paste. I mean... yeah I know I should use a headless CMS like Contentful or Prismic, but that just added a load of extra concepts I didn't want to think about.

And then I read about [Nuxt Content](https:/.nuxtjs.org/). I swear, do these people ever sleep? The idea is simple: you can put files in your `/content` directory and then query for them from your Vue templates. These files can be **Markdown, JSON, YAML or CSV.** 

The Markdown files are especially interesting because you can embed Vue components right into them, which is wild. I don't find that useful, however. What I do find useful is chunking out the content for my pages into multiple files:

![](/2022/11/bip_1139.jpg)

Sales pages have different elements that follow a general pattern (headline, agitation, problem, solution, CTA, etc) and being able to divide these out and query for them all at once was joyous!

The Markdown files also use frontmatter just like Jekyll or Hugo, which makes these extremely portable.

## Thing 4: The Headless Component

I actually prefer another name: _the logical component_, but "headless" works too. These are components that don't have any UI to them (or "view" in the Vue world) and they exist only to handle state or react to events.

The one I created was my `UserAuthentication` component, which tells me if a user has logged in using Firebase Authentication:

![](/2022/11/bip_1097.jpg)

That's a lot of code there, but the idea is that you can **use "slots" in a Vue** component and give them a name. You can also display them conditionally. Here, I have two slots which show things if a `user` is logged in or logged out. That's determined by a Firebase authentication event that fires in the component code.

In addition, **this component fires an event** whenever a user logs in or out - something I can wire up on the page where the component lives:

![](/2022/11/bip_1140.jpg)

Here, I'm wiring `v-on:logged:in` (my login event fired from my component) to `loadVideo`, which goes to Firebase and requests a video record based on the logged in user.

There are two templates here that correspond to the slots in my Vue component and they are displayed conditionally. The first one is given the logged in `user` object, the other just displays a prompt telling the user to login.

I use this component _all over the site_. It's extremely versatile. Here I'm using it to show different navigation elements:

![](/2022/11/image-1.png)

I love this!

## Thing 5: You Can Run Universal Mode on Firebase

This one blew my mind! I'm running my current site as a static web app backed by 8 or so Firebase functions (serverless). This works pretty well, but Nuxt likes to have a server behind it so it can do server-side rendering (SSR)... but how do you do that if you don't have a server?

It turns out you can wire up Nuxt 3's server (Nitro) to a Firebase function and you're good to go!

This is my deployment script:

![](/2022/11/image-2.png)

This is my `firebase.json` file, which I'm using for a test site currently:

![](/2022/11/image-3.png)

These two things together will create a function called `server` at Firebase, which exists to serve my site. That means I can create a full server API in my Nuxt app and run the whole thing virtually free on Firebase.

Wild!

## Interested? Let Me Know!

I'm writing up a full walkthrough of everything I did and I'm getting really close to being done... with the book part at least. I'm also creating a video that I'll be hosting [on my blog](%5F%5FGHOST%5FURL%5F%5F/) for my subs.

If you want to see something in particular, I'd love to know. Feel free to drop me an email (rob@bigmachine.io) or [ping me on Mastodon](https://mastodon.social/@robconery).

Hope this was helpful! 