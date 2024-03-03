---
layout: post
title: "Writing, Editing and Formatting a Technical Ebook in 2021"
image: '/img/book_2021.jpeg'
summary: "I love writing. I also love editing my writing because it starts to take shape. The formatting process, however, gets me every time. Over the years, however, things have become easier so for 2021 here's my list of tools you can use."
categories:
  - Writing
---

This post could easily be 20,000 words... _there is just so much shit to wade through to get your book looking just so_. What do I mean? Here are my concerns, which are simple ones I think. I want:

 - **Fonts to be crisp and readable**, the line-heights appealing to the eye and perhaps a few flourishes here and there like a drop-cap or small-capped chapter intro
 - **Images to layout with proper spacing**, a title for accessibility and to be center-aligned
 - **Code samples to be formatted** with syntax highlighting
 - **Callouts** for ... callouts. Like a colored box with a title maybe.

Things like this are easy for word processing tools like Word or Pages but when it comes to digital publishing, not a chance.

I could fill up paragraphs but I won't. I'll just summarize by saying: **formatting ebooks is a massive pain**. Thankfully I've figured a few things out.

## Have You Tried?

Yes, I'm 99% sure I have. I've used:

 - **Scrivener** (and I love it). Great for writing, crap for formatting.
 - **Markdown** turned into HTML and then formatted with Calibre. Works great - I did this with _Take Off with Elixir_ and it looked amazing. Tweaking Calibre and hand-editing the CSS wasn't so fun, though.
 - Michael Hartl's [Softcover](https://softcover.io) which was _stellar_ at formatting things and looked great but the styling choices were lacking. There were ways to edit things but I'm not a LaTex person. Installation was complex but doable... overall I enjoyed this one the most.
 - A zillion others including **iAWriter, Bear, Ulysses, Pages/iBooksAuthor** and many others I'm forgetting.

