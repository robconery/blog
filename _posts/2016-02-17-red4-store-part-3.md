---
layout: post
title: 'Red:4 Store Part 3 - Saving Session Data'
image: 'typewriter.jpg'
comments: true
categories: Elixir
summary: "We have a Session process that is being Supervised, which is the hard part. Now let's hook up a persistent data source."
---

Let's implement an intelligent shopping cart - something that tracks what the customer is doing, how they came to our store, etc. I tend to think of these things in terms of a "Session" - a shopping process where a customer selects things, puts them back, and eventually (hopefully) buys something. If I do things correctly (to me, at least), I should end up with tight little functions an **exactly 0 if statements**.

## Task 1: Proper Initialization

For review - we have a struct defined that we can use to hold items, logs, discounts and more. Each customer coming to our store will have a dedicated process which is supervised by the VM (*/apps/shopping/lib/shopping/session.ex*):

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

Working with GenServers takes a little time to get used to. What we're doing is actually *wrapping* GenServer functionality in a standardized way. With the code above we've implemented the first method: `start_link`. This wraps `GenServer.start_link/3`.

Now we need to open up a public API which will accept calls like `add_item`, `remove_item` etc. One problem we have, however, is that functional programming doesn't have the concept of "state", necessarily. It's all about immutability and *not changing things* - so how the hell are we going to track the items in our cart!

That's where GenServers come in. They don't *really* have state - they have *accumulators*. The best way to explain this is to just show you what I mean.

When you call `start_link` you pass in the initial "state" in the second position. This can be any data you want. In our case we're matching on `%{key: key} = args` which means we expect the key named "key", which represents a session key, to be passed in as our argument. The `args` variable can contain anything else, but at the very least it needs to have a `key`.

GenServer will now set the args as our initial state. But we have a problem - these `args` can literally be anything and we don't want that. We also don't want to bleed out our struct to calling code (forcing the calling code to initialize only our struct) - let' make this a little friendlier and a bit tighter using the `init` callback:

```elixir
defmodule Redfour.Shopping.Session do

  use GenServer

  def start_link(%{key: key} = args) do
    GenServer.start_link(__MODULE__,args, name: key)
  end

  def init(%{key: key} = args) do
    struct(%Redfour.Shopping.Session{}, args)
  end

  #...

end
```

In the code above `init/1` will be called automatically by GenServer right after `start_link/3` and the initial arguments will be passed to it. The result of `init/1` will then be the thing stored in "state". All we're doing here is creating the `Session` struct and passing it back.

Why did we do this? Because:

 - We want to be sure we're working with our struct as our state so we can add items, logs, etc
 - We're allowing a map to be passed in instead of the struct, making our API a little easier to use. We don't have to do this - this is just my preference.

Now, because I'm completely anal, let's tighten this up:

```elixir
defmodule Redfour.Shopping.Session do

  use GenServer

  def start_link(%{key: key} = args), do: GenServer.start_link(__MODULE__,args, name: key)

  def init(%{key: key} = args), do: struct(%Redfour.Shopping.Session{}, args)

  #...
end
```

You don't have to do it like this - I just kind of dig one-liners as they're a bit easier to read. Now let's add something to the cart.

## Task 2: Adding, Removing, Updating

Calling code shouldn't need to know it's working with a GenServer, it makes things a bit brittle and breaks an otherwise lovely encapsulation. So let's consider our public API:

```elixir
defmodule Redfour.Shopping.Session do

  #... initialization stuff

  # public API
  def select_item(pid, item),  do: GenServer.call(pid, {:select_item, item})

  def remove_item(pid, sku: sku),  do: GenServer.call(pid, {:remove_item, sku: sku})

  def change_item(pid, sku: sku),  do: GenServer.call(pid, {:change_item, sku: sku})

  # internal GenServer bits

  # privates
end
```

This is just the start, and if you're new to GenServers this will look strange. Basically we're just wrapping the functionality of GenServer here in a nicer API. For the method calls themselves, we're demanding a `pid` and then whatever arguments we need.

I like to use Keyword Lists to identify arguments explicitly. This helps with matching. When appropriate I'll use a struct (and it's appropriate here) - I'll get to that in a minute. The most important part is that we're telling GenServer to issue a `call/2` to a process identified by our `pid`. GenServer will do just that, passing the argument tuple along.

But then what happens? This is where OO people might cringe. We're going to "dual purpose" our module here to not only *issue the call*, but to also pick it up. Which makes sense because this module is also our process - so basically it's *calling itself*.

Why the ceremony? Simple answer: *we need state*:

```elixir
defmodule Redfour.Shopping.Session do

  #... initialization stuff

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

With the addition of these three `handle_call/3` methods, we can now execute calls to our process. Notice the three arguments - the first is the identifier and the data wrapped in a tuple (this is a standard Erlang/Elixir way of passing data around so you can match on it). The second identifies who's calling, which we're ignoring by preceding the variable with an `_`. Finally we have our `session` - which is our state.

Let's do the simplest implementation:

```elixir
def handle_call({:select_item, item}, _sender, session) do

  session = %{session | items: List.insert_at(session.items, -1, item)}
  {:reply, session, session}

