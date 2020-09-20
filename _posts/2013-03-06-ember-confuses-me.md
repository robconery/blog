---
layout: post
title: EmberJS Confuses Me
summary: "I've been teeth-deep in Client-side JavaScript frameworks over the last 4 months for Tekpub. This month is Angular, last month was Ember's turn and I gave up. It's the first time I've given up - here's why."
image: "/img/spinning-dizzy.jpeg"
date: "2013-03-06"
uuid: "AvmC9PkN-prwF-Ryxd-SM8X-GVYnlwhWXGXl"
slug: "ember-confuses-me"
categories: JavaScript Opinion
---

## I Tried
Saying something confuses me is no great claim - many things do. It's entirely likely that I didn't study Ember long enough, or maybe I didn't give it the "time to soak in" that it deserved. Either way I punted on my efforts to bring an Ember title to Tekpub.

Normally I'd just go about my business and sidestep posts like this one - but today I had a conversation with Trek Glowacki (core dev on the Ember team) and he was confused as to my confusion. I offered to blog my thoughts - he couldn't understand the points I was making about my confusion. 

So here's that post, stripped of hyperbole and "it's ON FIRE" statements. It's my honest take on this framework.

## You Keep Telling Me It's MVC...
Yes, the concept of MVC has been contorted over the past decade as web frameworks have adopted it and massaged it to their own ends. What does this mean?

 - Controllers in web MVC have a very short lifespan, and there are a lot of them typically
 - Views dont' communicate directly to a controller - they have to use an intermediary layer in HTTP (headers, querystring, etc)
 - Models are injected into views by Controllers
 - Controllers don't command the views directly

In more classic MVC (aka "Desktop") your controllers are typically spun up when the app starts, and configured one time, right there. A controller's job is to command aspects of the view as data changes, and to change the model when things on the view happen that mandate it. 

The model encapsulates the business logic for whatever its modeling, the view presents the data in a nicely formatted way to the user, and the controller sits between. I think we agree on this much - so what's the problem?

OK this is MVC as far as I have come to know it. There are lots of denominations I am sure - I have to think the church of MVC is about as crowded as the church of REST on any given holiday but there's room for all of us so let's move on...

