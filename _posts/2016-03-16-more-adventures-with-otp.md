---
layout: post
title: 'Red4 Store Part 5: Fun With Phoenix, OTP, and Agents'
image: 'max_smart.jpg'
comments: true
categories: Elixir
summary: "I've taken a little time from blogging about Elixir and this little project, mainly because I wanted to dive into OTP a bit more, and I also needed to figure out Phoenix and what I needed to remove."
---

*Before I get to the meat of this post, [the code for what I've written so far is up here](http://github.com/robconery/peach). The main bits are in `/apps/peach`.*

<hr>

## Stumbling a Bit

I've had a hard time over the last few weeks trying to figure out what's going on with this little app. It's been quite fun diving into OTP and the neat little abstractions Elixir provides on top of Erlang and OTP. I have found working with Phoenix, however, to be a bit challenging. Crawling up into the Phoenix abstractions and trying to understand them (so I can figure out if I can remove them) has been somewhat ... not fun.

I know the some will think I'm being "negative" but... well I like to be honest about things. I do try to give an educated opinion - not just be an ass for the fun of it... promise.

The conversations I've had about this over the last few weeks have basically gone like this:

> Me: Phoenix is rather convoluted and a bit heavy. I can see why people compare it to Rails

> Phoenix person: Phoenix **is not Rails** and it's not heavy.

> Me: Well that's my impression because I'm having to rip out quite a lot that I don't want or need. Just your saying so isn't really convincing me.

> Phoenix person: You'll need all of that eventually. Phoenix isn't heavy.

> Me: I'd rather opt-in to what I need. Namely Channels, Ecto, Brunch, Views... and

> Phoenix person: Those are all optional (aside from Channels). You can remove them by ...

> Me: Yes - this is my point. I have the kitchen sink here when all I need is a small bucket

> Phoenix person: You can have your small bucket. Phoenix is supposed to be beginner-friendly so just follow this procedures to strip Phoenix down

> Me: I thought Phoenix wasn't Rails? This conversation is draining (get it... you gave me the kitchen sink...)

> Phoenix person: /mute

This is the problem with **opt-out by default**: you (by definition) start out with way more than you need; all of which you need to understand before you do anything. If you don't completely understand the toolset you're given (by default), you end up building crap, which is precisely what happend to me (repeatedly) with Rails.

When you complain about this stuff, you're told you shouldn't use a tool you don't understand completely and by the way in the next version we're adding some really great new features everyone will love.

I think I'll coin a term here:

<div class="well">
  <p>
  <u><b>Technical Entrapment</b></u><br>
  <i>When a framework front-loads tools and abstractions to the point that technical debt and a rewrite within a year is guaranteed.</i>
  </p>
</div>

There's a lot I'm not using with Phoenix: namely Ecto and Brunch (yes, I did start off with `--no-ecto` and `--no-brunch` which I think should be the default)- and I'm not using migrations or models (I don't care for ORMs much and find them odd in a functional landscape). Because I'm not using models, I can't use the generators (which I guess I wouldn't use anyway).

I don't need real-time channels (although the option is nice to have if I want it later) and the View abstraction is something I don't care to use as I can just reference UI helper stuff directly from modules (I want to keep formatters etc centralized). Controllers don't make sense without Models and Views so there goes the whole MVC idea and I'm not putting the bulk of my application within the web project (I'm using an umbrella project to keep things initially separated).

If you're wondering why I'm using Phoenix at all - I think that's a really good question. I suppose, in part, because *I do think things will get more complicated* and I probably *will* opt for a Controller here and a View there. *Maybe* - I just don't know yet. I kind of want to figure that out as I go.

The primary reason for this is that I will likely offload a number of things to external services to start out with (like [Auth0 for user stuff](http://auth0.com) and [Keen.io](http://keen.io) for reporting. Mailjet will probably handle mailers too) so that just leaves a small core. I might change my mind and bring some of that stuff in-house in the future, so the option to build out is a good one to have.

I don't think I'm a unique snowflake here, but I do feel like **I'm somehow going against the grain** and "being Rob, doing things differently" (yes, that was said to me to). I guess I don't see this as *being different*. I see it as rather normal.

As my friend [Scott Hanselman](http://hanselman.com) said once:

> It's Comp Sci baby

But learning is fun so I suppose I should be grateful that I get to learn more things. So let's be positive.

I do like the Router, the integration with the rendering engine, and *I love* the way Phoenix just sits nicely with Plug. The `pipeline` is a neat idea and very clear. It would be great if I could just start here, by default. Then when I need to, I can add in controllers etc.

Anyway: I will spend some more time with Phoenix. The team has insisted that once I get into more complexity, the abstractions and structure will make sense. I believe them - they're smart people. Smarter than me, I'm sure.

Let's get to the OTP stuff.

## Simplifying with Agents

In [part 3 of this little series](http://rob.conery.io/2016/02/17/red4-store-part-3/) I dropped into using `GenServer` and OTP so I could kick up a `Session` for each customer to come along. This would be a standalone process running in memory that existed *only* to store information about the customer's shopping session (adding items, removing, etc).

I loved the approach - it felt correct. I loved how it simplified data access (saving the `Session` entirely when needed) and flexed the power of the Erlang VM. And then something occurred to me...

### What if I Event Sourced this?

I hate throwing jargon and terms around - but taking a step back and squinting at our little `Session` GenServer ... we might have [a classic Event Source](http://martinfowler.com/eaaDev/EventSourcing.html)

> The fundamental idea of Event Sourcing is that of ensuring every change to the state of an application is captured in an event object, and that these event objects are themselves stored in the sequence they were applied for the same lifetime as the application state itself.

If you consider the `Session` to be an event (which it kind of isn't... more below) and our GenServer process to be an "app" in Fowler's mind - it makes good sense.

So I decided to test this out.

The first thing I did was think more in terms of a meaningful result to this event. Shopping *is literally* an event, but I think what we would want to trap is *the result of that event*, which would be one of two things:

 - A sale
 - No sale

They both have value and meaning - but let's be positive and focus on the first thing. If I was to store a gigantic blob of data that clearly showed the result of a customer shopping in our store - what would that look like?

Here's what I came up with:

```elixir
defmodule Peach.Accounting.SalesOrder do

  defstruct [
     store_id: nil,
     customer_id: nil,
     status: "open",
     customer_name: nil,
     customer_email: nil,
     address: %{street: nil, street2: nil, city: nil, state: nil, zip: nil, country: nil},
     id: nil,
     key: nil,
     landing: "/",
     message: nil,
     ip: "127.0.0.1",
     items: [],
     history: [],
     invoice: nil,
     payment: nil,
     summary: %{item_count: 0, total: 0.00, subtotal: 0.0},
     logs: [%{entry: "order Created", date: now_iso}],
     discounts: [],
     deliverables: []
   ]

   #...
```

Relational data fans - look away. This will probably make you want to scream... I suppose if you're a document DB fan you'll probably want to scream as well... but stay with me.

This is a rather large struct that defines all kinds of entries where I can tack on data as the customer goes along:

 - "cart" items are tracked in `items[]`
 - payment info (the payment itself and the response) can be tracked in `payment`
 - address information is captured, and the generated `invoice` document as well
 - timestamped logs show what happened when

In short: *everything* is tracked, right here, within a context that makes sense. A **Single Point of Authority** if you will that I can use as the source of all kinds of data later on (sales reports, marketing, etc).

As the customer does things in the store (including check out), I slowly fill out this struct, saving it *en-mass* each time as a JSON blob in Postgres. When a checkout happens, I create the invoice, tack on the payment stuff and reset the status - nothing else.

So, so simple.

## Hand Meet Glove: Using an Agent To Track All of This

When you create a `GenServer` in Elixir you're following a formalized OTP pattern that allows you to keep some form of state on a process - that's their whole reason for existence (and you can Supervise them as well).

These can be long-lived (like our `Catalog`) or short-lived (like a fulfillment process). For semi-complex processes that need to "accrete state" if you will, [an Agent is perfect](http://elixir-lang.org/docs/stable/elixir/Agent.html):

> Often in Elixir there is a need to share or store state that must be accessed from different processes or by the same process at different points in time ... The Agent module provides a basic server implementation that allows state to be retrieved and updated via a simple API.

An Agent is just a GenServer with a few more abstractions, which is nice because writing all of that `handle_call` code can be a bit tiresome. Moreover, updating state is super simple!

The first thing is to change the call from `GenServer.start_link` to `Agent.start_link`:

```elixir
defmodule Peach.Sales do

  import Peach.Util
  alias Peach.Sales.CartItem
  alias Peach.Db.Postgres, as: Db
  alias Peach.Accounting.SalesOrder
  import Plug.Conn

  def start_link(%{key: key} = args) when is_binary(key) do
    order = Db.find_or_create_order(args)
    Agent.start_link fn -> order end, name: {:global, {:order, key}}
  end

  #...
```

*A few notes: I've changed the name of the store to Peach, which is a name I chose at random. I've altered things quite a bit, as you can tell (like working directly with Plug), and I'll go more into this in later posts.*

With this code I'm solving quite a few problems:

 - I'm registering the Agent in the global container, using the `{:order, "SOME STRING"}` tuple (which was [recommended by Ricardo Garcia Vega](http://rob.conery.io/2016/02/20/red4-store-part-4/) - thank you!). This solved a problem [that cropped up in my last post](http://rob.conery.io/2016/02/20/red4-store-part-4/) - using Atoms as names for my process, which you shouldn't do.

 - I'm now able to strip out about 1/2 my code and simplify it with `Agent.get_and_update`

## GenServer Fatigue

When working with `GenServer` you typically abstract the api for your callers, and it looks something like this:

```elixir
defmodule Peach.Sales do
  use GenServer

  #... initialization stuff
  def start_link(args), do: GenServer.start_link(__MODULE__,args)

  def init(args), do: args

  # public API
  def select_item(pid, item),  do: GenServer.call(pid, {:select_item, item})

  def remove_item(pid, sku: sku),  do: GenServer.call(pid, {:remove_item, sku: sku})

  def change_item(pid, sku: sku),  do: GenServer.call(pid, {:change_item, sku: sku})

  # internal GenServer bits
  def handle_call({:select_item, item}, _sender, session) do

  end
  def handle_call({:remove_item, sku: sku}, _sender, session) do

  end
  def handle_call({:change_item, sku: sku}, _sender, session) do

  end

  # privates
end
```

For every public API call you have a corresponding `handle_x` call that is responding to `GenServer`. You can simplify this by using `Agent`:

```elixir
defmodule Peach.Sales do

  #... initialization stuff
  def start_link(args), do: GenServer.start_link(__MODULE__,args)

  # public API
  def select_item(pid, item)  do
    Agent.get_and_update pid, fn(state) ->
      #do something with the state
      {state, state} #first item is the result, second is the new state
    end
  end

  def remove_item(pid, item)  do
    Agent.get_and_update pid, fn(state) ->
      #do something with the state
      {state, state} #first item is the result, second is the new state
    end
  end

  def change_item(pid, item)  do
    Agent.get_and_update pid, fn(state) ->
      #do something with the state
      {state, state} #first item is the result, second is the new state
    end
  end
  # privates
end
```

So much cleaner. But we can improve this even more! Given that storing state is common in each routine, we can centralize it:

```elixir
defmodule Peach.Sales do

  #... initialization stuff
  def start_link(args), do: GenServer.start_link(__MODULE__,args)

  #just return the current state
  def current(pid), do: Agent.get(pid, &(&1))

  # public API
  def select_item(pid, item),  do: current |> do_something |> save
  def change_item(pid, item),  do: current |> do_something |> save
  def remove_item(pid, item),  do: current |> do_something |> save


  # privates
  defp save(state) do
    Agent.get_and_update pid, fn(_state) ->
      #save to the DB
      {state, state}
    end
  end
end
```

This looks so much cleaner doesn't it? The only way it could be better is if we were working with `Plug.Conn`... and which is what I'll do next time!

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
