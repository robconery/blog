---
layout: post
title: "Alt.Tekpub: Consuming The API"
summary: "The best way to build an API is to use it while you're building it. At least that's what I find the most effective. But how am I going to consume this API?"
image: "/img/tumblr_lgq7hvUFtv1qdspyho1_500.jpeg"
date: "2012-03-18"
uuid: "51rBaJKl-o5qx-utis-vzW8-sKV4FLPjVHCx"
slug: "alt-tekpub-consuming-the-api"
categories: Tekpub JavaScript
---

## Take Nothing for Granted
As a programmer it's easy for me to think about ways that clients might consume [my API](http://wekeroad.com/2012/03/13/my-week-with-the-hypermedia-cowboys/). For instance - I'm imagining a few scenarios with Backbone, iOS, Android and WP7, for instance.

But the truth is ... **I have no idea how this API might be used**. But I can find out if it's useful - and that is to... drumroll... USE IT!

Rob Eisenberg [left this comment on my last post](http://wekeroad.com/2012/03/13/my-week-with-the-hypermedia-cowboys/#comment-464531782):

> If it were me, my next step would be to walk through the process of building a client of this API rather than working on the server implementation. Building the client will help draw out any assumptions a consumer may need to make about it.

Let's do it.

## What's a Client?
Over the last week I was on semi-vacation on the Big Island (Big Island Brewer's Festival) and I used this time to ponder what it means to consume a Hypermedia-style API. I could see the utility of the thing - but this is new stuff to me. I'm used to Rails-style REST and sending JSON back and forth (or maybe XML)...So I came up with **a plan: build one page using the API and see where it takes you.**

This led to a very strange back and forth and ultimately culminated with a strange understanding for me: I'm about to do something wonderful, or _incredibly stupid,_ with Backbone. Hear me out.

I started by wiping out everything on the home page that had been there before. Why? Because [all of that information is now present in the API](https://github.com/robconery/alt-tekpub/blob/master/lib/api.js). It seems rather strange to develop a separate "stream" if you will (views, partials, etc). Which is how things initially turned "weird" for me.

Alt.Tekpub is a website built on Node with ExpressJS and MongoDB. It's also an API (if I do things right) that can serve all kinds of clients. But isn't the browser the ultimate Hypermedia/REST client? If so - why would I *not* use my attempt at a Hypermedia-style API?

See where this is going? _Right into the sweet spot of theory vs. reailty_.

As I sit there with a completely blank page, I realized I needed to make a mental break between my website and my API. The web site was simply going to hand down some HTML and javascript. That javascript would tell the browser where the API is, and what to do from there.

Yes, I know, it sounds like I'm going in circles. But I decided to let it play out a bit.

Straight away I wanted to see how simple it would be to load up the page then request the API. That's simple for jQuery using $.get():

```javascript
<script>
$().ready(function(){  
  $.get("/api",function(data){   
    alert(data.title);  
  });
});
</script>
```

Short story: it worked fine and I had my JSON which you saw in my last post.

In that API are links to featured productions, channels etc - which would make more calls to the server if I wanted to - which of course I did since right now I have nothing on my page... hmmm...

## Sanity Check
Every alarm is going off in my head. Just how many GETs am I going to run here to just put some basic stuff on a page? I spose I'm OK with a single GET call ... no I'm not. And neither are you.This makes no sense whatsoever. Why would I make you, the page viewer, wait for even an extra millisecond if you don't have to just to satisfy some RESTful wonkery? I won't do it - I can't make myself create slower response times in the name of engineering.

But then... I do want to see this through to the end, and it's entirely possible this will all shake out somehow. So I compromised.

I decided to do what most devs do when working with Backbone in production: Seed the initial data load (Stripe, NYTimes, and just about every major production app out there does this).

Here's my Node code, in /routes/index.js:

```javascript
exports.index = function(req, res){  
  var preload = require("../lib/api");  
  preload.index.execute(function(err,result){     
    res.render("index", {preload: JSON.stringify(result)});  
  });
};
```
... and in the View (/views/index.jade):

```javascript
script(type="text/javascript")  
$().ready(function(){    
  tekpub = !{preload};   
  alert(tekpub.title);  //Welcome to Tekpub 
});
```
I'm dropping the JSON into a script block and assigning it as a variable to "tekpub". The "!{preload}" syntax here is a Jade View Engine directive that simply says "output the preload variable here".Planting JSON in a script block... hmmm. 

**This doesn't feel right**. I don't really like this - but at least I'm using the API to build the page. Let's keep rolling.

## Handlebars
Now that I have JSON on the page, I need to have a way to render it out so you, the client, can see it. This is where [Handlebars](http://handlebarsjs.com/) comes in - think of it as a View Engine for javascript in the browser. I chose it simply because I like Yehuda, it's fast, and it has some neat features - more on this in a later post.

I'll start by using the "special" object on my API, which describes a feature production that I want to highlight. In this case, it's [Hansleman's Art of Speaking](http://tekpub.com/hanselman) but my client doesn't know or care about this - only that there is a special production and it should show it prominently.

The Handlebars template code is pretty straightforward:

```javascript
script(id='special-template', type='text/x-handlebars')  
.row    
  .span8.special-production      
    h2{{lead}}      
      p <iframe width="680" height="420" src="http://www.youtube.com/embed/{{production.youtube_preview}}"></iframe>      
      p {{production.description}}
```

This is Jade syntax again. It's sort of like HAML but less noisy and faster. It relies on whitespace/indentation to know how to nest and render your HTML. The Handlebars stuff is in {{ token }} - which means "I want to render a value here".

Rendering it involves 3 steps:

```javascript
script(type="text/javascript")  
$().ready(function(){    
  tekpub = !{preload};    
  var source = $("#special-template").html();    
  var template = Handlebars.compile(source);    
  $("#special").html(template(tekpub.special));  
});
```

I need to pull the HTML from the template using jQuery (the "source" variable). Then I need to tell Handlebars to compile it. Finally I can use that template anywhere I please by calling it and passing in a chunk of data - which in our case is "tekpub.special" - the "special" production JSON object served from my API.And there he is! 

[![](http://wekeroad.com/img/2012/03/Screen-Shot-2012-03-18-at-9.57.07-AM.png "Screen Shot 2012-03-18 at 9.57.07 AM")](http://wekeroad.com/img/2012/03/Screen-Shot-2012-03-18-at-9.57.07-AM.png)

It loads very fast because we don't have to wait for the JSON pull from the server, so that's a good thing. But I can't help but feel like I've just created work for myself (as I'm sure you're sensing as well).

## Let's Take a Step Back... Bone
When you see something work during an exploration process it's imperative that you look at your creation qualitatively. And it doesn't take long for me to tell you, truthfully, that I don't like this. It makes no sense at all.

Which means that **my perspective is either wrong, or I'm doing something dumb**. Or both. Let's find out...

The whole goal of this exercise is to create a client that will consume an API. Am I doing that? Well... sort of. 

Not really - I'm creating a [turducken](http://en.wikipedia.org/wiki/Turducken) web app/api thing with javascript splattered all over the walls.

Yet I feel - no I know - that there's something more here. There's merit in this effort, I've just taken a wrong turn along the way.

It occurs to me that perhaps I need to stop thinking of Node as serving a web app altogether. This is really where I've been going, I spose - but it's all new territory to me and I'm not sure if it's Groovyville or Terror Town... but I need to find out.

Google made Ajax-driven sites (aka Single Page apps) fashionable with GMail and they nailed the experience. A single page loads, which then loads up all the assets and resources it needs... and off you go.

The compelling feature here is the speed of the interaction. Stripe does the same thing with their Dashboard and I love it. Does this mean AJAX ALL THINGS? No - but this approach really makes sense if I'm to lean on a Hypermedia API.

See where I'm going here? If I see Tekpub as a "Single Page App" (or at least significant parts of it) - then consumption of my API becomes very intriguing. Customer information is cached in the browser - Invoicing too. Serving of videos becomes insanely simple and the experience is a lot more interactive.

Doing all of this by hand would be utterly ridiculous. Using a framework like Backbone makes it simple (or Ember or whatever).Thoughts?

## Source Code
I need to add a README and a LICENSE (and a git ignore) but the source for this adventure [is up on Github.](http://github.com/robconery/alt-tekpub). Muse around, have some fun but don't rely on this being anything more than incredibly volatile. I'm treating it as a sandbox.
