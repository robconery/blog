---
layout: post
title: "Alt.Tekpub: Working More With The Hypermedia (style) API"
summary: "Continuing on with building out a NodeJS app with Express and other buzzwords  - I decided to build out a page using my API, while I build the API."
image: "/img/Balancing-Act-001.jpeg"
date: "2012-03-22"
uuid: "SeKcPdAX-YrtS-vdEo-tyUn-yAk75LJLIny5"
slug: "alt-tekpub-working-more-with-the-hypermedia-style-api"
categories: Tekpub JavaScript
---

## In Progress
I wanted to re-iterate, one more time, that **this is a work in progress so some of the things you see me do won't make sense in a grander scheme**. For instance - in production I probably wouldn't have the entire home page content load with $().ready() and a GET call to my server. That's kind of dumb.

Yet it makes sense if you want to be sure that you're giving your future clients what they need to build an app on top of your API. Let's see what that looks like.Also, I wanted to mention again the code is up at [http://github.com/robconery/alt-tekpub](http://github.com/robconery/alt-tekpub). It's a major work in progress and it's there as reference, not for consumption.

## Expanding The API
I've decided to build out a Single Page App and see what happens. I know this sounds stupid to quite a few people - but again this is a workout for the API mostly, helping it take shape. But what shape is that?

Let's put on our native (aka thick) client hats - pretend we're building an Android/iPhone app. You scroll around and find the Tekpub icon and press it. What do you expect to see next? Me, personally, I would expect to see (in terms of data):

- Some sort of intelligent list of productions (intelligent meaning not just a data dump)
- A sense of "state" - whether I'm logged in, what I can watch, my profile stuff, etc.

This means, basically, that **the API needs to "prime" the application** with a good amount of information from the start. Initially I provided a bunch of links (GETs) to pull production data as-needed, but this doesn't make much sense - the client apps will need this data no matter what.

In addition, I need to send down client information as well. If some type of token is passed in I can look the client up and populate the Customer stuff - I'm going to punt on that right now as it's really involved, I just want to take small steps for now.

Let's switch over to the client now - see if what I'm musing makes sense. I'll be using basic Javascript/CoffeeScript at this point - you'll see both as [I haven't really made up my mind](http://wekeroad.com/2012/03/21/coffeescript-or-straight-up-js-i-suck-either-way/) as to which I'm going to use.

## The Client
I'm going to build the client bits out in CoffeeScript as I don't know Objective-C and I think I can approximate a decent Client/Server situation using Javascript. 

The first thing I need to do is make sure the API is exposed. I've already created an [API route and wrapper](/2012/03/18/alt-tekpub-consuming-the-api/) (which I'll refactor later) - and if I go to localhost:3000/api I get a lovely splash of JSON:

![](/img/Screen-Shot-2012-03-22-at-11.01.56-AM.png "Screen Shot 2012-03-22 at 11.01.56 AM")

Previously I stated that I couldn't bring myself to use a $.get() to pull this code down - favoring a preload instead. I'm going back on that for now as I want to see how responsive this API is.

But how do we consume this?

Looking over the JSON, it's a nice description of Tekpub and what you can do with it. So let's create a Tekpub object:

```coffeescript
class Tekpub  
  constructor: (preload) ->  
    @special = preload.productions.special  
    @featured = preload.productions.featured  
    @blurb = preload.blurb  
    @title = preload.title  
    @customer = preload.customerwindow.
    Tekpub = Tekpub
```

In short, this function literal will take a preload of JSON data and set some literals internally. This means that my blob of JSON has to be organized to distinguish "special" and "featured" productions. I didn't have this before - what I had was GET urls for loading this data.

Let's switch back to the API in Node and see how this can work. This is written in Javascript.

## The API
The overall approach is starting to crystallize a bit in my mind. I'm going to preload an object on the client with JSON so it can operate as needed, right from the start. I don't want to go too far, but here's what I think is reasonable: Load all productions. 

I don't know how the client will want to use them - just send them all down.Run the filters for the client - no need to make the client do the filtering. I could send the criteria down for the filtering, but that's putting a bit too much in the hands of the client. Yes, I know it's a bigger JSON load but it's not that much, really.

I need to send some stubbed Customer information. Sorry for the huge picture here - it's a lot of code. I'm using a picture because this will change, I'm sure of it:

![](/img/Screen-Shot-2012-03-22-at-11.14.04-AM.png)

One thing to notice: "productions.all" is stubbed. Same with "productions.featured.productions". This object literal here is a bit of a "template" if you will. The "_execute" function will populate it:

```javascript
  var _execute = function(callback){    
    Production.all(function(err,response){      
      result.productions.all = response;           
      special = response.filter(function(p){        
        return p.slug == "ft_speaker";      
      });      
      result.productions.special.production = special[0];      
      result.productions.featured.productions = response.filter(function(p){        
        return p.slug == "mvc3" || p.slug == "ft_triage_oren" || p.slug == "ft_speaker";      
      });      
      callback(null,result);    
    });  
  };  
  return {    
    execute : _execute  
  }
```
We're hitting the database (Production is an object that abstracts basic queries - I'll talk more about that later) and pushing the resulting docs (response) into productions.all. Then, we're filtering those results, dropping them into featured and special.

