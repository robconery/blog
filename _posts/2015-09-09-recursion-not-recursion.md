---
layout: post
title: "Recursion, Not Recursion"
slug: recursion-not-recursion
summary: ""
comments: true
image: /img/2015/09/Princess_Bride_That_Word.jpg
categories: Elixir
---

Had a great comment from [my last post](http://rob.conery.io/2015/09/04/using-recursion-in-elixir-to-break-your-oo-brain/) (about using Recursion):

![](/img/2015/09/Screen-Shot-2015-09-09-at-8.55.13-AM-1024x226.png)

I had to Google what "acyclic call graph" meant because I just couldn't remember :). I *do* remember what a call graph is... but...

So I showed my brother, Mr. Computer Science Professor, who is learning Elixir with me for fun and profit and he said:

> Yep, he's right. Your use of recursion is interesting but it muddles things and it's not really recursive, even though you're using it that way.

Big brothers. Gah.

Here's the code in question:

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

He went on:

> A recursive routine typically performs some kind of operation that gets repeated. Here, you're doing three different things, abusing the notion of recursion.

And it hit me. Of course. As I mention in the very first post in my little Elixir excursion - I've used recursion in the past but certainly not regularly. It *did* solve a problem, but not appropriately.

Another lesson learned.

Anyway I refactored things a bit to a lot clearer and less of a muddle:

```elixir
defmodule Membership.DBResult do

  def get_first_result({:ok, res}) do
    cols = res.columns
    [first_row | _] = res.rows
    {:ok, cols, first_row }
  end

  def zip_columns_and_row({:ok, cols,row}) do
    {:ok, List.zip([cols,row])}
  end

  def create_map_from_list({:ok, list}) do
    {:ok, Enum.into(list, %{})}
  end

  def map_single({:ok, res}) do
    get_first_result({:ok, res})
      |> zip_columns_and_row
      |> create_map_from_list
  end
end
```

I need to add some error traps in here, of course, but this is so much clearer! Thanks **KMag** - appreciate the nudge :).


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