I've written 5 books over the last 6 or so years and I'm currently writing 2 more (which I'll go into in a second). I swear to you I've tried just about everything.

When I wrote _[A Curious Moon](https://bigmachine.io/products/a-curious-moon/)_ I just went back to Word and decided to break the writing process up into two steps: **actual _writing_ and then _formatting_**. I knew this is what a lot of writers did, but my process of writing (constantly evolving, "living" ebooks) didn't lend itself to this. No matter - I can adapt.

It worked out pretty well, too. **I wrote everything in Word** and then hired an editor. Once editing was done I ported it to InDesign and spent weeks (literally) learning this massive tool.

It was worth it, I think, the book looks amazing...

![](https://blog.bigmachine.io/img/gravity_assist.jpg)

The Problem is that it's **laborious** and just killed my inspiration. Making edits, for instance, means I have to use InDesign's ultra crap word editor to fix things, which isn't fun.

Things get really exciting when InDesign bumps versions and everything is _completely wrecked_ because they changed the way images are resolved (which happened)...

OK, enough complaining! Here's where I'm at today, with a process I really like.

## Writing in 2021

In my [last post](/2021/04/06/turning-a-blog-into-a-book/) I mentioned that I was writing a book with [Troy Hunt](https://troyhunt.com). It's a fun project in which I'm:

 - Curating posts from his blog that I find interesting
 - Curating comments from those posts and adding them at the end (anonymously)
 - Pushing Troy to write retrospectives on these posts, giving some kind of backstory

Once again I decided to use Word and I wonder if that was the right decision. My thinking at the time was that Troy is a Windows person and I could use OneDrive to share the document with him so he could make comments.

There are problems with this, which include:

 - The **document is huge**. We're up to 800+ pages with quite a lot of images. Syncing this thing real time is kind of a bugger.
 - The **formatting looks horrendous** and trying to explain to Troy "yeah, nah mate I'll make it look good" is a bit hard. Especially when he replies "I already did that... have you seen my blog?" and I reply "yeah... ummm..."
 - **Troy writes in Australian** and uses words like "flavour", "favourite" and "whilst". Word's spell checker doesn't like that and YES I've reset it to Aussie English but it doesn't seem to make a difference. Red squiggles are everywhere!

These are interesting problems to solve! For Troy, his blog is **a done thing** so my formatting woes are a bit ridiculous. I completely understand this, and I think I blew it by pulling things into Word first.

### Writing From Scratch: Ulysses

This might come as a shock, but I find Ulysses to be, hands-down, the best writing experience I've ever had. In 2018 [my choice](https://rob.conery.io/2021/04/06/turning-a-blog-into-a-book/) was [Scrivener](https://www.literatureandlatte.com/scrivener/overview):

> When it comes to assembling your thoughts and structuring your manuscript, there is nothing that beats Scrivener. The functionality it gives you is astounding, and you can write little snippets or big hunks - its all up to you.

>It successfully detaches the idea of text from presentation. You can kick up a manuscript and then compile it for various outputs such as epub, mobi, docx, and pdf. The compiler takes time to get used to, but once you do you can have a **serviceable** book.

This is still true, the keyword being "serviceable". Writing in Scrivener is an engineer's dream as it focuses to completely on the _process_ of writing. The aesthetics of it, however, **suck** and you end up with something... _serviceable_:

> By “serviceable” I mean the text will show on screen as well as the images, and if you’re lucky maybe some fonts will show up. I played with the compiler for days (literally), trying to get my epub layout flow the way I wanted. Line height, title leading, first paragraph non-indent… all of this is tricky or non-existent with Scrivener.

Ulysses, on the other hand, is **pure markdown**:

![](https://blog.bigmachine.io/img/shot_718.jpg)

When you come from Word and Scrivener, this is _amazing_. I can't tell you how many times I have to drop into "invisibles" to correct some janky weird formatting/layout issue in both Word and Scrivener. Things get so utterly ugly that I have to stop writing to fix it, which really makes the writing process suck.

With Ulysses, however, I just write in Markdown and I'm a happy person. It's more than just a Markdown editor - it's also a _writer's friend_ with some amazing support tools. The one I really like is the "Review" feature, which loads up your current page to [Language Tool](https://languagetool.org/). It takes the feedback (which is free) and shows you where corrections are suggested. There are also ways to annotate your text and leave yourself comments, which I also love.

When I'm ready to preview how things will look, there's a preview button right there that shows my markdown directly in epub. This is fine, if you're OK with producing something that's... "serviceable". But that's not what I want with Troy's book.

## Formatting for 2021

There are two apps that will format a book to near pixel-perfection for EPub and PDF that don't come from Adobe and require a master's degree:

 - Apple Pages (which has absorbed iBooksAuthor)
 - [Vellum](https://vellum.pub)

Apple Pages will open up a Word document, read the styling, and immediately show you a 99% perfect recreation of your Word document. From that point you can start polishing things up and off you go. It really is a great bit of software, but, oddly, it *sucks* for writing. Not quite sure why.

The winner for me is Vellum. Check this out:

![](https://blog.bigmachine.io/img/shot_719.jpg)

I was able to send my text directly from Ulysses into Vellum and this is the formatting I saw. It is _perfect_. A downside with Vellum is that it doesn't support syntax highlighting which was one of my requirements :(. Another downside is that the export themes are _slightly_ customizable, but that's about it. I don't mind it - it keeps me from going nuts.

I'm OK with doing screenshots for code and then making sure the reader has a link to a GitHub repo with code in it - that's what I did for _A Curious Moon_ and it worked out fine. It also looks better and, let's be honest, no one is going to copy/paste code from an ebook - it's horrible!

The features in Vellum are tremendous and it's great for formatting a high-end ebook. It can't do all that InDesign does because InDesign is all about document designing. But I kind of like that - Vellum is focused on wonderful book formatting, putting the focus on your words and content, no more.


I think it will work really well for Troy's book - but **you tell me**.

## Live Streaming the Formatting Process

I'll be live streaming the formatting process with Troy on Monday, **April 12th at 2PM PDT**. We'll have a few chapters of our book open in Word and I'm going to pull them into Vellum to see what he thinks. If he doesn't like it, I'll pull the book into Apple Pages and see what I can put together there.

If he doesn't like _that_ I'll have to go back over to InDesign which isn't the worst thing in the world, but it's detailed enough that we'll have to do another full stream.

We'll also be discussing titles and cover ideas - so please join us! I would love to hear your thoughts. If you want to be updated on our progress [I created a mailing list](https://book.troyhunt.com) and we'll be sending out updates when they happen... maybe twice a week.