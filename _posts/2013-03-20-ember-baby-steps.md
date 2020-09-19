---
layout: post
title: "Ember: Baby Steps"
summary: "If you read my blog, you know I've been goofing around with quite a few Javascript libraries. Some are easier than others. This time, it's Ember's turn."
image: /img/ember_get_started.png
date: "2013-03-20"
uuid: "f6o9urOM-R1ZF-mxlN-6H3w-7MwSWvInbFXw"
slug: "ember-baby-steps"
categories: JavaScript
---

## A Bit Steep
I figured it's about time to get constructive in terms of getting to know EmberJS. The only reason I haven't up until this point is that I've been very busy with [Tekpub's Angular production](http://tekpub.com/productions/angular). 

So, today's the day. Let's get started.

## Baby Steps
Getting Ember setup is frustrating. [The Ember guides](http://emberjs.com/guides/) are focused heavily on concept, not utility. For instance - getting Ember to load (for the uninitiated) is a matter of refreshing until the errors go away. I'll save you that time :).

Kick open a console (if you're on Linux/Mac) or crack open VS/WebMatrix if you're on a Windows machine. We want a bare application here so let's start by creating a directory:

```
mkdir hello-ember
cd hello-ember
```

Now we're in our directory. Let's create the pages/directories we'll need:

```
mkdir js
touch index.html
```

The next step is to get the scripts we'll need. We'll need 3:

 - jQuery
 - Handlebars
 - Ember

Ember won't work unless you have all three of these. I like to use the jQuery CDN at Google, but you'll need to [download Ember directly](https://raw.github.com/emberjs/ember.js/release-builds/ember-1.0.0-rc.1.js) and also [Handlebars](https://raw.github.com/wycats/handlebars.js/1.0.0-rc.3/dist/handlebars.js). Put these files in your `js` directory.

Be sure to use the unminified version for development. This goes for any library you're learning - the unminified versions are easy to traverse if you have a debugger, and they typically have helpful debug statements built in.

Save these files in your `js` directory. 

Let's add one more file where our application code will go:

```
touch js/app.js
```

Open up the index.html page and stub out our skeleton, with the script references in place:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Hello Ember</title>
  </head>
  <body>
    <div>
      <h1>Hello Ember</h1>
    </div>
  </body>
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
  <script type="text/javascript" src="js/handlebars.js"></script>
  <script type="text/javascript" src="js/ember.js"></script>
  <script type="text/javascript" src="js/app.js"></script>
</html>
```

Let's run this:

```
python -m SimpleHTTPServer
```

Things should be cycling [on port 8000](http://localhost:8000). If you're on Windows, just hit F5.

Now let's write some Ember code.

## Step 1: The Application View
Up front: there's a lot of magic that happens behind the scenes with Ember. Just about any tutorial you read will spend 75% of the time explaining the concepts behind Ember, and 25% of the time on actually using it.

This can be daunting for people who "want to get a feel" (like me) and don't like sitting through conceptual lectures. I like to write code to understand a tool - so let's do that and I'll explain what I know along the way.

Open up js/app.js and create the Ember application:

```javascript
var HelloEmber = Ember.Application.create();
```

We have an application, which is a lovely start. We need at least two more things before we know that Ember is even alive and running:

 - a View
 - a Controller

The simplest view to create is the overall application view - let's add that to our HTML page, removing the first-level headers:

```html
  <body>
    <div>
      <script type="text/x-handlebars" data-template-name="application">

      </script>
    </div>
  </body>
```

This script tag is a Handlebars template. If you don't know what that is: it's just like an ERB template in Rails (or a Razor template in ASP.NET MVC) except it works with Javascript on the client.

Handlebars is pretty simple to use, and Ember extends some of its functionality to make it work happily with the Ember bits.

We've identified this template using `data-template-name` as being the main application viewport. Let's stick something in it.

## Step 2: The Application Controller
If you're familiar with Rails-style MVC, well... forget it. There are many flavors of MVC and we'll be working with Desktop/Smalltalk-80 style here. This confused me greatly, and I still don't know how I feel about it, but it doesn't matter. This is the way Ember works.

In short: **Controllers in Ember convey data to your templates**.

To see this let's create our first Controller. Open up app.js:

```javascript
var HelloEmber = Ember.Application.create();
HelloEmber.ApplicationController = Ember.Controller.extend({
  greeting : "Good Morning Starshine!",
  happyThought : "The Earth Says Hello!"
});
```

If you've used Backbone before, this will look very odd. I should also mention that using the ApplicationController like this is not a good idea - I'll fix it in just a second.

Let's update the view so we can see our data:

```html
<body>
  <div>
    <script type="text/x-handlebars" data-template-name="application">
      <h1>{{greeting}}</h1>
      <h3>
        {{happyThought}}
      </h3>
    </script>
  </div>
</body>
```

If you're working in Chrome, make sure the console is open by using Cmd-Shift-I (or Ctrl-Shift-I in Windows). If you see any errors here, correct them. It's likely you might have a 404 reference to one of your script files, or you've put them in your page in the wrong order (use my code above for the right order).

If everything is working: refresh your page - you should see a nice, Wonka greeting.

## Step 3: Conventions
Look back over what we've written. Nowhere did we state "get this template and render it this way". Instead, Ember used the name of our template and married it up with the name of our Controller - and it all _just worked_.

This is a key bit of understanding with Ember: **Naming things properly is everything**.

To see this, let's get out of working with our ApplicationController directly.

First, create a new Controller, we'll call it the "IndexController". Don't name it something else - IndexController is what shows by default:

```javascript
var HelloEmber = Ember.Application.create();
HelloEmber.IndexController = Ember.Controller.extend({
  greeting : "Good Morning Starshine!",
  happyThought : "The Earth Says Hello!"
});
```

Now, let's update our view so that the application view doesn't have hard-coded values in it:

```html
<body>
  <div>
    <script type="text/x-handlebars" data-template-name="application">
      {{outlet}}
    </script>
    <script type="text/x-handlebars" data-template-name="index">
      <h1>{{greeting}}</h1>
      <h3>
        {{happyThought}}
      </h3>
    </script>
  </div>
</body>
```

Refresh your page. You should see the same thing we saw before: a nice Wonka greeting. But what happened here?

Again: naming conventions at work. The ApplicationController is gone from our code, but it still exists "behind the scenes" as Ember created it for us. In the first example (where we worked directly with it) - you can think of that as "overriding" the ApplicationController.

The same goes with the IndexController. It was always there - but we didn't need it. In the second example we essentially "overrode" the IndexController and created a view for it.

The rendered view was then injected into the application view where `{{outlet}}` sits on the page. You can think of `{{outlet}}` in the same way that `yield` is used in Rails.

## Step 4: Models and Routing
We've done some basic stuff here, let's explore the other parts of Ember. Once again, I'll keep it **extremely simple**. 

In app.js, let's define a model. I'll do this by extending an Ember Object:

```javascript
HelloEmber.Greeting = Ember.Object.extend({
  greeting : "Good Morning Starshine!",
  happyThought : "The Earth Says Hello!"
});
```

**Update** - this code has been changed based on feedback from Tom Dale and comments below.

Now, let's define a Route. Routes in Ember help to link models to Controllers:

```javascript
//our app
var HelloEmber = Ember.Application.create({});

//our model
HelloEmber.Greeting = Ember.Object.extend({
  greeting : "Good Morning Starshine!",
  happyThought : "The Earth Says Hello!"
});

//our route
HelloEmber.IndexRoute = Ember.Route.extend({
  model : function(){
    return HelloEmber.Greeting.create();
  }
});
```

This is all the code you should have in app.js. Notice how we have no Controller? We don't need one. This is confusing, but let's make sure things are working - refresh your page and you should see everything working just fine.

Assuming that it is - what we have here is naming magic at work, again. We've always had an IndexRoute (Ember created it for us since we didn't explicitly declare one) - but this time we wanted to specify a model so we needed to use a Route.

I mentioned that the Route exists to marry up a Controller to a Model, **but we have no Controller!** This can be maddening: we _do have a Controller_, we just didn't have to write the code for it: Ember did that for us.

The Controller that Ember created (the IndexController) was associated to our Route because we kept with the Ember naming magic. That Controller took the model that was available on the Route and "grafted it" onto itself, making the data on the model available to our view.

## Good Job!
If you've made it this far, you now know as much as I do. There's a lot happening in the background with Ember; the goal being that the Ember team wants to reduce the tedious "boilerplate" code you write with other frameworks, like Backbone.

This can be a neat thing, it can also be highly confusing if you don't know what's going on.

I encourage you to play around with Ember and Handlebars now that you have your footing. It's an interesting thought experiment that works well for many developers.

**Note:** _I'm not an Ember expert by any stretch so if you've found any misstatements or silliness here, please do let me know and I'll adjust._


