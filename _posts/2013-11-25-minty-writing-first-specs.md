---
layout: post
title: "Minty: Writing The First Specs"
date: "2013-11-25"
uuid: "94ef5e9b-f253-4b79-b5cb-89902f9ce22f"
slug: "minty-writing-first-specs"
image: /img/marionette_by_threa_d38w20x.jpg
categories: Node
comments: true
---

## Where To Start?

All I have right now is the notion of an Article - a pretty basic idea of a "model". I hesitate to call it a model because the only definition I have for it is a table schema in my Schema.js file:

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
  //...
  return self;
}
module.exports = Schema;  
```

This is a problem for me. I don't like (and have never liked) mixing the notion of a table with a model because it never "scales" over time, for me at least. There's always a bit of complexity that creeps in and you find yourself bending your DB to accomodate your code, or vice-versa. For now I'm not going to worry about it.

_**Note**: I'll address this specifically in the next post_.

Now what I want to focus on is how this Article is going to be used and this is where we can get into lengthy debates about "keeping it simple" vs. "doing the needful".

I've found over the years that if I do a "basic" separation right from the start between Things vs. Processes then changing my code later on is less painful. Let's see what that means - skip ahead if you don't like philosophical tangents :).

##Things vs. Processes

I like to start off by thinking aloud about what our app is going to do with the pieces I have defined thus far:

> A Writer writer writes and Article. An Editor changes the Article and gives it context.

Seems pretty clear. My "Thing" is an Article, "Writing" and "Editing" are my processes. Let's go with that and define a Writer class:

```javascript
var assert = require("assert");

var Writer = function(schema){
  //we need to have a db to talk with
  assert.ok(schema, "Can't function without a db");
  var self = this;
  self.createArticle = function(args, next){
    //add to the db...
    //call next()
  };
  
  return self;
}

module.exports = Writer;
```

Here I'm using a simple constructor to kick up a Writer "class" (JavaScript is a classless language but many use the term "class" to describe what I've just written). 

But is this going to conform to my tests? Let's see...

```javascript
describe("Writers", function(){  
    //...
    describe("creating a valid article", function(){
        it("is successful");
        it("creates an article");
        it("sets the title, body and slug");
        it("sets the status to draft");
        it("does not create a version");
    });
});
```

There's obviously some workflow here, and this means that I can't just shove some data into the database and be done. There are validations, status checks, versioning...

This tells me two things:

 - I need to create a process
 - I need some meta data about this process (if it's succesful, why it's not, what happened, etc)
 
I need to expand my thoughts on what exactly is happening here, and to do that I'll once again lean on plain English to tell me what to do:

> A writer creates a draft edition of the Article

This suggests a few concepts to me: Draft and Edition. [The definition of edition](https://www.google.com/search?q=define:edition&ie=UTF-8&oe=UTF-8) is (basically) the a form or version of a document. An "edit" is one or more changes to a document.

I'm tempted to create a meta-wrapper class called "Edit" which I think is more grammatically correct, but I also think it would be incredibly confusing to people as it's pretty general.

So let's use the term Edition (knowing we can change our minds later) and create a wrapper class.

## The Edition

This is the simplest thing I need for now:

```javascript
var Edition = function(args){
  args = args || {};
  return {
    success : args.success || false,
    message : args.message,
    article : args.article,
  }
};

module.exports = Edition;
```

When a Writer creates a Draft, the Edition will be the result. We'll be able to know if things are successful and, conversely, if things went wrong. Now let's think about the document creation process.

## Refining Our Specifications

I want to define things in terms of behavior. If I were Unit testing I'd probably kick up a suite of tests for validations, etc:

```javascript
describe("Validations", function(){
  it("validates the presence of a title");
  it("validates the presence of a slug");
});
```

This works fine, but as I mention I like behavioral testing because it's more intuitive (at least to me). Let's rewrite this in the form of BDD specifications:

```javascript
describe("Creating a Draft", function()){
  //happy path
  describe("with a valid Article", function(){
    it("is successful");
    it("creates an article");
    it("sets the title, body and slug");
    it("sets the status to draft");
    it("does not create a version");
  });
  
  //what happens when it's submitted...
  describe("without a title", function(){
    it("is not successful");
    it("provides a useful message");  
  });
  describe("without a slug", function(){
    it("is not successful");
    it("provides a useful message");  
  });
  describe("without a body", function(){
    it("is not successful");
    it("provides a useful message");  
  });
  describe("without a tl;dr summary", function(){
    it("is successful");  
  });
  describe("without an Author", function(){
    it("is not successful");
    it("provides a useful message");  
  });
});
```

I'm not a BDD purist, but at it's core BDD is all about examining behavior of a given feature (in this case creating an Article) when certain scenarios happen.

It's easy to get lost in the jargon or think you need some special tool - I don't think so. My process is:

 - Think concisely about the feature
 - Create the Happy Path (when everything goes right, what happens)
 - Create the What Happens When I Do This stuff
 
To me, it's critical to do the Happy Path first - you **always want this to succeed** as you test your assumptions.

## Testing ONE Object At a Time

Another thing I like to do is make sure I have one result under test for each inner describe block. So, for our first test I'll do something like this:

```javascript
describe("Creating a Draft", function()){
  var result = {};
  var testArticle = {
    title : "Test", 
    slug: "test", 
    body: "lorem ipsum",
    author : "Me",
  }
  before(function(done){
    result = myApp.createDraft(testArticle ,function(err,createResult){
      result = createResult;
      done();
    });
  });
  //happy path
  describe("with a valid Article", function(){
    it("is successful", function(){
      result.success.should.equal(true);
    });
    it("creates an article", function(){
      result.article.should.be.defined;
    });
    it("sets the title, body and slug", function(){
	  result.article.title.should.equal("Test");
      result.article.slug.should.equal("test");
      result.article.body.should.equal("lorem ipsum");
    });
    it("sets the status to draft", function(){
      result.article.status.should.equal("draft");
    });
    it("does not create a version");
  });
});
```

I do one operation, and every assertion I make analyzes the result of that operation. This keeps your tests clean (usually just one line) and fast (not hitting the DB, running logic, or instantiating unneeded things).

All of these specs should be failing hard right now as we don't have the code in place.

I'll do that next time.