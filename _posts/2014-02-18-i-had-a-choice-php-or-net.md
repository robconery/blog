---
layout: post
title: 'PHP or ASP.NET: Did I Do The Right Thing?'
image: '/img/Waybackmachine3.png'
comments: false
categories: Opinion
summary: In 2001 I had a choice to switch to PHP or learn ASP.NET. I did the latter, and I'm wondering if that was a good idea.
---

## It Was 2001, and I Had a Decision To Make

Imagine if you could go back and rebase your technical career. What pivotal moments would you change? In 2001 I was cofounder of a pretty successful web consultancy and we did everything with Classic ASP, which was pretty hot shit at the time. We were a Microsoft shop and damn proud of it! But...

I had played with early versions of .NET and utterly hated it. I hated Visual Studio, I didn't know C#, and VB.Net was kind of a joke. I remember sitting on the Oakland/SF Ferry determined to get the basics of ASP.NET to work and I remember thinking to myself:

> How fucking hard do you need to make this?

I got to work that day (2nd and Brannan, 3rd floor) and sat with my cofounder and told him .NET had "gone off the rails". He laughed a bit and we had a long talk about the future of our firm, and my future technically.

I knew Classic ASP, IIS, SQL Server, Windows NT/2000 - I knew what to do with these things. I didn't know Linux or MySQL but I knew from the code I'd seen that this "new" framework was basically a copy of Classic ASP but with some love for MySQL and Apache.

I could get to know this, and it would be a challenge but it would be fun. I loved learning then like I love learning now - I'll just go buy the books and I'll be good to go in a month or so!

But then again, we had paying clients we couldn't abandon and I needed to service them now and into the future. Learning a new platform would be hard - especially if our clients found out because we basically sold them on Microsoft (the needle tears a hole... that old familiar sting...). 

**This might seem like an obvious choice** - "go with what you know". The trouble is that "what I knew" didn't translate very well to .NET. No matter what happened, I would need to learn a new language and framework.

## It Was Microsoft's World

![MVP Baby](/img/MVP.png)

You have to keep in mind that in 2001 it was a very Microsoft world. Big sites were built with Linux/Java and if you were in Silicon Valley and told people you were a Microsoft developer, you got laughed at (which is still true today, of course, but has spread a bit...).

Outside of Silicon Valley in corporate America (as well as up and coming businesses) - Microsoft was the answer. These companies were already investing in Microsoft with Windows and Office - and now they needed websites. There was no anti-Microsoft bias here, in fact it was just the opposite.

Unfortunately for me (after my consultancy went belly-up with the bubble) I worked at a startup in "The Valley" who's entire infrastructure was Open Source/Java/Emacs/Eclipse and I was the lone Microsoft guy brought in to work with a premiere client who was all Microsoft.

**Their dev team would take weeks** to make a small change to the client website - I would be done in a matter of hours using SQL Server and Classic ASP. **They could laugh all they wanted to, but I gave the client results that they loved**.

This is why I chose to stay with Microsoft and become a .NET developer. More than that, I was hell-bent on becoming a Microsoft Certified Developer (which I did!). Ultimately I became a Microsoft MVP which, at the time, **I thought meant that I had made it**.

It's easy to laugh at now, but if you were there, at the time, working in the peer group that I worked in - **the MVP was everything**. Go ahead and ask your .NET friends - they'll tell you...

## And Then This Happened

![ODS ... Oh Dear Shiva!](/img/ods.gif)


<blockquote class="twitter-tweet" lang="en"><p>Can’t use EF because ObjectDataSource won’t bind to DataList!</p>&mdash; Rob Conery (@robconery) <a href="https://twitter.com/robconery/statuses/435907090373435392">February 18, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

