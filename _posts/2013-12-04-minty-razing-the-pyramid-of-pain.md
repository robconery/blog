---
layout: post
title: "Minty: Razing the Pyramid of Pain"
date: "2013-12-04"
uuid: "049a53dc-5077-448c-a1e5-20c8a510c61e"
slug: "minty-razing-the-pyramid-of-pain"
image: /img/Mothership_destroys_Abydos_1.jpg
categories: Node
comments: true
---

## So Much Code For Such a Simple Thing...

I can barely type that sentence without feeling a twinge of ... not-happy. [In the last post](http://rob.conery.io/2013/10/27/minty-sanity-check-one/) I showed some code that probably looked a bit weird if you're not a into evented Node "stuff" and that's what I'm going to dive into today.

Our subject today will be "publishing a draft article" (or posting a new post - whatever). Here are the things we'll need to do:

 - basic validations (title, body, slug)
 - check to see if the slug has been used
 - assign/associate the author
 - save/associate the tags
 - save to the DB
 - snap a version
 
These are my requirements (for now). Let's implement them.

## One Block at a Time

That's how you build a pyramid (pretending that we have existing functions) :

```javascript
function saveArticle(article, next){
  validateArticle(article, function(err,ok){
    if(err){next(err,null)};
    if(ok){
      checkSlug(article, function(err,ok){
        if(err){next(err,null)};
        if(ok){
          assignAuthor(article, function(err,ok){
            //same stuff here
            saveTags(article, tags, function(err,ok){
              //and again...
              saveToDb(article, function(err,newArticle){
                //and again...
                saveVersion(article, function(err,version){
                  //make it stop please...
                });
              });
            });
          })
        }
      });
    }
  });
}
```

This. Sucks.

Many people will blame Javascript for this mess which might be a bit silly. Javascript might not be the most elegant language, but it surely doesn't make you commit acts of Code Treason.

Let's fix this and we'll use a few different ways...

## Promises

Promises are a popular way to do this with Node and Javascript. A "promise" is the result of an async function and looks something like this:

```javascript
getInfoFromTheDb({id : 1}).then(function(result){
  console.log(result);
});
```

Simple stuff. It relies on a bit of a fluent interface (where you chain method calls together) and can also be semantic:

```javascript
getInfoFromTheDb({id : 1})
  .success(function(result){
    console.log(result);
  })
  .error(function(err){
    console.log("On NO!" + err);
  });
```

This is how Sequelize works. It's pretty handy and can solve a lot of problems for you. In our case, we could do something like...

```javascript
validateArticle(article)
  .then(checkSlug(article))
  .then(assignAuthor(article))
  .then(saveTags(tags,article))
  .then(saveToDb(article))
  .then(snapVersion(article))
  .error(function(err){
    //log it etc
  });
```

This is sort of free-handed as it depends on the library you use to do the promising. Currently [the q library](https://github.com/kriskowal/q) is the most popular promise framework for Node.

A lot of code was replaced with some simple "promise-flow", which to me is pretty groovy. I should also add here that promises, at one time, were part of Node but were taken out as the Node Gods figured that they were creating a tool - not a way of writing code - so they removed it.

Understanding why they did this is pivotal to understanding Node. Many might see this as a condemnation of promises (there are a few out there who hate them). The Node folks decided that the community could come up with better ways of handling async workflow - so they decided to let promises be added as needed.

Anyway.

It's a fairly simple affair to chain a workflow as you can see, but I think we can do better. There's nothing inherently "bad" here - but there are benefits to other approaches that we can leverage.

## Async

You've already seen me use [the async library](https://github.com/caolan/async) - I used it in [my last post](http://rob.conery.io/2013/10/27/minty-sanity-check-one/) to handle some intense async functions happening in a loop:

```javascript
  var findOrCreateTag = function(tag, next){
    //create a tag if it doesn't exist
    schema.Tag.findOrCreate({name : tag}).success(function(found){
      dbTags.push(found);
      next(null,found);
    });
  };

  var associateTags = function(article, tags, next){
    //this feels gross - but it really is helpful...
    async.each(tags, findOrCreateTag, function(err){
      article.setTags(dbTags)
          .success(function(){
            next(null,article);
          })
          .error(function(err){
            next(err,null);
          });
    });
  };
```

This library handles all kinds of workflow for you. You can run serial operations (like we did with promises) that step through a workflow, or you can execute them in parallel like I'm doing above. You can also do a "waterfall" where one function passes the result to the next.

I prefer this over promises simply because of the flexibility you have. This is a subjective thing - when dealing with this stuff I don't think there's a "bad" option really.

## Events

Of all of these approaches, I prefer Node's built-in EventEmitter. [I wrote about this once before](http://rob.conery.io/2012/04/05/cleaning-up-deep-callback-nesting-with-nodes-eventemitter/) but I've also found a way to improve upon it a bit.

First, let's set our writer to be something that is Event-aware:

```javascript
var Emitter = require("events").EventEmitter;  
var util = require("util");  

var Writer = function (schema) {
  //constructor call
  Emitter.call(this);
  var self = this;
  return self;
});

util.inherits(Writer,Emitter);
module.exports = Writer;
```

There are a few ways to plug evented stuff into your "classes" with Node - but inheriting from EventEmitter seems to be the way that most Node-heads do things, so I do it too.

Now that we've done this, we can emit events that external listeners can tap into which is great for extensibility. BUT, we can also use it for our own gain...

To emit an event, you simply do this:

```javascript
self.emit("some-event", {mssg: "hi"});
```

Here I give the event a name, and I pass along some data. To listen to this event I use `on`:

```javascript
function logEvent(args){
  console.log(args.mssg);
};

//subscribe
self.on("some-event", logEvent);
```

Whenever the `some-event` is emitted, the logEvent function will get called. In addition, and this is important, **whatever data is provided in emit is passed as an argument to the listener**. So our logEvent will receive `{mssg : "hi"}` and then log it out.

Interesting stuff - so how does this apply to us? For this, let's think about **monads**.

I hesitate to say that we're writing a monad here - but I do think the concept helps. In short, [a monad is](http://en.wikipedia.org/wiki/Monad_(functional_programming)):

> In functional programming, a monad is a structure that represents computations defined as sequences of steps. A type with a monad structure defines what it means to chain operations, or nest functions of that type together. This allows the programmer to build pipelines that process data in steps, in which each action is decorated with additional processing rules provided by the monad.

That's what I want to do: send some data through a process pipeline and see what happened to it - _and we can do it with Node's EventEmitter_.

The first step is to come up with the "package" - or the thing to be sent through the pipe. We'll need to know:

 - What's happening to it
 - If it's completed
 - The data from each operation

For this, I'll use the `Edition` object I created before:

```javascript
//a helper class we're using as a bit of a MONAD
var Edition = function(args){
  args = args || {};
  return {
    success : args.success || false,
    message : args.message,
    article : args.article,
    changes : args.changes,
    setInvalid : function(mssg){
      this.success = false;
      this.message = mssg;
    },
    setSuccessful : function(mssg){
      this.success = true;
      this.message = mssg;
    }
  }
};

module.exports = Edition;
```

This is a *very* simple object that allows us to tack on a message and to know if we've completed the operation and some messaging to let the calling code know what happened. I'm using a simple string field here - you can get as nuts as you like. For this approach to work, we'll need to send along the Edition instance to every function.

That's the magic here.

To start things off, I'll need a publicly visible function which I'll call `saveDraft`:

```javascript
var Emitter = require("events").EventEmitter;  
var util = require("util");  

var Writer = function (schema) {
  //constructor call
  Emitter.call(this);
  var self = this;
  var continueWith = null;
  
  self.saveDraft = function(args, next){
    var edition = new Edition(args);
    continueWith = next;
    self.emit("draft-received", edition);
  };
  
  return self;
});

util.inherits(Writer,Emitter);
module.exports = Writer;
```

I've added a simple function that creates an Edition from the passed-in arguments and then emits that Edition using a "draft-received" event. 

To see how this ties together, let's add a validate function:

```javascript
  //check for required bits (author, title, body)
  var validateEdition = function(edition){

    //we have an article, so build a proper one
    var article = edition.article;
    var author = edition.author;

    //make sure we have the info we need
    if(!(article.title && article.body)){
      edition.setInvalid("Need a title and a body for the article");
      self.emit("invalid",edition);
    }else{
      //we're good!
      self.emit("validated", edition);
    }

  };
```

Since we're emitting the Edition from "draft-received" we can assume that it will be passed completely to our `validateEdition` function. We do our validations and when everything goes well we emit a "validated" event, and pass the same edition along (which may have been changed).

And so it goes, all the way through to the very end (saving tags, sending to the DB, saving a version - each function works with the Edition instance and then emits it back out).

If things didn't go well, we emit an `invalid` event, making sure to set the edition invalid, explaining why.

To wire this up, we simply setup a listening chain:

```javascript
var Writer = function (schema) {
  //constructor call
  Emitter.call(this);
  var self = this;
 
  //...
  
  //event wireups
  self.on("draft-received", validateArticle);
  self.on("validated",assignAuthor);
  //... rest of steps
  self.on("saved", draftOk);
  
  self.on("invalid", draftNotOk);  
  return self;
});
```

The endpoints of our workflow are `draftOk` and `draftNoOk` - these will send control back to the calling code, and this is where it gets interesting.

Up to now, we've been playing an internal game of ping-pong with our events. At any given step we can emit `invalid` if things go wrong, specify a reason, and be on our way. But how do we hand control back to the caller?

In the very first step I assigned a variable called `continueWith` and I set it to be the callback function passed in to our `saveDraft` method. I can use this to fire the callback and we're good to go:

```javascript
  //all's well
  var draftOk = function(edition){
    //set success to true
    edition.success = true;
    //return a nice message
    edition.message = "Edit made";
    //emit a final event for external subscribers
    self.emit("draft-saved",edition);
    //fire a callback if we have one
    if(continueWith){
      continueWith(null,edition);
    }
  };

  //something didn't work out - the final method called
  var draftNotOk = function(edition){
    //this is default, but just to be sure...
    edition.success = false;
    //fire a final event
    self.emit("draft-not-saved",edition);
    if(continueWith){
      //invoke the callback
      continueWith(edition.message,edition);
    }
  };
```

And with this, we've finalized our operation. It's worth noting that it's roughly the same as using promises or the async library with one major difference: **with EventEmitter you can also have extensibility**. This might not seem like a big deal now, but in the future it will come in handy.

OK, this post is long enough - here's the final code once again - sans pyramid. You can see the workflow clearly at the very end, and it's very, very easy to change as needed:

```javascript
var assert = require("assert");  
var _ = require("underscore")._;

var Edition = require("../models/edition");  
var Emitter = require("events").EventEmitter;  
var Tagger = require("./tagger");

var util = require("util");  
var uuid = require('node-uuid');

var Writer = function (schema) {

  Emitter.call(this);
  var self = this;
  var continueWith = null;
  var tagger = new Tagger(schema);
  //check for required bits (author, title, body)
  var validateEdition = function(edition){

    //we have an article, so build a proper one
    var article = edition.article;
    var author = edition.author;

    //make sure we have the info we need
    if(!(article.title && article.body)){
      edition.setInvalid("Need a title and a body for the article");
      self.emit("invalid",edition);
    }else{
      //we're good!
      self.emit("validated", edition);
    }

  };

  var setTags = function(edition){
    tagger.setTags(edition.article, edition.tags,function(err,result){
      if(err){
        edition.setInvalid(err);
        self.emit("invalid", edition);
      }else{
        self.emit("article-tagged", edition);
      }
    });
  };


  //create a slug if doesn't exist
  var checkForSlug = function(edition){
    var article = edition.article;
    article.slug = article.slug || edition.createSlugFromTitle();
    self.emit("slug-checked",edition);
  };

  var assignAuthor = function(edition){
    schema.Author.findOrCreate(edition.author)
        .success(function(author){
          edition.article.setAuthor(author)
              .success(function(){
                self.emit("author-assigned", edition);
              })
              .error(function(){
                edition.setInvalid(err);
                self.emit("invalid", edition)
              });
        })
        .error(function(err){
          edition.setInvalid(err);
          self.emit("invalid", edition);
        })
  };

  var sendDraftToDB = function(edition){
    //guarantee this is draft status
    edition.article.status = "draft";
    //create a unique ID - v4 is random, v1 is clock-based
    edition.article.uuid = uuid.v1();
    schema.Article.create(edition.article)
        .success(function(draftArticle){
          edition.article = draftArticle;
          self.emit("article-saved",edition);
        })
        .error(function(err){
          edition.setInvalid(err);
          self.emit("invalid", edition);
        });
  };

  //the happy endpoint of the process pipe
  var draftOk = function(edition){
    edition.success = true;
    edition.message = "Edit made";
    self.emit("draft-saved",edition);
    if(continueWith){
      continueWith(null,edition);
    }
  };

  //something didn't work out - the final method called
  var draftNotOk = function(edition){
    edition.success = false;
    self.emit("draft-not-saved",edition);
    if(continueWith){
      continueWith(edition.message,edition);
    }
  };

  //the one visible
  self.saveDraft = function(args, next){
    assert.ok(args.article && args.author, "Can't save something without an article and author");

    //set the article
    var edition = new Edition(args);
    continueWith = next;
    self.emit("draft-received", edition);
  };

  //process
  self.on("draft-received", validateEdition);
  self.on("validated",checkForSlug);
  self.on("slug-checked",sendDraftToDB);
  self.on("article-saved",assignAuthor);
  self.on("author-assigned",setTags);
  self.on("article-tagged",draftOk);

  //uh oh
  self.on("invalid",draftNotOk);

  return self;
};

util.inherits(Writer, Emitter);  
module.exports = Writer;  
```