This will work for now - not sure how well it will scale if we move to 1000 productions :) but it makes a nice proof of concept.

Now that we have the data - let's wire up the Client.

## Back To The Client
I don't like having templating script blocks all over the view pages. They look a bit wonky in my mind, so I'm going to put them into partials. I'll create two partials: specialTemplate and featuredTemplate.

Tekpub has the notion of a "Special" production - one that we're exceedingly proud of. So let's build that template and stick it onto the home page (again, this will change so I'm just snapshotting the code. If you want it, it's up at github):

![](/img/Screen-Shot-2012-03-22-at-11.23.55-AM.png)

This is Handlebars.js - it's exceedingly fast and pretty easy to understand. I'll inject the "special" data into it, and it will render out the production YouTube preview as well as some nice quotes.

Next, I need to render it somehow. I can add this to my Tekpub client object:

![](/img/Screen-Shot-2012-03-22-at-11.26.24-AM.png)

This code takes the JSON assignment (preload) and renders a template that I specify. I'm trying to lean on conventional naming so I don't need to execute the same template rendering code all over the place - but in short loadTemplate() will find the "specialTemplate", compile it, and then render it with the "@special" data - which is populated in the constructor.

Now I need to do the same for featured.

![](/img/Screen-Shot-2012-03-22-at-11.28.51-AM.png)

There's something tricky going on here. Notice the "include" statement? That's how the Jade ViewEngine works with partial views. I know I'll be reusing that production view and I'm trying to keep these templates as clean as I can. So I need a 3rd partial to work with - and I'll call it simply "production.jade": 

![](/img/Screen-Shot-2012-03-22-at-11.30.40-AM.png)

Things are really starting to take shape. I have my views, my partials, some client script and an updated API. Let's make it work.

## Hooking It All Up
Back on the index view (my home page) I need to render out the partials, as well as make sure that I'm calling the API and loading up my Tekpub client object with the API data. Might seem like a lot - but my view is exceedingly light. LOVE IT:

![](/img/Screen-Shot-2012-03-22-at-11.33.11-AM.png)

I have to say - that was pretty easy and took me about 2 hours to stitch together. 

Have a look:

![](/img/Screen-Shot-2012-03-22-at-11.34.12-AM.png)

## Thoughts
I always look for a time during an "exploration process/spike" where things start to flow and make sense. This was one of those times. The lightness of the code (in my eyes) and the way I was able to hand off small chunks of process and layout - it really felt good to me.

One thing in particular that I wanted to dive into was using CoffeeScript alongside Javascript to actively build something out. Specifically I wanted to see if the negative things were actually negative things. I did get tripped up a bit once or twice - but in the end, reading the Tekpub class code above was more than compelling for me.

I like the aesthetics of it. Then again, I also like Ruby. What do you think?

Also, as I was building this out I was starting to see the divide between what Backbone can handle, and what I don't need Backbone for. Simple presentation like this - I don't need Backbone for. However when it comes to adding things to an Invoice, switching the view around for previews/downloads and purchases - yeah Backbone will work great.That comes next.
