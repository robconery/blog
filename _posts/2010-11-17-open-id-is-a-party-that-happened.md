---
layout: post
title: Open ID Is A Nightmare
summary: "I've always been a major proponent of Open ID. I love the idea and the intention - it's a great solution to a long-standing problem and solves a lot of issues for developers. Unfortunately it creates a ton more for business owners."
date: "2010-11-17"
uuid: "a5C8eszm-Cmqw-K7WS-QvVb-QFUBRr5g9UBA"
slug: "open-id-is-a-party-that-happened"
categories: Opinion
---

## It Seemed Like Such a Great Idea


I know the first thing you're going to think: "StackOverflow seems to have worked it just fine". I said this very thing about 12 times over the last year as I pounded my head against my desk, wondering what I was missing. James then said to me "really? when's the last time you logged in?"

So I head over to Stackoverflow and login using the Open ID I use for everything - Google. And I'm met with this:

![](https://blog.bigmachine.io/img/so_openid.png)

James is laughing hysterically as I sputter... "What the FU**! You GOTTA be KIDDING me!" I don't have a ton of rep over there - but I spose it's enough to care about. In truth I haven't had to login over there in a very long time - I've just been really busy.

So I start going through the recovery process:

![](https://blog.bigmachine.io/img/so_openid_recover.png)

Problem is I have a few emails that I use - and if I didn't use my Google login (as I thought I did above) - I really have no idea which email it is. So I start rifling off all of my emails, waiting to see if SO would know who I am.

Honestly - I feel dumb about this. How could I possibly forget how I logged in? Also - how could I not know which emails are associated with which providers I setup? And hey WAIT A MINUTE, if Stackoverflow doesn't require email... well what if my provider didn't send it? I have a lot more to say about that, but let's get back on track.

As I sit there and grumble about emails and Open ID, Avery is in my ear saying "Dude you used a different provider". Not a chance - I don't have another Open ID as far as I can remember.

*Oh shit. Right.*

I remember that I once setup a MyOpenID account! That was years ago and I never use it ... but YES! It's coming back to me now... So I head over to MyOpenID and go to login and...

Yep, username/password and I have no idea what it is. I try 5 or so combinations and finally figure it out. And I login to StackOverflow. "At least Jeff doesn't charge money" I think. If he did, I have a feeling this feature would be gone.

And James is still laughing.

## Welcome To My Nightmare

I'm both a developer and a business owner. I care about the technology, I care about my users more. The story I relayed above happens about 3 to 5 times a week for people who are paying me money. People forget their Open ID - it happens a lot more than you would believe. And when they forget, I need to help them remember.

I search our database and find 4-5 entries for them (we let anyone login and create an account with their Open ID) - once they login they want to go watch a video. And all they see is that their account doesn't have a subscription anymore and they get pissed off, and have to contact me.

You never want to piss off your customer. You NEVER NEVER want to make them feel stupid. Both of those things are happening now: You have to gently remind them that they logged in with Twitter, Facebook AND Google and ... "do you remember which one you created the order with?". Eventually you solve the issue - but they remain upset.

I caused this problem. I caused it because I'm making it too hard for the user to get into the sight - and that's really where the story ends for me. I don't care why, honestly. They don't have a problem with username/password - they need to use that for their Open ID provider anyway.

Boil this down from a User's perspective:*User wants to watch a Tekpub flick, so they come to our site

 - User has to login, our Open ID system kicks them over to their provider
 - They enter the username/password for that system
 - They come back and they watch their flick (if they've remembered correctly)
 
As a developer I'm happy about this because I'm not storing credentials (which is a solved problem as far as I'm concerned). As a business owner I'm wondering why we need 4 steps to happiness. They enter their username/password anyway? What's the damn difference?

## Anatomy of a Authentication Nightmare

When we started Tekpub, it was with pure Open ID using a javascript Open ID selector. I liked it, it worked pretty well in the beginning. And then the complaints started rolling in...

People would login successfully once, pay for a subscription, then login later and the sub would be gone. Turns out that Yahoo and Google have a different idea about what Open ID is supposed to do - because the the Identifier used for these users would change based on... some voodoo (sorry, but that's all I can deduce).

All of a sudden Google (by far our most popular provider) would change the token (the encrypted value on the end of the Open ID) and boom - you're completely lost to us. We have no other way of knowing who you are - and more than once I've had to track people by their PayPal accounts (we track the transaction ids - which we can look up through PayPal to find out who you are).

This problem gets worse when Google allows you to engineer your own URL - which they did about a year ago.

To mitigate this issue I decide that we need to use the email instead of the identifier. Open ID providers don't have to provide an email - in fact about half of them don't (which is why, I think, Stackoverflow doesn't require one. They can't reliably get one using Open ID). Google is good about this, however - they always return the email.

When sending a request to a provider for a user's credentials (after they've logged in) - you have to structure a bit of an incantation based on conflicting standards to get additional information. There's all kinds of stuff you can ask for - name, address, gender, and yes - email. We asked - more often then not, we were denied.

So all was working well with Google - we were using the email to identify people. **And then they decided that UK folks would have their extension changed from "gmail.com" to "googlemail.com".**

*And just like that, we are on our asses again.*

## The Dumbest Decision I've Ever Made

The code for our Open ID responder is spiraling, with just about every conditional setting in there you can imagine for the various providers out there. I'll save you the grumbling rant, but coding up Open ID stuff is utterly mind-numbing frustration. And while I'm doing this, I'm not recording videos... creating product.

Then I read about JanRain and their service RPXNow. I'll jump on this and say that as far as service providers go - they have been just fine. Their service is generally up 99.999999% of the time, which is pretty outstanding for a SaS provider.

In addition they offer access to other providers: Facebook, Twitter, Wordpress, Yahoo... and they do all the "heavy lifting" for you in terms of understanding which standards incantation goes to which provider.

I plumbed it in, it worked immediately and I was stoked! And then all hell broke loose...

Let me just preface this by saying of all the failure points in your business - you really don't want the door to be locked while you stand behind the counter waiting for business. No, let me rephrase that: you don't want the door jammed shut, completely unopenable while your customers wait outside - irate that you won't let them in.

You don't want that ever. Not even once, not even for 10 seconds. We're very, very small and this kind of thing will sink us.

3 times the RPX people changed their API on us and our authentication system went down. We were able to fix it within 20 - 30 minutes each time; once, however, was at 5 in the morning.

RPX as a service has gone down 3 times in the last year. This last time (about 4 months ago) it was down for about 4 hours - effectively shutting our doors for us. This isn't a small provder - there are many, many, many businesses that rely on them to authenticate their users.

It happens. Services go down and we are patient. As a developer and user I need to learn how to say that. As a business owner you can go f*** yourself if you think I'll use you again.

## Rolling Your Own


I've thought about it - the problem is that we're committed now. RPX uses OAuth to talk to Twitter and some special sauce to talk to Facebook Connect. I'm not going to write that code - I'd rather deal with the outages.

Coding against the Open ID spec (and now OAuth) is utterly ridiculous. This is a dying standard, being dominated by one or two providers who change their minds as they see fit - taking the specs with them. I'm sure you recall when Windows Live got into the Open ID circus - playing by their own rules. Google retaliated doing the same.

I'm caught in the middle of this "user information warfare" as a business owner - and I choose not to fight. I choose to walk away, my finger in the air proudly shown to both of them.

## The Solution

Starting with our next release (coming in a few weeks) I'm weaving in a stronger presence for "traditional authentication". We already have the ability to sign up with username/password - but we're going to make that the *only* way to register for our site from now on.

If you want, you can add Open ID to it moving forward. But no longer will my business be closed because Open ID gets flakey. I also want you, as our customer, NOT to feel stupid when you can't remember your login.

I'm sure there are some who will defend Open ID and tell me all the ways I screwed up. Unless you own a business of your own, running behind Open ID, I truly don't want to hear about it. Put money on your decisions - put the customer first - and you change your tune.

A friend of mine was offering a ton of solutions to my Open ID woes over Skype the other day - insisting that it's worth "investing in for the long run - the kinks will get worked out". I sort of agree as a dev - as a business owner I couldn't give a rat's ass.

The best part? 5 days after our discussion, his custom Open ID provider crapped out - I don't know what happened (you can be your own provider if you like - it means a bit of code here and there but some people like the custom domains). He couldn't login to Tekpub... and I had to push his subscription over to a new account.

What a mess.