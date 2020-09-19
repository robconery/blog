---
layout: post
title: "Should I Trust Firebase? Of Course Not!"
image: 'firebase/pants_fire.jpg'
comments: false
categories: Firebase
summary: "Let's address the elephant in the room: Should you trust a service like Firebase to handle your business? Not unless you want your pants on fire(base)!"
---

In the last post I discussed my initial foray into the serverless thing, and why going with other platforms (AWS Lambda, Webtask.io, etc) didn't make sense at the time.

I've received a number of comments since then, specifically about [this post](https://startupsventurecapital.com/firebase-costs-increased-by-7-000-81dc0a27271d) which details how one company had their costs jacked up by Firebase 7000%:

>Due to a change in how they report data usage, our monthly costs for Firebase, a SaaS provided by Google, has increased from $25 a month to what is now moving towards the $2,000 mark — with no changes to our actual data use. This change was made without warning.

The question was a simple one: *how can I possibly trust my business to a company that would do this sort of thing?* My answer, in most cases is simple: **you shouldn't**. Not now, not ever.

Let's dive into this.

## A Quick Summary Of This (and Every Other) Service Dissapointment

There are a number of problems discussed in the post referenced above, but they basically distill thus:

 - The startup (HomeAutomation) was doing IoT stuff and had a **query going off once a minute from all of their distributed devices**. The query was small (a flag check) and when the company checked their bandwidth usage they were within the limits of their $25/month plan which let them push 20 gigs of data per month (which is a hell of a lot).
 - **Firebase realized they had a bug in their bandwidth measurements**: they weren't accounting for the SSL payload. They fixed this in March/April of 2017. This fix caused HomeAutomation's bill to go up by 7000%.
 - **HomeAutomation could not fix this problem** without going offline and changing their app entirely. Given that it's IoT, this basically means going out of business.
 - **Firebase was not responsive** and it took a blog post to push them to (rightly) credit costs that were not foreseeable nor accountable. They have corrected it, but the customer service hit here is really, really bad.

No one looks good in this. Yes, Firebase did something dumb. I've been trying to find the right words to express my thoughts correctly, and I think I've hit on one:

> Duh

Firebase (and therefore Google) are Big Companies. They're in this to make money and if you're getting by on $25/month for a large distributed IoT system then yes, *something is probably wrong*.

I know that it sounds like I'm about to blame the developer for trying to plan for something that they had no actual metric to plan for it with. This is true, Firebase wasn't telling them accurate information, but as they say in Hawaii...

## Akamai!

I don't trust many people. I don't trust *any* businesses either. One company I used promised "unlimited bandwidth" until I soaked up 4Tb in a single month and they tried to charge me, saying "it was unreasonable for you to do that". Sure, whatever, lates.

I'm ready to jump ship with any service/platform on a moment's notice. I'm almost *too ready* as a matter of fact and routinely need to get pulled off the ceiling by peers. I'm SaaS trigger happy I guess. 

I could fill this entire post with the different companies that have let me down over the last 2 years, doing shady things and trying to overcharge me. Other's have [simply disappeared](https://twitter.com/userapp_io/status/770596364937932800) without telling people. While fun (for me), I don't want to derail this post too much.

Let me just summarize this way: *if something seems just too good to be true, expect a nasty surprise*. 

![Surprise!](/img/firebase/joker.jpg)


Paying $25/month pushing 10s of gigs of data over the wire fits that description.

## Coding For The Future

Pardon me while I climb the stairs to my Ivory Tower... ahh the view is nice from here! I can see the past in perfect 20/20 clarity...

When you write software applications it's usually a good idea to have a look at what other people have done before you. This situation could have been mitigated/avoided by embracing a simple sentiment that my friend [Rob Sullivan](http://datachomp.com) stated quite elegantly once in a talk he gave at NDC Oslo:

>Change hurts when you write bad code, doesn't it?

Developers in the previous decades have learned the hard way that hitching your wagon to *any* particular dependency, and betting your entire business on it *will always be a bad thing*. This goes for services, frameworks, and even the people themselves.

HomeAutomation seems to have just found this out, as this was one of their summary points:

> Always build your architecture in a way that will avoid becoming trapped into a specific service. Build your application in a way that swapping one service for another is as simple as possible.

**You have come correct** sir. Writing apps is indeed hard and takes some forethought.

## So, Should You Trust Firebase?

No. **Don't "trust" anything**. As a developer you're not allowed to "trust" any language, service, platform or other coder for that matter. Most of all: **you're not even allowed to "trust" yourself**. In short *trust has nothing to do with creating software*.

Firebase is a service that you can use with a reasonable amount of confidence. It can help you get your app out quickly and, hopefully, if you need to change something later on then you should be able to do that!

I know, I know: Ivory Tower Dev wagging Ivory Finger. But *hoooonnnneeessstlllyyyyyyyyyy* do we have to keep learning this lesson again and again?

At the very least - if your app is pushing 10s of gigs of data per day, don't you think it's reasonable to ask the question:

>"Are you sure we only have to pay $25/month"

This would scare me. It should scare you too! Here's the really scary part: *even if they built their app to handle a complete service change, they would have been in serious trouble anyway*.

Let's say they made it easy to move their system to AWS, for instance. They're in business to make money too, as it turns out, and if you're pushing 10's of gigs of data *per day* (or in HomeAutomation's case, 100s of gigs of data though they didn't know it at the time) you will have to pay for that. $2000/month is not unheard of for this.

I am going to be extremely curious what happens to this company in the next few months. No excuses for Firebase here either... this was a complete mess on all sides.

Which means you and I have to build defensive systems with interchangeable parts... because **change sucks** no matter what you do.

I've been using Firebase for 3 years total now, for very small things compared to HomeAutomation. I like what I've seen and so far I'm happy. This doesn't mean you will be, nor does it mean that I will be in a year or so.

I'm expecting that. You should be too.

---

## [See this series as a video](https://goo.gl/yCliXG)

Watch how I built a serverless ecommerce site using Firebase. Over 3 hours of tightly-edited video, getting into the weeds with Firebase. We'll use the realtime database, storage, auth, and yes, functions. I'll also integrate Drip for user management. I detest foo/bar/hello-world demos; I want to see what's really possible. That's what this video is.


