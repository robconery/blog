---
title: The Logical Disaster of Null
date: '2018-05-01'
image: /img/2018/05/nothing_everything.jpg
layout: post
summary: "I'm in the middle of writing the next volume of The Imposter's Handbook and I found myself down a Rabbit Hole from the very outset: how can we, as programmers, justify the existence of null in our..."
categories:
  - Opinion
  - Syndication
---

I'm sure answers are jumping to mind, but hear me out, please. The use of Null in a purely logical landscape is problematic. It's been called [The Billion Dollar Mistake](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare) and [The Worst Mistake of Computer Science](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/). The `NullReference` Error is the runtime bane of .NET developers everywhere, and I would assume Java too.

Logically-speaking, there is no such thing as Null, yet we've decided to represent it in our programs. Now, before you jump on Twitter and @ me with all kinds of explanations, please know that I've been programming for 25 years in both functional and OO settings. I find that the people I talk to about this _instantly_ flip on the condescension switch and try to mansplain this shit to me _as if_.

## Update

Somehow this post [hit HN](https://news.ycombinator.com/item?id=17028878) and people have decided that I _of course_ need a mansplanation. These typically go along the lines of "There is more than one type of logic" and "the OP needs to spend some time investigating ternary logic... Aristotle's idea isn't the only one."

Absolutely _fascinating_ responses! I thought I would reply here with as concise a response as I can muster: programming is based on a binary premise, there is no other logical approach we can take. It's a yes/no, 1 or 0 operation and anything else that we throw in there is **something we made up**. An abstraction, and a failed one at that as evidenced by everything you're about to read. **People make up what they think Null means**, which is the problem.

\--

Null is a **crutch**. It's a placeholder for _I don't know and didn't want to think about it further_ in our code and this is evidenced by it popping up at runtime, shouting at us exceptionally saying "ARE YOU THINKING ABOUT IT NOW?".

Scott Hanselman has a great post which [discusses abstraction and our willingness to dive into it](https://www.hanselman.com/blog/PleaseLearnToThinkAboutAbstractions.aspx):

> My wife lost her wedding ring down the drain. She freaked out and came running declaring that it was lost. Should we call a plumber? I am not a plumber and I have no interest in being a plumber. While I advocate that folks try to be handy around the house, I choose to put a limit on how much I know about plumbing. While my wife has an advanced degree in something I don't understand, she also, is not a plumber. As a user of plumbing she has an understandably narrow view of how it works. She turns on the water, a miracle happens, and water comes out of the tap. That water travels about 8 inches and then disappears into the drain never to be seen again. It's the mystery of plumbing as far as she is concerned.

Null is every programmer's sink drain. The point at which they don't want to think further into the business problem in order to decide what a value means, or what it should be. This causes problems.

## Representing Nothing as Something

The next volume of [The Imposter's Handbook](https://bigmachine.io/products/the-imposters-handbook/?utm_source=conery&utm_medium=blog&utm_campaign=blog_post) is all about information: how we create it, deal with it, store it and analyze it. The first chapter sets the foundation for the rest of the book: I go over Aristotle's Laws of Thought, then glide into Boolean Algebra, Binary This and That, Claude Shannon and Information Theory, Encoding, Encryption, Network Basics, Distributed Application Design and finally Analysis and Machine Learning. Believe it or not, all of this goes together and tells a pretty outstanding story!

I'm about 50% done with the writing process and should be done with the book in a month or so. I've been researching these topics for a year and a half - this stuff is deep! The reason I'm telling you all of this is that I found myself trying to explain how Null could exist in a binary world of true and false... and the ground opened up and swallowed me whole.

## Not Logical

As I mention, I wanted to start the book from a solid logical footing so I could build a story from there, so I decided to start with Aristotle's Laws of Thought:

- Identity: something that is true or false is self-evident. Something that is true cannot present itself as false, and vise versa.
- Contradiction: something that is true must also be not false and not not true.
- Excluded Middle: something is either true or false, there is no other value in between

These laws apply to logical expressions about things that exist. In other words: you can't apply these laws to the unknown, which also includes the future. This is where we arrive at the edge of the rabbit hole: _null represents nothingness/unknownness_, so what the hell is it doing in a deterministic system of 1s and 0s?

Computer systems are _purely logical_, but the applications that we write, if they embrace Nulls, are apparently not. Null is neither true nor false, though it can be coerced through a truthy operation, so it violates Identity and Contradiction. It also violates Excluded Middle for the same reason. So why is it even there?

## The Billion Dollar Blunder

The idea of Null was first implemented in ALGOL by Tony Hoare, who [had this to say](https://www.lucidchart.com/techblog/2015/08/31/the-worst-mistake-of-computer-science/) about the whole thing:

> I call it my billion-dollar mistake…At that time, I was designing the first comprehensive type system for references in an object-oriented language. My goal was to ensure that all use of references should be absolutely safe, with checking performed automatically by the compiler. But I couldn’t resist the temptation to put in a null reference, simply because it was so easy to implement. This has led to innumerable errors, vulnerabilities, and system crashes, which have probably caused a billion dollars of pain and damage in the last forty years.

Null pointers and safe references make sense, but it's a machine concern, not a logical one. With this one decision, uncertainty was introduced into programming through the use of the null pointer and, for some reason, we all just went along with it.

At this point, I will avoid falling further into hyperbole and philosophy and, instead, hold up a mirror and show you how three programming languages: C#, Ruby, and JavaScript, all deal with **Null**. You can then decide what you think.

## Ruby

Ruby's handling of Null is interesting. It's handled by a class called `NilClass` that is represented globally as a singleton: `nil`. Here's what happens if you try to do comparisons and math with it:

![](https://blog.bigmachine.io/img/screenshot_854.png)

Ruby throws, which makes sense. Python does this as well with its `None` construct. When you try to do other fun things, however, like ask `nil` if it is, indeed `nil` or convert `nil` into an integer or array...

![](https://blog.bigmachine.io/img/screenshot_855.png)

This is where coercion comes in and the fun begins. We rarely deal with Null directly; it tends to pop up as the value of a variable and is then coerced into logical operations. Here, Ruby is trying to be helpful by converting `nil` into an empty array, 0 and so on. This leads to an inconsistency: if `to_i` will turn `nil` into a 0, why won't that coercion happen when trying to multiply?

I suppose it's helpful if you know the rules, which you absolutely need to know because _you can't rely on logic_ to tell you what's going to happen.

## JavaScript

JavaScript has both `null` and `undefined`, but I'll just focus on `null`. As you might imagine, you can do all kinds of fun things with it:

![](https://blog.bigmachine.io/img/screenshot_858.png)

JavaScript won't throw when trying to do things with `null`. Instead, it will coerce as needed.

Null in JavaScript is a primitive value and is not represented by an object. If you wanted to verify this, however, you would see this:

![](https://blog.bigmachine.io/img/screenshot_859.png)

This is JavaScript lying to you, believe it or not, and is the result of [a bug in the specification (from MDN)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/typeof):

> In the first implementation of JavaScript, JavaScript values were represented as a type tag and a value. The type tag for objects was 0. null was represented as the NULL pointer (0x00 in most platforms). Consequently, null had 0 as type tag, hence the bogus typeof return value.

Object, not an object... whatever...

## C#

Believe it or not, this is where things get strange. C# is a pretty "hefty" language, for lack of better words, and I thought it would do things that just make sense. I was wrong:

![](https://blog.bigmachine.io/img/screenshot_860.png)

You can evaluate whether `null` is equal to itself, which it is. You cannot, however, apply a negation to it. I think I like this as C# is deciding not to coerce `null` into a truthy value.

Until lines 13 and 14, where I try to run logical comparisons. Neither of those is logically consistent and straight up violate logic altogether.

Finally, when I try to add or multiply, _the result is `null`_, which is weird. To .NET developers, this makes sense somehow, because clearly "anything multiplied by an unknown value is unknown."

Which is what `null` represents in C#: _unknown_. Eric Lippert, one of the language architects, [affirms this](https://blogs.msdn.microsoft.com/ericlippert/2009/05/14/null-is-not-empty/):

> The concept of "null as missing information" also applies to reference types, which are of course always nullable. I am occasionally asked why C# does not simply treat null references passed to "foreach" as empty collections, or treat null strings as empty strings (\*). It’s for the same reason as why we don’t treat null integers as zeroes. There is a semantic difference between "the collection of results is known to be empty" and "the collection of results could not even be determined in the first place," and we want to allow you to preserve that distinction, not blur the line between them. By treating null as empty, we would diminish the value of being able to strongly distinguish between a missing or invalid collection and present, valid, empty collection.

If you're a .NET person, you owe it to yourself to read [another article](https://ericlippert.com/2015/08/31/nullable-comparisons-are-weird/) Eric Wrote on the subject: "Nullable Comparisons are Weird":

> What is the practical upshot here? First, be careful when comparing nullable numbers. Second, if you need to sort a bunch of possibly-null values, you cannot simply use the comparison operators. Instead, you should use the default comparison object, as it produces a consistent total order with null at the bottom.

Eric's explanations are fine, and all, but I had always read that a routine should throw if it didn't have the information it needed to return a result. Surely `10 * null` falls under this guideline, doesn't it?

Why doesn't C# throw? I had to find an answer.

## Going Undercover

I figured that this question deserves a forum that's not Twitter. I wanted to hear thoughts from others, so I decided to turn to StackOverflow.

If you follow me on Twitter, then you know that I recently [aired some grievances](https://twitter.com/robconery/status/974678531832610816) about StackOverflow, rage-quitting the service because it has turned toxic. This is something they have [acknowledged](https://stackoverflow.blog/2018/04/26/stack-overflow-isnt-very-welcoming-its-time-for-that-to-change/), which I think is GREAT. Seriously: _kudos_.

The reason I bring this up is that I received a lot of pushback on my opinion and some people asked me to basically "prove it". Ahh yes: "prove to me how you feel about something so I can judge whether it's valid". Strange that the people asking me this couldn't see the toxicity in the very Discourse we were having.

Anyway: a few of my friends have created "undercover" accounts on the service to see what it's like as a new user with low rep, and I did the same. I decided to [ask about nulls with respect to C#](https://stackoverflow.com/questions/49636514/why-doesnt-the-c-sharp-compiler-throw-for-logical-comparisons-of-null) to see if I was missing something. There were some pointed suggestions that the question was argumentative, so I decided to target it to "Why doesn't the C# compiler throw for logical comparisons of null".

I think that's a good question. You can read through the answers if you want to see the confusion and condescension. You can also see a rather positive experience with a very kind user named EJoshuaS, who left this comment:

> ﻿﻿ ﻿﻿﻿Excellent first question by the way - welcome to the site.

That was kind. Other commenters were a little more direct and more than a bit condescending. More of this please - you _will_ create a better environment for others which will lead to better answers.

Read the question and you decide if it was asked/answered fairly. No one seems to know why C# behaves the way it does. The decision seems... arbitrary at best (to me).

## Escaping Nullism

Some languages don't have Null, like Swift and Haskell. I think it would be great fun to code in a language that embraced logic at every level, and I wonder if it's possible to do this kind of thing intentionally.

I'm not sure Null should have a place in programming. Then again, this is the first time I've ever really thought about it. Maybe someday I'll write a programming language and implement my ideas for Null. Why not? That's what every other language has done, and we get to live with it.
