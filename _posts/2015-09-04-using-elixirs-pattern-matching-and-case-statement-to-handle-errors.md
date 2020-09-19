---
layout: post
title: "Using Elixir's Pattern Matching And Case Statement To Handle Errors"
slug: using-elixirs-pattern-matching-and-case-statement-to-handle-errors
summary: ""
comments: true
image: /img/2015/09/learn_elixir.jpg
categories: Elixir
---

I don't really know what I'm doing. I'm trying to learn Elixir and I'm having so much fun doing it that I thought I would share what I'm learning. So ... here goes. The code for the stuff I'm writing is [up at Github](https://github.com/bigmachine-io/bigmachine-membership) - feel free to drop over.

[In my last post](http://rob.conery.io/2015/09/03/hello-elixir-wow/), Ayende Rahien mad a great comment:

<a href="http://rob.conery.io/img/2015/09/ayende_comment.png"><img src="http://rob.conery.io/img/2015/09/ayende_comment.png" alt="ayende_comment" width="895" height="482" class="alignnone size-full wp-image-566" /></a>

Excellent question (of course)! At the time I was just hacking things and wanted to see a result - I didn't worry too much about errors.

That said, let's see how we can handle this better. And please, if you know of a better please share in the comments!

## Case And Pattern Matching

A better way to execute the query for our call would be to use `case`:

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

Case statements are pretty standard for programming languages, and this one essentially operates the same way. Here, we're evaluating the return of the query and matching against that return. If all is OK, the `Postgrex` driver will match against `{:ok, %Postgrex.Result}`, otherwise it will match against `{:error, %Postgrex.Error}`.

This matching thing is really head-twisty. The nice part is, however, that we only need to think about the atoms (`:ok` and `:error`) here, Elixir will see that the second argument is a variable and will bind to it - making the match work out.

Crazy stuff.

So, back to the `case` statement. If a match is made on `:ok`, I'll return the struct I was returning before using an anonymous function (the `->` operator). If things aren't OK and we match on `:error`, I'll just pass the error on.

## Using This

I can now use this in my test for a cleaner error response if something goes wrong, or just handle it as needed, again, using a `case` statement:

```elixir
setup do
  {:ok, pid} = Postgrex.Connection.start_link(database: "bigmachine")

  case Membership.Registration.register({"test@test.com", "password"}) do
     {:ok, res} -> {:ok, [res: res]}
     {:error, err} -> raise err
  end

end

test "Registration with valid credentials", %{res: res} do
  assert res.success,res.message
end
```

This `statement` evaluates what comes back from `register` and if it's OK, returns a tuple that gets set as the test context, which I use down below.

If things aren't OK, I raise. I could log here as well, or do other things - for now raising works.

Also - I should mention if you haven't figured it out that the last line in any function is the return value, just like in Ruby.

Case statements return values - you can bind a variable if you like or you can have them as the last operation, as I'm doing here.

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
