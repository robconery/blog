---
layout: post
title: My Week With The Hypermedia Cowboys
summary: I asked for help with the Alt.Tekpub API from the RESTafari because I grew incredibly weary of the constant talk and Fielding quotes. Here are my results.
image: "/img/Baby-Giraffe.jpeg"
date: "2012-03-13"
uuid: "oBkWO7pX-q1UY-oExJ-V8Ri-Uc072hJf7ZJT"
slug: "my-week-with-the-hypermedia-cowboys"
categories: Tekpub JavaScript
---


## Hyperbole: Take a Break
I received a lot of help over the past few weeks from good folks like [Mike Amundsen](http://www.amundsen.com/blog/archives/1124), [John Sheehan](http://john-sheehan.com/post/18688963163/dont-build-the-best-rest-api-build-the-best-http-api),[Darrel Miller](http://www.bizcoder.com/index.php/2012/03/05/a-tekpub-api/), and [Steve Klabnik](http://blog.steveklabnik.com/posts/2012-03-08-transmuting-philosophy-into-machinery). Each offered a varying level of hands-on help and **I very much want to honor their efforts with the least amount of snottiness possible.**

I do have some strong opinions about the REST/Hypermedia thing - and I'll offer those at the end. First, however, I'd like to share what I've learned.

## Ideas
Many of the hardcore REST folks are getting into the idea of "Hypermedia". That's a bit of a vague term - but essentially "Hypermedia" is the big brother of "Hyperlinks" - meaning it can be text/html, images, videos - basically any content type you can transmit from one machine to another.

From what I understand - the idea of Hypermedia transcends HTTP as a transport mechanism. This is important to the REST guys because it gets away from the whole HTTP VERB thing and into content-type negotiation.

_I'm fairly certain I have this wrong. I'm leaving comments open so **feel free to correct me** - I'll amend the post. Just use small words._

Finally - and I feel this is incredibly important - Hypermedia is a Grand Idea. As far as I can tell (and I asked this repeatedly on Twitter) there is no "canonical" example of a "good" Hypermedia API currently out there (and no, the web itself doesn't count - more on that below). Or, at least, not that anyone can agree on.

I was directed to Netflix, Darrel sent me to Live Labs - and others offered examples of what a canonical Hypermedia API might look like if one existed.This, to me, means that **we're in High Theory Territory**. By definition there will be some rough edges, wrong guesses, and overall strangeness trying to build out something concrete (in the same way the earth could never be flat and man can't break the sound barrier).

## My First Pass
A Hypermedia API is supposed to offer all the information required, in the form of embedded links etc, so that a client can work with the API by following links and so on (just like you do with a web page). Ideally the API should be complete enough that "RTFM" should not be an issue.

If you consider (as many like to point out) the Web is "one big Hypermedia API" - it would seem silly to have to read the docs on every single web site in order to tell your browser how to use and render it. The browser understands the "text/html" content-type and when it sees certain tags, knows what to display.

If we crystallize that notion and remove the HTTP/HTML bit - we have Hypermedia. Again, I'm probably wrong here. But it's what I'm understanding at this point.

_**How do we do this with an API?**_ 

The first step is to decide the actual content we're going to pass back. [Mike](http://www.amundsen.com/blog/archives/1124) and [Darrel](http://www.bizcoder.com/index.php/2012/03/05/a-tekpub-api/) talk a lot about this choice - [Steve formalized it for me](http://blog.steveklabnik.com/tekpub-productions.html). I have to send _something _from my server to the client - and it has to be "formatted" if you will in some way.I like JSON - so I went with that:

```javascript The Start of the Tekpub API
var api = {  
  name        : "Tekpub's API",  
  description : "This is Tekpub's Hypermedia API. Possibly... lorem ipsum la la la"}
```
_I'm showing this as simple JSON for the moment - I'll get to returning it in Node in a minute._

This is the root document and should offer an entry point to our application just like Program.Main() does for any .NET app. In other words: this is the root document and should explain what people can do.

Given my requirements from the last post: _ people should be able to browse productions_, login and register. So what would that look like?

This is where understanding a Media Type is important. I could thrash around using something like Atom/AtomPub, I could also create a lot of work for myself using OData - but this API is very simple, so I'll keep the concepts low and rely on a common sense understanding:

```javascript The Basic API
var api = {
  name : "Tekpub's API",
  description : "This is Tekpub's Hypermedia API. Possibly... lorem ipsum la la la",
  queries : [
      {name: "All Productions",        url : "http://tekpub.com/channels"},
      {name: "Microsoft Productions",  url : "http://tekpub.com/channels/microsoft"},
      {name: "Ruby Productions",       url : "http://tekpub.com/channels/ruby"},
      {name: "JavaScript Productions", url : "http://tekpub.com/channels/javascript"},
      {name: "Featured Productions",   url : "http://tekpub.com/channels/featured"},
      {name: "Recent Episodes",        url : "http://tekpub.com/recent"}
  ],
  actions : {
    login :    {
      url : "https://tekpub.com/sessions/",
      method : "POST",
      fields : [
        {name : "email",               description : "Your tekpub.com email address"},
        {name : "password",            description : "Your password"},
      ]
    },
    register : {
      url : "https://tekpub.com/customers/",
      method: "POST",
      fields : [
        {name : "email",                description : "Your tekpub.com email address"},
        {name : "password",             description : "Your password"}
        {name : "confirm",              description : "Password confirmation"}
      ]
    }
  }
}
```

And there you have it. There are a number of very interesting ideas at play here - not the least of which is the clarity of what you can do with the API (which I really like). It's self-descriptive and more than that, self-propelling.

If I were to use this API in the browser with a template engine (Handlebars or jQuery templates) - I could consume the API and bind the template directly to "actions.login.fields". The API even offers up descriptive captions!

... and at this point, you're hopefully seeing something a bit more here. This isn't just a JSON data transmission in the same way that HTML sent to your browser isn't just an "HTML data transmission". In this JSON document are all the client needs to move around our application and use it in the way it's intended.

And, just like HTML: if we change the API in the future - perhaps we require a first and last name - the client can render it out directly and not break (if it binds directly to the API... which it probably should since it's a Hypermedia API...).

## Scaling
Of course, this is just the root document and building this out could be a whole lot more difficult that I expect. I'm hoping, however, that if people see issues with the API - they'll jump in and help with a patch.Moving forward, I can see how using "api.queries[0]" sorta sucks - I'd like to have a name in there so I'll change that. I also need to consider what's returned in a list of productions, and also what else I need to show. I also need to be sure that whatever naming I use (so far I have "queries", "actions" etc - which is where the formalized content-type comes in) I stick to it.

I can't see any reason why an API like this can't scale with the application - if you see something please yell.

## Implementation
The big question: how do I use it already! I'm using ExpressJS with Node so it's kind of a trivial matter to set this up in a single document - let's call it "api.js" and stick it "./lib":

```javascript Wrapping the API In a Node Module
exports.root = {
  name : "Tekpub's API",
  description : "This is Tekpub's Hypermedia API. Possibly... lorem ipsum la la la",
  // ....
}
```
ExpressJS maps urls to routes, just like Sinatra (I’ll get into this in a later post) so in my “root” route, I can do this:

```javascript Exposing the API in a Route
exports.index = function(req, res){
  api = require('../lib/api.js');
  res.header("Content-Type", "application/vnd.tekpub.productions+json");
  res.send(api.index);
}
```



I’ve amended the content-type here so people know what they’re dealing with, but it sort of seems like a bit too much ceremony. I talked to Darrel Miller about this at length over Skype and he suggested that as long as the client can see that the media type is “Tekpub-flavored” – then we can do without the filigree.

Implementing that, we get:

```javascript Exposing the API with Altered Content Type
exports.index = function(req, res){
  api = require('../lib/api.js');
  res.header("Content-Type", "application/json, profile='tekpub-flavored-json'");
  res.send(api.index);
}
```

## Some Opinions
_(lifting the ban on Hyperbole)_

Hopefully you can see the utility of an API like this. I can – but I also am keeping a healthy dose of skepticism until this baby giraffe starts to walk. Ideas are neat, but basically we have a bunch of super smart engineers discussing some high theory as if it were tried and tested.

And it’s not. Now here is where I would be told that “The WEB is REST/Hypermedia Dude!” and that’s true. Sort of. The web is the web and we deal with the realities of HTTP, HTML, and the dominance of “get ‘er done” scripters. I like the Hypermedia approach, but I wonder if it’s far too lofty/theoretical to ever engage mainstream devs.

All in all, I had a reasonably enjoyable time trying to figure this all out. I’m sure I’ve made many mistakes in this post and I invite you to help me out. I also invite you to help me get this giraffe to walk – because as far as I can tell, it’s sitting there looking like it should walk… wants to walk…
