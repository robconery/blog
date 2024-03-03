---
title: My Writing Process (This Week)
date: '2018-01-12'
image: /img/typewriter-801921_1280.jpg
layout: post
summary: "Writing a book is fun and can easily consume you. Just like writing software, however, if the tools get in your way, writing becomes a chore."
categories:
  - Postgres
  - Writing
---

The first book I wrote on my own ([The Imposter’s Handbook](https://bigmachine.io/products/the-imposters-handbook)) was written in 5 different applications:

- iBooks Author
- Gitbook
- Scrivener
- Middleman (blogging app)
- Softcover (from Michael Hartl)
- Back to Scrivener

Why did I move so much? Simple: _formatting_. Each of these apps/platforms does things that the others do not. Some have outstanding WYSIWYG capabilities (such as iBooks Author) but _blow_ when it comes to code layout. Others (Softcover and Gitbook) are great at that but confine you to their structure.

With [my latest book](https://bigmachine.io/products/a-curious-moon), however, I think I have it figured out. Someone asked me about this on Twitter so I figured I’d dust off my blog and put it down in some detail.

## Scrivener

![img-alternative-text](/img/1515811760.png)

When it comes to assembling your thoughts and structuring your manuscript, there is nothing that beats Scrivener. The functionality it gives you is astounding, and you can write little snippets or big hunks - its all up to you.

It successfully detaches the idea of text from presentation. You can kick up a manuscript and then compile it for various outputs such as epub, mobi, docx, and pdf. The compiler takes time to get used to, but once you do you can have a _serviceable_ book.

By "serviceable" I mean the text will show on screen as well as the images, and if you're lucky maybe some fonts will show up. I played with the compiler for days (literally), trying to get my epub layout flow the way I wanted. Line height, title leading, first paragraph non-indent… all of this is tricky or non-existent with Scrivener.

It's not Scrivener’s fault really. It’s not designed to do this stuff and, moreover, epub is really just some whacky HTML under the hood. You would _think_ that my being a web programmer would mean I could get in there and do some twiddling which is sort of true. Scrivener has opened up the CSS completely to people who understand it, but … it just doesn’t do what’s needed.

Which is fine! Scrivener is good at structuring long-form text. No need to ask it to do much else!

## Proofing and Grammar

Scrivener has some decent spell checking and grammar checking but it doesn’t come close to the power of Word. I actually started writing A Curious Moon using Word, but that quickly became annoying for long-form needs. You could write an entire book inside of Word and it would handle it, but try finding a given passage or sentence… painful.

Yes, yes it’s _possible_ but when you’re flying around between sections, you want some metadata to help you out, which is what Scrivener is amazing at. For the best of both worlds, you can export from Scrivener directly into Word, which is just what I did. I then plugged in my new favorite thing: [Grammarly](https://www.grammarly.com). In fact, I'm using it right now to edit this post :).

![img-alternative-text](/img/1515811820.png)

I paid for a year without thinking twice and then installed the Word plugin (which only works on Windows). I had it do its thing and YIKES! I make a lot of mistakes when I write!

For 3 days I went through and checked the _thousands_ (yes, literally) of mistakes caught by Grammarly. It's not perfect, and sometimes would offer a correction and then correct the correction, GOTO 0. That's OK, it found a ton of stuff.

## Editing

Your book is only as good as your editor. My wife bought me Stephen King’s amazing memoir called _[On Writing](https://www.goodreads.com/book/show/10569.On_Writing)_, and there are some great quotes, including:

> The road to hell is paved with adverbs. Kill your darlings, kill your darlings, even when it breaks your egocentric little scribbler’s heart, kill your darlings.

And, my favorite:

> In many cases when a reader puts a story aside because it 'got boring,' the boredom arose because the writer grew enchanted with his powers of description and lost sight of his priority, which is to keep the ball rolling.

Writing is lonely, and I think writers go a little crazy during the process. That’s why there are editors and editors are like producers for hit songs: they _squeeze the amazing out of it_.

I was going to go with Upwork on this one, there are a lot of editors there for a reasonable price, but I got lucky that a friend of mine has some insane literary skills _and_ she’s a PostgreSQL DBA.

I popped the chapters out as PDFs and loaded them into Dropbox where she was able to use their online editor to leave comments, which worked perfectly. Yes, I could have done all of this in Google Docs, but this worked great.

## Design and Formatting

Finally, we come to the pain. I’m very driven by formatting and presentation. The things I make don’t need to look overly fancy, I just want them to look (as Steve Jobs once said about the iPhone) _like you could lick it_. Pixel-precision makes people like what they’re looking at.

![](https://blog.bigmachine.io/img/indesign.png)

For that, I took my edited final draft and loaded it into Adobe’s InDesign. I had to take 4 (seriously: 4) classes from Lynda.com to figure how this thing worked, but once I got it down it was off to the races. Yes, I could have farmed this out to Upwork too but I’m kind of a nut about this stuff.

It’s not perfect, but it’s good enough. Once output, I put the epub (reflowable epub 3.0) into Calibre so I can create a Kindle version (KF8). Kindle people always have problems no matter what I do which is because of Kindle’s use proprietary garbage instead of standard epub, but… I won’t get started on that.

That’s it!
