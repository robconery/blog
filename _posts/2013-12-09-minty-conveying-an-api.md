---
layout: post
title: "Minty: Conveying an API"
date: "2013-12-09"
uuid: "8dc5c6f9-959e-43c4-8497-097f323810dd"
slug: "minty-conveying-an-api"
image: /img/connectors3.jpg
summary: I'm building out a Node application - in this case a Blogging engine - and these posts are my adventures building this thing. This is part 8.
categories: Node
comments: true
---

## Feedback So Far

I've received a number of great comments - thank you! People seem to be of the same mind that the [original model](http://rob.conery.io/2013/10/03/minty-sanity-check-one/) was hard to follow and no fun. I agree.

Opinions are somewhat split when it comes to my solution using Eventing - this makes sense as it's hard to see the benefits until you start hooking things together.

Finally - a few people have pointed out that the way I'm handling callbacks in the Writer class can cause issues if I push two posts at the same time. Indeed it's dumb:

```javascript
var Writer = function (schema) {

  Emitter.call(this);
  var self = this;
  var continueWith = null;

    //the one visible
  self.saveDraft = function(args, next){
    //set the article
    var edition = new Edition(args);
    //set the instance variable
    continueWith = next;
    self.emit("draft-received", edition);
  };

  //...
  var draftOk = function(edition){
    edition.success = true;
    edition.message = "Edit made";
    self.emit("draft-saved",edition);
    if(continueWith){
      //possible race condition here
      continueWith(null,edition);
    }
  };
};
```

The problem is a bit nebulous - and the reason I'm bringing this up now is because it plays directly into how we express this functionality to calling code - AKA our API.

If we have only one instance of Writer, the possibility exists that `saveDraft` could be called simultaneously (if we had multiple authors writing an article at the same time).

Let's say that `article1` is the first Article, `article2` is the second. If our authors press "submit" at roughly the same time - they'll get sent to the same Writer instance with `article2` invoking `saveDraft` before `saveDraft` completes with `article1`.

Now, if you've ever done any async programming or have had to deal with threads - your skin might be crawling right now. This type of thing leads to deadlocking and thread hell.

The good news for us is that Node is single-threaded. On the backend Node uses a task queue (the Event Loop) which is also synchronous - this means that you don't have the threading issues that you normally have with thread-based asynchronous coding.

In our example here, each task for `article1` and `article2` would be queued on the Event Loop in the order that the Node thread drops them there. That's when this gets interesting.

It's possible (I think) to interweave the tasks on the Event Loop for both `article1` and `article2`:

```
article1::validate
article1::assignAuthor
article2::validate
article1::saveToDb
article2::assignAuthor
article2::saveToDb
```

We're still safe here - `article2` will still exit our event chain **after** `article1`. But we still have a problem...

`saveDraft` can still be called before `article1` has exited. This means that `article2`'s callback will overwrite `continueWith` and that's a Really Bad Thing.

So how do we get around this? Well, there are two ways - the first is to stop using instance variables to store state (which in this case are kind of global). I can solve this immediately by attaching the callback to the `Edition` variable:

```javascript
  self.saveDraft = function(args, next){
    //set the article
    var edition = new Edition(args);
    //set the callback so we know what's next
    edition.continueWith = next;
    self.emit("draft-received", edition);
  };
```

The other is to be sure we always use a new instance of Writer, and we do that via our API.