## Separation. Only Not.
In EmberJS, the [controller's job is changed a bit](http://emberjs.com/guides/controllers/):

> A controller may have one or both of these responsibilities:
 
> - Representing a model for a template.
> - Storing application properties that do not need to be saved to the server.

> Most of your controllers will be very small. Unlike other frameworks, where the state of your application is spread amongst many controllers, in Ember.js, we encapsulate that state in the router. This allows your controllers to be lightweight and focused on one thing.

For me, this is where the confusion begins. A controller proxies the model, and then exposes itself to the rendering engine so that the view can consume it (you may need to read that sentence twice). As a result, we have view code like this (this is Handlebars):

{% highlight html %}
{% raw %}
{{#each person in personController}}
  <h1>{{name}}</h1>
{{/each}}
{% endraw %}
{% endhighlight %}

This can be shorthanded to this:

{% highlight html %}
{% raw %}
{{#each controller}}
  <h1>{{name}}</h1>
{{/each}}
{% endraw %}
{% endhighlight %}

**This is where I hit a conceptual wall**. First: let me say that I'm not the best programmer in the world and I could be dead wrong on this. But as far as I understand it, this is about as tightly bound as we can make things.

As stated above, a controller "proxies" the model onto itself for use in the view. I'm trying my best to reconcile this with the notion that a controller (classically speaking) is supposed to ... well **control** the view. Here, it's not doing that. 

If I'm not mistaken, the view is controlling the controller and the model is nowhere to be found. Well that's not true I spose: **the model is the controller**. Sort of. Well it's not literally the same thing in concept but in practice the controller and the model are one. Bound. Together. Tightly.

In Angular this separation is achieved by a "scope" object that is, basically, a vehicle of sorts that gets passed between the controller and the view:

```javascript
var PersonCtrl = function($scope){
 $scope.people = [{name : "Rob"}, {name :"Mary"}] 
}
```

In your view, you declare which controller you're using and then consume the information that's on the scope:

{% highlight html %}
{% raw %}
<div ng-app>
  <div ng-controller='PersonCtrl'>
    <ul>
      <li ng-repeat='person in people'>{{name}}</li>
    </ul>
  </div>
</div>
{% endraw %}
{% endhighlight %}

The downside to this approach is that your HTML is "compromised", if you will, and many developers don't like that. My thought is that **it's already compromised using Handlebars** so what's the difference here?  Personally I have no issue using the ng-* directives. Some people do, and I respect that.

But let's get to the controller code. Notice that the $scope is injected? That's Dependency Injection at work and is a core concept in Angular which greatly helps testability.

Now you might be saying "but ROB! The controller is declared directly in the view! That's the same problem!". And that's true - until you loop in routing (below) and you can remove that directive since it's handled explicitly by routing:

{% highlight html %}
{% raw %}
<div ng-app>
  <ul>
    <li ng-repeat='person in people'>{{person.name}}</li>
  </ul>
</div>
{% endraw %}
{% endhighlight %}

In Backbone a view is created (optionally) with the model (or collection) that it needs for data. There are no controllers (classically) in Backbone - though you can surely wedge one if needed and have it deal with the view.

These concepts align with my understanding of MVC. Not the case with Ember - if anything it confuses me greatly.

## Routes, Objects, and More Confusion
I can get past the controller issue - I'm not a purist and if there's a reason the team wanted it this way, then I believe them. [It's Yehuda](http://yehudakatz.com/) and I think Yehuda is a very nice and smart person (as is [Tom Dale](http://tomdale.net/) - the co-creator of Ember). 

I respect these guys so much I want to be very careful to **not suggest** that they don't know what they're doing. As I keep saying: **this is my confusion**. I own it.

Which brings me to Routes. Here's [one way to define a route](http://emberjs.com/guides/routing/defining-your-routes/) using EmberJS that looks rather familiar:

```javascript
App.Router.map(function() {
  this.resource('posts', { path: '/posts' }, function() {
    this.route('new');
  });
});
```

Rails devs will recognize this straight away as a Resourceful Route. But what does a "resource" have to do with a Desktop app? When talking routes, urls, and resources - that's a RESTful consideration and involves stateless state "stuff" (sidestepping the REST debate here). **What is this concept doing in a desktop app?**.

Here's another way to define a route:

```javascript
App.Router.map(function() {
  this.route("about");
  this.route("favorites", { path: "/favs" });
});
```

This is straightforward. Client MVC apps can manipulate browser history with "hashbang" URLs for bookmarking convenience. To manage that, we use a router and define routes.

And if you know that Ember relies heavily on naming conventions you could probably assume that you'll need an AboutController and a FavoritesController (like Rails - and Yehuda is a Rails core dev too so it would make sense...).

But that's not quite what needs to happen. You need to also define a RouteObject (which you can think of as a route handler):

```javascript
App.FavoritesRoute = Ember.Route.extend({
  model: function() {
    return App.Favorites.find();
  },
  setupController: function(controller, model) {
    controller.set('content', model);
  }
});
```

I've been repeatedly told that "Ember uses MVC in the classical Desktop way" following Cocoa/Smalltalk style. OK I can buy that - but if that's the case **why are controllers being tied to routes and models**, conceptually? That might make sense for the web, but hardly for a desktop app.

Now I completely understand that we can throw theory at this [and that Smalltalk-80 MVC](http://st-www.cs.illinois.edu/users/smarch/st-docs/mvc.html) was instrumental in forming the concept behind Ember. 

But even then - one model could be used in many controllers (and the reverse) depending on the need. I'm happy to shift my mind into Desktop mode - but it seems Ember still wants to retain some conceptual likeness to Rails, which I find most ... strange.

I remember watching [Geoffrey Grosenbach](http://blog.peepcode.com) explaining this in [Peepcode's very well done video tutorial on EmberJS](https://peepcode.com/products/emberjs) and feeling rather confused. I rewound the section and played it back, to see if I could understand what I was seeing.

And rewound it a few more times after that. It wasn't sinking in. I could not understand the difference between declaring a route, and configuring a RouteObject. Why not have the URL be a setting on the Ember.Route?

Now it could be that it was this way in the past - I've only gotten to know Ember 1.0 rc1 and I also know that the API changes rather dramatically from time to time.

But this is really confusing.

Here's how you do it in Angular:

```javascript
//declare the app and any dependencies
var App = angular.module("App",[]);

//configure the app, injecting the Route Provider
App.config(function($routeProvider){
  $routeProvider
    .when("/about", {
      templateUrl:"about.html",
      controller : "App.AboutCtrl"
    })
    .when("/favorites", {
      controller : "App.FavoritesCtrl",
      templateUrl: "favorites.html"
    })
});
```

Angular's approach is interesting and somewhat "concept-y" if you're not familiar with Dependency Injection. Once you get past that (or maybe you love it already) it becomes straightforward to understand that "here's a route, use this template and this controller". This is straight up configuration: **which is exactly what the method name is**.

I love parity between method names and the code I'm writing.

Here's how you do it in Backbone:

```javascript
App.Router = Backbone.Router.extend({
  routes: {
    "/about": "showAbout",
    "/favorites": "showFavorites",
  },
  showAbout: function () {
    //render the view, or call to a controller
  },
  showFavorites: function () {
    //render the view, or call to a controller
  },
```

The Router in Backbone is also a bit confusing - there's no doubt about it. It can quickly turn into a mess of configuration AND instrumentation - in other words doing a controller's job.

I think this is why the Ember team tried to separate the configuration of the routes from the route itself. But in doing so they marginalized the controller (which was their intent, if you read the controller's definition).

With Backbone I know what I'm getting into. I can use the Router as a controller (it used to be called that btw) and when things get a bit nuts, I can create a controller of my very own ([or just use MarionetteJS that has this concept built in](http://marionettejs.com)).

## Naming
Ember relies heavily on naming conventions that must not only follow [syntax guidelines, but also casing guidelines](http://www.emberist.com/2012/04/09/naming-conventions.html).

The reason for this is straightforward: Ember will generate code for you if you just need basic, boilerplated stuff, alleviating you from tedious coding which is rampant in other frameworks like Backbone.

The problem I have with this is that the relationship between things is in name only, and that seems like it's a rather brittle rule. It also tells me that I have to know the naming conventions **as well as** how to use the framework - which is fine, typically, as long as there's a big payoff.

And that's where I get stuck (again): **what's the payoff, aside from implicit code generation, for following the naming conventions here?**. Consider the routing code, above:

```javascript
App.Router.map(function() {
  this.route("about", { path: "/about" });
  this.route("favorites", { path: "/favs" });
});

App.FavoritesRoute = Ember.Route.extend({
  model: function() {
    return App.Favorites.find();
  },
  setupController: function(controller, model) {
    controller.set('content', model);
  }
});
```

The only way I know that one thing depends on the other is by name. Now I know that should seem obvious and you might be thinking "well duh, Rob, that's the point!". Yes, but it's also a great way to have a highly confusing API.

What's the problem with something like this:

```javascript
App.FavoritesRoute = Ember.Route.extend({
  url : {name :"about", path: "/about" },
  model: function() {
    return App.Favorites.find();
  },
  setupController: function(controller, model) {
    controller.set('content', model);
  }
});
```

This, to me, is a whole lot more apparent and I'm not reconciling functionality through a naming filter. For some that might be much easier than reading the code (or reading the tests) - to me it seems arbitrary and confusing.

## You Asked, I Answered
In wrapping this up, I would like to say that I am writing this as a way to make my points a bit clearer to Trek as Twitter doesn't work well for this kind of thing. He didn't understand my confusion about Ember (specifically why I didn't think it aligned with my understanding of MVC) so I told him I'd write something that explained my confusion.

It would be easy to see this as "Rob ranting on Ember" and I'm sure it will be taken that way by many. Not my intent, really. I have 4 videos to edit in front of me, and a book to write. I took time out of my day to respectfully respond to the Ember team with my thoughts - even if they're not glowing and exciting with praise.

If Ember works for you I think that's great. It doesn't work for me.

