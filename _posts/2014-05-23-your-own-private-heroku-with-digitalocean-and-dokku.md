---
layout: post
title: 'Your Own Private Heroku with DigitalOcean and Dokku'
image: '/img/badass_unicorn.jpg'
comments: false
categories: Node Opinion
summary: "I've been playing around with DigitalOcean lately, specifically the pre-rolled Applications they have setup. I'm just blown away at how simple things have become: <b>including setting up your own private Heroku</b>"
---

## Dokku, Like Heroku But Not

Dokku is one of those projects that I've been hearing about, but haven't had the time to look into. I did that today, finally, and I have to say it's... pretty impressive.

It's 100 lines of shell scripts that manage Docker for you - creating a Heroku-like experience where you can deploy your application using Git. There's a lot to it - but [have a read on Jeff Lindsay's blog](http://progrium.com/blog/2013/06/19/dokku-the-smallest-paas-implementation-youve-ever-seen/) (he's the creator of Dokku) - he has an interesting screencast that will give you more of an idea.

In summary form: you push your git repo to Dokku and it figures out what to do with it. Let's say it's a Node app - Dokku will create a Docker container for your app (Docker is sort of like a VM, but it uses your processor and memory) and install everything needed for it to run.

For Node, it does this by analyzing your package.json. For Ruby/Rails, your Gemfile. You can also use with Java if you like - but I have no idea how that works.

The whole process takes about 10 seconds, and when you're done... you have a working deployment.

## The Walkthrough Is Drop-dead Simple

In my last post about Gitlab I basically summarized DigitalOcean's online walkthrough. I did that because I wanted to underscore just **how bleedingly simple** this stuff has become. 

For setting up Dokku - [just have a read of this post and follow what it says](https://www.digitalocean.com/community/articles/how-to-use-the-digitalocean-dokku-application). 

I used a quick Node app and it *almost worked perfectly* the first time, but I had to jigger a few things:

 - Make sure you have a Procfile in the root of your app that tells Docker how to start your app. This can be as simple as `web: npm start` or a longer Rails incantation. Don't forget the `web:` key in there.

 - Make sure you specify which node and npm version to use in your package.json file. These go in the "engines" setting.

Here's the package.json I used for a successful deployment:

```javascript
{
  "name": "application-name",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "start": "node ./bin/www"
  },
  "engines": {
    "node": "0.10.26",
    "npm": ">=1.3"
  },
  "dependencies": {
    "express": "~4.0.0",
    "static-favicon": "~1.0.0",
    "morgan": "~1.0.0",
    "cookie-parser": "~1.0.1",
    "body-parser": "~1.0.0",
    "debug": "~0.7.4",
    "jade": "~1.3.0"
  }
}
```

## Do You Need To Do This?

Yes, absolutely. If you're working with Node/Ruby/Python/Whatever Heroku Supports - you'll likely have client demos or just public goof-off code you'll want to share. As a web developer these days, it's really important to have a "playground" where you can publicly play with ideas too.

Heroku is amazing, but it's also pretty expensive when you ramp things up. Deployment can take forever as well! I'm a big fan of owning as much of your content as you can - your blog included (DigitalOcean does Wordpress too).

At the very least - see what Dokku can do, and be amazed at what's possible these days.


