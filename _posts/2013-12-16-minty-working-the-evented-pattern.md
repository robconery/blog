---
layout: post
title: 'Minty: Working The Evented Pattern'
image: '/img/bacon-maple.jpg'
comments: true
categories: Node
summary: I'm building out a Node application - in this case a Blogging engine - and these posts are my adventures building this thing. This is part 9.
---

## Refactoring, Refactoring

I'm stumbling my way to something interesting here... but things aren't feeling exactly right. I do like the way that my code is a bit cleaner using the Event bits with Node, but I think there's a better way.

Firstly - our Publisher "class" is doing a number of things, It's:

 - Running validations
 - Saving/Pulling data
 - Instrumenting our processes

There are a few too many responsibilities here - and that's acting as a bit of a "smell", if you will, that something is amiss. 

The first thing I'd like to do is pull out validations. I like to think of classes that act on models as people doing a job with a thing (or some data). This is just how I think of things. I put classes like this in my `/lib` directory (as opposed to `/models`) - these are pure processes:

```sh
vim ./lib/validator.js
```

Now, drop in some code:

```javascript
var Emitter = require("events").EventEmitter;
var util = require("util");
var Article = require("../models/article");

var Validator = function(db){
  Emitter.call(this);
  var self = this;

  self.checkRequired = function(edition){
    //need an author, title, and body
    if(edition.changes.author && edition.changes.title && edition.changes.body){
      self.emit("validated", edition);
    }else{
      edition.setInvalid("Need an author, title, and body", edition);
      self.emit("invalid", edition);
    }
  };

  self.checkExistence = function(edition){
    db.articles.findOne({slug : edition.changes.slug}, function(err,found){
      if(found){
        //move the passed in bits to the changes to be made
        edition.article = new Article(found);
        self.emit("exists", edition);
      }else{
        self.emit("doesnt-exist", edition);
      }
    });
  };
};

util.inherits(Validator,Emitter);
module.exports = Validator;
```

Much better. This is an EventEmitter as well - both of our "process" classes are, which makes sense if they're people doing a thing. You could imagine them in a Kung Fu theater movie... shouting out "ARTICLE VALIDATED!" when Jade Scorpion stance is in full effect...

But how can we use this now?

## Shake Those Limbs!

It's usually a simple refactor like this that pulls the loose thread in my Node sweater: I now have two processes (Validation and Publication) that I need to synthesize somehow. The good news is that I can use events like I was doing before... but where?

If you consider workflow in the Real World, there's a lot of abstraction. I like to think of restaurants in this regard - when you drop into Voodoo Donuts you don't roll into the back and tell the fryer person to drop in some dough, glaze it with that lovely brown maple and then finally slab on two slices of bacon - no **you ask the person at the front to get you that action**.

> I'd like a Bacon Maple Bar of Cardiac Arrest please

This person is an API:

```javascript
exports.takeDonutOrder = function(order, next){
  //handle the cooking if needed
  //when not have donut
  next("NO DONUT FOR YOU", null);
  //when have donut
  next(null,donut);
};
```

