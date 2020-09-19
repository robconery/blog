---
layout: post
title: 'A Simple Approach to BDD'
image: '/img/pragmatic_bdd.png'
comments: false
categories: Tekpub Screencasts
summary: I just released my latest screencast for <strike>Tekpub</strike> Pluralsight and I rather like it. It's live coding and I'm building something I need; I did my best to keep it real, and bring in what I've learned from other frameworks like Ruby on Rails and Node.
---

## So. Many. Opinions.

I want to start here as it's some of the first ... "feedback" I received when I told my friends what I was up to:

> Oh no. Not that again.

BDD causes arguments and people become rather obsessed with what it is, the syntax you use, the tools you use, and how you part your hair when doing it. Some of these things are indeed important - but I think it's fair to say that a bit of a Cargo Cult has emerged because of it.

[I wrote a fairly long post about this](http://rob.conery.io/2013/08/28/how-behavioral-is-your-bdd/) a few months back as I was putting this production together, and now I'm happy to report that [the screencast is now live at Pluralsight](http://pluralsight.com/training/Courses/TableOfContents/pragmatic-bdd-dotnet).

My goal with this screencast was to strip all the noise away, focus on [Dan North's Big Aha Moment](http://dannorth.net/introducing-bdd/), and see what we could do with XUnit, Visual Studio and EntityFramework. I also used [NCrunch](http://www.ncrunch.net/) to shorten the "feedback loop". I have to say, **this was the most fun testing I've had, ever**.


## A Focus On Simple

I think BDD has become a cargo-cult in the .NET space, with people focusing on tools and syntax - losing focus entirely on the core idea behind BDD (testing the behavior, not the mechanics, of your application).

![BDD Jargon](/img/bdd_jargon.png)

I like many of the tools out there, but more and more I hear people ask me if I used "BDD framework X" or "BDD tool Y" for this production. My answer:

> No, I used Visual Studio, XUnit, and EntityFramework.

![BDD with VS](/img/membership_specs.png)

If you like SpecFlow (it's a great project) then _rock you some gherkin good dev_. I like the clarity and simplicity of the tests I wrote using XUnit and nothing else:

```csharp
[Trait("Authentication", "Password doesn't match")]
public class PasswordDontMatch : TestBase {

  AuthenticationResult _result;
  public PasswordDontMatch() {
    var app = new Application("rob@tekpub.com", "password", "password");
    new Registrator().ApplyForMembership(app);

    _result = new Authenticator().AuthenticateUser(new Credentials { Email = "rob@tekpub.com", Password = "fixlesl" });

  }
  [Fact(DisplayName = "Not authenticated")]
  public void NotAuthenticated() {
    Assert.False(_result.Authenticated);

  }
  [Fact(DisplayName = "Message provided")]
  public void MessageReturned() {
    Assert.Contains("Invalid email", _result.Message);
  }
}
```

## Over The Shoulder

I was talking to [Mr. Hanselman](http://hanselman.com) the other day and I asked him if he likes fancy fonts for his slides and where he gets his color palettes from. His reply got me thinking:

> I don't do slides anymore, son.

And it's true - he doesn't (unless he has to - which is weird some conferences insist you use at least one slide). I've always appreciated his ability to pick excellent demos and talk his way through the code - showing **real results** that underscore what he's saying rather then silly pictures and diagrams.

So that's what I did for this (although there are some slides in there for conceptual things... just a few. Sorry Scott).

I do a live-coding thing and I wanted you to feel like you are sitting next to me. I clipped out all the umms/ahhs/oh-damn's and kicked up the pace so it's watchable, but I really wanted you to get that "pair-coding" feel. I'm hoping to see more of this at Pluralsight as well.

Anyway - [it's up and live](http://pluralsight.com/training/Courses/TableOfContents/pragmatic-bdd-dotnet) so go watch it. If you're not a Pluralsight member [got get a free 30 days](http://pluralsight.com/training/Products/Individual) and "try my product" - they have a huge library with [all of our stuff in it](http://pluralsight.com/training/Courses/Find?highlight=true&searchTerm=tekpub) (the migration is complete) so **get you some**!




