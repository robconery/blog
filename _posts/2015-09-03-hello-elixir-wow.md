---
layout: post
title: "Hello Elixir. Wow."
slug: hello-elixir-wow
summary: ""
comments: true
image: /img/2015/09/elixir_1.jpg
categories: Opinion Elixir
---

I don't know anything about elixir but I very much want to learn it. I like learning new things - I feel it's required for our industry. It's easy to feel a twinge of snark about this, I feel that too, every day. But every now and again something comes along and I just find myself getting pulled right in.

I know nothing about Elixir short of 6 chapters I read in a book over the weekend and some goofing around today. If you want to learn along with me, hurrah! Let's go.

## Why Is Elixir Exciting?

For me it's both a positive and a negative reason. I remember the joy I felt when Ruby/Rails hit the scene, dragging me away from .NET. Five or so years later, Node came along and made life so much simpler - moving away from the monolithic web monster that's so easy to create with Rails.

But Node is JavaScript, and to be honest my programming skills have eroded **tremendously** since I started doing Node full time over the last 4 years or so. I found this out when I tried to write some C# a few weeks ago. Ugh.

C# introduced me to some very interesting programming concepts, which I further exercised with Ruby and then flat-out ditched while working with JavaScript. Sigh.

Elixir is exciting to me because it's fast, fast, my god **it's fast** and has many of the nice facilities that Ruby does - with the power of Erlang behind it.

I like this.

## Can I Build Something Right Now?

For most languages that you're learning the answer is a flat "no". Getting set up takes some time (Java, C#, Haskell, etc). With Elixir you just install it and you can write some code:

```
brew update &amp;&amp; brew install elixir
```

