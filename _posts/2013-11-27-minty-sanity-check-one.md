---
layout: post
title: "Minty: Sanity Check One"
date: "2013-11-27"
uuid: "21b1e568-c05f-4240-885a-bfd66d68fac3"
slug: "minty-sanity-check-one"
image: you_have_upset_the_tetris_god_video__d48a6c7ffe.jpg
categories: Node
comments: true
---

## Before We Get Too Far

One of the reasons I like spiking things is so I can get a feel for what my code will grow into. I've written so much crap in the past - it would pain me to do it again.

So I like to stop at certain points to see where things are at. Right now we have:

 - A representation of an Article
 - a way to store data with Sequelize
 - A clean set of specs that focuses on behavior
 
Or, in other words:

> It's 106 miles to Chicago, we got a full tank of gas, half a pack of cigarettes, it's dark... and we're wearing sunglasses

## Hit It

NO STOP! I need to build on this way of doing things and I don't want to look back from under a [Big Ball of Mud](http://en.wikipedia.org/wiki/Big_ball_of_mud) wondering why things suck.

So I'm going to spike again - to blow this thing as far out as I can think in an effort to fray the edges and force the cracks to appear. 

_**Note**: This is something I like to do; I'm not recommending it for everyone. How an application "feels" to me is very, very important._

First, let's create a branch (this assumes you've been committing at your own rate in your own style so far):

```sh
git checkout -b spikeone
```

Now, let's open up Schema.js and see what we have:

```javascript
var Sequelize = require("sequelize-sqlite").sequelize;  
var assert = require("assert");

var Schema = function(conn){

  var self = this;

  self.Article = self.db.define('articles', {
    title : {type : Sequelize.STRING, allowNull : false},
    slug : {type : Sequelize.STRING, allowNull: false, unique: true},
    status : {type : Sequelize.STRING, allowNull: false, defaultValue: "draft"},
    summary : Sequelize.STRING,
    image : Sequelize.STRING,
    body : {type : Sequelize.STRING, allowNull: false},
    publishedAt : {type : Sequelize.DATE, allowNull: false, defaultValue: new Date()}
  });

  self.sync = function(next){
    self.db.drop().then(function(){
      self.db.sync().then(function(err,result){
        next(null,{success : true});
      });
    });
  };

  return self;
}
module.exports = Schema;  
```

Already I'm not happy. I **hate that my model is defined in terms of its storage**. What if I want to have a helper method here - something like "isPublished()"? 

I have to work within Sequelize's structure:

```javascript
  self.Article = self.db.define('articles', {
    title : {type : Sequelize.STRING, allowNull : false},
    slug : {type : Sequelize.STRING, allowNull: false, unique: true},
    status : {type : Sequelize.STRING, allowNull: false, defaultValue: "draft"},
    summary : Sequelize.STRING,
    image : Sequelize.STRING,
    body : {type : Sequelize.STRING, allowNull: false},
    publishedAt : {type : Sequelize.DATE, allowNull: false, defaultValue: new Date()}
  }, {
  instanceMethods : {
  	isPublished : function(){
      return this.status === "published";
    }
  });
```

This works, and I dislike it strongly. I'm thinking about all those people who will want to hack into Minty later on who will need to understand how Sequelize works before they can change the model.

I'm apt to forget the syntax here as well. Specifically  
 
 - what data types I can use 
 - how to have special getters/setters
 - hwo instance and class methods work (and their syntax)
 - how to use validations 

Having to read over a tool's documentation every time I make a change is annoying (ActiveRecord comes to mind). It's straight up friction and I dislike it being right smack in the center of my app.

So to me: this is **strike one**.

## OK, Now Hit It

One thing I know I'll have to do is work with the concept of tags. This is a classic Many to Many and that association usually is the perfect measure for how far your DB tool can stretch.

Let's open a drink of choice, turn on Tool, and ramp this schema out to what our final final might look like:

