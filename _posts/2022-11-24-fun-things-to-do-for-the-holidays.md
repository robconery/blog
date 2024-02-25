---
layout: post
title: "Fun Geeky Things To Do For the Holidays"
image: "https:/img.unsplash.com/photo-1502519144081-acca18599776?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMTc3M3wwfDF8c2VhcmNofDIxfHxkYW5jZXxlbnwwfHx8fDE2NjkzMjY5OTk&ixlib=rb-4.0.3&q=80&w=2000"
date: "Thu Nov 24 2022 22:18:52 GMT-0800 (Pacific Standard Time)"
categories: null
summary: I love nerding out over the holidays and today was no exception. I added a feature to my blog that I've wanted to add forever!      
---

Hope you're having a great holiday season and if you celebrate Thanksgiving, which is today, I hope you're 1) having a wonderful time with friends and family and 2) **have something queued up to occupy your time**!

I'm having a great day - it's the first Thanksgiving I've spent on my own and **I love it**. I know that many people might think this would be a sad thing, but far from it. You can really focus on the things you're grateful for! _If you're curious: almost everyone I know came down with COVID so all my plans went out the window... which is OK because..._

## There's Nothing More Fun Than Coding During the Holidays!

Even if you work for yourself, which I've done for many years, there's something about **taking a break during the holidays** and focusing on _fun, nerdy stuff_. For instance: this site uses Ghost and I've always wanted to find a way to **turn Ghost into something that could host a video course**. Turns out, it's not that easy!

My first solution was to use Vimeo's "showcases", which is a bit of a janky JavaScript layer on top of their player. It works, but I don't care for it.

I then had the fun idea, since I'm polishing my book/videos on Vue 3, to **pop Vue into a custom template with Ghost**! It's just a page that I can dedicate, can't I?

## Experimenting With Vue and Ghost

It's... unfortunately not that easy, for a variety of reasons. The first is that Ghost's pages are written using Handlebars, which display templated content with the same delimiter as Vue: `{{stuff}}`.

You cat get around this in Vue by telling it to use something else:

```js
  Vue.createApp({
    delimiters: ["[[", "]]"],
    data(){
      return {
        videos: Vue.reactive([]),
        thisVideo: Vue.reactive(null),
        player: null
      }
    },
```

Here, I'm telling Vue to use square braces instead. This works pretty well, but then comes the next hurdle: **how do I know which videos to pull**? The custom template is just that - how's it going to know which video production I want to show?

The short answer is that I can use the slug of the URL, which means I have to pop that into JavaScript:

```html
<script>
  const slug="{{slug}}";
</script>
```

I've done worse. This will plant the slug serverside in a page variable so I can use it to query an API where my videos live. Fun times.

I have to use a bunch of `script` tags to pull in the libraries I want, which means I need to use Vue's `mounted` lifecycle hook to be sure the DOM is loaded with my script tags. 

Once all that's done, it's off to the races. I think it looks kind of nice, don't you?

![](/img/2022/11/bip_1235.jpg)

Currently, **I'm doing this for member-only stuff**, but if you want to see a list of the courses I [have you can have a look here.](%5F%5FGHOST%5FURL%5F%5F/tag/courses)

A fun way to spend a few hours on Thanksgiving morning - and I hope it improves the experience for everyone!

## This Site vs. Big Machine

I decided to loosen things up a bit and give myself a little "playground" where I can make all kinds of content. If you've bought stuff from me before, you might be wondering if anything is going to change - and no, it's certainly not. All the videos you see here are available to subscribers (paid), or you can still buy them individually on [Big Machine](https://bigmachine.io) if you want.

## And Finally: Here's Your Black Friday Discount

You didn't think I'd leave you hanging, did you? [I'm offering a 50% discount this holiday season](%5F%5FGHOST%5FURL%5F%5F/holiday) to this here site, which has every video I've made in the last few years - and I'm going to keep adding more.

As I mention, I'm wrapping up a 2 hour video "thing" with Vue/Nuxt 3.0 which I hope to get out the door in a few weeks. I also have plans for other fun things, like Firebase, Go and more.

I also write long-form premium posts for members too. Things that don't quite fit into a video. So sign up already!

[Sign Up for 50% Off](%5F%5FGHOST%5FURL%5F%5F/holiday)

Oh - and happy holidays!

**Rob**