---
layout: post
title: "The Easiest Postgres Experience You've Ever Seen"
image: "https:/images.unsplash.com/photo-1475869568365-7b6051b1e030"
date: "Mon Nov 21 2022 20:38:03 GMT-0800 (Pacific Standard Time)"
categories: postgres
summary: Web Assembly is enabling people to do some crazy stuff in the browser, including running a full PostgreSQL installation and Adobe Photoshop!      
---

A few months ago my friend [**Craig Kerstiens**](https://twitter.com/craigkerstiens) decided to see what's possible with Web Assembly, the thing that runs Code That's Not JavaScript in the browser. If you're a Microsoft dev, you might have heard of Blazor, which compiles C# code to Web Assembly which then gets handed to the browser to run in-process.

It turns out that people are taking Web Assembly pretty seriously, including Adobe, which [compiled PhotoShop and Acrobat to Web Assembly](https://web.dev/ps-on-the-web/) so you could run it in the browser!

![](https://blog.bigmachine.io/img/2022/11/image-8.png)

Image from https://web.dev/ps-on-the-web/

Love the image of the elephant... which reminds me... this post is mostly about Postgres, so let's get back to Craig's story...

## Using Web Assembly Entirely the Wrong Way

Craig cofounded a company named [Crunchy Data](https://www.crunchydata.com/) which is focused on proper running and hosting of PostgreSQL databases in the cloud. Or, as I like to think of it: _Postgres done right_.

Anyway, the story goes like this: **Joey Mezzacappa**, a Crunchy engineer, was reading a blog post about "[runnable Markdown examples](https://wasmer.io/posts/markdown-playgrounds-powered-by-wasm)" from a company named _Wasmer_. The example that caught his eye had to do with a SQL query running in SQLite:

> There was one in particular that _really_ got my attention: [SQLite](https://wapm.io/sqlite/sqlite). On that page, there is a fenced code block with some SQL queries inside. If you click the "Run in Playground" button, it runs the query right there in the web browser with SQLite compiled to WebAssembly.

That's impressive. Being a Postgres person, his next thought was completely natural:

> After running that SQLite query in my browser, I thought, "Can I do this with Postgres?"

It turns out that no, you can't run PostgreSQL like that in the browser. SQLite is unique in the database world as it's a little C binary that creates an _embedded_ database (meaning "just a file on disk"). It doesn't need to access internal "system stuff" like Postgres does, so compiling it to Web Assembly was a straightforward proposition.

That's how Web Assembly works: _it's just a compilation target_ in the same way you might target Windows, ARM processors, 32-bit Linux and more. If you compile something to Web Assembly, you can run it in a browser.

## What If I Just...

That's where Joey decided compilation rules didn't apply to him, nor to Postgres:

> ... the modern web browser is a very powerful platform. Let's just change the target platform to something other than WebAssembly, then run it in WebAssembly anyway like a rebel. 😎... It's actually possible to emulate a PC _inside the web browser_! There have been quite a few implementations over the years... I ended up choosing v86 for this... 

Long story short: Joey setup an Alpine Linux virtual machine running Postgres and shoved it into a VM emulator using Web Assembly, **[and it worked](https://wasmer.io/posts/markdown-playgrounds-powered-by-wasm)**.

![](/2022/11/image-4.png)

If you click the link above to the [Postgres Playground](https://wasmer.io/posts/markdown-playgrounds-powered-by-wasm)'s `psql` tutorial, you'll see this exact page along with some commands to help you get to know the powerful Postgres binary.

That's Postgres running in your browser. Not on the cloud somewhere: **_right in your browser_ in a VM emulator**.

I think that's fascinating. But it doesn't stop there.

## Craig's Easter Egg

One of the things you'll notice in the output above is that it's pulling in a SQL file for the tutorials, which is a single table named `weather`:

![](/2022/11/image-5.png)

This is fine, of course, if you want to learn `psql` and just need a simple dataset. But the thrill of the moment is indeed _momentary_ as working with data you don't know and don't necessarily care about can provide an undewhelming experience. Craig knew this so decided to **give people the ability to load a SQL file of their own**.

That seems like a very, very bad idea doesn't it? **Talk about a massive security risk**! But then again: this server is running in your browser. You close the tab or navigate away and it's gone! So why not?

It just so happened that, at the very same time as Craig was announcing this on Twitter, I was creating my free ebook: _[The Little SQL Book](https://bigmachine.io/little-sql-book/)._ I wrote this book because I know a lot of people who want to learn SQL but yawn right out of it, so I went in search of a data set that many people could relate to. 

I chose Fantasy Football (American Football, that is). Many leagues were going through their drafts and so I decided to share what I had done in the past with Postgres, sifting/querying past league data looking for trends. I know football isn't everyone's jam but hey, you gotta start somewhere don't ya?

Anyway: Craig asked me for my data set [and next thing I know](https://www.crunchydata.com/developers/playground?sql=https://gist.githubusercontent.com/craigkerstiens/2297d5fce53832a73c975e94e6a7f0c8/raw/7d858bdb9ecd8bd1445425fa948197b655804e31/ff.sql)...

![](/2022/11/image-6.png)

The PSQL Playground for The Little SQL Book

![](/2022/11/image-7.png)

**Craig had added the ability to append a `sql` querystring key which points to a public SQL file**. That public SQL file is actually a [GitHub gist](https://gist.githubusercontent.com/craigkerstiens/2297d5fce53832a73c975e94e6a7f0c8/raw/7d858bdb9ecd8bd1445425fa948197b655804e31/ff.sql) which has all the SQL my readers need to get started.

Think on that! This is a book about learning SQL and Postgres in particular. Normally there would be an installation/setup/yak-shaving phase before we get started but not with this option! You just click a link and you're off and running in the browser.

I think that's one of the neatest things I've ever seen! Hats off to Craig and Joey for putting this all together.

## Web Assembly is Coming...

We work in an industry that is in a constant state of hype and disruption so distrust is natural. I first heard of Web Assembly years ago when I saw [Steve Sanderson's first demo of Blazor at NDC Oslo](https://www.youtube.com/watch?v=uW-Kk7Qpv5U). I thought it was interesting and I also love the idea that maybe, someday, we could get away from using JavaScript to create browser applications.

That last bit is happening with the rise of TypeScript, but I'm not too sure about the first bit. I'll be honest and say that using something like C#, Go, or Rust (the current "main" players in the WASM world) on the browser feels like overkill to me. I like the idea of a "scripting" approach because it keeps things simple... but then again frontend applications aren't growing simpler, are they?

So I'm sitting on the fence, waiting to see what happens in the frontend space. The _backend space_, however, is grabbing my attention.

Web Assembly is making a similar migration as JavaScript did with Node: it's moving from the browser to the server. This is fascinating to me for a variety of reasons, primarily because Web Assembly is _fast_ and it's also very lightweight. Unlike Docker, **Web Assembly can be run as a binary**. This means that **you don't need to have a base installation of Linux just to have your service run - it can be executed like any other binary application** on your system.

Think of your "services" as pure code living in subdirectories of a main project. Your root directory might have some kind of manifest and your individual services could be written in any language that can be compiled to WASM. Once compiled, you would have a set of binaries that could be run anywhere WASM could be run.

Web Assembly in the browser is completely sandboxed so writing full service-based applications is still something that's being worked out, which is where [WASI](https://hacks.mozilla.org/2019/03/standardizing-wasi-a-webassembly-system-interface/) comes in:

> WebAssembly is an assembly language for a conceptual machine, not a physical one. This is why it can be run across a variety of different machine architectures... Just as WebAssembly is an assembly language for a conceptual machine, WebAssembly needs a system interface for a conceptual operating system, not any single operating system. This way, it can be run across all different OSs... This is what WASI is — a system interface for the WebAssembly platform.

I think this is exciting!