```javascript
var uuid = require('node-uuid');
var Sequelize = require("sequelize-sqlite").sequelize;

var Schema = function(conn){

  var self = this;
  var Sequelize = require('sequelize-sqlite').sequelize;

  //setup the DB connection
  self.db = new Sequelize('minty','minty','password',{
    dialect: 'sqlite',
    storage: conn.db,
    logging : false
  });

  self.Article = self.db.define('articles', {
    uuid : {type : Sequelize.STRING(36), allowNull : false, unique: true},
    title : {type : Sequelize.STRING, allowNull : false},
    slug : {type : Sequelize.STRING, allowNull: false, unique: true},
    status : {type : Sequelize.STRING, allowNull: false, defaultValue: "draft"},
    summary : Sequelize.STRING,
    image : Sequelize.STRING,
    body : {type : Sequelize.STRING, allowNull: false},
    postType : {type : Sequelize.STRING, allowNull : false, defaultValue : "blog-post"},
    publishedAt : {type : Sequelize.DATE, allowNull: false, defaultValue: new Date()}
  });

  self.Version = self.db.define('versions', {
      title : {type : Sequelize.STRING, allowNull : false},
      slug : {type : Sequelize.STRING, allowNull: false},
      status : {type : Sequelize.STRING, allowNull: false, defaultValue: "draft"},
      summary : Sequelize.STRING,
      image : Sequelize.STRING,
      body : {type : Sequelize.STRING, allowNull: false},
      postType : {type : Sequelize.STRING, allowNull : false, defaultValue : "blog-post"},
      snappedAt : {type : Sequelize.DATE, allowNull: false, defaultValue: new Date()}
  });

  self.Tag = self.db.define('tags', {
    name : {type : Sequelize.STRING, allowNull : false, unique: true},
    description : {type : Sequelize.STRING}
  });
  
  self.Author = self.db.define("authors", {
    email : {type : Sequelize.STRING, allowNull : false},
    password : {type : Sequelize.STRING},
    name : {type : Sequelize.STRING, allowNull : false},
    github :{type : Sequelize.STRING},
    stackOverflow : {type : Sequelize.STRING},
    bio : {type : Sequelize.STRING},
    location : {type : Sequelize.STRING},
    twitter : {type : Sequelize.STRING},
    vimeo : {type : Sequelize.STRING},
    youtube : {type : Sequelize.STRING}
  });

  //associations
  self.Article
      .hasMany(self.Version, {onDelete: 'cascade'})
      .hasMany(self.Tag)
      .belongsTo(self.Author);

  self.Tag.hasMany(self.Article);
  self.Version.belongsTo(self.Article);
  self.Author.hasMany(self.Article);

  //helpy thing
  self.sync = function(next){
    self.db.drop().then(function(){
      self.db.sync().then(function(err,result){
        next(null,{success : true});
      });
    });
  };

  return self;
};

module.exports = Schema;
```

I went ahead and built this out as well as 36 specs to support it. It works, but as I suspected there's enough magic happening that I'm getting a bit worried.

A few things to note here first, however.

As far as schema declarations go - this is really clean. I like how associations are handled and how you can drop this right into your DB (sqlite, pg, or mysql) and it adds the tables with all the schema things you like.

I like how Many to Many relations are handled too - just 2 `hasMany` references and you're off.

Finally: I think it's reasonable to assume that most developers picking this up would find it understandable. [The Sequelize documentation](http://sequelizejs.com/documentation) is really well-written too - this makes me feel a bit better.

Now let's focus on the bigger issue: tagging.

## The Tag Test

When saving an Article I want to be able to pass in tags. Ideally these are just strings in an array property of the Article itself.

At some point I need to:

 - peel the tags off the Article
 - see if each one exists in the Tags table and add it if it doesn't
 - associate the tag with the Article which involves removing existing tags (if this is an edit)
 
This type of transaction is a typical "Crap Trap" for "simple" systems like a blog engine. Given this, I spent a number of hours going "full tilt" - building things out.

This is the result of my spike/binge/obsession. I know I'm not being very TDD and I'm probably breaking a number of rules, but I'm paranoid. Anyway - here's that Writer class I referred to a few posts ago:

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

That's a lot of code. Take some time and look through it - I'll talk  about the Emitter stuff in another post but for now (and how I avoided callback hell) - have a look at the `setTags()` method.

As you can imagine, this thing was a nasty spiral of callbacks and promises. And **I mean really nasty**. Which is exactly what I suspected. I was hoping that Sequelize would implement some type of async flow for this and they _sort of_ do with query chains - but it's not very well documented and I simply couldn't make it work.

So I did my own thing.

This is calling in to a special function called "Tagger":

```javascript
var async = require("async");
var assert = require("assert");
var _ = require("underscore")._;

var Tagger = function(schema){

  var self = this;
  self.schema = schema;

  var deleteTags = function(article, next){
    article.setTags([])
        .success(function(){
          next(null);
        })
        .error(function(err){
          next(err)
        })
  };

  var dbTags = [];

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


  self.setTags = function(article, tags, next){
    deleteTags(article, function(err,result){
      assert.ok(err === null, err);
      associateTags(article, tags, next);
    });
  };

  return self;
};

module.exports = Tagger;
```

In this module I'm combining the promises of Sequelize with Node's callback structure and I hate it. Strike two.

I'm also forced into using the "async" library (which I love) but I **can't stand that I have to do it for a DB write**. 

And that's **Strike Three**.

## Glad I Did This

Once again, a long post but I'm glad I spiked this thing like I did. It took me 4 hours in real time to get to the point where I could:

 - fully understand Sequelize's Many to Many associations
 - write and remove tags successfully
 - associate tags successfully

I never got to the point where I could pull Articles out by tag - but that was beyond what I needed to do.

What's apparent to me now is that **I don't need a relational database** here. As expected: it's adding complication where I don't need it and yes I know there are other tools out there but I simply don't want to deal with it.

I'm going to [take NeDB for a spin](https://github.com/louischatriot/nedb) - which is billed as the "sqlite of document databases". If that doesn't work I'll just store each post as a JSON document and load them all in memory at app start.

So that's what's next:

 - explain WTH with the Emitter stuff and
 - move over to NeDB
 
See you then.