*This is installing elixir using Homebrew on a Mac. [other installation options are here](http://elixir-lang.org/install.html)*

Within 30 seconds you have Elixir (and Erlang) on your machine. You can see this right now:

```
iex
```

That opens up the Elixir REPL. Type something:

```
iex> x = "Rob"
Rob
iex> x
Rob
```

You just wrote some Elixir. Nicely done! For me that's the first victory - 0 to code in under 5 minutes. Nice!

## Mix, NPM For Elixir

Sort of. Mix is a "project and build" manager for Elixir. It's a little bit of Rake, a little NPM - kind of in-between. Mix will create a new project for you - which you can think of as both a package and an executable (this is a command line command, not an iex command):

```
mix new hello_elixir
* creating README.md
* creating .gitignore
* creating mix.exs
* creating config
* creating config/config.exs
* creating lib
* creating lib/hello_elixir.ex
* creating test
* creating test/test_helper.exs
* creating test/hello_elixir_test.exs
```

This is so, so nice. It's created a tight little package structure for us, with a README, a .gitignore, a test directory (ready for tests!) and what's obviously an entry point with a `mix.exs` file. Even a central place for "config stuff"!

This is brilliant. It's also heavily commented so you can read through and have a basic understanding of what's going on.

## Something Useful

If you want to skip right ahead - go for it. [I put all the code on Github](https://github.com/bigmachine-io/bigmachine-membership) and will be tweaking it over the coming weeks.

So I could step through and do some silly crap where I output "Hello World" - but I'd rather do something more fun. **How about we connect to a database and execute a query**. Great idea - let's create a new Mix project called "Membership":

```
mix new membership
* creating README.md
* creating .gitignore
* creating mix.exs
* creating config
* creating config/config.exs
* creating lib
* creating lib/membership.ex
* creating test
* creating test/test_helper.exs
* creating test/membership_test.exs
```

I want to create a harness around my [pg_auth](https://github.com/robconery/pg-auth) project. It's a set of Postgres tables, functions, etc for handling membership in your application. I want to see how hard it is to execute a query, and WTF is going on here.

Yes I could read the book more, *but I much prefer to actually do something*, learning as I go.

The first thing to find out is whether there's a PostgreSQL driver. Elixir has been around for a while, so I'm fairly certain there is one, and [yes indeed there is](https://github.com/ericmj/postgrex).

Now, I need to figure out how to get that project into my new project. The instructions are right on the main page of the Postgrex project: so open up `mix.exs` and edit the dependencies as well as which applications we'll be using inside our own:

```elixir
def application do
  [applications: [:logger, :postgrex]]
end

#...

defp deps do
  [{:postgrex, "~> 0.9.1"}]
end
```

The bottom directive says that we want the `postgrex` package, the top directive says we want to "mount it" in our app... I think. Still a bit hazy on what exactly is going on here.

The next step is to make sure the dependencies are installed:

```
mix deps.get
```

This goes out to "hex.pm" - kind of like npmjs.org - it's where the package bits for Elixir are stored online. It will look for the `postgrex` package (version 0.9.1) and download it - creating a new directory called `deps` in our project.

Have a look in there (after you run this command). *It's the source*. Which I think is quite nice. It is, essentially, NPM's "node_modules" approach - grab the source and stick it in your project so you can review etc. This *seems* to be a single-level dependency graph, unlike node_modules, which recursively grabs the entire internet just in case.

Anyway - we have what we need here - access to a database.

## The Membership Module

Let's write some code. I have a function called "membership.register" that I want to call, and I want to return the results somehow. For this I'll crack open `membership_test.ex` and have a look at the test structure:

```elixir
defmodule MembershipTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end
end
```

Gloriously sparse. It's not hard to figure out what's going on here - especially if you know Ruby. We're defining a module with a `do` block (yay!), bringing in some help from the ExUnit test library, and then writing a wonderfully terse test.

The fun Ruby vibes are setting in. This is exciting.

Let's write our test and watch as everything explodes:

```elixir
defmodule MembershipTest do
  use ExUnit.Case

  test "Registration succeeds with valid credentials" do
    {:ok, res} = Membership.register({"test@test.com", "password"})
    assert res.success,res.message
  end

end
```

This is stretching what I know about Elixir - but basically I have a tuple on the left there, that's being "matched" with the result of the `Membership.register/1` on the right.

We're now in the new language weeds. Here's what I know so far about this.

Every function in Elixir works on the concept of "pattern matching". You don't just call a function or "send a message" as you do in Ruby (though those ideas work too). You try to match things on both the left and right side of the assignment.

On the left I have a tuple with the first element being an "atom". You can think of this exactly as a Ruby symbol. The second element is any kind of data coming from the function result. This is a different kind of thing for me, but I think I get it and I'm going to punt on talking about that more because, simply, I'm just not sure what I can really do with it.

OK, let's write our `register` routine:

```elixir
defmodule RegistrationResult do
    defstruct success: false, message: nil, new_id: 0
end

defmodule Membership do

  def register({email, password}) do
    {:ok, pid} = Postgrex.Connection.start_link(database: "bigmachine")
    sql = "select * from membership.register($1, $2);"
    {:ok, res} = Postgrex.Connection.query(pid, sql, [email, password])
    [record | last] = res.rows
    [new_id, validation_token, auth_token, success, message] = record
    {:ok, %RegistrationResult{success: success, message: message, new_id: new_id}}
  end

end
```

This is going to look very, very strange to you if you've never seen Elixir. It might also look incredibly strange to you even if you have! *I'm very new to this stuff*.

In the first lines up there I'm defining a struct to hold my result. I don't need to do this, but it's a nice way to package up results. I could use a `Dict`, `Hash`, or `Map` (or even a tuple) - but I like working with dot notation and you can do that with a struct.

In the register function I'm accepting a tuple (which is a good thing to do - a single argument that is flexible and expandable) and then opening the connection, matching it against a tuple to hold the `pid`.

That `pid` is not an operating system pid, it's Process pid built into elixir which is pretty mind-twisty. It's like having a little message queue all your own right inside your runtime. I don't know nearly enough to talk more about it, but I'm excited to get there.

OK, the next lines are pretty clear - I create a SQL string, pass the params, and execute using a pattern match on `{:ok, res}` where `res` is a struct for handling results.

Now that I have the result, I need to peel off the "head" of the rows array. This is where I think my code is pretty damn messy and I'm sure there's some better way - but for the sake of learning and trying to get something done I hacked the crap out of it.

The deal is that you can ask for the "head" and "tail" of a list by using this notation:

```elixir
[h | t] = [1,2,3,4]
```

Here, `h` will equal "1" and `t` will equal "[2,3,4]". You might be thinking "WTF? Why?" like I did, then you get to see some recursive action and it will blow your mind. Again: I need to know more about that before I start writing anything.

So, the record I want is the first element of the return array - that means I need to pattern match against a list of variables, which will hold those values. Weird notation, but I think it's pretty interesting.

Finally I kick up a new struct and assign the results, making sure to pass the `:ok` atom first thing.

## Testing This Properly

This took me a while to figure out. I wanted to write a test that executed the `register` function once so I could write a set of asserts on the result - I don't want to call `register` multiple times.

I tried my Ruby approach, using module-level variables and assigning them in the `before` block, which didn't work. Turns out it's much simpler:

```elixir
defmodule MembershipTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = Postgrex.Connection.start_link(database: "bigmachine")
    Postgrex.Connection.query!(pid, "delete from membership.users", [])
    {:ok, res} = Membership.register({"test@test.com", "password"})
    {:ok, [res: res]}
  end

  test "Registration with valid credentials", %{res: res} do
    assert res.success,res.message
  end

end
```

There's a setup "macro" (don't know what those are yet) that does what you expect. I open a connection, drop the users, and then run my registration function.

This is where things get neat. Every `setup` block can pass along a "context" to each test. It's just the result of `setup` - which is the very last line. The result has to be in the form of something like this:

```
{:ok}
{:ok, [key: value, another_key: another_value]} #a Dict
```

As you can see, Elixir has the convention of returning an atom in the fist place of a tuple to "define" what the tuple represents. If things are all good, `:ok` is returned. You can use anything in the first position - like `:person`, `:refund`, or `:err`. It's simply a convention - just like Node's callback structure `(err, res, next)`.

Where I got into trouble was trying to send back a raw result (my `RegistrationResult ` struct) from the `register` function - I kept getting an error about my `RegistrationResult`:

```
** (Protocol.UndefinedError) protocol Enumerable not implemented for %RegistrationResult
```

I got this error because the `setup` routine was trying to treat it like a `Dict` (dictionary) - which is enumerable (that's what `Enum` is, an enumeration module).

OK anyway I finally figured out I could send the result directly to my tests by using this:

```elixir
    {:ok, res} = Membership.register({"test@test.com", "password"})
    {:ok, [res: res]}
```

That meant I could structure my test this way:

```elixir
  test "Registration with valid credentials", %{res: res} do
    assert res.success,res.message
  end
```

And it worked. **My god it worked**.

## Why I Put Wow In The Title

Elixir is intimidating to me. I suck as a programmer and really, I'm kind of a hack. But in about 3 hours I was able to take what I read in a book, connect to a database **without a framework** and execute something in a rather elegant way.

Wow. This made me quite happy today. We'll see about tomorrow.

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