I tweeted this today, but it's [still a question on many ASP.NET Developer's minds](http://blogs.msdn.com/b/mvpawardprogram/archive/2014/01/06/using-objectdatasource-with-asp-net-listview-for-entity-framework-6.aspx). This is not a parody, by the way, this is the Microsoft Developer Network site.

This is a summary of my development career up until I decided I'd had enough and branched out to do other things. 

From 2002 up to 2008 or so the Microsoft web world was (and to a large degree still is) all about "Visual Component Development". What that means is you **basically do a lot of drag and drop** and let the components do the work for you (write HTML, hookup server code, CSS, etc).

This goes for form fields all the way down to "Data Sources" which were mapped bits of XML that crawled up through the keyboard, into your fingernails and turned your soul into black muculent ooze.

It never felt right, but I stayed with it. No... seriously don't ask me why.

## And Then This Happened Too

In 2008 I started to play with Rails and I fell in love, instantly. No, this isn't a prelude to "and I never looked back" - far from it. Rails helped me to see **what a complete echo chamber I had been living in**. HTML and CSS weren't scary (as they were to ASP.NET developers) and code was your friend.

In the .NET world, up to that point, we dealt with Code-behind and Server Components and the most skilled developers could write an app with as little code-behind as possible. Somehow in the evolution of this fucking mess **we became the exact opposite of what we were supposed to be: Web Developers**.

All of this came down around me and I remember thinking that "Yes, indeed I'm am D-O-N-E with .NET". But after letting that emotion wash over me, I came to my senses.

> What if I could pick apart the things I like about Rails and bring them back to ASP.NET?

That's when I started SubSonic (my ActiveRecord-inspired ORM) and I even tried 5 different ways of creating an MVC framework specifically for .NET! I liked C# and the market for MS products was pretty big - **why do we need to rely on Redmond for how we build on their stack?**.

This shaped my career for the next 5 years or so. I was branded an "trouble-maker", "pot-stirrer", "complainer" and generally regarded as a troll. Perhaps I deserve a bit of that - the role of "change agent" was new to me (as was Twitter) so ... yeah I think my PR skills could have been better.

That's off-topic (but still relevant). What I really want to know is...

## What If I Didn't?

The thing that is bringing this all up for me today is that I once again was asked to look at a [Ghost Blog](http://github.com/tryghost) module (as part of a random discussion) and it was still written entirely like a PHP application in Node.

This made me wonder: "If I stayed with PHP, would I be writing Node apps this way too?" I would have seen the web through a scripter's eyes and miss out on some of the "higher concepts" I've learned as a .NET dev - so it's natural to think that yes, I would be writing Node this way.

Which of course begs the question **do I write Node apps like a .NET developer?**.

Probably, a bit. I know I wrote Ruby apps that way... and is it such a bad thing? Which influence would I rather have distorting my Node code?

I know I would have learned a lot more Linux/MySQL and I'm sure I would have been involved in some interesting Open Source as I was with .NET. I also know I probably would have fallen in love with Rails and tried to pull some of the Rails goodness back to PHP and ... yeah.

It's likely that history would be aligned here, but **one major thing would be different: I wouldn't have lost 5 years in the mess that was ASP.NET.** I think it's also fair to say that I would:

 - Know Linux a whole lot better
 - Be very familiar with MySQL and other Open databases
 - Be less scared of Javascript then I was 4 years ago
 - Be less reliant on an IDE
 - Love HTML and CSS

This is the one shining negative here: .NET stunted my knowledge of HTML/CSS/Javascript. I don't need to tell you how important these things are and will always be.

In addition I became used to "Visual Tools" and still fight this every day. I'm used to a tree view of tables in my database and files in my web project. Visual Development is burned into my brain! GAH!

## On The Other Hand

It might just be that my frustration when I finally did jump into the Rails world fired me up to learn as much as I could. That fire remains with me - and is the inspiration for this post. To borrow from Lewis Black:

> If it weren't for my horse, I wouldn't have spent that year in college

<iframe width="560" height="315" src="//www.youtube.com/embed/sJ0s0KUUpxo" frameborder="0" allowfullscreen></iframe>

My horse was ASP.NET.

