---
layout: post
title: "How To Learn a New Programming Language While Maintaining Your Day Job"
slug: how-to-learn-a-new-programming-language-while-maintaining-your-day-job-and-still-being-there-for-your-family
summary: ""
comments: true
image: /img/2015/10/learn_programming.jpg
categories: Elixir Opinion Career
---

I don't typically write "lifehack" posts, but this question has come up *repeatedly* over the last few weeks:

> How did you find time to learn Elixir? Must be nice to not work or have a family :p

First: *I'm certainly no expert in Elixir* but I am finding my way through the language. I pushed [my first two](https://hex.pm/packages/blackbook) [packages to Hex](https://hex.pm/packages/stripity_stripe) over the weekend and I'm having a really good time.

I'm also very married and a father of two, and [I'm happily working full time](http://www.pluralsight.com/author/rob-conery) (more than full time really) with Pluralsight. **But I also had ample time to dive into Elixir** and I thought I would share how I did it.

And I'll just come out with it right here: *A series of little wins*. I set myself up to win tiny little tasks which then led to more tiny Little Wins and the next thing I knew, I was thinking in Elixir. **A series of Little Wins**, I can't write that enough. More on this below.

This post will be a combination of "lifehack" stuff as well as tangible steps I took over the course of two weeks to become reasonably proficient in the language. Apply to whatever language you like. Elixir is the 7th programming language I've learned (and no I'm not counting HTML and CSS):

 - Pascal
 - vbscript/VBA
 - SQL/PLPGSQL
 - C#
 - Ruby
 - JavaScript

These are in no particular order and we could argue whether SQL is really a programming language but I've [programmed systems using PLPGSQL](https://github.com/robconery/pg_auth) so I say it is :p.

Anyway, onward.

## Give Yourself Permission

Make the decision, don't waffle. Don't say stupid shit to yourself, including:

 - It's a fad
 - I'm too old/young/fat
 - There's no job market for it
 - Something will come along and replace it later

I could go on, but you get the idea. These **are downers** and only serve to derail inspiration and make you sound toxic. Don't be toxic.

### It's a Fad (or: "I'm an Asshole")

People have said this to me about *every single language I learned* save for Pascal (because it was the 80s) and SQL (because it's a workhorse language that's been around forever). **Everything is a fad in a long enough time scale** and when you say these words aloud **you sound like a complete asshole**. You might be right, the language you're referring to might go away in a few years - *you still sound like a toxic asshole* so let be aware of how your words impact others - mostly yourself.

Assholes don't do anything but sit on the sidelines and call people names. Let them. You hitch your wagon to whatever star you like and be a better you. We're in an industry that is ever-changing, ever-moving. You need to move with it or you need to move aside.

### There's No Job Market/Use Case/What Can I Do With It?

You're opening a door here, not solving a problem. Even if nothing amounts from it you've stretched your brain some, exercised your ability to solve a problem and **that is always a win**. You simply cannot go wrong by trying to learn something.

When you do learn it you might find yourself creating something fun or solving a problem in a more elegant way that you can bring back to your day job. I did just this when I learned Ruby - my brain exploded with ideas and I created Subsonic and a number of other projects inspired by the language.

And you never know what could happen in a few years' time. Ruby and JavaScript didn't have much of a market years ago, neither did Java and .NET. Be ahead of the curve - or **define the damn curve yourself**.

Decide. Just... **Decide**. Now let's...

## Execute

Before I get into the nitty gritty details I need you to focus on the *importance of execution*. You can't go into this with the decision made and say "ho hum when I get the time... maybe this weekend". Nope. **You must execute** and it can literally be 10 minutes a day at lunch or 2 hours at night where you code instead of fucking off on Xbox.

What's coming next is how to set yourself up to win little tasks - building one win on top of another, creating a "cadence" the builds under you. But you won't do any of it unless you commit. I put "Elixir Time" on my calendar every day and treat as an appointment I need to keep, which underserves it because it's so much more.

This is time I'm investing in myself, in my career. Time that I will not question, I'll just execute.