This is [what we're doing with our API](http://rob.conery.io/2013/12/09/minty-conveying-an-api/): abstracting process. Our fictional donut counterperson knows what needs to happen, and instruments the donut fryer, glazer, and ... bacon-stripper (?) to do their jobs.

We can do the same. Our Publisher has too much control - let's move that out so we can centralize our process flow:

```sh
vim index.js
```

Now, let's add a function to instrument what the publisher and validator are doing:

```javascript
//the save process
var wireEvents = function(){
  publisher.on("save-requested", validator.checkRequired);
  validator.on("validated", validator.checkExistence);
  validator.on("exists", publisher.updateArticle);
  validator.on("doesnt-exist", publisher.createArticle);

  //happy path
  publisher.on("created", saveOk);
  publisher.on("updated", saveOk);

  //sad path
  publisher.on("invalid", saveNotOk);
  validator.on("invalid", saveNotOk);
};
```

This only works, of course, if we have instances of Publisher and Validator - let's drop those in the `init()` function:

```javascript
//local, private variables
var db = {}, publisher, validator;

Minty.prototype.init =function(conf,next){
  var self = this;
  conf = conf || {};

  //... db wireup code snipped

  publisher = new Publisher(db);
  validator = new Validator(db);

  //set up the event chain
  wireEvents();
  
  //... snipped
};
```

This allows us to clip a ton of code out of our Publisher - and what we're left with is two classes that do a single thing:

 - Validator validates articles
 - Publisher persists/pulls article data

These work together happily (as your tests should hopefully be showing you) as-instrumented by our CMS Counterperson: index.js.

## Patterns Repeating

Back to our donut analogy - when your Voodoo Bar of Death is ready the counterperson will let you know - you get it and you're off. You're reacting to certain events - maybe they call your name/order number, or you can just smell the pain coming.

When you decided to get yourself a donut - you created a bit of an Event Chain in your head:

- Walk to Voodoo Donuts
- Order some glazed pain
- Write a blog post while waiting
- Eat donut
- Go home and take a bath and then a nap

This is how you fit the donut experience into your work flow. We can do exactly the same with our CMS.

Right now we have these events on our API:

 - `article-saved`
 - `article-tagged`
 - `article-published`
 - `article-unpublished`
 - `article-taken-offline`
 - `article-error`

These operations are what you would expect from a CMS system. But they're meaningless unless you plug them in somehow - let's do that now!

Let's create a blog (making sure to get out of our minty-cms directory):

```sh
cd ..
npm install -g express
express minty-blog
cd minty-blog
npm install -d
```

This will create a basic Express site for us and then install the dependencies. Let's crack open the package.json file:

```sh
vim package.json
```

And we'll update the basics, adding a name and description:

```json
{
  "name": "minty-blog",
  "description": "Our rad blog",
  "author": "Rob Conery",
  "version": "0.0.1",
  "private": true,
  "dependencies": {
    "express": "3.4.4",
    "ejs": "*",
  }
}
```

Now, let's add our CMS module. I've been [pushing mine to Github](https://github.com/robconery/minty-cms) which means I can just tell NPM to use my repo:

```sh
npm install robconery/minty-cms --save
```

This is yet another reason I love NPM/Node - you can use Github for this kind of thing! Note: I didn't need to do this, I could have simply executed:

```sh
npm install ../minty-cms
```

And NPM would have found the project there and pulled it in. If you look at package.json now - you'll see it's been updated! Now let's put our party hats on and get in the time machine - months into the future where we've piled together some modules that we'd like to use with our blog.

Or maybe we've found some online that we'd like to use. Either way - let's take a look at the fictional modules we'll be using:

 - `minty-membership` - This is actually something I wrote and will be publishing with a screencast I'm trying to finish. It's trying to be Devise for Node, without the kitchen sink
 - `minty-archivist` - A versioning library that snapshots data for you
 - `node-es` - We want full text right? Let's use our ElasticSearch box to do this. We could use Lucene or any other system - this is up to us!

Let's install what we need:

```sh
npm install robconery/minty-membership  --save
npm install robconery/minty-archivist  --save
npm install node-es  --save
```

Now let's wire this all up!

## Get Some Pliers

I'll create a lib directory for my blog app, and in there create a simple module called "blog.js":

```sh
mkdir lib
vim lib/blog.js
```

The following is pseudo-code but it's based on a working prototype I have here in front of me. We can wire these modules together in the same exact way as we did with our Publisher:

```javascript
var CMS = require("minty-cms");
var Archive = require("minty-archivist");
var ElasticSearch = require('es');

exports.init = function(next){
  var self = this;
  //es connection stuff...
  var options = {...} //server, host, etc
  self.searchIndex = ElasticSearch.createClient(options);

  CMS.init({db : "./data/articles.db"}, function(err,minty){
    //this is optional - but it is damn convenient
    self.cms = minty;
    self.archive = new Archive({db : "./data/archive.db"});
    wireEvents();
    next(null,self)
  });
}

var indexArticle = function(edition){
  self.searchIndex.index("blog", 'Article', edition.article, function(err, next){
    //hijack the events here :)
    self.cms.emit("article-indexed", edition);
  });
};


var wireEvents = function(){
  
  self.cms.on("article-saved", indexArticle);
  self.cms.on("article-indexed", archive.snapVersion);
  self.cms.on("version-saved", doSomethingElse);

};
```

In this example we're extending our eventing pattern out to the use of other modules just for what we want to happen with our blog app on save. We can instrument all kinds of things emanating from the CMS - customizing our Blog app to do whatever we want when certain things happen.

Admittedly - this hasn't always been a simple affair when I've done it! Also - again this is pseudo code as I don't have a working example - I'm just extending the pattern we've been using.

For instance - the `indexArticle` function needed to be created because the data returned from "article-saved" is an Edition and not in the format this function needs - so I had to write a wrapper. 

I think that's balanced, however, by emitting custom events on the `cms` instance ("article-indexed"). This might seem interesting to you... or it might not...

## Summary

This type of programming is quite old - if you used ASP.NET back in the day then you wired events to the press of a button and this was quite normal to you. To me, the benefit of writing code this way is **flexibility**.

However - please don't think I'm telling you this is best way to do things! **I'm still searching** for a comfort level here and I'd love to hear what you think!

