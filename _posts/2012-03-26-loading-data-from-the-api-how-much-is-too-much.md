---
layout: post
title: "Loading Data From The API - How Much Is Too Much?"
summary: "I'm really liking what's coming together with this Hypermedia-ish API. So many ideas and approaches are starting to come into focus. Like this one: how much structured data do I pass on the initial load of the API?"
image: "/img/startingline1-500x337.jpeg"
date: "2012-03-26"
uuid: "F0iX0M6N-KfvU-ZXSI-ozQn-Cdz7AIBTpxD0"
slug: "loading-data-from-the-api-how-much-is-too-much"
categories: Tekpub JavaScript
---


## Data Or Code?
Here's the deal: the API i'm putting together for Alt.Tekpub is starting to "formalize" itself into an initial "burst" of data, with "auxiliary" stuff requested later on. At this point I need to reduce the chatter - so I'm handing down a structured JSON set from the get go:

[![](http://wekeroad.com/img/2012/03/Screen-Shot-2012-03-26-at-1.31.19-PM.png "Screen Shot 2012-03-26 at 1.31.19 PM")](http://wekeroad.com/img/2012/03/Screen-Shot-2012-03-26-at-1.31.19-PM.png)

You'll notice the "productions" bit is an empty array - that gets set by a query call later on.The thing I'm facing right now is this:

> Do I organize the productions into semantic groups, then send? Or do I just send that information down and let the client do what it will?

Let's review the options shall we?

## Option 1: Structure This In MongoDB
The interesting thing that's happening here... sort of... is that my API is starting to define a document structure that at some level I can just store and edit later on. If I went full tilt down this road, I'd end up with one document in my database.

**And that's dumb**.

The good news is that MongoDB helps you with this structuring and through a bit of Map/Reduce and some other means, I can whip out a nice API document and send that down. The bad part is that the API document would have lots of repeated data and basically be 100K bigger than it needs to be.

The code on the server is ridiculously light, but the code in the DB grows a bit. It's all javascript so... hmmm.

## Option 2: Knit Up The API Using Node
That's sort of what I'm doing now. I can see how I could peel off a single "Tekpub" document and then assemble it with Node. The categories would have productions embedded, features would again have embedded productions, and the productions array would have yet more productions.

This is highly repetitive and again an extra 100K (which really isn't all that much). The engineer in me hates this. The UI programmer digs it as it's less client code I need to write...

## Option 3: Roll It To The Client
Right now the productions have tags - so I can figure out rather easily how to pull out Microsoft, Ruby, JavaScript stuff and so on:

```javascript Filtering The Ruby Productions
var _ruby = function(){  
  return data.productions.filter(function(p){    
    return p.tags.indexOf("ruby") > -1;  
  });
}
```

The upside here is that the client has a lot more freedom in how to display the information. The downside is that I've shifted some responsibility "down stream" and that doesn't feel too good for some reason.

## My Gut Feeling
It seems a good rule of thumb: **less is more when you're coding... anything**. Duplicating data just doesn't seem like any kind of win. 

I talked to Derick about this today and his opinion was that "normalization isn't really a concern when doing an API load" and I agree - this puts a burden on the client to structure the data and it defeats the purpose of a sweet chocalatey API.

It's just not clear! The API has a notion of "Channels" and the link is just not obvious - that the "tags" on each production denotes a relationship to a "Channel".

What do you think? If you're a Hypermedia Cowboy... I'd really love to hear from you.
