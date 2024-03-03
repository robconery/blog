---
title: The Modern Dev Team
date: '2018-01-22'
image: /img/2018/01/IMG_0193.jpg
layout: post
summary: "The smallest comment from a good friend can lead to introspecting your life choices. This just happened to me!"
categories:
  - Opinion
  - Travel
---

The other day I was chatting with some friends in Slack, watching them discuss Kafka “stuff” and things that are good and bad about Kubernetes (which I think you’re supposed to call K8?). I made a small quip along the lines of “I think I need to get a real job” as I’m having an increasingly hard time caring about this stuff.

One of the people in the room, Rob Sullivan, had an epic response:

![img-alternative-text](/img/1516635749.png)

At first I was like "oh you can f\*\*\* right off" but then I just turned 50 so I have a bit of a soft spot when it comes to "falling behind". This is captured perfectly by one of my favorite authors, Charles Stross:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">An unspecified time after the impostor syndrome goes away, over-the-hill syndrome moves in: the irrational conviction that you're a burned-out has-been, phoning it in, best days behind you, a broken-down hack whose audience is losing interest rapidly.</p>— Charlie Stross (@cstross) <a href="https://twitter.com/cstross/status/955403735521521664?ref_src=twsrc%5Etfw">January 22, 2018</a></blockquote>

<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

It really has been a while since I've worked on a "modern" team. I still write code, in fact, I do it every single day. Mostly for myself: I have 3 running projects which are all focused on helping me run [my business](https://bigmachine.io) - but that is hardly the same as being part of a team.

I think the last time I was part of a team like that would be (gasp) 2009 or thereabouts when I worked at Microsoft. The project was called _Orchard_ and I hated every minute of it. That's a whole other story… but I think that's the last time I ever did institutional coding.

My goodness.

## Am I a Burned Out Has-been?

I don't _think_ I am… but then again I do catch myself lamenting over "the good old days" more and more. Obviously, this is a massive cliché and I know it when its happening, but there is a shred of truth to it sometimes.

Trying to be a good person, I decided to face this question head-on. Just last week I headed over to [NDC London](http://ndc-london.com) and had, once again, a _really really good time_. I think this was probably the best NDC London yet, primarily because they moved the venue to the Queen Elizabeth Center, right down the street from Buckingham and across from Westminster Abbey.

![](https://blog.bigmachine.io/img/ndc-stage.jpg)

While I was there, I decided to dig into Rob Sullivan’s thought a bit: _what would happen if I joined a modern dev team_? I remember sitting in the back of the room during [Felienne’s](http://www.felienne.com) amazing keynote, pondering what that would even look like:

> Lots of Docker? _Probably_. Learning new systems and ways to decentralize things? _For sure_. Solving the same problems that teams have had forever but in a new way? _Absolutely_.

That last bit wasn’t me being snarky! Evolution is an iterative process. New tools give us a fresh way to solve old problems, so I’m in! But… am I just fooling myself? Have I been out of the loop for so long that getting up to speed on modern "stuff” would drive me to constant complaining?

After 3 days of sitting in talks and seeing what people are doing at their jobs (which are my favorite talks: the good old _war story_), I decided that **no, I’m not quite burned out yet.** In fact, I’m likely more energized than I’ve been in a very long time.

Why? Because unlike many years ago when I had to learn all this stuff from scratch: **I already know most of the problems trying to be solved**, or at least I feel like I do. It’s fascinating to see how they’re being approached today as well. Let me explain...

## It’s Still a Thing: Reinventing Erlang

OK that _does_ sound snarky, but it’s also true: building concurrent applications invariably leads one to rediscover what Erlang solved so many years ago (and solved well). Yes yes! I know I sound grumpy! But stay with me as I don’t mean to be a jerk about this: _it just is_. If we can accept this truth without tribalism flaring up, we can free ourselves to introspect whether modern solutions might be better.

Deep breath, let me fill in some details.

Here’s a simple truth that I think we all recognize: _[The Free Lunch Is Over](http://www.gotw.ca/publications/concurrency-ddj.htm)_:

> The biggest sea change in software development since the OO revolution is knocking at the door, and its name is Concurrency.

That post was written many years ago by Herb Sutter, and it’s slowly coming true. Concurrency is a thing, and with processor clock speeds reaching the top of their asymptotic rise, the programming industry is trying to figure out ways to catch up.

Architectures are shifting to allow for this. Microservices. Parallel/elastic scaling, message-based architecture, orchestrated containers and serverless functions in the sky - these all focus on the idea of _concurrency_. Programs that grow sideways with more cores rather than up, with faster cores. Or no cores at all, in the case of serverless...

I know you know this. _At least you should_. You probably also know that **this is precisely the problem that Erlang was created to solve**. That doesn’t mean that everyone should stop what they’re doing and use Erlang! It just means that understanding a bit of history will help you know when you’re doing things better, or worse.

## Containers, Processes, and Serverless

I sat through a few talks about container orchestration, the most fun was with Scott Hanselman and Alex Ellis entitled [Building a Raspberry Pi Kubernetes Cluster and running .NET Core](https://ndc-london.com/talk/building-a-raspberry-pi-kubernetes-cluster-and-running-.net-core/). One of the demos showed how Kubernetes will monitor a node and if it dies, restart another one. _Straight from the Erlang playbook_: "let it die". I love that approach to writing programs with Elixir (and Erlang), and its great to see it being used elsewhere.

But you don't need the Erlang VM for this, just a bigger infrastructure to run Kubernetes, Docker and so on. Is this a good tradeoff? I suppose it must be as people are using it.

Other talks I went to discussed serverless “functions in the cloud”. Some used Google’s Cloud bits, others focused on Azure and gave a nod to AWS Lamda. Each of these talks also weaved together a story where you could “write a single function that takes in the data it needs and returns an answer. String these functions together and you have an app”.

In other words: _functional programming using the actor model_. Well, for the most part, I guess. You’re forced to reconsider the notion of state, something you don’t have with a function “in the sky”. Yes, you can use a database, but then your endpoint becomes dedicated so what's the point?

Functional purity (and the actor model) is something I learned well when I started doing Elixir. I don’t think I’m being a crabby jerk by recognizing this. In fact, it’s the opposite: **I’m seeing interesting ways in which existing patterns are being applied with new solutions**, outside the Erlang ecosystem, solved with infrastructure rather than a platform. Fascinating!

## The Next 10 Years

10 years ago I turned 40 and I remember wondering what I would be doing 10 years from then when I turned 50. I found out what I would be doing during NDC London, on a boat on the Thames. A really fun way to celebrate my 50th birthday: surrounded by good friends and a _big ass chocolate cake_.

As we motored along, I remember looking over at the London Eye, all lit up, looking grand:

![img-alternative-text](/img/1516638978.jpeg)

What will I be doing 10 years from now?

I hope these years will be fun, just like the last. I think I’m old enough now to be able to step back from quantifying my value by whether I’m “in the trenches” or in front of an audience. **I love what I do**, whether it’s writing a book about what I’ve learned or stressing out over a breaking build: it’s just stepping from one role to another.

That said, I _did_ walk away from NDC London with the possibility of joining a very, very interesting project. I’d be part of a team - a very _modern_ team at that. I’m quite excited about it! Just as I am about the next volume of _The Imposter’s Handbook_, which is well underway. I guess this much seems obvious: choosing which thing to do is kind of silly.

**Have fun**. It doesn’t matter how you have it. Oh, and recognize when you’re being a crabby jerk :).
