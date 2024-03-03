---
layout: post
title: "Everyone Has a Plan, Until They Get Hit in the Face"
image: "/img/2023/04/bip_1822.jpg"
date: "Thu Apr 20 2023 19:45:16 GMT-0700 (Pacific Daylight Time)"
categories: frontend
summary: I spent almost 3 hours last weekend trying to figure out one of the most vexing problems I've ever faced, and I recorded all of it.      
---

That's a quote from Mike Tyson, who was paraphrasing another quote from a German military strategist:

> No battle plan survives contact with the enemy

Great quotes, which fit my experiences over the last week. You see, **I'm experimenting with a new format for online videos**, which I think will be interesting... but it requires a ton of patience. And a steel jaw.

In short: I've deployed the stack I'm working with (Vue, Pinia/Vuex, Nuxt, Nuxt Content (more recently), Vuetify and Nitro (also more recently)) 8 total times over the last 3 or so years. I've done this for myself (for online course stuff) and for Microsoft (internal projects). I enjoy it, I really do, but there are enough moving parts that **it's inevitable you're going to walk face-first into the right hook** of framework chaos.

If you don't know: Vue is a popular JavaScript frontend framework and Nuxt is the opinionated app framework built on top of it. Vuetify (the subject of this post) is a UX design framework (a bunch of components) that is tremendously useful for buidling complex UIs. I love these tools. I use them often. I dig pain.

That's what happened last weekend.

## My Idea: The Soap Opera Walkthrough

The video format I'm going for can best be described as "episodic walkthrough", or more directly: "coder soap opera". I'm _doing it live_, building a complete application from the ground up. **Less editing, more looking over my shoulder** as I build out something I know very well. You gain real-world experience and **see exactly how someone with their livelihood on the line actually builds things.**

That last bit is very important. This _is not a to-do list, DVD rental app or a blog_. This is an [actual site that I have deployed](https://vue.bigmachine.io) to make customers happy. It's a complicated thing, as anyone knows who has tried to watch a tutorial video and translate it into the Real World: to-do lists can only take you so far, which isn't that far at all.

I've made a lot of these things. **I know the mistakes, the wrong assumptions, the shortcuts and the tricks to use to actually get working software out the door.** I think that's a lot more valuable than rehashing concepts you can read from the documentation.

If all goes well, you'll end up with something that looks like this, which is a real, working site that I deployed a few months ago:

![](https://blog.bigmachine.io/img/2023/04/bip_1798.jpg)

That's the plan, anyway. But then again...

> Everyone has a plan until they get hit in the face.

**It took 9 episodes for things to go completely pear-shaped**, which they did, in spectacular fashion. This wasn't a simple bug that I had to hunt down (and there were many of those) - this was a full-stop, critical bug that I had no idea how to fix.

## WTAF?

As I mention I'm 9 episodes in - around the 3.5 hour mark - and Vuetify landed a beauty right on my chin:

![](https://blog.bigmachine.io/img/2023/04/bip_1813-1.jpg)

What you're seeing here is the menu bar for a video course viewer (the app I'm making), with the last two icons (discussions and GitHub link) being repeated. More than that - the first four icons are shoved to the left about 180 pixels... _for no apparent reason_.

The console had some generic Vue warnings regarding a "hydration mismatch" which are common and happen if you have invalid HTML, among other things. This is what it looks like:

![](https://blog.bigmachine.io/img/2023/04/bip_1762.jpg)

A most annoying Vue error

But I don't have invalid HTML. Not that I could tell, anyway. I'm using bare-bones Vuetify, which is designed to "just work" and, moreover, I don't have any tricky `if` statements or loops that would cause things to duplicate like they are.

## Yes, I Found the Answer (I think)

I tried recording a debug session but 45 minutes in I was swearing far more than I wanted to and generating what I consider to be pointless content: me, trying anything and everything to make something happen. In other words: _completely thrashing_. You don't want to see that.

During one of the thrashing moments I decided to change the way I was outputting the links

![](https://blog.bigmachine.io/img/2023/04/image.png)

Vuetify in action

All of that `v-` stuff is Vuetify, specifically buttons and icons that have prebuilt styling. It looks great, when it works! Anyway - when I removed the `v-button` everything lined up, like magic:

![](https://blog.bigmachine.io/img/2023/04/image-1.png)

This is what it should look like.

Which told me there was something weird going on with regards to the DOM and my buttons. But there's more! As you can see from the problem screenshot, where things are repeated (scroll up a few screenshots) - _only two buttons were repeated_, not the whole lot!

This was a clue!

![](https://blog.bigmachine.io/img/2023/04/image-2.png)

**The repeated bits have dynamic links** which come from Pinia, the state store. The non-repeated bits have hard-coded values from the `href` tags, which you can tell because of the `:href` notation using the prepended colon.

If you write larger applications using a frontend framework it's generally a good idea to keep your reactive data (stuff that changes or is needed in more than one place) in a centralized store. That's what Pinia is for Vue.

There are three parts to a Pinia store: the _state_ (aka reactive data), the _actions_ (methods that mutate state) and _getters_ (computed, read-only functions). Here's what my state looks like:

![](https://blog.bigmachine.io/img/2023/04/image-3.png)

The variable we care about here is `course`, which as you can see is defaulted to an empty object. I load up the course using an action called `setCourse`:

![](https://blog.bigmachine.io/img/2023/04/image-4.png)

I'm at the wireframing stage of development, which is why you see `stub` here - it's just fake data to get us off the ground. But the big realization came with the way I was setting `course`, which is outlined in red.

## Respect the Reactive

Pinia will automatically wrap any variable declared in the `state` block as `reactive`, which is a special Vue function that turns ordinary JavaScript objects into little evented bits capable of notifying the application if they change (aka "reactive"). 

The problem here was simple, and also annoying as I had run into this before and didn't remember as I was recording! **If you replace the state variable entirely, you blow up reactivity**. Here, I'm reassigning `this.course`, which you can do with Pinia and things will still remain reactive. Vuetify, however, doesn't see it this way. The first `course` value does not equal the second `course` value so **it helpfully adds a second element to the DOM for you.**

Makes sense, I suppose. Would be nice if it popped a warning about that but it would also be nice if I could play better and remember things.

The fix becomes straightforward at this point:

![](https://blog.bigmachine.io/img/2023/04/image-5.png)

The fix

**If you're going to wholesale replace a bit of state, make sure you use** `Object.assign`, which will graft one object's values onto another.

Once I did this, everything just worked!

## Is This Valuable?

I'm going to assume that it is because **if watching this saved you the 3 hours I lost (not to mention the frustration and very real possibility of giving up on Vuetify altogether) then yes, I think there's value here**.

Vuetify is easy to swear at but if you know it's quirks, it's incredibly powerful. You can prop up an amazing site in a weekend - but yeah you need to know the particulars.

That's why I'm making these videos, which are supposed to go along with the book I just finished the first draft of. **The conceptual stuff goes in the book, the Real World stuff goes into the soap opera videos**.

Specifically: I want to walk through building an application with the above components, but I also want to show how I would integrate Stripe (payment processor) as well as a full API using a tool like Sequelize. I want to show how I test these things (using Playwright) and also do simple authentication.

That's a tall order, to be sure, but it becomes more doable if I follow the soap opera idea: light editing to keep a good pace, play-by-play, etc. Probably the longest video I'll ever make - I'm up to 3.5 hours already and I'm barely 1/3 of the way through!

I would love to know if this is interesting for you, or if you have any suggestions. You can leave a comment if you like (you have to be logged in) - would love to hear from you!

Hope this post saved someone a few hours...