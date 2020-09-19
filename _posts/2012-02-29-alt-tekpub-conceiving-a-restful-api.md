---
layout: post
title: "Alt.Tekpub: Conceiving a RESTful API"
summary: "Right from the start I've known this application would serve a number of clients over its lifetime: HTML, Single Page JS Apps, and Mobile. How do we lay this thing out? A touchy subject of late, to be sure."
image: "/img/illustration-strange-machine-1707.jpeg"
date: "2012-02-29"
uuid: "iVvYEXHZ-6b3y-S3mO-tQ0v-kPXeA12Ov5De"
slug: "alt-tekpub-conceiving-a-restful-api"
categories: Tekpub JavaScript
---

## Use Cases
Always start with the user/consumer in mind (_in this post the user or consumer is someone using my API for whatever reason_). If they don't like what you do, your app is pointless. This can mean a lot of things to a lot people:- To a UX designer it means getting your wireframes together before anything else

- To a backend engineer it means defining your API
- To a marketing douchebag it means coming up with a "viral campaign" and making sure we "have SEO" so the app gets into user's hands

Let's approach this with our feet on the ground shall we? Each perspective above is correct, but neither requires superposition. The good news is that I have an HTML front end already (our current site) and I have no timeline (as of now) for getting the mobile story together (though that will hopefully change soon).The best plan is to start small and iterate - doing all things together. Given that - let's roll together our API in the first, smallest step possible.

## Hello There
If you asked a group of engineers what the first, most important part of our New Alt.Tekpub API should be (given that they understand we have Customers, Productions etc) - they might very well say

> Authentication/Authorization. We need to know who the user is before we can do anything!

The problem is that violates the first sentence above. **It's the "We" part - who cares about "We need"?** What about "they need"? Don't want to be preachy - but I really do think this is important - **our API needs to give users what they're probably interested in most: Value.**Our Value is our Productions - so there we start.

If I was in the Rails world I would probably do something like this

``` 
rails g model Production slug:string title:string price:decimal description:text released_at:daterake db:migrate
```

... and perhaps a few more fields, but this is fine for now. But something's not quite right here. Let's take a diversion.

