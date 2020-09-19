---
layout: post
title: 'Red:4 Store Part 4: The First Problem - Atoms'
image: 'sheep.jpg'
comments: true
categories: Elixir
summary: "I've run into my first problem, and it's a big one: using Atoms inappropriately."
---

I was asked a great question on Slack the other day - I wish I could remember the person's name (sorry!) but I can't find it ... anyway they asked me (paraphrased):

> I see you're creating a new process for each session by generating a unique key. Given that process names need to be atoms, isn't this a problem? Won't you fill up the atom table and cause your VM to crash?

Yep. This needs to change.

There are a finite number of atoms that you can use in your Elixir code, which stems from how Erlang handles these things. An atom is like a symbol in Ruby or Smalltalk: its name is its value. They are used as labels and, as such, aren't garbage collected in the same way as other code in your system.

It's a weird Achilles heel, but it exists nonetheless: **the Erlang VM can only support 1,048,576 atoms**. This number can change if you need it to, but it goes against some general guidance which I knew about but thought I could avoid (more below): *do not arbitrarily generate atoms*.

## Erlang Limits

In addition to the limit on the atom table, there is **also a limit on the number of current alive (running) processes: 32,768**. You can (just like atoms) change this number if you want to.

For now I'll just change the way I start up my Shopping process to avoid the atom problem. I still need the key, but I'll remove the setting of the name in `GenServer.start_link/3`:

```elixir
defmodule Redfour.Shopping.Session do

  use GenServer

  def start_link(%{key: key} = args) do
    GenServer.start_link(__MODULE__,args) #remove the name: key bit
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

  #...
end
```

The atom problem has now been dealt with - and it was no small problem. Atoms don't go away once they've been added to the VM so after a period of time (after a million or so people drop by) - my VM would have simply crashed. This could have happened in a month (I should be so lucky!) or after six years. Or it might never have happened.

My little session isn't the only thing creating atoms. Libraries and frameworks create them too. An interesting problem to have and one I should have avoided to start with... but that's how we learn things isn't it! Ahh failure...

But why did I do this in the first place?

## A Session Per User

My idea was that each customer would have some kind of cookie - a way of tracking them as they came to the store to shop for things - sort of like a "Shopping Cart Key" if you will. I thought having parity between the cookie and the session process as well as the session in the database would make good sense.

I still like the idea - but now I'm seeing that I need to pay more attention to *how the session process will end* and I need to do that now. I would be very lucky to have 100 concurrent sessions running at any given time - meaning 100 active shoppers. But that raises some questions:

 - what makes them inactive?
 - can I reactivate the session once it becomes inactive?
 - what do I do with the old, inactivated sessions after a long period of time?

A lot of this is business logic which I should probably figure out right now - so I will - and I'll tackle it next time.

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
