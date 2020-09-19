---
layout: post
title: A Dynamic Data Utility for WebMatrix
summary: "I promised myself I'd never do this again: create an ORM-y/Data Tool for .NET. But I needed some utilities for some work I'm doing, and I extracted the databits because I can't help myself. I like to share - mom taught me right."
date: "2011-02-07"
uuid: "blQCJaZ4-C8VU-ILug-Qhg5-v8g9gZothf1a"
slug: "the-super-dynamic-massive-freakshow"
categories: Database
---

## I Suppose It's Not an ORM


There's no Object, no Relational Mapping - it's all Dynamic - %100. It's not terribly structured either - I'm shooting for simple simple simple with a "Rails" flavor to it. There are other alternatives out there that embrace WebMatrix.Data - [Mark Rendle's Simple.Data (https://github.com/markrendle/Simple.Data) comes to mind.

There's nothing wrong with Mark's stuff - in fact [it looks very compelling.](http://blog.markrendle.net/2010/08/05/introducing-simple-data/) I'm just after something a bit different. I should mention that I mused on this over the weekend and currently I have everything compressed into 360 lines of code (give or take).

The LOC is important to me - I don't want to have a DLL that I can't tweak. I love the simplicity and transparency of a single code file.

Before I get to the code - I'll be talking about this and a few other neato things tomorrow (Tuesday 2/8/11) at the [MVC Conf.](http://www.mvcconf.com/). If you're not busy - drop by and I'll show it in action starting at 11am PST.

## Signatures

I don't mind writing inline SQL. Sort of - I don't mind writing SELECT queries, but INSERTs and UPDATEs bother me for some reason. I'd much rather write something like this:

```csharp
var table = new Products();
table.Insert(new { ProductName = "Jumbo Shrimp" });
//fix the name of product ID 10
table.Update(new { ProductName = "Da Kine Pig"}, 10)
```

Or something like

```csharp
var table = new Products();
dynamic thingy = new ExpandoObject();
thingy.ProductName = "Poi Poppers";
table.Insert(thingy);
```

Or maybe sidestep the whole object/dynamic thing:

```csharp
var table = new Products();
//make sure you have a whitelist!
table.Insert(Request.Post);
```

And that's what I made.

## DynamicModel


I wanted to stay as close to the "metal" as I possibly could. This (to me) meant that I didn't want to worry about Types, Tracking Containers, Contexts and so on. What I did want to do is describe my table - and this is the only type I have (which, ironically, is a Dynamic type):

```csharp
public class Products:DynamicModel {
    public Products():base(Database.Open("northwind")) {
        //set the PrimaryKeyField
        PrimaryKeyField = "ProductID";
        
        //I could optionally set the TableName too
        //or I could rely on convention, using the class type name
    }
}
```

In this class I'm using DynamicModel and setting the PrimaryKeyField. I don't need to do that, it would default to "ID" if I didn't. From here I can do fun things like run the Inserts/Updates above, or Selects:

```csharp
var table = new Products();

//all products
var products = table.All();

//products from category 5
var productsFive = table.All("where categoryID = @0", 5);

//get a single product
var product = table.Single(2);
```

That last line there is probably one of the more complicated aspects of the bits I wrote. Normally WebMatrix.Data would return a thing called "DynamicRecord" - which is basically a DynamicObject with some meta data that describes a database interaction.

I want to be able to use what I pull from the DB - so I set the rule that whatever comes out of the DB is an ExpandoObject - then I can set whatever I want on the object and send it back in:

```csharp
var table = new Products();

//get a single product
var product = table.Single(2);
product.ProductName = "Lomi Lomi Salmon";
table.Save(product);
```

It's also worth mentioning that I don't need to use any of these constructs - I can just use "table.Query" and "table.Execute" and send in raw SQL. The main point is to save time where possible - get out of the way the rest of the time.

## Validations


This is where the "Rails-y" part comes in. I really like model-level validations and how simple it is to "wire up" a set of validators on your model.

I **tried** to do that with `DynamicModel` - allowing you to wire in your validators in the constructor of your class:

```csharp
public class Products:DynamicModel {
    public Products():base(Database.Open("northwind")) {
        //set the PrimaryKeyField
        PrimaryKeyField = "ProductID";
        
        //this is a bit wordy - but I think it works
        ValidatesPresenceOfAlways("ProductName");
        
    }
}
```

If you use `table.Save()` or `Update()` or `Insert()` - these validations will fire. Currently there are 3 main types:

 - PresenceOf
 - Numericality
 - Custom
 
The custom validator works with a delegate (`Func`) that gets fired for the event you wire it to (insert, update, or both):

```csharp
public class Products:DynamicModel {
    public Products():base(Database.Open("northwind")) {
        //set the PrimaryKeyField
        PrimaryKeyField = "ProductID";

        //make sure that category id is between 1 and 5
        ValidatesOnInsert("Category ID Must be between 0 and 5", x => {
            return x.CategoryID > 0 && x.CategoryID 

```
It's simplistic - that's for sure and there's a lot more thought to put into their use. There are a number of validators out there that I could lean on - but they're focused on Statically Typed stuff. When you're working with dynamic/expando there are some gray areas.

Specifically - if you have a "ValidatesPresenceOf('CategoryID')" and you pass in an anonymous type like this:

```csharp
var table = new Products();
table.Update(new { ProductName = "Da Kine Pig"}, 10)
```

Is the `CategoryID` not present? Well, literally, that's true - but it *is* present in the database and we're not trying to change that. Although it's also possible that I could drop in a `CategoryID == null` here too, even though that would be silly.

I don't know - I might rip these things right out. Just thought I'd share where I'm at with them currently.

## Why Did I Do This Again?


The short answer is that I needed it. Mark's work (link above) is fine - but didn't do what I was hoping at the time. I just wanted a bit of a "utility" - not a full blown framework for running data. If Mark can the stuff I've kicked up here - hooray! I'd be happy to fork and contribute when it's ready. I'm not looking to start up Yet Another Data Access Tool.

My other goal is to show the possibilities of "Thinking Dynamic" with a light framework like WebMatrix. This is a super-raw prototype, but with a bit of polish it can take a large chunk of time out of your data work.

If you're wondering where the code is - I'll push it to Github in the coming weeks. I'll probably extract a few more things from what I'm doing, and I also need to make sure that it's not just plain stupid what I'm doing.

I also want to work in support for Transactions. At it's core, WebMatrix.Data uses System.Data.Common - and allows you to work directly against the Connection, which means you can send transactions in.

This is immensely helpful for large data transactions - I just need to figure out how to work it with a simple concept. I don't want to kick up an object tracking container, but I do have some ideas in the back of my mind.

## A Bit of a Teaser


If you do drop by MVC Conf tomorrow, I'll show you the other fun thing I've been working on for both MVC Conf and [Tekpub's forthcoming WebMatrix Production.](http://tekpub.com)
  
Like this little data toolio - it's not completely ready for prime time, but it's working for the most part.

Here's some pics:

![](http://rob.conery.io/img/massive-test.png)

![](http://rob.conery.io/img/massive-results.png)