## Kitchen Nightmares
[It's one of my favorite shows](http://en.wikipedia.org/wiki/Kitchen_Nightmares), and Gordon Ramsey is one of my favorite people. He goes into a restaurant that's failing and strips it of any pretense (usually with more than a bit of antagonism) - all in an effort to get them to serve up good food and make people happy.

In every single episode - no fail - he ends up shouting at the chef. And it's always the same thing (this is paraphrased):

> Did you taste this before you tried to serve it? It looks like it just fell out the back of my f**ing DOG

What strikes me is just how many times the chef in question **did NOT taste their food**. It kind of amazing when you think about it - the arrogance of someone making you dinner... not tasting it to see if everything went together with enough salt or whatnot - aka making sure you get the experience you're paying for.

I think the same thing about a really mangled RESTful API. Or worse yet - a confusing one. And trust me, I do not want to [open up the whole REST can of worms](http://wekeroad.com/2012/02/28/someone-save-us-from-rest/) again (now you know why I wrote it) - **I'll just say this: what makes sense to the engineer often has absolutely nothing to do with the user.**

## This is Art
To see what I mean - let's consider a very simple API: a CRM. There are so many to choose from but we'll start with the one I use:[ 37signals Highrise](http://developer.37signals.com/highrise/reference). If you have a look over the "Resources" in this API, what does it mean to you?[![](http://wekeroad.com/img/2012/02/Screen-Shot-2012-02-28-at-3.35.03-PM.png "Screen Shot 2012-02-28 at 3.35.03 PM")](http://wekeroad.com/img/2012/02/Screen-Shot-2012-02-28-at-3.35.03-PM.png)

Seems pretty clean to me with a few vague terms here and there - but overall I think this API is doing its job: **_It's communicating to me how I can work with HighriseHQ_** and the information I've put into it.

Contrast this with [SugarCRM](http://www.sugarcrm.com/crm/support/documentation/SugarCommunityEdition/6.3/-docs-Developer_Guides-Sugar_Developer_Guide_6.3.0-Sugar_Developer_Guide_6.3.0.html#9000495)(and yes they consider it to be RESTful):[![](http://wekeroad.com/img/2012/02/Screen-Shot-2012-02-28-at-3.42.09-PM.png "Screen Shot 2012-02-28 at 3.42.09 PM")](http://wekeroad.com/img/2012/02/Screen-Shot-2012-02-28-at-3.42.09-PM.png)**SugarBeans**? 

Please note: I'm not saying anything is "bad" here, nor am I complaining. All I'm saying is that

> A RESTful API is in the eye of the beholder

And I think it's important to craft your API with your clients in mind - and by clients I mean anyone who wants to build a thing against your API. Whatever that thing is: a widget, a full-blown application for doing stuff - who knows.

The simpler and more palatable you make it (**in other words: taste your own API**) - the happier everyone will be.But how?

## Resources: Productions
It's easy for a group of engineers to wave their arms and decide what a Resource might be. We can try to comply strictly with our own internal definition of REST or perhaps what Wikipedia and Fielding tell us to think - or we can do absolutely everything from the perspective of our users. Which I like.

So let's start there: **what do users do when they come to Tekpub**? The answer is pretty straightforward: they want to see what videos we have that might interest them. Then they want to know how long, how deep we go into a subject, who's authoring it, and perhaps what other people think.On our home page we don't just splash out all of our productions - that would be useless. Instead we present them in some context that's interesting:

1. **Featured** - productions we're proud of or we think people might really enjoy
2. **Recent Episodes** - things we just released
3. **Categorized**: grouped by some relationship, such as ".NET", "Ruby", or "Javascript"

There are probably more ways to group this - but let's start here.

Now you might have looked at the section header here and said "dude - don't confuse a Resource with your Model or Domain Entity" and I would whole-heartedly agree. And then I'd tell you to go away :). Politely of course.

I need to slice this API up somehow - and that starts with URLs. And if it happens that those URLs coincide with my Model and Controllers then that's OK with me - but it certainly is not guiding my approach. The only thing I care about (have I said this enough) is the caller.Back on track: what URLs make sense to people and clearly define the "Resource" their getting back?

## URLs
EDIT: through my omission I left "productions" singular below - my mistake. Edited.

To me, a reasonable set of URLs would be:

- **GET/productions** - for all productions
- **GET/productions/{slug}/episodes/1** - for a single episode to view
- **GET/episodes/recent** - things we've just released
- **GET/productions/javascript** - categorized

_I'll get into POST/PUT and.. ahem PATCH operations in another post_ 

Does this make sense though? Possibly. My first hurdle is "will consumers know what a Production is vs. an Episode?". I tend to think so - it follows along with a common Television show approach so if they read the docs, it should be simple enough to figure out the players here.

Do "/episodes" on their own make sense? No - really they don't [as I discussed previously](http://wekeroad.com/2012/02/22/alt-tekpub-moving-to-mongodb/). Yet my users want the ability to know which episodes recently aired - much in the same way you would want to know which episodes of Sherlock might have just aired. There might be other operations we can do on episodes... so I'll leave it.This is a good place to start - and I'm not locked into anything. This API will change probably as the concepts get baked but that's OK. We're agile yo.

## Code
Now I need to write the code and build out the routes/models to support this. Before I do, I'd love to hear your thoughts on what might make more sense. The code will come in the next post.

I kindly ask that you present your own thoughts and opinions and please don't quote Wikipedia/Fielding to me - and I ask you kindly to avoid pedantry if possible. I will be heavily moderating the comments to stay on track - but **I DO value your thoughts. Just make sure they're your own!**