end
```

This code is extremely simple. We're appending the passed in item to the `items` list on our struct (see above) and passing back a new session. Finally, we're telling GenServer that things are lovely with `{:reply, session, session}`. Let's talk about that response.

If things go wrong we can pass back something else, like:

 - `:noreply, session` - basically something happened, all went well, here's the new state
 - `:stop, reason, [reply], state` - something bad happened, stop the process with a reason

These are very useful responses for certain scenarios. For instance if an item comes in with a negative price, it might be a good idea to kill the session and send the customer packing fearing some type of hack - you could use `:stop` for that if you like.

For what we're doing, we're replying with the new session and then resetting the new state of our process using that same session. This is the basic structure of our process - now we just need to wire things up.

## Task 3: Data Access

Our `Shopping.SessionSupervisor` will restart our session if it `:exit`s unceremoniously. We could create a "stash worker" (see [Programming Elixir](https://pragprog.com/book/elixir/programming-elixir) from PragProg, page 214) and have our process seamlessly restarted, or we could be a little safer and use a persistent data store.

*Note: I originally stated that Supervisor's will restart a service with the last known state. This is incorrect - thanks to Graham Kay for correcting the mistake!*

I'll sidestep discussions on what's the most appropriate, but let's quickly have a look at our options:

 - A standard database like Postgres. For this we could use [Ecto](https://github.com/elixir-lang/ecto) or something a little lighter weight, such as [Moebius](https://github.com/robconery/moebius).
 - A document system, such as Erlang's built-in Mnesia using the [Amnesia](https://github.com/meh/amnesia) library. This is a *great* option for getting things off the ground, but not so good moving forward. The simple reason is that querying is a bit painful but also - it's not partition tolerant. Meaning if one node goes down, writes can't happen. It *is* ACID compliant, however... We could also use RethinkDB using [Peter Hamilton's rethinkdb-elixir library](https://github.com/hamiltop/rethinkdb-elixir). I've used it, I really like it! We're not allowed to use MongoDB here at Red:4, but you're welcome to have a look at that solution.
 - *No persistence at all*. This is a bonkers approach. It means that if you restart your server, your customers lose their sessions. When you do the math on this it's actually a very, very small inconvenience to a select few people. Erlang tends to run for long stretches and if you plan your restarts accordingly - well it might not be so bad. Also - losing cart data might be acceptable to you.

For me, I'm choosing Postgres and Moebius. I like the ease of use (it's why I wrote it) and if I didn't choose it... well I'd probably be in trouble. If you want to play along, I'll be using the [dbworker](https://github.com/robconery/moebius/tree/dbworker) branch which should be 2.0 in the future.

The first thing I need to do is install Moebius in `apps/shopping/mix.exs` and set it as an application:

```elixir
def application do
  [applications: [:logger, :moebius],
   mod: {Redfour.Shopping, []}]
end

defp deps do
  [
    {:moebius, github: "robconery/moebius", branch: "dbworker"},
  ]
end
```

Next, I need to setup a database module that will become a worker which will be supervised. I'll add */lib/shopping/db.ex*:

```elixir
defmodule Redfour.Shopping.Db do
  use Moebius.Database
  import Moebius.DocumentQuery
  alias Redfour.Shopping.Db

  #session stuff
  def find_or_create_session(%{key: key, domain: domain} = args) do
    case db(:sessions) |> contains(key: key) |> Db.first do
      nil -> db(:sessions) |> Db.save(struct(%Redfour.Shopping.Session{}, args))
      found -> found
    end
  end

  def save_session(session) do
    db(:sessions) |> Db.save(session)
  end

end
```

Moebius allows you to work with Postgres as a document store - which is a great way to get yourself off the ground. Here I simply need to `use Moebius.Database` which gives us some macros to play with, including `run, first, save`. Which is all I need for our `Session`.

With the first method I'm finding or creating (using Postgres 9.5 I could use `upsert` but I'm using 9.4), with the second I'm just pushing the entire session into the database as a document (Moebius wraps this up for me).

OK, so I have a module that "declares a database" if you will. Why did I do all of this? Because my new database module is a GenServer and I'll want to be sure it's supervised within the scope of my app. For that, let's add some code to our start routine:

```elixir
defmodule Redfour.Shopping do
  use Application
  import Supervisor.Spec, warn: false

  #the entry point to start our app
  def start(_type, _args) do
    #supervision goes here
    start_session_supervisor
    start_database
  end

  def start_database do
    #start the supervised DB
    db_worker = worker(Redfour.Shopping.Db, [database: "redfour"])
    Supervisor.start_link [db_worker], strategy: :one_for_one
  end

  #...
end

```

We're loading up a `worker`, passing in a reference to our database. This is a significant change to what Moebius used to do (you would set the connection info in config) - by changing like this we can now have multiple database connections formalized and supervised. Yeeha.

Now that I have this in place, let's make our `Session` data aware:

```elixir
defmodule Redfour.Shopping.Session do
  use GenServer
  alias Redfour.Shopping.Db

  defstruct [
     store_id: nil,
     id: nil,
     key: nil,
     landing: "/",
     ip: "127.0.0.1",
     member_id: nil,
     items: [],
     logs: [%{entry: "Session Created"}],
     discounts: []
   ]

  def start_link(%{key: key} = args) do
    GenServer.start_link(__MODULE__, args, name: key)
  end

  def init(%{key: key, domain: domain} = args) do
    session = Db.find_or_create_session(args)
    {:ok, session}
  end

  #GenServer callbacks
  def handle_call({:select_item, item}, _sender, session) do

    session = %{session | items: List.insert_at(session.items, -1, item)} |> save_session
    {:reply, session, session}

  end

  #...

  # privates
  def save_session(%Redfour.Shopping.Session{} = session, log: log) do
    %{session | logs: List.insert_at(session.logs, -1, %{entry: log})} |> Db.save_session
  end
end
```

This is a good start, but it's far from a final solution. Things are still a bit too lose.

## Summary

We need to put some guards in place for when things don't go well, and I also need to plug in better date management. Right now you can pass whatever you want to `select_item` which isn't good... so we'll fix that. Next time!

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
