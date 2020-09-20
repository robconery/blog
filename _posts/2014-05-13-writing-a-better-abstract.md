---
layout: post
title: 'Writing a Better Abstract'
image: '/img/write-better-abstract.jpg'
comments: false
categories: Opinion Speaking
summary: "I get asked rather often by friends if I wouldn't mind reviewing abstracts they've put together for submission to various conferences. This usually happens after they've been rejected. I'm not a Master Speaker by any stretch - but one thing I know how to do is to craft a compelling abstract. I offered to review an abstract for a friend today - as long as he let me blog it... so here goes.."
---

## Channeling Dexter

The first thing that any abstract needs to do is connect with the potential audience. This is hard, especially when you're dealing with some ultra-technical stuff. 

Let's start with a success. My friend [Rob Sullivan](http://datachomp.com) wanted to speak at NDC Oslo last year (my absolute favorite conference on the planet) and sent me this note:

> I'm having a little trouble getting my thoughts in order for 1 of my NDC abstracts-

> **How to Murder Your SQL Server and Get Away With It:**

>_Is .NET without SQL Server possible? Not only is it possible, it is cheaper, faster and more liberating to do so. Using Redis and postgres we will be murdering our SQL Server in the most loving way possible. Who knows, by the end we may even find ourselves not even needing Windows._

From this I could tell that Rob wanted to be edgy - really edgy. Rob is/was a SQL Server DBA who just fell in love with Postgres and wanted to share this with his audience by, essentially, trolling them. Rob's sense of humor is pretty... dry and definitely a bit "in your face" - but that doesn't come through at all in the abstract above. 

His complaint was spot-on: his thoughts were a bit jumbled and his humor wasn't coming through. So we exchanged a few emails and he said something that completely put a picture in my head:

> The talk itself is sort of Dexter like with references to the Dark Passenger and needing to find justice for the app...

