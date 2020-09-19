---
layout: post
title: Hello Minty
date: "2013-11-19"
uuid: "24d45d15-8b60-43a7-91c6-c7aec1960495"
slug: "hello-minty"
image: /img/Minty_Fresh_Vector.png
categories: Node
---

## My Boss Wants Me To Build This Node App...
I get quite a few emails like this - all centering on a single question:

> I need to build a Node app for work and I know Javascript OK and I understand Node pretty well - how do you put all of this together?

That's a very, very good question - **one that I've been obsessing on for over a year**.

So, doing what I do, 18 months ago I started building a Node app - specifically an ecommerce store - with the sole purpose of exploring various ways of structuring a Node app for the long run.

I must have scrapped and rebooted about 12 times (no, not exaggerating) until I finally hit on something that has really worked well for me.

I leaned on my experience with .NET and ASP.NET MVC, working with Ruby on Rails for the last 6 years and finally the things I've picked up with Node over the last 2. And then I sort of **rammed them all together**.

Anyway - to the point: I love learning in the open so I thought I'd build something that I need: **a developer's blog**. Yeah yeah I know but it's a learning exercise and if it comes to something than yay! Otherwise you get to watch me fail spectacularly...

## What About...?

[Ghost](http://ghost.org)? There's a bit of a story here so let's get it out of the way up-front. I don't like the idea of going off and rebuilding what another group of devs is already trying to build - I'd much rather help out an existing project.

So I did. Well, _I tried_. I've really been concentrating on how I write this next sentence because I truly and sincerely don't want to sound like an a**hole. I want them to succeed and do well - but I don't think we're seeing things in the same way.

Ghost is written like Wordpress: a large "PHP-style" app with an architectural approach that embraces global settings and an all-encompassing plugin/theming model. 

I find Node to be much more elegant than a typical "all-in-one framework" model (Rails/ASP.NET MVC/Django). You plugin what you need, when you need it and no more. I like this because it helps you scale your development nicely - and there's so much that NPM can do for you!

Anyway I had a few interactions with the Ghost team and I did just about everything wrong while trying to do things right - there's just no way to politely suggest a large refactor like that - even if you do offer to do it all yourself. Sigh.

No, I don't know everything. No, I'm not dismissing anyone. What I am trying to do here is **show you what I've learned and listen to what you think about it** - even if you tell me you think it sucks (just tell me why).

I'm going to build something I've wanted to build forever (in fact I started building it a year ago and got sidetracked): a semi-static blog that is built specifically for developers. Yes, a blog. I know. But it's a learning exercise so... who knows what will happen.

## One Thing
Enough preamble - let's get started! I'm building a simple pimple application - and that sentence right there should scare me :). A blog engine should be simple but there are so many concerns - it's overwhelming!

_Which is precisely why we're going to focus on one thing at a time_.

When thinking about a blog and what it does - well you can break it into a number of smaller parts:

 - The CMS Bits (Articles, versioning, etc)
 - The Web/CSS (Serving pages, look and feel)
 - The Admin site (dig it)
 - API stuff (RSS etc)
 
That's how I would break it out, at least.

First things first: let's create a project directory:

```
mkdir minty
```

In here we'll create some subdirectories to hold our modules (more on this in a second):

``` 
cd minty
mkdir minty-cms
mkdir minty-web
mkdir minty-admin
mkdir minty-api
```

Each of these will be a node module. That's the punchline. Which I spose is boring... let's write some code to see how this all goes together.

## Containment
Node modules are different then rubygems and library projects in .NET. They're organized a bit differently, are more portable, and you can do a hell of a lot more with them.

Let's work with minty-cms first:

```
cd minty-cms
```

This is an empty directory - let's turn it into a Node module! This is a fairly simple process (I'm using the Vim editor here - use whichever one floats your plane):

```
vim package.json
```

That's our module manifest - congratulations! We have a Node module... well almost. Let's fix it up a bit (using your favorite editor):

```javascript
{
	"name" : "minty-cms",
    "author" : "You!",
    "description" : "Fun with Node modules",
    "version" : "0.0.1"
}
```

Save that - and you're good to go. Don't forget the version in there as that's how NPM (Node's Package Manager) will know how to load your module.

OK, let's do some work:

```
vim index.js
```

Now, with index.js open let's do say hello:

```javascript
console.log("Well hello there fine people!");
```

Now run this:

```
cd ..
node minty-cms
```

You should see your message! There's more to do so let's just get right to it without the looooong explanation - all of this will become apparent as we go along.

Move back into our directory:

```
cd minty-cms
```

Now let's install some things (you might need to sudo this depending on your setup):

```
npm install mocha -g
npm install should --save-dev
```

You should see some stuff flying by on your console. These commands are installing node modules _just like the one you wrote above_ right into our project. If you look in the minty-cms directory, you should now see a "node_modules" directory.

You should see one module in there: _should_. The other one (mocha) used the `-g` flag, which means install it globally.

What did we do? We installed a test framework (mocha) and an assertion library to use with it (should). So let's use it!

Let's make a test directory and write a test : (again I'm using Vim - use whatever works):

```
mkdir test
vim test/first_test.js
```

In our first_test.js file, let's write a mocha test:

```javascript
//use the should module by requiring it...
var should = require("should");

describe("My First Test", function(){
	it("is really fun!", function(){
    	"1".should.equal("1");
    });
});
```

Huzzah! Now let's run it:

```
mocha
```

Mocha will scan your current directory and look for one called "test", then it will scan each file in there and look for tests to run - you should see something that says "1 test passes".

Let's make it prettier by giving mocha some options:

```
echo "--reporter spec" > test/mocha.opts
mocha
```

How's that look now? Pretty? 

## The Basic Module Structure I Use

We now have a dedicated place to write our tests, and these tests are isolated to our cms module - which means they'll run quickly and we won't get confused sifting through a sea of them.

Let's do a bit more with our module manifest - I don't want to run mocha directly every time and I want to be a bit more idiomatic about this - let's _lean on NPM_ - this is something I'll be saying a lot as time goes on.

```javascript
{
	"name" : "minty-cms",
    "author" : "You!",
    "description" : "Fun with Node modules",
    "version" : "0.0.1",
    "scripts" : {
    	"test" : "mocha -w"
    }
}
```

You can script NPM right through your package.json file - to see this just use `npm --help` and you'll see all the commands you can hook into. We'll get to more of those later on.

Let's fill out the rest of our module's structure:

```
mkdir lib
mkdir models
touch README.md
touch LICENSE
touch .gitignore
```

Now, open up .gitignore and let's be sure to ignore a number of things:

```
.idea
.DS_Store
node_modules
data
*.swp
*.swo
*.db
```

These are annoying files or things in general we don't want. Primary of these, though, is the "node_modules" bit: _we do not want to be saving these_. Our package.json file manages this for us - and npm will isntall this stuff when it installs our module. This is scary magic, but it's amazingly wonderful.

I'll go into all of that over this series.

This structure is fairly common though many people just stick everything into the lib directory. I like to separate things - things I can model (like Product, Customer, Article) go into models and processes (like Checkout, Registration) go into lib.

Also it's considered good manners to have a README markdown file here with what your module is and why it exists - same with a LICENSE (though it's not necessary).

## Overkill?
At first this can look like overkill - but when we start filling out our specs and writing our api code... it will become sweetness.

That part is coming up in part 2...

<div id="disqus_thread"></div>
<script type="text/javascript">
        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
        var disqus_shortname = 'wekeroad'; // required: replace example with your forum shortname

        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
</script>