Here are some simple steps to move beyond dreaming about it and actually doing it. They might sound silly, but each one is a demonstration of your commitment and, in a way, a Little Win:

 - Follow the movers and shakers on Twitter
 - [Sign up for the weekly newsletter](http://blog.plataformatec.com.br/2015/01/introducing-elixir-radar-the-weekly-email-newsletter-about-elixir/)
 - Install Slack and subscribe to the language team
 - Read and Post questions on Stack Overflow
 - Write some blog posts (if you're into that kind of thing) about your explorations. This requires you to be fearless (see above).

And now, let's write some code.

## My Series of Little Wins

*I suck as a programmer* so it's important for me to not give into my incompetence and lack of confidence. I Decided to learn elixir I gave myself time to Execute - now the question became *what, exactly, will I do?*.

Having a goal is nice, but it can also be destructive if you set it when you have no idea what's going on. **So skip the goal**, let's Execute and have a good time!

### Task 1: Creating a New Project

How much easier could it be? With C#/.NET it's File > New Project and you pick your flavor of project. With Ruby it can be a single file all the way up to a nicely structured set of directories. It's a little wild west in there, but it's doable. With Node it's `npm init my_project`.

With Elixir [it's spelled out with a quick Google search](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html):

```sh
mix new my_project

➜  Projects  mix new my_project
* creating README.md
* creating .gitignore
* creating mix.exs
* creating config
* creating config/config.exs
* creating lib
* creating lib/my_project.ex
* creating test
* creating test/test_helper.exs
* creating test/my_project_test.exs

Your mix project was created successfully.
You can use mix to compile it, test it, and more:

    cd my_project
    mix test

Run `mix help` for more commands.
```

That took 3 or 4 minutes of reading, 3 seconds to do. At this point we have a lot we can do, but the first thing to notice is the last line - where to find help. That says something about the project. We have a `README.md`, a `.gitignore`, a `/test` directory and a config setup.  Nice!

We just learned a lot and executed a little win. We can now stop here and go play Xbox.

### Task 2: Writing a Test

We've created an initial project, now how do I write a test? This is where things can get kind of nuts because we haven't even dabbled in the language yet! Let's not get too out of control on this one - *we need a small win* so make this easy.

There's a `test` directory so having a look inside we see two files: `my_project_test.exs` and `test_helper.exs`. This tells us something:

 - The file extensions for Elixir are `.ex` and `.exs` as seen in our project setup. Something to write down later as a Little Win.
 - The `my_project_test.exs` file is likely a throw away, which is great because we can hack it up
 - The concept of Test Helpers is there for us. Nice!

Looking inside the test file we see this:

```sh
➜  my_project  cat test/my_project_test.exs
defmodule MyProjectTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end
end
```

It's a somewhat familiar syntax and I can apply rules from other languages to it. The constructs are clean and feel very Ruby-ish to me. I like that (I like Ruby) and from here I think I can write a test of my own:

```
defmodule MyProjectTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "my name" do
    assert "Rob" == "rob"
  end
end
```

Kind of a dumb test, but I want to watch it fail (hopefully). If it doesn't, I just learned something rather huge. Now I just need to figure out how to run a test.

I remember when I created the project it said "Run 'mix help' for more commands". Let's start there - if mix created the project for us, it will probably run the tests too:

```sh
➜  my_project  mix help
mix                   # Run the default task (current: mix run)
mix app.start         # Start all registered apps
mix archive           # List all archives
mix archive.build     # Archive this project into a .ez file
mix archive.install   # Install an archive locally
mix archive.uninstall # Uninstall archives
mix clean             # Delete generated application files
mix cmd               # Executes the given command
mix compile           # Compile source files
mix deps              # List dependencies and their status
mix deps.clean        # Remove the given dependencies' files
mix deps.compile      # Compile dependencies
mix deps.get          # Get all out of date dependencies
mix deps.unlock       # Unlock the given dependencies
mix deps.update       # Update the given dependencies
mix do                # Executes the tasks separated by comma
mix escript.build     # Builds an escript for the project
mix help              # Print help information for tasks
mix hex               # Prints Hex help information
mix hex.build         # Builds a new package version locally
mix hex.config        # Reads or updates Hex config
mix hex.docs          # Publishes docs for package
mix hex.info          # Prints Hex information
mix hex.key           # Hex API key tasks
mix hex.outdated      # Shows outdated Hex deps for the current project
mix hex.owner         # Hex package ownership tasks
mix hex.publish       # Publishes a new package version
mix hex.registry      # Hex registry tasks
mix hex.search        # Searches for package names
mix hex.user          # Hex user tasks
mix loadconfig        # Loads and persists the given configuration
mix local             # List local tasks
mix local.hex         # Install hex locally
mix local.rebar       # Install rebar locally
mix new               # Create a new Elixir project
mix phoenix.new       # Create a new Phoenix v1.0.0 application
mix run               # Run the given file or expression
mix test              # Run a project's tests
iex -S mix            # Start IEx and run the default task
```

Good grief. There's a lot in here - **stuff I should actively ignore right now** because I'll short-circuit, become overloaded and give right into my insecurities that I talked about above (*I can't do this, it's too big, it's a fad**).

Right there at the bottom is what I need - `mix test              # Run a project's tests`. Boom.

```sh
➜  my_project  mix test
Compiled lib/my_project.ex
Generated my_project app


  1) test my name (MyProjectTest)
     test/my_project_test.exs:7
     Assertion with == failed
     code: "Rob" == "rob"
     lhs:  "Rob"
     rhs:  "rob"
     stacktrace:
       test/my_project_test.exs:8

.

Finished in 0.02 seconds (0.02s on load, 0.00s on tests)
2 tests, 1 failures
```

Radical! I learned so, so much with this Little Win:

 - Elixir is a compiled language
 - Testing a project also compiles it
 - Case sensitivity is built-in for strings (hooray!)
 - The assertion failed in an informative way. `lhs` means "left hand side", `rhs` is "right hand side" and I can see what failed and how.

With these two wins I can now move on feeling pretty damn happy.

## Strings, Dates, Numbers - Getting a Footing

This part might seem obvious, and indeed it is. It also requires a book or some type of learning resource besides Google. For this kind of thing I tend to go [directly to Pragmatic Programmers](https://pragprog.com). Do a search on Elixir and find a great set of books. But there's one that stands out and it's amazing: [Dave Thomas's Programming Elixir](https://pragprog.com/book/elixir/programming-elixir). This book is simply wonderful and I can't recommend it enough.

Usually when I read programming books I like to read them in the order in which makes sense - for me it's learning the basic types, then the operators, data structures and so on. Here I found Dave's lead in to be so fun to read - I recommend it highly.

Elixir is a functional language so this book starts with that, which it should. For me, functions are made from primitive elements like strings, numbers, dates etc. so I like to know how those work. I read how those work, play around in my little project and write some more tests to see these things work.

Specifically strings - that's just me. I find that if a language has any warts it will be in how it handles strings, mutability, regex, and so on.

This is where you and I will branch off. I get my footing by understanding basic types - you might need to learn data structures and method calls. Either way slice it up so you can learn a little at a time. For me, it was:

 - Concatenating a String
 - Using basic Regex to run replacements and matches
 - String syntactic sugar

With dates I found out (rather quickly) that the date/time story in Elixir is a bit limited and if you need to work with these things you'll be installing [a package called Timex](https://github.com/bitwalker/timex). I also found out that you can access stuff from Erlang directly (which a lot of people do). I bookmarked this as a thing to come back to (which I still haven't done).

## Data Structures and Databases

My first set of experiments and Little Wins took about a week, and the more I built up my wins, the harder it became to get focused. I fight this constantly - *I just want to jump to the finish line* and build stuff. It takes a lot of effort to stop myself and stay focused.

I felt pretty good about the basics and how projects went together - now it was time to work with basic lists and data structures.

**And this is where my brain exploded**. Elixir is a functional language and there are aspects to it that are completely foreign to me (which is no surprise really). I tried as hard as I could to control the firehose of concepts coming at me... but eventually I just gave up and let it wash over me and I read the book all the way through.

Knowing I would pick it up again and read it quite a few times over.

At this point I stared at the mess of concepts on the floor and decided to pick one and dive into it. So I did - setting myself up for Little Wins here and there with each "higher" concept beyond the basics. Specifically:

 - Using Recursion to iterate over a list and perform an operation
 - Using List Comprehensions in a meaningful way
 - Using the Pipe operator

The problem I typically have with this kind of thing is that *it's all so demo-y*. I need to grasp something real! So I did, and I modified my list:

 - **Successfully Query PostgreSQL**
 - Using Recursion to iterate over a list and perform an operation
 - Using List Comprehensions in a meaningful way
 - Using the Pipe operator

From there I was able to roll lists of data that meant something to me, using the the types and tests that I began to understand from before... the wins were piling up...

## An Ongoing Thing: Finding the Idioms

Here's a neat thing about Elixir - there are some voluntary idioms that people use (like the callback structures in Node) to make life easy. Here are a few:

 - Required function parameters come first and are listed out. Optional parameters are passed using a Keyword List
 - Function results typically have a tuple structure that indicates what happened - like `{:ok, return_data}` or `{:error, message}`
 - Pattern Matching allows you to control the flow of your application in a very elegant way
 - Writing smaller, more concise functions and piping them together makes programming a lot of fun

There are more idioms - and right now this is where I'm at. Call it "Level 5" if you will - and this is where the work begins. From here the Little Wins shift from learning to building, which is exactly what I've started to do.

I feel pretty good about the way things are going.

## Summary

Are you feeling anxious about this post? Do you want to tell me how *you wish you had time* or that *that sounds fun but I need to make money*? I'll ask you why you work in a young, vibrant industry and expect things to stay the same for you.

Be an innovator. Make positive changes. You can do it - just give yourself the time and go for the Little Wins.

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
