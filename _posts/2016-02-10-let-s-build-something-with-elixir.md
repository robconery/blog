---
layout: post
title: "Let's Build Something With Elixir and Phoenix"
image: 'roy_monolith.jpg'
comments: true
categories: Elixir
summary: "Red:4 needs an online store. We could continue to use Shopify but that's not our style. As CTO, I've decided to build an eCommerce store with Elixir and to do it publicly. You're going to help me."
---

As CTO I get to call the shots [here at Red:4](http://redfour.io) but I do have to answer to the CEO and others. It's easy to arm-wave, to go on and on about Elixir and functional languages - but at the end of the day it's what you *do*, not what you say that counts.

## Putting Elixir To The Test

Given that, I've decided to build an eCommerce store using [Elixir](http://elixir-lang.org) and [Phoenix](http://www.phoenixframework.org/). I want to stress the language (and myself) - to solve problems with its constructs and to throw it all at Phoenix, to see how it responds. If you know anything about Elixir then you know it runs on the Erlang VM. That's like telling your friends your mom gave you the jet for the weekend so you could fly to Burning Man.

I suppose that's a bit hyperbolic. In truth I actually don't know first-hand how powerful Erlang is in production short of what I've been told (over and over): *[Whatsapp (powered by Erlang) sold for 22 billion - mostly for its engineeering](http://www.wsj.com/articles/SB10001424052702304834704579403012327306216), [Erlang systems have claimed "nine nines reliability"](https://pragprog.com/articles/erlang) which means they basically went down for a second or so over the span of 20 years, [Phoenix clipped 2 million concurrent sockets on a single server](http://www.phoenixframework.org/blog/the-road-to-2-million-websocket-connections)* - stuff like that.

Neat stories, I want to do more than read. I want to see how the sausage is made and if I, as a really crappy developer, can expect to have this same power at my disposal.

First: *I expect to fail* and fail *often*. This isn't a tutorial, this isn't me trying to sell you Elixir/Erlang. This is me exploring what can be done with the Elixir/Phoenix platform, to see if I can put together a reasonably complex app, discovering aspects of the language (and OTP) along the way.

## Some Thoughts At The Outset

At the core of it: *I'm building a website*. If you [read over the docs for Phoenix](http://www.phoenixframework.org/docs/overview) you quickly see something that looks like Rails. If you heard a shout in the distance, that would be [Chris McCord](https://twitter.com/chris_mccord) and [Jose Valim](https://twitter.com/josevalim) yelling at me. They hate the comparison because they believe (rightfully so) that [Phoenix is something quite different than Rails](http://blog.plataformatec.com.br/2016/02/stateless-vs-stateful-web-apps/).

As much as they might dislike the comparison, there just simply is no escaping that Phoenix, the way its presented, looks like a Rails clone. *Yes: a clone*. Models, Migrations, Controllers and Views using Elixir's Ruby-inspired syntax. *It feels like Rails* as much as Jose and Chris want it to be otherwise. I do believe it's a lot more than that - and it's one of the reasons I decided to write this set of posts.

There's nothing wrong with Rails and I want to quickly veer away from "Rails vs. Elixir/Phoenix" as fast as I can. You just can't compare these two things; they are, at their core, utterly different even though they look the same. The only thing I'll say about Rails at this point is that **I am not [embracing the Majestic Monstrosity](https://twitter.com/dhh/status/695272044024487936)**:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">The Majestic Monolith is how a small team like Basecamp can do a complete rewrite from scratch in 18 months across all platforms at once.</p>&mdash; DHH (@dhh) <a href="https://twitter.com/dhh/status/695272044024487936">February 4, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

I ran my business on Rails for four years and, like DHH, I rewrote my app because of the improvements to Rails and also because when you try to change *anything* in a Majestic Monstrosity it tends to fall apart. I'm sure it was me - I suck. Now let's move on.

## Enough Talking: Mix New

Mix is Elixir's workhorse. It's a project tool, your compiler, test-runner, task-runner - it's basically Your Little Elixir Buddy. To create a project you simply:

```
mix new thing
```

... where `thing` is the name of your project. Your project can be a big application or a small component. Phoenix builds on this and has a task of its very own:

```
mix phoenix.new redfour
```

Doing this will give me a phoenix site:

```
mix phoenix.new redfour

* creating redfour/config/config.exs
* creating redfour/config/dev.exs
* creating redfour/config/prod.exs
* creating redfour/config/prod.secret.exs
* creating redfour/config/test.exs
* creating redfour/lib/redfour.ex
* creating redfour/lib/redfour/endpoint.ex
* creating redfour/test/views/error_view_test.exs
* creating redfour/test/support/conn_case.ex
* creating redfour/test/support/channel_case.ex
* creating redfour/test/test_helper.exs
* creating redfour/web/channels/user_socket.ex
* creating redfour/web/router.ex
* creating redfour/web/views/error_view.ex
* creating redfour/web/web.ex
* creating redfour/mix.exs
* creating redfour/README.md
* creating redfour/lib/redfour/repo.ex
* creating redfour/test/support/model_case.ex
* creating redfour/priv/repo/seeds.exs
* creating redfour/.gitignore
* creating redfour/brunch-config.js
* creating redfour/package.json
* creating redfour/web/static/css/app.css
* creating redfour/web/static/js/app.js
* creating redfour/web/static/js/socket.js
* creating redfour/web/static/assets/robots.txt
* creating redfour/web/static/assets/img/phoenix.png
* creating redfour/web/static/assets/favicon.ico
* creating redfour/test/controllers/page_controller_test.exs
* creating redfour/test/views/layout_view_test.exs
* creating redfour/test/views/page_view_test.exs
* creating redfour/web/controllers/page_controller.ex
* creating redfour/web/templates/layout/app.html.eex
* creating redfour/web/templates/page/index.html.eex
* creating redfour/web/views/layout_view.ex
* creating redfour/web/views/page_view.ex

Fetch and install dependencies? [Yn]
```

This task created the skeleton of my web app, including:

 - Tests for controllers, views and layouts which I don't want (the controller test fails when you change the index page template's text. That kind of thing drive me NUTS)
 - A complete Brunch setup for handling my assets for me which is nice
 - An Ecto Repository for data access
 - A `web` directory, which is where models, controllers, views and channels go
 - A smattering of other things

