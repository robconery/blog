---
layout: post
title: "Using Recursion In Elixir To Break Your OO Brain"
slug: using-recursion-in-elixir-to-break-your-oo-brain
summary: ""
comments: true
image: /img/2015/09/recursion_title.jpg
categories: Elixir
---

I have to start out each post this way: *I have no idea what I'm doing*, but dammit am I having fun. In the fist few posts I ham-handedly threw some code against the wall to see what would ... stick? Anyway It worked, but I realized (as I did with Ruby, wonderfully) that *there just has to be a better way*.

I don't want to diminish that observation **because it's what I love about Ruby**. I always felt like I could level-up my Elegance in Ruby if I just took the time (and patience) to see what was possible.

With elixir it's the same.

## Refactoring, Loops, Recursion

If you read about loops in elixir or [Google Elixir for loop](https://www.google.com/search?client=safari&rls=en&q=Elixir+for+loop&ie=UTF-8&oe=UTF-8) the first hit you'll see is "Elixir Recursion". Which scared me.

You see, I suck as a programmer. As I mention - I really am a hack. **The fact that I understood recursion and can use it** is pretty damn outstanding incredible (on Elixir's end, not mine). OK enough blathering, let's see some code.

**The Problem**: I have this intensely fugly routine where I query a database and send the results back when a user registers:

```elixir
def register({email, password}) do
  {:ok, pid} = Membership.connect()
  sql = "select * from membership.register($1, $2);"

  case Postgrex.Connection.query(pid, sql, [email, password]) do
    {:ok, res} ->
      cols = res.columns
      [first_row | _] = res.rows
      [new_id, validation_token, auth_token, success, message] = first_row
      {:ok, %RegistrationResult{
        success: success,
        message: message,
        new_id: new_id,
        authentication_token: auth_token,
        validation_token: validation_token
    }}

    {:error, err} -> {:error, err}
  end
end
```

It's a start, but this function does way, way too much:

 - Queries a database
 - Transforms the results
 - Creates a struct and returns the results

Honestly I can live with this. But, like working with Ruby, I know there's a better way and **I know when I find that better way, I'll be better at Elixir**. So let's see what can happen.

## The Solution

I need to split this stuff out and I need a better way to cast the result properly. I hate the way this is all going together - so let's use some recursion and split things out into a specific module built to handle database results:

```elixir
defmodule Membership.DBResult do

  def map_single({:ok, res}) do
    cols = res.columns
    [first_row | _] = res.rows
    map_single {:cols_and_first, cols, first_row}
  end

  def map_single({:cols_and_first, cols, first_row}) do
    zipped = List.zip([cols,first_row])
    map_single {:zipped, zipped}
  end

  def map_single({:zipped, list}) do
    {:ok, Enum.into(list, %{})}
  end

  def map_single({:error, err}) do
    {:error, err}
  end

end
```

I'm sure this code still sucks, but I love how it's split out here. Notice that each function has the same name but has a different parameter signature? **Pattern Matching**, people. This is too fun.

So, basically an outside caller will simply do this:

```elixir
Membership.DBResult.map_single(query_result)
```

And Elixir will figure out how to match for you. From what I've read, Atoms do this for you and it's one of the idioms Elixir people use just for this reason. Each one of these functions has a different signature, and each one does a single thing. The first matches the `{:ok, ...}` tuple, which is the result from the query.

That function then calls itself, but with a different Atom at first position. That matches against the second function... and hopefully you can see the pattern here. Basically, what I'm trying to do is handle/transform the query result in one place. I'm sure there's probably a better way - but this takes a convoluted query result and transforms it really nicely.

## Pass The Pipe

There are two ways to use this new module. I can use it directly:

```elixir
Membership.DBResult.map_single(query_result)
```

Or do something just a bit more elegant by *piping* the result data through a pipeline:

```elixir
def new_application({email, password}) do
  {:ok, pid} = Postgrex.Connection.start_link(database: "bigmachine")
  sql = "select * from membership.register($1, $2);"
  Postgrex.Connection.query(pid, sql, [email, password])
    |> Membership.DBResult.map_single
    |> to_registration_result
end
```

I really love this. I'm running the query and then using the Elixir pipe operator `|>` to essentially "shove" the results into the next routine, which is the `map_single` stuff I wrote above. Finally, when I get it back I shove it into a `to_registration_result` function, which is this, here:

```elixir
def to_registration_result({:ok, res}) do
  {:ok, %Membership.RegistrationResult{
    success: res["success"],
    message: res["message"],
    new_id: res["new_id"],
    validation_token: res["validation_token"],
    authentication_token: res["authentication_token"]
  }}
end

def to_registration_result({:error, err}) do
  {:error, err}
end
```

Notice that I have two methods with the same name? This is, once again, **Pattern Matching** at its best. Elixir will call the function according to whatever signature is passed along. If there's an error, the second function will be called. Otherwise it will be the first, which then, finally, passes the result back.

As always, [you can see the code I'm writing up here, at Github](https://github.com/bigmachine-io/bigmachine-membership). I *know* that there is a ton of room for improvement - so if you have a thought please share.

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
