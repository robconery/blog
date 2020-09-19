---
layout: post
title: "Minty: Defining the Model"
date: "2013-11-20"
uuid: "7a7f32b5-ac61-412d-8085-296f9ceec61b"
slug: "minty-defining-the-model"
image: /img/10188.png 
categories: Node
---

## What's a Model?
If you're a Rails fan, a Model is where you drop validations, hooks, and some custom methods.

In .NET it might be a place to define what Entity Framework shoves into your database for you (with some special sauce annotations).

In Node... it's all of these things. You can choose to use a full-blow ORM, a simple query tool... or something in between. People have even adapted Backbone's Model to work with databases! It's called [BookshelfJS](http://bookshelfjs.org) and it's what the Ghost team is using.

How you model your app is **incredibly important** because people will be picking it up after you've moved on - no matter if it's you're own creation or something you've created at work.

I call this the [Ayende Test](http://ayende.com):

![seriously?](/img/seriously.jpg)

> How hard is it going to be for me to figure out how the datas gets into the database?

When working with Ghost I wanted to add the ability to save a post image so I decided to see how posts are saved in general. The Ghost admin UI is a Backbone app that talks to their API which is a set of Express routes.

I [started with this file, which is the api](https://github.com/TryGhost/Ghost/blob/master/core/server/api/index.js) and worked my way backwards. See if you did better than I did at finding it.

To me this is the first thing that people are going to want to know:

> How are you dealing with your data

I'd like to make it obvious, so let's do it!

## Setting Up Sequelize
[Sequelize](http://sequelizejs.com/documentation) allows you to define your model in database terms. I don't like the idea of thinking about this as a true Model, so I'm going to call it a Schema and attach my table definition to it.

First thing, however, is to install Sequelize and crack open a schema.js file:

```
npm install sequelize-sqlite --save
vim models/schema.js // I might move this
```

Start out by requiring Sequelize and creating a constructor which will take connection information:

```javascript
var Sequelize = require("sequelize-sqlite").sequelize;
var assert = require("assert");

var Schema = function(conn){
    //the db location is required
    assert.ok(conn && conn.db, "Need a db setting here");
    //may not be necessary, but I'm paranoid
	var self=this;
    
    //setup the DB connection
    self.db = new Sequelize('minty', 'minty', 'password', {
    	dialect : "sqlite", //make this configurable later
        storage : conn.db,
        logging : true
    });
    
    return self;
}

module.exports = Schema;
```

Here I'm following what the Sequelize docs say to do and I'm hard-coding (for now) a connection to sqlite3. I may change this... I may not.

The first line makes sure we have some arguments - I'm using Node's built-in assertion library to confirm we have a connection argument, and that it has a db setting.

The next line is making sure I keep a reference to `this` to avoid Javascript's notorious scoping issues.

The final bit is simply telling Sequelize where the database is and how to behave. 

## Synchronization
One really handy thing about Sequelize is that it allows you to role your schema to your database just like EF's code first or DataMapper's auto_update feature.

To do this, I'll setup an explicit `sync` method that will drop/reload our schema. Once again, this is `schema.js`:

```javascript
var Sequelize = require("sequelize-sqlite").sequelize;
var assert = require("assert");

var Schema = function(conn){
  
  var self = this;
  
  //..
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

There was a lot that just happened right there, so let's break it down.

### Node's Callback Idiom
When working with Node, you'll start working with callbacks (or continuations which is usually the case). I'll assume you know what these things are - if you don't [have a read here](http://recurial.com/programming/understanding-callback-functions-in-javascript/) as they Mike Vollmer explains it much better than I can.

Callbacks have an idiomatic structure in Node - if you follow this way of doing things, your life will be much much easier. It is simply this:

```javascript
callback(error, returnValue);
```

You'll find this pattern everywhere in Node. Here's an example:

```javascript
var myFunction = function(args, next) {
	//let's get some data...
    args.db.getSomeData(function(err,data){
    	if(err){
          //pass the error along without a return value
          next(err,null);
        }else{
          //no error! Yay! pass what was passed here
          next(null,data)
        }
    });
}
```

We're accepting a function as the second argument to `myFunction` here and we'll need to invoke it when operations are done. We can do that explicitly, as above, or we can avoid some extra code and _lean on Node's idiom_, knowing that the callback passed in is **expecting two arguments (err,returnValue)** - thus we can rewrite things:

```javascript
var myFunction = function(args, next) {
	//let's get some data...
    //and pass along our callback
    args.db.getSomeData(next);
}
```

This last example is why you want to structure your callbacks the Node way - it really helps Callback Hell.

### Promises
Node used to have promises built in, but they took them out long ago. You can still use them if you want using the When or Q libraries - but I tend to favor simple callbacks.

Anyway - that's another thing you see in the sync code I wrote above:

```javascript
  self.sync = function(next){
    self.db.drop().then(function(){
      self.db.sync().then(function(err,result){
        next(null,{success : true});
      });
    });
  };
```

All of the ".then" stuff here is a promise, which is an explicit way of saying "when you get back from dropping the database I want you to run sync() and then I want you to fire the next callback".

This is counter to Node's callback idiom, but you find it often. My use of "then" here can also be "success" and "error" depending on the result of the chained operation.

OK - let's get back to the code.

## Wiring It To Our Tests
I need to define an Article and then sync it when my tests run. First thing, let's use Sequelize's facility to define our Article:

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

A pretty basic definition. Now let's wire this up to our tests:

```
vim test/writer_spec.js 
```

I want to use the `before` hook with mocha to drop/reload my database before all my tests run. I do this by dropping it in the outermost describe block:

```javascript
var Schema = new require("../models/schema");
describe("Writers", function(){
	before(function(done){
		var schema = new Schema({db : "./test/test.db"});
        schema.sync(function(err, success){
        	//tell mocha we're done with the before block
        	done();
        });
    });
    describe("creating a valid article", function(){
        it("is successful");
        it("creates an article");
        it("sets the title, body and slug");
        it("sets the status to draft");
        it("does not create a version");
    });
});
```

Here we're passing a hook into the before function called "done". Mocha will wait until we call "done" before it fires the rest of the tests - this is how you do asynchronous testing with Mocha. It also works with "it" blocks.

One nice benefit of wiring our tests up this way is that every time we run it, our database gets reloaded and our schema updated :).

## What About The Ayende Test?
Right now I have my Article defined in a single file called "schema.js". I plan on passing it into dependent classes directly, one of which is what I'll be creating next: **the Writer class**.

I'm over 1200 words on this post so I'll kick that to next time...