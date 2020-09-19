---
layout: post
title: "Thinking About Function Signatures in Elixir"
slug: thinking-about-function-signatures-in-elixir
summary: ""
comments: true
image: /img/2015/10/pipeline_builders.jpg
categories: Elixir
---

One of the things I've had to adjust to is how I want to structure function calls in Elixir. This is forced upon you by [Pattern Matching](http://elixir-lang.org/getting-started/pattern-matching.html) and is a Very Good Thing. Deciding on these patterns early on can really be helpful.

Consider this function:

```
def charge_customer(id, amount, description, card, currency \\ "USD") do
  #  ...
end
```

This is how you might *think* about writing an Elixir function - what's required, what can be defaulted. But then I get that twitch that I used to get with Ruby all the time: *there has to be something more elegant*.

## Taking a Step Back

The method call above is a bit too long and is also a bit "wobbly" for lack of better words. The first thing to consider here is *how will this function be used?*. I think it will be something like this:

```
def process_checkout(args) do
  verify_cart(args.cart)
    |> charge_customer
    |> create_invoice
    |> debit_inventory
    |> empty_cart
    |> send_email
end
```

The `|>` operator simply chains the calls together, sending the result of one function into another. Also - this is *semi-pseudo-code*, there would likely be transactions involved here... anyway...

Consider what is going to be passed to the `charge_customer` function - it will be the result of `verify_cart` which, likely, will be the cart so that's good. But as you scan down the list... you start to realize that passing information along will require some greater thought. And lighter functions with simple parameter structures.

## Just Tell Me What You Need!

One way to do this is to only pass a single argument along (an *arrity of 1* in Elixir-speak: `/1`). You can do this by using tuples:

```
{:ok, cart}
```

By passing a "qualifier" in the first tuple position, you can setup Pattern Matching in a much nicer way (which I'll get to later). But this only gets us half way. Our `charge_customer` function needs a lot more than just a cart - it needs some kind of payment method as well (the description, amount and currency can be pulled from the cart).

We can do this by tweaking the parameter list thus:

```
def charge_customer({:ok, cart}, card) do
  #  ...
end
```

This looks a little strange, but it's doing two things:

 - By setting the first parameter to `{:ok, cart}` it's making sure that whatever function is calling to it is delivering back a good result
 - The second parameter, card, is required

Now we can add an additional definition to handle an error:

```
#just pass along the error through the chain
def charge_customer({:error, err}), do: {:error, err}
def charge_customer({:ok, cart}, card) do
  #  ...
end
```

Now we have two solid pattern matches, which is good. Our function structure is more flexible than before, but there's more we can do.

## Building In Flexibility With a Keyword List

Pattern matching is key to writing flexible code that you can massage later on. For instance - if we're using a gateway like Stripe we might want to pass a card token along, rather than the card information itself. Or we might be using Paypal's Express Checkout and have a Paypal token in there.

What we need is a more flexible structure - and we can do this (and flex pattern matching) using a [Keyword List](http://elixir-lang.org/getting-started/maps-and-dicts.html) as our second argument:

```
def charge_customer({:error, err}), do: {:error, err}
def charge_customer({:ok, cart}, [card: card]) do
  #  ...
end
def charge_customer({:ok, cart}, [token: token]) do
  #  ...
end
def charge_customer({:ok, cart}, [paypal: paypal]) do
  #  ...
end
```

Each one of these methods will match based the payment type. But how would this work in a Pipeline? Like this:

```
def process_checkout(args) do
  verify_cart(args.cart)
    |> charge_customer(token: "cx_339393939")
    |> create_invoice
    |> debit_inventory
    |> empty_cart
    |> send_email
end
```

There are two really neat things happening here. The first is that you can "inject" arguments into a piped function call, and whatever you add will be placed at the end of the parameter list. So `verify_cart` will return `{:ok, cart}` that will then get passed to `charge_customer`, then the token will be passed in second position (that's a keyword list with some syntactic sugar, braces removed).

In the real world the payment information would be passed in through the arguments, and you would probably pass on `args.payment` or the like.

## The End Result

Thinking about pattern matching and functional "interop" if you will leads you naturally towards keeping things flexible and light. As I was writing out the little libraries I wrote over the weekend, I started to focus less on writing individual functions and more on entire modules, together.

I found that adhering to the `{tuple}, options` argument structure worked really well for me, but as I keep saying *I am just learning this stuff* and if you have found better patterns, sound off!

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
