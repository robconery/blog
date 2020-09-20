---
layout: post
title: "Minty: The First Steps"
date: "2013-11-20"
uuid: "32a3951e-1473-4674-a4ca-0187535e1a3e"
slug: "minty-the-first-steps"
image: /img/baby_steps.jpg
categories: Node
---

## What Are We Doing?
I have an idea, now it's time to flesh it out. In a traditional setting you may have sat with "stakeholders" or clients and fleshed out some requirements - at least enough to get you started.

I have a clear idea of what I want to do overall - but again I'm focusing on the single "CMS" aspect  - creating, editing, tagging and versioning of things I write.

So how do you get started? I don't have an answer for everyone - but **this is how _I_ get started**.

## Break It On Down
I want this module to function well in isolation, and to do what it's supposed to do without worrying about my specific implementation (a blog engine).

That means I need to define the basics of what it means to deal with publication of content. This can spiral out of control, but let's start small so we can get something built. 

Here's what I need:

 - The notion of a blob of text that represents a coherent idea I want to share. I shall call it _Article_.
 - The Article will conform to what I use right now for my blog posts - this means it will have a body, summary, title, and tags.
 - When important changes happen, I want to have a version created
 - Each Article needs to have a way of tying directly to a URL (aka a "slug") and this needs to be unique.
 - Each Article needs to have a status (draft, published or offline) as well as a publication date
 
This _should_ be enough to get us started and to get our juices flowing. And up front: **I know this will change** and I'm embracing the idea that change will come, so I'm going to fashion my tests accordingly.

I also know that once I start this mental exercise, a metric-ton of "What-ifs" start pouring in RE caching, validations, etc. _We'll get there_ - what's important for me right now is to stare at the fact that we're dealing **only with the CMS** aspect of things, and we're trying to start somewhere.

So let's start.

## Spikes
I have a basic set of requirements, this next part is critical: _do I start spiking a model? Or do I write some specs?_

Sometimes I start spiking because you start to see various ways of doing things that might not be apparent later on.

For instance - I could write an Article "class" (which isn't really a class because JavaScript doesn't have this notion but it's close enough) and see what jogs my brain:

```javascript
var Article = function(args){
  this.title = args.title;
  this.summary = null;
  this.body = args.body;
  this.slug = args.slug;
  this.createdAt = args.createdAt || new Date();
  this.updatedAt = new Date();
  this.status = args.status || "draft";
  this.publishedAt = args.publishedAt || null;
}
```

It's a start, and again this is a spike as I want to see where my thoughts take me. Right away I think "I need an author" and "I need some tags" - so I can add those too... but how would this look in my model?

```javascript
var Article = function(args){
	//...
	this.tags = args.tags || [];
    this.author = args.author || {};

}
```

This is starting to look like a traditional document in a document database. I can go that route - using something like [NeDB (sqlite for Node/DocumentDBs)](https://github.com/louischatriot/nedb) and goof around... or I can use an actual sqlite3 backend.

Spikes can be incredibly important - they allow you to see what it is your idea is capable of - and offer you different ways of thinking and maybe even help you to expand your vision.

So what would a sqlite (or any relational) backend look like? And what benefits would it offer?

One project I like a lot is [Sequelize](http://sequelizejs.com/documentation) - it's what I hoped MassiveJS would become eventually (I thought about updating MassiveJS but decided I needed to focus).

Here's a model definition in Sequelize:

```javascript
var db = new Sequelize('minty','minty','password',{
  dialect: 'sqlite',
  storage: "path/to/db",
  logging : false
});

var Article = self.db.define('articles', {
  uuid : {type : Sequelize.STRING(36), allowNull : false, unique: true},
  title : {type : Sequelize.STRING, allowNull : false},
  summary : {type : Sequelize.STRING},
  slug : {type : Sequelize.STRING, allowNull: false, unique: true},
  status : {type : Sequelize.STRING, allowNull: false, defaultValue: "draft"},
  body : {type : Sequelize.STRING, allowNull: false},
  publishedAt : {type : Sequelize.DATE, allowNull: false, defaultValue: new Date()}
});
```

This is billed as "Model" in Sequelize and falls into the ActiveRecord way of thinking. On one hand I like it because I can control the storage - on the other hand I hate it because this is a table definition - not a model. 

How do you choose?

## Decide
Right now the storage mechanism doesn't matter to me all that much. What's important is that I can work with the abstraction to get the data in and out OK. Sequelize works fine and it's one of many tools that I can use to work with sqlite.

NeDB is fascinating, but there are a few restrictions that drive me crazy. For instance, you can't sort or limit your result set, and you can only store one "collection type" (in my case "Article") in one DB.

I know all of this because I create a page in my Node app specifically for spiking things - I call it `rob.js`. In here I'm free to play around with various ideas - including what it looks like to create/edit/and publish records in both NeDB and Sequelize.

You can copy/paste the code right from the demos they show on github - and to run it simply:

```
node rob
```
I use `console.log` liberaly to see what happens here. This is a lot of fun but be sure to take your time and see what fits and what doesn't.

It was during this goofing around that I discovered that I couldn't sort/limit NeDB - that didn't make me feel very happy. The good news? I know enough to push forward with Sequelize. Either way I'll try to write my app so that changing directions in the future won't hurt.

## Good Behavior
Now let's get to the fun part: specifying how our app will behave. I usually like to start with how data gets into the system, so let's do that. When I write these things I always try to imagine real people doing something.

In a publishing process you have three things at work:

 - a **Writer** creates something
 - an **Editor** will change/contextualize it
 - this process is called **Publication**

Again: _I can always change things later on_ and no doubt I will. For now I know that writers write stuff so I'll start by describing that:

```
vim test/writer_spec.js
```

Vim's open and I'm staring at an empty page. I'll start off with what I know I'll need:

```javascript
var should = require("should");
var assert = require("assert"); // this is for asserting error conditions
```

Now let's put together our first spec:

```javascript
describe("Writers", function(){

	describe("creating a valid article", function(){
    	it("is successful");
        it("creates an article");
        it("sets the title, body and slug");
        it("sets the status to draft");
        it("does not create a version");
    });
});
```

I try to write my specs as closely to a "script" as I can. For instance - in this case the feature I'm working on is "Writing" and the people in my head I'm thinking of are "Writers".

Since I'm trying to model behavior, I like to focus on the sentence **"what happens when..."**. In the example above that "what happens when" is "creating a valid article" - in other words "when everything goes according to plan".

This is known as the Happy Path - and **I like to spec this out first** because no matter what I do later on - I want to know that this Happy Path will always work.

Finally, the "it" statements describe the resulting behavior and what I expect to happen. This is enough to get us off the ground - so let's run it:

![](/img/2013/Nov/Screen_Shot_2013_11_20_at_2_08_25_PM.png)

All of our "it" statements above show up blue, which means they're pending and we need to write some code to make them pass (or fail).

## Next Up: The First Model
I'm glad I wrote that spike because I have a few ideas on how I can fulfill this specification. I could keep writing more specifications but I'd like to stop here.

My personal tendency is that if I'm given enough time to come up with "what-ifs" I'll probably never get anything done!

Next time I'll dive into the model itself, and get these specs to pass!

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





