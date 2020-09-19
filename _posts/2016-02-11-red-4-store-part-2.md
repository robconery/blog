---
layout: post
title: 'Red:4 Store Part 2: Wrapping Our Heads Around Processes'
image: 'elixir_processes.jpg'
comments: true
categories: Elixir
summary: "It's time to dive right into the deep end and consider how we're going to use OTP. The learning curve is deceptively steep, but if we can do this correctly we'll have a rather bullet-proof system."
---

When you build applications in the Erlang world you create discrete processes that interact. In theory this is pretty straightforward - until you *actually try to do it*. Microservices fans out there know the value (and the pain) of managing a fleet of services; there are benefits to it, definitely, and also problems.

Consider [this quote from Benjamin Wootton](http://highscalability.com/blog/2014/4/8/microservices-not-a-free-lunch.html), describing what he's going through while building a system based on microservices:

> I am currently involved in architecting a system based around Microservices, and whilst the individual services are very simple, a lot of complexity exists at a higher level level in terms of managing these services and orchestrating business processes throughout them... Microservices [is] one of these ideas that are nice in practice, but all manner of complexity comes out when it meets reality...

So very true. I like how [Jessica Kerr](http://twitter.com/jessitron) puts it:

> Erlang has been providing [the connection between services] for literally 25 years. As we get more and more sophisticated microservice implementations, each one grows their own crappy version of Erlang

Erlang has been doing this kind of thing for 25+ years. The community has had time to formalize a number of ideas into concepts, which have made their way into a platform: [OTP](http://learnyousomeerlang.com/what-is-otp). That's exactly what we'll be using, right now.

## The First Task: A Shopping Cart

It's a fine place to start, why not. The first thing to do is embrace that I'm building a process here, not a set of objects (`Cart` and `CartItem` e.g.). If you think about `Shopping` as a process that your customer engages in - well I'd say we have our first `Application`:

```bash
cd apps
mix new shopping --module Redfour.Shopping

* creating README.md
* creating .gitignore
* creating mix.exs
* creating config
* creating config/config.exs
* creating lib
* creating lib/shopping.ex
* creating test
* creating test/test_helper.exs
* creating test/shopping_test.exs

Your Mix project was created successfully.
You can use "mix" to compile it, test it, and more:

    cd shopping
    mix test

Run "mix help" for more commands.
```

We've just created an `Application`, which is [a discrete OTP construct](http://erlang.org/doc/design_principles/applications.html):

> When you have written code implementing some specific functionality you might want to make the code into an application, that is, a component that can be started and stopped as a unit, and which can also be reused in other systems.

You can think of Applications as "components" or "beans" or "dlls". This fits perfectly well with what we want - our `Shopping` application will implement a number of its own child services, and it will be used by our `web` app as well (which is another `Application`).

## Task Two: The Session

We've setup the structure of our `Shopping` process - but how will it be carried out? As with Real Life, Shopping is just a concept for customers walking around your store, picking things off the shelves. Each one of them is `Shopping`, if you will.

If I were to break the process down, it would look like this:

 - A Customer enters the store, starting a shopping session as they browse our catalog and various promotions
 - They put stuff in their cart, remove stuff, and decide whether they are buying something
 - They take their selections to checkout and buy them (hopefully)
 - We record the sale and all the data that went into it (because we tracked them through the store) for reporting purposes

Functional programming is all about moving/transforming data through a one or more processes. Looking at this list I would say that a `Session` moves through a `Shopping` process. Let's define that! The first thing to do is to create an application for `Shopping`:

```bash
cd apps
mix new shopping --module Redfour.Shopping
```

The next thing is to create a directory and code file:

```bash
cd apps/shopping
mkdir lib/shopping
touch lib/shopping/session.ex
```

Now let's pop some code in:

```elixir
defmodule Redfour.Shopping.Session do

  defstruct [
    domain: nil,
    id: nil,
    key: nil,
    landing: "/",
    ip: "127.0.0.1",
    member_id: nil,
    items: [],
    logs: [],
    discounts: []
  ]

end
```

This struct defines our `Session` explicitly. The domain of the store (in case we have more than one, which is possible), an `id` from our database, a `key` that uniquely identifies it in a business sense, and lists to hold `items`, `logs` and any `discounts` that they use. To have an effective store we need to *track everything* - and this is a great first start.

## Task Three: The GenServer

Any code that you write in Elixir runs in a singular `process`. Even if you try to write some Elixir and quickly run it with iex (the Elixir REPL) - it's still given a process. At the most basic level a process can be this:

```elixir
iex(1)> spawn(fn() -> IO.puts "Hello World" end)            
Hello World
#PID<0.62.0>
```

The `spawn` command tells Elixir to spin off some code and run it separately. The `fn() -> IO.puts "Hello World" end` bits are just an anonymous function declared inline - that part's not important - what is important is how easy it is to spawn things that run in their own process and just do stuff.

*Note: These are VM processes, completely contained within the Erlang VM. Not OS processes*.

We would have a massive hill to climb if we decided to build our `Session` using nothing but `spawn`. We would, as Jessica put it above: *build our own crappy version of Erlang*. Let's jump ahead and just use OTP:

```elixir
defmodule Redfour.Shopping.Session do

  use GenServer

  def start_link(%{key: key} = args) do
    GenServer.start_link(__MODULE__,args, name: key)
  end

  defstruct [
    domain: nil,
    id: nil,
    key: nil,
    landing: "/",
    ip: "127.0.0.1",
    member_id: nil,
    items: [],
    logs: [],
    discounts: []
  ]

end
```

By implementing `use GenServer` here, we've made our `Session` into a formalized OTP Server that can do a number of groovy things - the most important of which is *that it can now be supervised*. More on that in a minute.

No matter how much I write and wave my arms - understanding `GenServer` takes some actual *doing*. It honestly isn't that complicated - but the first few times you encounter this little beasty ... well you're on Google non-stop (at least I was). There's a learning curve here but, hopefully, we can learn as we go.

We have our struct defined and have made our `Session` into a formalized `GenServer` process. I need to make sure this thing can *maintain state*, which might sound a little odd given that we're using a functional language; the whole idea of which is to remove the notion of mutation and, basically, *the changing of state*.

That's what `GenServer`s do: they give you a way to attach state to a process. We do that by seeding it with some data when it starts, and passing that data back after each call. With `start_link` we seeded the data with a map:

```elixir
def start_link(%{key: key} = args) do
  GenServer.start_link(__MODULE__,args, name: key)
end
```

This is telling OTP to create a process for us in the VM with the initial data of `args` (which is a Map) and a name corresponding to some key. Here's how I would use this:

```elixir
iex(1)> {:ok, pid} = Redfour.Shopping.Session.start_link %{key: :my_session}
{:ok, #PID<0.93.0>}
iex(2)> Redfour.Shopping.Session.do_something :my_session, some_arguments
```

We now have a process running in memory that I can refer to anywhere, as long as I know the name `:my_session`. This process will uniquely describe the notion of someone browsing through our store, looking at things, picking them out, etc. You might be wondering what happens when another customer comes and I need to start another `Session`?

```elixir
Redfour.Shopping.Session.start_link %{key: :new_customer}
```

Now we have two sessions running. How do I know? Let's have a look:

```elixir
iex(3)> :observer.start
```

You should see an application pop up with all kinds of interesting tabs on it. This is the Erlang observer - it tells you what's happening with the VM and all the processes running inside. If we look for ours:

![Our Processes](/img/redfour_2_processes.png)

Which is nice and all, but not ideal. Just like any thread or process in other languages, if something goes wrong this process will exit and die - along with all of it's state (items in the cart and so on). This is bad. Speaking of "bad" - you might be wondering about scalability here. How can we expect our app to scale if we have all of these processes bouncing around in memory?

This is one of the (many) great parts about the Erlang VM: *it's incredibly efficient*. Each process has its own heap - which basically means that there's no shared memory between processes. When one dies, everything goes with it. When a parent process dies, all of its children die too. Of course we don't want these processes living forever - so we can actually set a timer on them if we want; but I'd rather handle that explicitly (kiling them) - which I'll do in a later post.

Let's flip over to the *Applications* tab:

![Our Processes](/img/redfour_2_applications.png)

This tells you what OTP Applications are currently running - and so far it's just one: ours. Process 0.82.0 is our `start_link` and 0.83.0 is `init` (which I'll talk about more next time). We then have an `Elixir.Logger.Supervisor` process which, in turn, has spawned a number of child processes that it needs.

Our little processes are nowhere to be found in this tree. We need to change that.

## Task Four: Supervision

In Elixir (and Erlang), you don't write code to recover from errors: **You let things die**. You do this because you can, and it's a natural thing to do if you want a system that stays up and doesn't crash. This might sound completely bonkers at first - but hold tight hopefully you'll see what I mean.

What we need for our `Application` is a *Supervision Tree*. In OTP, a `Supervisor` is a process that watches other processes and, if they die, it restarts them. Pretty simple to explain, a bit harder to correctly put together.

When I created our `Application` I made it rather bare bones with no notion of a `Supervisor`. If I would have added the `--sup` flag it would have created a supervisor for us - but that's OK we can just do it ourselves. The first thing to do is to change our `apps/shopping/lib/shopping.ex` main file:

```elixir
defmodule Redfour.Shopping do
  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    #supervision goes here
  end
end
```

Next, we need to formalize this as the startup module by telling Mix. Open up `apps/shopping/mix.exs` and edit the `application` callback to define the start module:

```elixir
def application do
  [
    applications: [:logger],
    mod: {Redfour.Shopping, []} #add this
  ]
end
```

This callback is telling Mix what additional applications to start, aside from our own. You can see the `:logger` here - which is what we saw in the `:observer` above. In addition to these applications, we want Mix to run our `Redfour.Shopping` module, passing in an empty argument list.

Now, let's flip back over to `shopping.ex` and add our `Supervisor` code. I'll do this in two separate functions:

```elixir
defmodule Redfour.Shopping do
  use Application
  import Supervisor.Spec, warn: false

  #the entry point to start our app
  def start(_type, _args) do
    #supervision goes here
    start_session_supervisor
  end

  #define our parent supervisor
  def start_session_supervisor do
    #spec the session supervisor
    session_worker = worker(Redfour.Shopping.Session, [])
    Supervisor.start_link([session_worker], strategy: :simple_one_for_one, name: Redfour.SessionSupervisor)
  end

  def start_session(key: key) when is_binary(key), do: raise "Please use an atom key"
  def start_session(key: key) when is_atom(key) do
    res = Supervisor.start_child(Redfour.SessionSupervisor, [%{key: key}])
  end
end
```

This took me a while to figure out - hours to be exact. It's a little impenetrable and rather hard to find resources online to properly explain it all - but I'll do my best. The `start` method is called by Mix when the app starts up. This, in turn calls `start_session_supervisor` which defines a worker - a thing which will be supervised. This is just a spec, it's not actually starting up the process.

I'm using a `:simple_one_for_one` strategy which means, basically, "if the worker dies, restart it". Finally I'm giving it the name `Redfour.ShoppingSupervisor`. Now for the good stuff.

I'm declaring a method called `start_session` that will spawn a worker within the purview of a `SessionSupervisor`. Every time I call this, the `SessionSupervisor` will call `Redfour.Shopping.Session.start_link %{key: key}` - creating our `GenServer` on the VM.

Let's give it a whirl. Navigate into the `apps/shopping` directory and start things up with iex, making sure to tell it to load up the `mix.exs` file using `-S mix`:

```elixir
iex -S mix
#...

iex(1)> Redfour.Shopping.start_session key: :my_key
{:ok, #PID<0.96.0>}
```

Yes! Let's have a look at the observer again - run `:observer.start` within iex one more time. Don't close iex! You should see this in the *Applications* tab:

![Observer](/img/redfour_2_observer_2.png)

Here, 91 and 92 are our application starting up. Then we have our `Supervisor`, which is a child process of our application and finally our `Session`, identified by our key `my_key`. Let's add another session to be sure we've done things correctly. Keeping iex open, start another `Session`:

```elixir
iex(3)> Redfour.Shopping.start_session key: :another_key
{:ok, #PID<0.676.0>}
```

![Observer](/img/redfour_2_observer_3.png)

Radical! Now let's prove our theory. Keeping iex open still, let's kill a process off and make sure it gets restarted as we expect:

```elixir
iex(4)> pid = Process.whereis :my_key
#PID<0.96.0>
iex(5)> Process.exit pid, :kill
true
iex(6)> Process.whereis :my_key
#PID<0.683.0>
```

I can grab a running process by name using `Process.whereis` and get its pid - here you see it's 0.96.0. I then use `Process.exit` passing in the `pid` and the directive to kill it off, which indeed happens. If I ask for the process again - I can see it's running once more with a new `pid` of 0.683.0! You can confirm that it's been restarted looking back at the `:observer`.

## Next Time: Working With Data

A Session that's built to stay alive with a unique key assigned. Let your brain wander on that a bit - how would you store the data? More importantly: *when would you need to*? Given this `Supervisor` structure, the building of our application has changed quit a bit.

I don't need to focus on doing small, incremental writes in case our app crashes. Or our database. Or web server for that matter. **The only thing that will destroy our `Session` (and its data) is if the VM crashes or our server loses power.** The Erlang VM is not really known to crash - but yes it's a possibility. I certainly don't want to be arrogant about this - but *my god* - this is too fun.

If you had to persist data with only a server crash in mind... how would you do it? How would you compensate for the possible loss of your database - given that *you now can*?

Hopefully you see why I said what I did in the [first post in this series](/2016/02/10/let-s-build-something-with-elixir/) about Rails: *these two systems are night and day different*.

See you next time! If you see any corrections or have any thoughts - leave them below.

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
