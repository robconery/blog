---
layout: post
title: "Writing A Book Is Frustratingly Addictive"
image: 'goldizalgo.jpg'
comments: false
categories: Writing
summary: "I want to love this process... I ... want to ..."
---

I really enjoyed writing [The Imposter's Handbook](https://bigmachine.io/products/the-imposters-handbook/), as well as making the videos. I can say that *now* because it's done with and the human mind has an amazing ability to cull things negative.

So, naturally, I'm doing it again.

I have a fun idea for my next little project. Once again it will be a book/video thing, but this time I'm going to let my creative side run free. It's the only way I can deal with the subject matter: *Node and ES6*.

Yes, I know. There a quite a few books out there, but none like what I have in mind. I'll write a bit more about it at another time (when the idea is a bit more shaped), for now I can tell you that it involves my fictional aerospace company (Red:4), the August 2017 eclipse, lasers and the moon.

I have a newsletter signup thingy at the bottom of the post if you want to sign up. I promise I won't spam you :).

A number of people have asked if there will be a "volume 2" to the Imposter's Handbook and yes, indeed, I am actively researching it. The first one took me 18 months to "finish", this one will likely be the same. There are a few things I want to do in the interim however...

## Goldilocks And The Three EBook Formats

Here's the thing: **formatting an ebook is like trying to give five cats a bath** (that's seriously the closest analogy I can come up with). Trying to have parity between formats is a pointless, wet, cold, and scratchy exercise... and no one is ever happy. Especially your cats.

There are three main formats you have to provide if you want to make *anyone* happy:

 - **epub**. An open standard used by quite a few ereaders. It's based on HTML, CSS and some XML and, just like the web technologies its built on, there are multiple "standards" you can build to (versions 2 or 3 are significantly different). You can create a book with pixel-perfect placement, or you can do a traditional "reflowable" book that is basically easier to read.
 - **PDF**. You know what PDF is. Read it anywhere on pretty much anything. You lose some of the bells and whistles that an ereader provides, but you can do fun things like "stamping" which imprints the name of the buyer on the book. It's the most usable and versatile format, which is likely why no one wants to use it for books.
 - **mobi**. This is the proprietary Kindle format and *it makes me want to scream every time I have to deal with it*. There are quite a few different Kindle formats out there, so when you build your ebook file for the Kindle (using Kindlegen from Amazon) it will *create a version for every Kindle out there*. The mobi size for The Imposter's Handbook was 1.5G. *Exciting times*.