Wow. What an image. Next thing I knew, I was writing - taking [the monologue from Dexter's opening](https://www.youtube.com/watch?v=HDVZuqRuAYs) and bending it around a bit:

> **How to Murder Your SQL Server and Get Away With It:**

> It's come to this: tonight's the night. All the waiting, the deadlocks, corruption of tempdb and devastating abuse to innocent SQL Statements… tonight's the night I let my Dark Passenger roam free and solve… finally solve this problem that plagues developers the world over: **SQL Server**.

> There it sits, pretending… just like me. Pretending to love my data and be an upstanding citizen of our development group. All the while… in the dark, fetid reaches of it's kernel it's silently plotting. Soaking up RAM and carefully laying licensing traps that will suck the blood from our company… But not this time.

> This time I won't let it - and I have a plan. I won't do it alone - I'll bring in my trusty friend Postgres to confront SQL Server and force it to see the evil thing it's become for developers. And when the time is right, and SQL Server is strapped to the table begging to be set free, I'll pull out my favorite weapon of choice… shiny, simple, sharp and brilliant: Redis. 

> And I'll send it straight into SQL Server's heart once and for all.

This is SO OVER THE TOP but I can totally hear Rob's voice in it - **and it gives me a sense of what the talk will be about**: Alternatives to SQL Server. And I'll probably be entertained by some shock value.

Rob's talk was accepted with some very slight tweaks to this abstract, and the room was packed. One of the best talks I went to - Rob is a pro.

## Solve A Problem, Answer a Question. Above All: Entertain

You don't need to sing and dance to entertain. In a Good Talk, someone will come away having learned something - which is always a fun thing to do. In a Great Talk, they'll come away smiling, happier then when they went in - remembering some of your quotes or slides, telling their friends how good the talk was.

Always remember: **people want you to be great**. This is mostly for selfish reasons because everyone wants to have been in "that talk" where the presenter just nailed it.

And it all starts with the title and abstract of your talk. Walking the conference halls or sitting in the hotel in the morning - people will have their schedules open on their phones (or in their hands) looking for a talk to go to. They're looking for a name and failing that, a title/subject that sounds interesting.

Read Rob's title and abstract above. Would you choose that over Yet Another Talk About JavaScript? I sure would.

## Stay Focused, Tell Me What You're Going To Say

I got an email today from my friend [Anders Ljusberg](http://twitter.com/codinginsomnia) asking for a bit of help with a failed submission. He felt his abstract might have been a bit boring, or maybe didn't convey everything in his talk correctly. I asked if I could help by blogging about it (as I've been meaning to blog about this) and he said "YES!".

Anders then gave me this background:

> The talk I submitted to Øredev is about CQRS and what I've learned so far by working with it for the past few years. I suppose one problem may be that it's not as "hip" of a subject as it was three years ago but I'm quite sure there are plenty of attendees out there who'd be interested in the topic if I could sell it to them.. :)

Yep. I'd be one of them. Here's his title/abstract:

> **Commands, Events, Views and everything in-between**

> CQRS and Event Sourcing. When you see it in theory it looks quite easy, doesn't it? You just need some Command Handlers, an Aggregate Root, a few View Builders and then you're done!

> Well, obviously there's the Event Store too. Probably a Service Bus. And let's not forget the NoSQL database. Oh did I mention that many businesses prefer it if there are redundant servers that handle the load? And that a View Builder generally doesn't like it when you update the same model simultaneously from two different instances? But at least you're certain that the messages going through your Service Bus are consumed in the order they were published, right..?

> In this session I will take you through some of the gotchas I've run into when implementing CQRS based systems and show you how you can handle them. Expect some diagrams, expect code, and definitely expect a demo with plenty of moving parts.

From this I can say that **I have no idea what this talk is actually about**. Here's why

 - The title says CQRS, but the abstract tosses a lot of jargon around
 - There are leading questions in there without any resolution, assuming that I might somehow understand what the point is.
 - The last sentence makes the talk sound like a bit of a variety show: some dancing, some singing, and a juggling cat

The abstract also suffers a bit from Anders sense of humor not really coming through: "_You know about this thing, right? And this other thing, right? Well, obviously..._" This can come off as pedantic and condescending unless you know the speaker - and I have to be honest - reading this abstract in the hotel room in the morning... I'd be hard-pressed to go (but I know Anders so I probably would).

How can we fix this up?

Anders point is that there's a lot to know about CQRS and that initially it can be a simple thing to think about. But, like most of programming, there are problems to deal with under certain circumstances (scaling, client demands, etc).

Let's focus this talk by telling the audience what it's about, and what problem we're going to solve. I always like to use a bit of humor if the talk will be humorous - if you're not a funny person then make sure your abstract is straightforward. Anders is a funny person so let's have the title mirror his personality. We'll start with 3 takes and see what happens:

 - **Everyone's Got a Plan Until They Get Hit: My Adventures Working With CQRS Everyday Over the Last Four Years**. A famous line from Mike Tyson - so true - and it echoes the idea of theory vs. reality and "this is what I've learned".
 - **A Thousand Cuts of CQRS**. Echoes the idea of "experience through small, tiny bits of pain".
 - **Taking the Service Bus To the Event Store, and Other Bad CQRS Puns**. Some people like puns - a bit of a weaker title but if your goal is to talk about jargon and you like puns... there's a lot you could do here with your slides.

OK, we have some working titles. If you have spoken before and you think your talk will be accepted - maybe go a bit more risky. If you've never been to this conference, or you're a bit newer to speaking, maybe go a bit less risky. 

Anders says this of his experience:

> I'm fairly new to speaking. Have done a couple of local conferences in Sweden and some user groups. Got accepted at NDC Oslo last year which is the biggest one I've done so far. I tend to get reviews that range from OK to good, but not glowing.

Given this, I'd say to choose the first title. It's clearer and has a nice hook. Now we need to do the hard thing - write the abstract that will set the hook from the Tyson quote. Expect to write this 3-5 times and **show it to friends before you send it in**.

Some simple rules:

 - Never assume people know what you're talking about (ie: don't use jargon)
 - Tell people the problems you'll solve and/or the questions you'll answer
 - Tell people who you are and why you're there

Let's keep this abstract straightforward. CQRS is a tough subject, but we're narrowing it down to the idea of Adventures and What Can Go Wrong - always a fun talk to go see:

> Command/Query Responsibility Separation (CQRS) is an interesting way to architect larger software systems. It's also a great tool for shrinking your ego as it comes with some unique pitfalls that aren't apparent from the start. I've been working with CQRS continually for the last four years building a system that handles millions of transactions per hour and CQRS has helped tremendously - but it's also brought me to tears. In this talk I'll show you how I failed - and then solved - some very unique problems that come from scaling a large system using CQRS.

Reading this over - I think it's a pretty good start... at least I can say I'm much more interested in this talk then I was before. I don't know Anders' particulars but I think he can take an outline like this and buff it out a bit - plugging in some details (like system size... people love that stuff) and maybe where he worked (is it a bank? Or maybe a large retail chain?)

Notice the arc of the paragraph as well: _Here's the subject that you may have heard about - it's not perfect. I've been using it for a long time and I like it, but it's also been difficult at times. I'll tell you why - and what I've learned_.

This is a classic storyline of the hero that travels to far-off lands, confronts dragons, and emerges victorious. Really - its that simple. Always remember you're the hero of your talk - maybe you're saving the empire, or you're meeting strangers in exotic lands.

The human brain has been conditioned over the last million or so years to learn at story time by the fire - so [get to know some basic story structures](http://en.wikipedia.org/wiki/Narrative_structure) and keep to that - in both your abstract **and** your talk. This will help people to follow you and your thoughts a little easier.

Good luck Anders!