## The API
In [the very first post](http://rob.conery.io/2013/10/03/hello-minty/) I talked about how Node modules work. You have a package.json manifest that describes your module and also let's you tack on some NPM overrides, and you have an entry point that gets fired.

That entry point can be set in package.json:

```json
{
  "name" : "minty-cms",
  "author" : "Rob Conery",
  "main" : "./lib/writer"
}
```

This would expose the writer.js file as our module entry point - which probably isn't very usable.

A more common way is to have a file called "index.js" - this is the default entry point if you're using a directory for your module (as we are) and it frees you up from having to specify the entry in your package.json.

This has the added advantage of letting us put our processes and models in their own files, combining as needed and expressing them concisely in a nice API.

Let's create an index.js file in the root of our module:

```sh
touch index.js
```

We're ready to plug in our API, but I still have some work to do since I moved to a document database in the last post. Let's fix things up and then express them through index.js.

## Publisher

We're able to do things a bit nicer now that we have a document database to use. So nice, in fact, that I think I want to simplify things a bit. I wanted to separate the notion of Writer and Editor - but that seems a bit silly. This is a publishing process, so I'll start there, simply.

The first thing I want to do is make sure I don't tie my new class to the database I'm using - so I'll make sure that's passed in through a constructor (using the same utility libraries as before and also requiring my models):

```javascript
var assert = require("assert");
var _ = require("underscore")._;
var Article = require("../models/article");
var Author = require("../models/author");
var Edition = require("../models/edition");
var Emitter = require("events").EventEmitter;
var util = require("util");

var Publisher = function (db) {
  //make sure a db is passed in
  assert.ok(db, "Need a datastore to work with");
  Emitter.call(this);
  var self = this;
}
util.inherits(Publisher, Emitter);
module.exports = Publisher;
```

This will work with the EventEmitter bits as well.

The Publisher will be responsible for enforcing our rules and process - the API will be responsible for conveying these rules and functionality to the calling code.

So, let's start by creating separate create and update routines:

```javascript
  var updateArticle = function(edition){
    //apply the changes - this uses _.extend
    edition.article.updateTo(edition.changes);
    db.articles.update({slug : edition.article.slug}, edition.article, {}, function(err){
      if(err){
        edition.setInvalid(err);
        self.emit("invalid", edition);
      }else{
        edition.setSuccessful("Article updated");
        self.emit("updated", edition);
      }
    });
  };

  var createArticle = function(edition){
    var newArticle = new Article(edition.changes);
    db.articles.insert(newArticle,function(err,newDoc){
      if(err){
        edition.setInvalid(err);
        self.emit("invalid", edition);
      }else{
        edition.article = new Article(newDoc);
        edition.setSuccessful("Article created");
        self.emit("created", edition);
      }
    });
  };

```

I'm using the evented approach that you saw me use in the last post. Create is a simple matter of shoving the article into the database as I've added the validation rules to the Article itself (from the [last post](http://rob.conery.io/2013/11/05/minty-refactor-1-moving-to-a-document-db/)):

```javascript
var Article = function(args){

  //can't have an article without a title and body
  assert.ok(args.title && args.body && args.slug, "Need a slug, title and a body");

  //we also need an author
  assert.ok(args.author, "Need an author");

  //...
}
```

An Article can't exist without these things so asserting here, to me, is OK. It's up to the calling code to deal with the assertions - which means I'm going to let that bubble straight up and through to the top level code.

`updateArticle` works in much the same way - I graft the updates onto the article and save them down.

You'll notice that these functions are private - they can't be called directly. This is because I want to have a single save entry point for simplicity:

```javascript
  self.saveArticle = function(article, next){
    //save continuation to use when events are done
    //I'll leave this as an instance var for now
    continueWith = next;
    //there's workflow here, so hand it off to the save event-chain
    var edition = new Edition({changes : article});
    self.emit("save-requested", edition);
  };
```

Same as before - I'm using event chaining to handle the flow here. Here's the event chain:

```javascript
  //the save event chain
  self.on("save-requested", validateArticle);
  self.on("validated", checkExistence);
  self.on("exists", updateArticle);
  self.on("doesnt-exist", createArticle);
  self.on("created", saveOk);
  self.on("updated", saveOk);

  self.on("invalid", saveNotOk);
```

You should be able to read this process and understand (I hope) exactly what's happening. If you want to see all of the code for the Publisher [have a look at the repo](https://github.com/robconery/minty-cms/blob/master/lib/publisher.js) - let's get back to the API stuff.

## Wiring It Up
In our index.js file let's setup our API:

```javascript
var assert = require("assert");
var _ = require("underscore")._;

var Publisher = require("./lib/publisher");
var Emitter = require("events").EventEmitter;
var util = require("util");
var Datastore = require("nedb");

//local, private instance of the DB
var db = {};

//initialize the EventEmitter bits
var Minty = function(){
  Emitter.call(this);
  return this;
};

//inherit from Emitter
util.inherits(Minty,Emitter);

//export a new instance
module.exports = new Minty();
```

The next step is to initialize our API and I'll do that with a simple method:

```javascript
Minty.prototype.init =function(conf,next){
  conf = conf || {};
  var self = this;
  //article storage
  if(conf.db){
    assert.ok(conf.db,"Need a db setting");
    db.articles = new Datastore({ filename: conf.db, autoload: true });
  }else{
    //in-memory only
    db.articles = new Datastore();
  }

  //need to be sure to index slug
  db.articles.ensureIndex({fieldName : "slug", unique : true}, function(err){
    next(err,self);
  });

};
```

A nice thing about NeDB is it allows indexing. I'll query by slug often so I'll be sure to pop a unique index there. Another nice thing is that I'm passing configuration in here - right at the top level of my module.

Now, let's save an Article-

```javascript
Minty.prototype.saveArticle = function(args, next){
  var publisher = new Publisher(db);
  var self = this;
  args = args || {};
  //make sure we have a slug
  args.slug = args.slug || sluggify(args.title);

  publisher.saveArticle(args,function(err,edition){
    if(err){
      self.emit("article-error",err);
    }else{
      self.emit("article-saved",edition);
    }
    next(err,edition);
  });
};
```

Simple enough - we also have a clean way of setting the slug (which is required) if one wasn't set previously. This might not seem like we're just repeating what we've done previously - but there's more to do.

The purpose of the API is to convey your rules/functionality as explicitly as possible to your end user. So we can add a few more methods here:

```javascript
Minty.prototype.tagArticle = function(slug, tags, next){
  var self = this;
  var publisher = new Publisher(db);
  this.getArticle({slug : slug}, function(err,article){
    article.tags = tags;
    publisher.saveArticle(article,function(err,edition){
      if(err){
        self.emit("article-error",err);
      }else{
        self.emit("article-tagged",edition);
      }
      next(err,edition);
    });
  });
};

Minty.prototype.publishArticle = function(slug, next){
  var self = this;
  var publisher = new Publisher(db);
  this.getArticle({slug : slug}, function(err,article){
    article.status = "published";
    article.publishedAt = new Date();
    publisher.saveArticle(article,function(err,edition){
      if(err){
        self.emit("article-error",err);
      }else{
        self.emit("article-published",edition);
      }
      next(err,edition);
    });
  });
};

Minty.prototype.unpublishArticle = function(slug, next){
  var self = this;
  var publisher = new Publisher(db);
  this.getArticle({slug : slug}, function(err,article){
    article.status = "draft";
    article.publishedAt = null;
    publisher.saveArticle(article,function(err,edition){
      if(err){
        self.emit("article-error",err);
      }else{
        self.emit("article-unpublished",edition);
      }
      next(err,edition);
    });
  });
};

Minty.prototype.takeArticleOffline = function(slug, next){
  var self = this;
  var publisher = new Publisher(db);
  this.getArticle({slug : slug}, function(err,article){
    article.status = "offline";
    article.publishedAt = null;
    publisher.saveArticle(article,function(err,edition){
      if(err){
        self.emit("article-error",err);
      }else{
        self.emit("article-taken-offline",edition);
      }
      next(err,edition);
    });
  })
};
```

This echoes a preference of mine - be explicit in your API and make sure the code matches what's happening to a reasonable extent. I know this can spiral if the processes get complicated, but I'm setting simple dates and statuses - there's no need to bury this.

I don't care for it on the Article itself (say with a method called publish()) because that's not how the world works (Articles don't publish themselves... although if you read my blog you might disagree). I like the notion that the author, who's sitting behind the screen using this API is publishing the Article - I'm just setting the information for them.

Long post again - let me know your thinking...
