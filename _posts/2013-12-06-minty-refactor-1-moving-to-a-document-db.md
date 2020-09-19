---
layout: post
title: "Minty: Refactor 1 - Moving To a Document DB"
date: "2013-12-06"
uuid: "732d81aa-a752-4a85-8b7a-2cd78f4bd8bc"
slug: "minty-refactor-1-moving-to-a-document-db"
image: /img/keeping_it_simple_project_plan_from_point_a_to_point_b.jpg
summary: I'm building out a Node application - in this case a Blogging engine - and these posts are my adventures building this thing. This is part 7.
categories: Node
comments: true
---

Image Credit: _http://cobaltpm.com/keep-it-simple-and-succeed/_

## This Can Be Simpler
[In my post about building the model](http://rob.conery.io/2013/10/04/minty-defining-the-model/) I kicked up Sequelize, defined an Article, and went about my business:

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

I don't care for this much. It works and isn't all that much code - but if I wanted to add some helper methods (like isPublished() or whatnot) I need to do it within the Sequelize construct:

```javascript
var Schema = function(conn){

  var self = this;

  self.Article = self.db.define('articles', {
    title : {type : Sequelize.STRING, allowNull : false},
    slug : {type : Sequelize.STRING, allowNull: false, unique: }
    //...
  }, instanceMethods : {
  	isPublished : function(){
      return this.status === "published";
    }
  });
```

When you find yourself writing basic Javsascript inside an object called "instanceMethods" - that should ring some bells.

I certainly don't need to do this - I could call this "ArticleTable" and use it within an Article class - but that's misdirection to me.

There are more reasons in the model article - have a read there - but the bottom line is that I've made up my mind: I'm moving to a document db.

## The New Models
I decided to [give NeDB a spin](https://github.com/louischatriot/nedb) to see if it lives up to it's reputation as "The SQLite of document dbs". My first thought was just to write JSON to disk and move on (querying things with Underscore) - but let's see what we can do here.

The first thing is to write a sane model:

```javascript
var uuid = require("node-uuid");
var assert = require("assert");
var _ = require("underscore")._;
require("date-utils");
var Author = require("./author");

var Article = function(args){

  //can't have an article without a title and body
  assert.ok(args.title && args.body && args.slug, "Need a slug, title and a body");

  //we also need an author
  assert.ok(args.author, "Need an author");

  this.title = args.title;
  this.summary = args.summary;
  this.image = args.image;
  this.body = args.body;
  this.slug = args.slug;
  this.createdAt = args.createdAt || new Date();
  this.updatedAt = new Date();
  this.uuid = args.uuid || uuid.v1();
  this.status = args.status || "draft";
  this.allowComments = args.allowComments || false;
  this.postType = args.postType || "post";
  this.publishedAt = args.publishedAt || null;
  this.tags = args.tags || [];

  if(args.author){
    this.author = new Author(args.author);
  }

  this.setPublishedDates = function(){
    if(this.publishedAt){
      this.publishSlug = this.publishedAt.toYMD();
      this.prettyDate = this.publishedAt.toFormat("DDDD MMMM, YYYY");
    }else{
      this.publishSlug = null;
      this.prettyDate = null;
    }
  };

  this.isPublished = function(){
    return this.status === "published" &&
            this.publishedAt &&
            this.publishedAt <= new Date();
  };

  this.wordpressUrl = function(){
    if(this.publishedAt){
      var dateFragment = this.publishedAt.toFormat("/YYYY/mm/dd/");
      return dateFragment + this.slug;
    }else{
      return null;
    }
  };

  this.setPublishedDates();
  this.updateTo = function(changes){
    _.extend(this,changes);
    return this;
  };

  return this;
};

module.exports = Article;
```

There's a bit going on here, but with a little reading you should be able to figure out exactly what I'm doing. In the top block I'm setting the basic values with defaults where necessary. I then have some custom methods that do things like format a url for me (I might move this) and the setting of publication dates.

I added some helper modules that do nice things for you when working with Node:

 - [Underscore](http://underscorejs.org): a great utility library from Jeremy Ashkenas which sprinkles some Ruby love into your JS experience. I might [move to Lo-dash](http://lodash.com) later on... if needed.
 - [date-utils](https://github.com/JerrySievert/node-date-utils): I can't emphasize enough how much I love this library. Date math, nice formatting, some date sugar - it's great.
 - [node-uuid](https://github.com/broofa/node-uuid): a handy library that creates GUIDs for you. It will create them in sequential order based on time, or randomly.

This is a POJO (Plain Old Javascript Object) and it makes me very happy. I also defined an Author in the same way I've been doing:

```javascript
var assert = require("assert");
var gravatar = require('node-gravatar');

var Author = function(args){

  //gotta have an email and a name here
  assert.ok(args.email && args.name, "Need a name and an email");

  this.email = args.email;
  this.name = args.name;

  this.gravatarUrl = function(options){
    return gravatar.get(this.email, options);
  };

};
module.exports = Author;
```

Nothing shocking in here. I'm using the [node-gravatar](https://github.com/emerleite/node-gravatar) module to help spin up the authors image - other than that I simply need an email and name. I might do more with this later on.

I have 20 or so tests behind this - but I'll get to that next time as there's a bit of a runup to understanding what I did and why. For now, let's see how to work with NeDB.

##NeDB
Having a quick [look at the examples](https://github.com/louischatriot/nedb) (also, remember you can look in your `node_modules` directory for any module folder - look inside there and you can usually see an "examples" folder) we can see it's pretty simple to set up a DB and talk to it:

```javascript
var Datastore = require("nedb");
var db = {};
//set the articles explicitly
db.articles = new Datastore({filename : "./data/articles.db"});
db.articles.insert({slug : "test", title : "blah blah", author : "me"}, function(err,newArticle){
  console.log(newArticle);
});
```

That's it really. A couple of things to learn from this example:

 - there's only one "collection" level here; if we want to store Authors separately we'll need to create a new file... something like  `db.authors = new Datastore({filename : "./data/authors.db"})`. Not ideal - but it shouldn't be an issue (as we'll see in a second).
 - it works off the basic Node callback structure - no promises

A few other things about NeDB that might not be apparent:

 - You can do basic querying, but nothing as rich as MongoDB. There is no sorting and no setting of limits (more on this below).
 - If you open up the `articles.db` file, you'll see a text file full of JSON. NeDB is a thin layer of abstraction on top of storing data as JSON on disk. This is exactly what we need.
 - NeDB loads all documents into memory and works from an in-memory cache, only reading from disk when a change occurs. This makes it incredibly fast (see their benchmarking on the project page).

When I first saw the limitations of no sorts or setting of limits - I was about to walk away. Then I realized that I could probably do this easily using Underscore - especially if there's no read from disk.

But how do we wire this all together? I'll get into that next time.

## Summary, and Thoughts on Scaling
I like the models I have, and I like the flexibility I have with NeDB. Now, you might be thinking:

> Pumping all of your posts into memory seems like a scaling nightmare. How can you shard, replicate and do all the things people do when scaling servers?

That's a good question - but as [my friend Karl Seguin points out in his lovely Little Book on Redis](http://openmymind.net/redis.pdf) - the entire works of Shakespeare fill about 5.5Mb on disk.

Currently I have about 182 posts which come in at 250K or so (if that). I'm not worried about a memory footprint. In addition - there are numerous things to do with a blog when it comes to scaling:

 - caching services like [Cloudflare](http://cloudflare.com)
 - static caching of files as with Rails Page Caching (which I'm planning to implement)
 - making the data store "pluggable" so you can centralize it (which I might do)

For what it's worth - I've had my blog running on NestaCMS which statically caches pages - running on a LinuxVM with 1G of RAM up at MaximumASP for years. _It's never crashed_ even under ridiculous load.

I wrote [a post about PostgreSQL](http://rob.conery.io/2012/07/19/postgresql-rising/) that sat on top (literally number 1) for half a day which then hit Reddit and my server got flooded. MaximumASP saw the traffic and thought I was getting DOS'd so they throttled the switch - so some people saw a gateway error... but my site was still happily running.

Point being: I can lean on caching for a blog pretty heavily.

That's it for now...