I have spent months and months trying to figure this out. I've used all kinds of writing and conversion tools (which I'll describe below), but the closest I've come to parity between formats is...

 1. Create the best epub book you can, formatted as you like.
 1. Use [Calibre](https://calibre-ebook.com) to convert from epub to PDF/mobi. Give it the time it needs as you'll be twiddling all kinds of settings to get your margins *just so*.
 1. Set your mobi output to the Kindle Paperwhite (in Calibre). This (for me) covered most of my Kindle customers well enough, and the ones who had a different reader (the Fire, for instance) could use the PDF
 1. Use images for code samples.

That last point there? Number 4? That's a big deal. You see - no matter what you do, the fonts you choose will be obliterated by the ereader. These things want to show books the way *they* want to show them and your formatting be damned.

If you really care about the way the code reads, snap a screenshot. The downside is the book gets rather large... 

I'm getting ahead of myself. Let's talk about...

## The Actual Writing Process

I've been through every editor and writing tool you can think of. Please trust me on this, as I know you're gearing up to "have you tried X" and yes, I swear to you I have. Yes, them too. YES THAT ONE TOO.

It's quite sad how many editors I've tried... and given up on. Let's go through a small subset of my choices - the rest you can assume *simply sucked* for writing a book. It's hard! Books need a bit more than just regular old long-form writing tools. Yes you can *get by* with Word, but seriously it's a major pain in the ass to structure that many words and keep track of everything properly.

Anyway, here's what I've been using.

### iBooks Author

It's what I finally settled on and what I'm using for the next book. Overall it's giving me what I want: a great looking book, a nice writing experience and a reasonable structure. 

### Pros
The first is easy! **It's free**, but you have to have a Mac. You can create two kinds of epubs: standard reflowable and pixel-perfect "picture book" style. If you choose the reflowable option you can export your work in epub format, if you choose the pixel-perfect style you get PDF or `.ibooks` format.

Styling, layout, etc work like most editors you've probably used and the built in templates make it incredibly easy to get off the ground quickly.

If you have code examples, you can copy and "Paste and Retain Style" easily. With some small formatting tweaks you can have your code look *almost exact*, which is great.

It comes with a built in glossary, so if you need a quick reference for words and terms you got it. It also has a number of "widgets", like picture galleries and popups - you can even embed HTML! This is neat, but only people with iPads and sophisticated epub readers will be able to take advantage.

#### Cons
The format you write in is dictated by the export you need. If you choose the regular epub format, that's all you can export to, there is no PDF export for some stupid reason. If you choose to have a pretty, well-formatted epub 3 book, you can export to PDF but **without any TOC or navigatable outline**. This makes the PDF basically unusable.

The whole epub 3 thing is kind of a joke as other readers can read these epub 3 books just fine, but you can't export to them and Calibre won't convert them the way you want.

Fonts. There easy to use and set up, and you will be tempted to use all kinds of funky ones that will get blown away in the conversion process, or just scrubbed over completely when the reader loads your file. This is especially true for code! The best way around this is to use screenshots, but that inflates the size of your book dramatically and can also change the way your book reads. They also look crappy in "night mode".
 
### Scrivener
I love this tool, it's the best one I've found for writing. I've gotten to know it very, very well and messed with the compiler settings well into the night on multiple occasions. 

#### Pros
There is no tool out there that helps you organize your thoughts, do research and sketch scenes/chapters like Scrivener. It is quite simply the best.

Tons of helpful utilities, like a scratchpad, research folder, breaking big pages into little sections.

Easy to use to get up to speed.

Will export to PDF, mobi, reflowable epub, manuscript (for paper books) and a few other formats.

#### Cons
Formatting. My GOD this is so FRUSTRATING! Scrivener splits the writing process into two buckets: text and formatting. Which you would *think* would work well, but it doesn't because you get the choice to format your text during the writing process *and* during the compilation process, when all of your lovely text is assembled into whatever format you want to use.

Twiddling. So. Much. Twiddling! All kinds of settings and tweaking this, nudging that to get the layout to look *reasonable*. Not stellar, mind you, just *reasonable*. You can setup the compiler for each different format you need: epub, PDF or mobi. I put this as a "con" because you need to spend time with each setting to get it to show the way you want. **And it's never right**.

Styles. There are style presets you can use, "blockquote" for example. If you set some block quotes and then continue writing, but on page 200 decide "you know these look horrible let's change them", changing the style setting does *nothing*. You have to go back and tweak each one by hand. I have no idea why this decision was made.

Overall frustration. *I want to love this writing tool*. I've used it for years, but mostly for smaller things so formatting and other things didn't really bother me. It's so well done and the utilities you're given are incredibly well thought-out... but the rest of it makes me want to scream (and I have, on many occasions).

### Adobe InDesign
I gave this thing three solid days on two different occasions. Each time I kept thinking "wow this is amazingly great/horrible".

#### Pros
You can export to any format, reliably, and it looks great. There are tons of resources out there that show you how to create some interesting books, too. epub 2, 3, mobi, PDF - it's easy to use.

Drawing tools built in! That's pretty neat, especially if you're doing an epub 3 book and want things to look nice. [Take a look at this book](http://sunnibrown.com/doodlerevolution/) and you'll see what I mean. Sunni Brown (the author) used InDesign for it and was able to weave some interesting fonts together with her drawings and generated line sets - it works *really well*.

It's affordable. If you have an Adobe license you can add it in there (or maybe you already have it); if not it's only $24/month.

#### Cons
It's Adobe. You have to install their crappy crapware tool and deal with their emails. If you have Adobe stuff already this isn't going to ruin your day... I don't and I didn't enjoy the experience.

It's Adobe. Buttons, knobs, settings buried in settings within boxes on top of panels within other boxes and panels. The icons were indecipherable to me, but if you're an Adobe person already maybe you'll get it. Seriously: *you can't use this thing without taking a class first*. Not hyperbolic here, [it's the main reason I keep a Lynda sub](https://www.lynda.com/InDesign-training-tutorials/233-0.html) - learning tools like this one.

It's Adobe. Usability is out the window in terms of the act of writing. That's not what you do with InDesign, you *design* a book. Which is fine! Unless you're writing a book.

### Leanpub, Softcover, Gitbook, Static Sites (like Middleman) and Every Other Service You're Going To Suggest...
I used both Gitbook and Softcover for The Imposter's Handbook and they worked OK. For the most part it was nice to work in a text editor with Markdown.

#### Pros
Markdown is very simple to use, and Softcover and Leanpub have their own flavors of it so you can do some extra things. Softcover, for example, allows you to use LaTeX for math equations right in the markdown, which I did a lot.

Structure. It's nice the way these tools apply structure to your writing. Figures have numbers as do your chapters. 

Additional Services. If you want to publish and sell your book through them, these services will let you! This is a nice addon if you're doing this as a side thing. Leanpub is especially good at this.

Formatting. I used Softcover for the latest versions of The Imposter's Handbook and tweaking the CSS was pretty easy to do. I was also able to add my own formatting blocks. It wasn't easy, but it was doable.

#### Cons
Yak Shaving. Setting up Softcover involves Ruby, the Softcover gem and some additional programs. Softcover helps you with this by checking to see if you have what's required:

```
$ softcover check
Checking Softcover dependencies...
Checking for LaTeX...         Found
Checking for ImageMagick...   Found
Checking for Node.js...       Found
Checking for PhantomJS...     Found
Checking for Inkscape...      Found
Checking for Calibre...       Found
Checking for KindleGen...     Found
Checking for Java...          Found
Checking for EpubCheck...     Found
All dependencies satisfied.
```

These aren't small additions to your system. LaTeX is gigantic and there's a bug in the latest release of Inkscape which doesn't work with Softcover... and you only discover that when your math equations aren't showing up in PDF format.

Buggy. All of these tools work *for the most part*, until they don't. It could be for a number of reasons, but when you're using node and ruby to "build" a book, there *will be problems* because you're not using a unified toolset, rather a collection of smaller tools that will have dependencies that don't work right. I've come to a bit of a detente with Softcover: *it works, so I don't touch it*. This is after spending quite a few nights trying to figure out why equations weren't showing up at all in certain formats of the book. [The PDF version still has problems](https://github.com/imposters-handbook/feedback/issues/207) and to fix it, I need to debug Softcover. This is a pain in the ass.

Formatting. These toolsets were built by developers to create technical books, which is fine. If this is all you're creating then they might work fine for you. I like to make things look pretty and it's kind of hard. I got close with Middleman and the [Elixir book I wrote](https://bigmachine.io/products/take-off-with-elixir/), but just like Softcover I've had to deal with formatting issues.

### Ulysses, Bear, Ai Writer, And Every Other Writing App You'll Suggest
These things look GREAT, but once again fall completely short when it comes to structuring and formatting your book the way you want. I keep coming back to this: *these tools are great for certain things*, but not everything I need.

Yes, Goldilocks. That's me! And I'm OK with that. I want things to look and read a very certain way because technical books can be disastrously boring slogs; I want to create something more. 

For example: Ulysses allows you to embed code using their weird code block markdown syntax... but there's no highlighting. Which means it's pointless. Same with Bear and Ai. You also can't "Paste and Retain Style" because you're using markdown... frustration!

## Onward! Let's Write This Thing...

So that was the last 2 years of my life :). Figuring out how to write the book I want, realizing I probably want just a bit too much. 

For now, I'll stick with iBooks Author and hope for the best. I'll share what I'm doing as I go, and I'll send out email updates if you're interested. You can sign up here, if you want, and I promise I won't spam you:

<form class="ui form" action="https://www.getdrip.com/forms/17123094/submissions" method="post" data-drip-embedded-form="17123094">
  <h3 data-drip-attribute="headline">Node/ES6 Newsletter</h3>
  <div class="ui action input">
    <input type="text" name="fields[email]" value="" placeholder="Email address">
    <button class="ui teal right labeled icon button">
      <i class="envelope icon"></i>
      Sign Me Up!
    </button>
  </div>
</form>

