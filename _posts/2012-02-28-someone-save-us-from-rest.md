---
layout: post
title: Someone Save Us From REST
summary: "I made the mistake of publicly commenting on someone's idea of a RESTful API. And already - I've probably lost you. I don't know any single term more explosive and zeal-inducing than REST and \"what it means to be RESTful\". Oh - you say \"it's quite simple?\" You say \"what's so hard?\" Pedanticize away my pedantic pedant..."
image: "/img/2809.png"
date: "2012-02-28"
uuid: "NOVd0tf0-xvCA-YIOM-Kfjf-26ZxEsrdS4Dy"
slug: "someone-save-us-from-rest"
categories: Opinion
---

## ZOMG Did You Hear The News?!?!?!?

> **[PATCH is the new primary HTTP method for updates](http://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates)**. Think files, for example. If you upload a file to S3 at some URL, you want either to create the file at that URL or replace an existing file if there's one. That is PUT.

>Now let's say a web application has an Invoice model with a paid flag that indicates whether the invoice has been paid. How do you set that flag in a RESTful way? Submitting paid=1 via PUT to /invoices/:id does not conform to the semantics, because such request would not be sending a complete representation of the invoice for replacement.

Do you know who this is important to? **No one.** Well maybe except [this guy](https://github.com/rails/rails/issues/348) (from the Rails issue list): 

![](https://blog.bigmachine.io/img/Screen-Shot-2012-02-27-at-3.18.47-PM.png)

Can you imagine? **How in the hell did Rails make it this far without properly implementing PATCH?** 

As opposed to piling on to [the "Rails 3 Sucks" bandwagon](http://gilesbowkett.blogspot.com/2012/02/rails-went-off-rails-why-im-rebuilding.html) (which[ I don't think at all](http://wekeroad.com/2012/01/12/understanding-the-rails-asset-pipeline/) - I quite like it) **I'd like to openly ask the Rails team to [remember what got them here](http://rubyonrails.org/quotes)**.

Which, I daresay, was a bit of attitude and daring as well as the ability for the team to Give The Heismann to the Spec Police and Enterprise Engineers of the world.

![HEISMAN](/img/heismann.jpeg )

But as I say - **I'm not writing this to "Occupy Rails"** as it were and suggest that "we are the 99%" (even though we are... ) - no I'd rather look at some of the shockingly strange things that people do in the name of REST (like [push a verb change past 743 other issues in the list](https://github.com/rails/rails/issues)). 

**It's time to stop being afraid of the REST police.** 

![I find your lack of REST disturbing](/img/lackoffaith.png)

## Did You Just Make The Jump to l33tSpeed?

That's one of the most appalling things about any REST discussion. Otherwise interesting and intelligent people flip on the Pedantic Switch and decide that quotes and explanations (also known as [Appeal to Authority](http://en.wikipedia.org/wiki/Argument_from_authority)- see what I did there?) are the best way to explain something. 

Because it needs explaining. Because clearly you don't know REST.

**Did you know Rails 4 is *_finally_* using PATCH?**

Feeling Antsy? Should I bring up [Big O notatio](http://www.hanselman.com/blog/BackToBasicsBigONotationIssuesWithOlderNETCodeAndImprovingForLoopsWithLINQDeferredExecution.aspx)n or [P=NP](http://www.codinghorror.com/blog/2008/11/your-favorite-np-complete-cheat.html) to round out the douche-quotient here? Let me guess...

 - You've already formulated the first part of your comment - and how you're going to politely address what I don't know.
 - You want to help me - to explain what I don't know... to "enlighten" me with all that you've found out about REST and how it works.
 - You know a person who "really knows REST" that I should talk to if I'm confused.
 - You just went over to Wikipedia to brush up on definitions
 - You read that Wikipedia article for the first time in the last 6 months and, since it's fresh in your mind, feel rather clear on the concept so it's worth your time to "help me out".
 - You've written a REST API before and "do it every day" so you really understand it well.
 - You know Roy Fielding personally and helped him write his dissertation.
 - You just checked Wikipedia to see if it was Roy, or Ray - so as to point out just how in the dark I must be.

This was my experience last week. This has been my experience last year. This will continue to be my experience well into the future because REST is something everyone must know (like HTML5, CSS3 and CoffeeScript).

Yet they don't. Neither do you. Certainly I don't. We're all going to get sucked into the void without truly knowing what Fielding was trying to tell us... and in the end... there's only...![SOAPBOX](/img/soapbox_9.jpeg)

A Soapbox. Because it's not "knowable" even though I'm sure you really do know it. It's not a thing that two people will come together and agree upon but the conversations are always fun:

> Oh yes yes - that's a lovely example of a nice RESTful API: using HTTP verbs to operate on a resource represented by a unique URL... lovely

> Right, yes but it [doesn't support PATCH](https://github.com/rails/rails/issues/348) **and it's using Rails. Hardly RESTful...**

> Right, yes but - they really should be using CONNECT and TRACE with Node and dropping into a socket to really do REST the right way

> Right but oh no no no - CONNECT should really only be used with HTTPS and one shouldn't need to rely on a single framework to define their RESTful API. And moreover... are you trying to suggest that REST over HTTP has anything to do with WebSockets? Cause ummm....

> Right, yes but you just used Rails to say something is not RESTful did you not? May I not do the reverse? And WebSockets are a viable alternative then creaky old HTTP so why can't we discuss --

> Right, yes but in doing so your knuckles become that much closer to the ignorant ground. Clearly you haven't read [Section 6.3.3.1 in which Fielding clearly states](http://www.ics.uci.edu/~fielding/pubs/dissertation/evaluation.htm#sec_6_3) that the HTTP protocol, as it stands, is not enough to support high-performance concurrent connections and, in fact, proposes two new protocols: MGET and MHEAD which **deal more directly with MIME response** which is a much nicer implementation then --

>Right, YES BUT YOU should know that **MGET and MHEAD were REJECTED** because they VIOLATED many RESTful conditions - specifically that before a RESTful request could be made, the requestor would have to make all of its requests at ONCE because it wouldn't actually know the length of the request prior to sending and requests are bound by length and it's fundamentally --

>WELL ACTUALLY I understand that but you're not hearing me: Fielding never wrote this dissertation with WebSockets in mind and --

>DUH IDIOT YES OF COURSE HE DID HE KNEW IT WAS COMING**

>You presume to know the mind of Fielding**? Well then - that certainly puts us into clever territory! No one can presume to --

>RIGHT YES My dear fallacious, mouth-breathing idiot of a friend: my brother went to UC Irvine, where Fielding studied. I've read his dissertation's abstract at least 2 times. I know Fielding, sir, and you're no Fielding...**

>Right YES BUT...

<span style="font-size:80px">**AMIRITE?**</span>

## Blasphemy.

I'll come to the point: REST is a fascinating andilluminatingset of ideas and, as it turns out, is a handy guideline for effectively preparing an API. As it turns out - digging deep into what you think REST means runs the perils of digging deep into any religious philosophy: **adherence turns into devotion**.

I like REST like I like any [Religious Doctrine]. I dislike the people who drop Fielding Passages in some apostolic attempt to save my non-RESTful soul. **My relationship with REST is a personal one** and, frankly, I like to think REST guides me in my application development walk in the way Fielding intended for me, and my web app.

**I like to think that no one truly knows the mind of Fielding** and, even then, [his dissertation was written](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm) in the very ancient tongue of **12 year old internet technology. 12 YEARS!** How can we possibly think we understand, today, what Fielding was sharing back then?

> Isn't it possible that Fielding speaks to each of us? In his own way?

## No, Really
A good friend of mine is a Fielding devotee and he regularly will try to "help me out" with my apparent lack of devotion. I know I shouldn't answer the door when these people come knocking - but he was making the rounds and as I mention - he's a friend of mine.

He shows me some samples to read over - and against my will - I found myself drawn in.

**UPDATE** - turns out this was written by my friend Glenn Block. He [followed this post with one of his own](http://codebetter.com/glennblock/2012/02/28/why-are-there-2-controllers-in-the-asp-net-web-api-contactmanager-example-rest-has-nothing-to-with-it-2/), explaining why he did what he did.

And I asked the question. I shouldn't have. But I couldn't help it. The Controllers... there were two of them, and they had the same name, and their code was roughly the same...

![](https://blog.bigmachine.io/img/2012-02-27_1431.png)

I should have known I was doomed:

> Why are there two Controllers here - one singular, one plural?

And madness ensued.

## Well, Actually...
No seriously: **Madness**. My question about the Controllers in the above example came from **the standpoint of a developer, trying to understand what the application does**.  Two Controllers make no sense to me in a small application of this size.

Some suggested the developer saw the list of Contacts (dealt with in the pluralized controller) as a separate Resource... which means(?) an separate Controller.

Really?

And the defense of the the extra controller doubled back on itself ... and me as well:

>Controllers don't dictate REST anyway what's wrong with you!?!!

**What's wrong with me is that I have a dumb habit of asking questions.**

And a worse habit of asking more questions when the answers don't make any sense. Or are simply quotes and citations from a dissertation that's over 12 years old and has nothing to do with the Modern Web.

**Where have we come when the first headline of Rails 4 is a proclamation that "We're Using PATCH Instead of PUT!"** I can guarantee you that 95% of the audience had absolutely no knowledge of the PATCH verb prior to reading that passage.

And they promptly forgot about it when they navigated away.

<del>The developer who wrote those two Controllers will avidly defend them to me, citing Fielding and quoting Wikipedia.</del>

Glenn, as smart and amazing as he is, defends this practice by saying "a list of a resource is semantically different then a single resource - but this has nothing to do with REST".

But... you... I ... but... but...We will consume ourselves... slowly into RESTful Madness and ...

## Someday... this war's gonna end.

![He Comes](/img/zalgo___white_version_by_amindfuckingusername-d4ahwnj-1.png)

Admit it. *You think I don't know REST...*