I want about 60% of this.

Forgive me - the first bits of this post sound kind of negative; they're not meant to be. I've learned the hard way over the past 10 years (or so) what can happen when you give control of the development process over to a framework and its conventions. These conventions are designed to get you off the ground fast but can (and have) make future maintenance a bit of a problem (see a few paragraphs above RE rewrites).

What I want is this:

 - functionality broken down into discrete components and processes that can be tested individually, that are isolated, and do not rely on a global framework
 - to feel and embrace the love of OTP (Elixir/Erlang's underlying framework) at every level
 - to **not grow my web application into a monster**

Unfortunately the Phoenix guides walk you through a process of *adding to the monolith* - dropping a model and migration here, a controller there, adding a view and a template. *There is so much more that's possible*.

Let's turn this in a positive direction.

## Creating Our App Directory

Our application will be comprised of many parts; one of which is our web site. For this, Elixir's umbrella project structure will be perfect. It creates a structure for you that all your "sub applications" can live in - sharing dependencies while staying relatively independent:

```
mix new redfour --umbrella

* creating .gitignore
* creating README.md
* creating mix.exs
* creating apps
* creating config
* creating config/config.exs

Your umbrella project was created successfully.
Inside your project, you will find an apps/ directory
where you can create and host many apps:

    cd redfour
    cd apps
    mix new my_app

Commands like "mix compile" and "mix test" when executed
in the umbrella project root will automatically run
for each application in the apps/ directory.
```

Perfect. These little "sub applications" are loosely associated in that they share a dependencies folder (not the dependencies themselves - just the folder on disk), you can run your entire project's tests from the root, and you can reference each application using some syntactic sugar.

Let's drop into the `apps` folder and install Phoenix. This time I'm going to strip it down to the bare essentials - I don't want to use an ORM-y database tool (Ecto) and I don't want to use Brunch; I have a way I like to manage/compress assets:

```
cd redfour/apps

mix phoenix.new web --no-brunch --no-ecto --module Redfour.Web
...
```

Have a look in your `/web` directory. It's so trim and clean! Now have a look in the `/deps` directory in your root:

```
ls -la ../deps

drwxr-xr-x  11 rob  staff  374 Feb 10 16:25 .
drwxr-xr-x   9 rob  staff  306 Feb 10 16:25 ..
drwxr-xr-x  11 rob  staff  374 Feb 10 16:25 cowboy
drwxr-xr-x  10 rob  staff  340 Feb 10 16:25 cowlib
drwxr-xr-x  12 rob  staff  408 Feb 10 16:25 fs
drwxr-xr-x  14 rob  staff  476 Feb 10 16:25 phoenix
drwxr-xr-x  13 rob  staff  442 Feb 10 16:25 phoenix_html
drwxr-xr-x   9 rob  staff  306 Feb 10 16:25 phoenix_live_reload
drwxr-xr-x   9 rob  staff  306 Feb 10 16:25 plug
drwxr-xr-x  10 rob  staff  340 Feb 10 16:25 poison
drwxr-xr-x   9 rob  staff  306 Feb 10 16:25 ranch
```

A central place with all the dependencies for your project so you don't have bloat and dependency repetition. Ahhhhhhhhh.

This is lovely. A stripped-down version of this radical framework that I can tweak as I need to. I like Controllers, I like the idea of Views (which I'll talk about more later on) and the routes/templating are great. There is so much goodness here, which I really feel is clouded a bit by the way it resembles Rails.

## Next Up: Our First Process

We have our skeleton and we're ready to rock. As opposed to deciding up-front what data access I want, logging, infrastructure and everything else, I'm going to lean on OTP and think about things in terms of processes and (to a degree) monitored services.

How would you do this for a commerce app? [Let's see if our opinions match up for the next post](/2016/02/11/red-4-store-part-2/). Feel free to leave a comment below.

<div class="ui items" style="padding-top:36px;border-top:1px solid #e5e5e5;">
  <div class="item">
    <div class="image">
      <a href="https://goo.gl/zvMHWK" target=_blank>
        <img src="/img/red4_product_slide.png">
      </a>
    </div>
    <div class="content">
      <a class="header" href="https://goo.gl/zvMHWK">Want to learn Elixir?</a>
      <div class="meta">
        <span>Learn how to build fast, fault-tolerant applications with Elixir.</span>
      </div>
      <div class="description">
        <p>
          This is not a traditional, boring tutorial. You'll get an ebook (epub or mobi) as well as 3 hours worth of tightly-edited,
          lovingly produced Elixir content. You'll learn Elixir <i> while doing Elixir</i>, helping me out at my new fictional job
          as development lead at Red:4 Aerospace.
        </p>
      </div>
    </div>
  </div>
</div>
