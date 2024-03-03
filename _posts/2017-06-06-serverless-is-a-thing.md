---
layout: post
title: "Kicking The Tires On This Serverless Thing"
image: 'firebase/cover_1.jpg'
comments: false
categories: Firebase
summary: "Yes, I know, you're sick of the term. The idea is interesting... but is it realistic? In this blog series we'll find out. This is Part 1: where I investigate various serverless services..."
---

I just [released a video series](https://goo.gl/yCliXG) about building a serverless application with Firebase, and I thought I would write it up in a blog series as well. I think it's worth reading and understanding what I went through. This is Part 1 of that series.

## The Punchline

Before doing this I spent a few months with AWS Lambda (which you'll read about below); first with [The Serverless Framework](https://serverless.com/) (which I quite like - so jealous they got that domain!) and then with [ClaudiaJS](https://claudiajs.com/) which didn't quite fit what I wanted. Finally I rolled my own thing with some shell scripts and a zip file.

I ended up with a mess that cost more money than I wanted it to. It wasn't easy to figure out and more than once I had to rage-swim at the Y to get over the stress of the day.

I had better luck with Firebase. **I had a fun time and built something interesting**. At least *I* think it is. I had to approach the development process in a completely different way than what I was used to... but I like that kind of thing. I know others don't. The big thing to me, however, is that I was able to build something *that I would truly use*. In fact I'm using parts of it now in production (more on that in a future post).

This is a long story and will cover many posts. Not sure how many but I'll try to keep it focused. As you can clearly tell I like Firebase, a lot, and yes I encountered quite a few issues along the way but they were surmountable. I'll get into all that, I promise.

For now let's start at the beginning, when I first dug into the "serverless" thing.

## AWS, Firebase, Webtask.io...?

Let's start with [Webtask](https://webtask.io). I know a number of people over at Auth0 (who own and run Webtask.io) and I have a ton of respect for them. Everything you're about to read has been said to them in person, so don't think I'm being unfair - I think they would agree with me straight away.

If you [head over to the Webtask](https://webtask.io) site you'll see a simple page with a headline:

![](https://blog.bigmachine.io/img/firebase/webtask.jpg)

It's a puzzling headline with a rather sparse lede. If you click on anything on this page (the green button or "learn more") you're asked to log in. Once you log in you're taken to this page:

![](https://blog.bigmachine.io/img/firebase/webtask_2.jpg)

It's gorgeous, as you can see, but it just adds to the confusion. What "more" am I supposed to learn here? How much does this cost? What language do I use? What... is happening?

I've built a few tasks with this tool and they worked great, but from there... I have no idea. If you [read their pricing](https://webtask.io/pricing) you'll become more confused, most likely. [The documentation](https://webtask.io/docs/101) looks promising but is, once again, more than a bit sparse. 

**Verdict**: Webtask is a neat idea but doesn't seem to be the thing I need. In fact I have no idea what it's supposed to be.

### AWS

Amazon introduced [AWS Lambda](https://webtask.io/docs/101) over a year ago and it made a big splash. The pitch was simple to understand:

>AWS Lambda lets you run code without provisioning or managing servers. You pay only for the compute time you consume - there is no charge when your code is not running. With Lambda, you can run code for virtually any type of application or backend service - all with zero administration. Just upload your code and Lambda takes care of everything required to run and scale your code with high availability. You can set up your code to automatically trigger from other AWS services or call it directly from any web or mobile app.

If you've worked with AWS before, you know that *nothing AWS is ever simple*. I went into this with a good dose of skepticism!

#### Step 1: Pick Your Function

After signing into the AWS console and clicking on "Lambda", you're sent to a splash screen with a button that says "Get Started". You're then taken here:

![](https://blog.bigmachine.io/img/firebase/aws_1.jpg)

Welcome to AWS. It might just be me, but I feel like working with AWS is like wandering around the Mall of America, hoping to find *that one store* that sells *that one thing* you're trying to find.

![](http://visitshakopee.org/img/2016/02/Mall-of-America-Attractions-Banner.jpg)

*Note: for foreign readers, the Mall of America is a gigantic structure in Minnesota that embodies everything that is not wonderful about the US*.

**AWS is conceptually deafening**. I am literally exhausted after working with it for a few hours and often I roll out of my chair onto the floor, weeping, as I can't remember what I just did nor how much it will cost me.

OK maybe a little hyperbolic. There's just a lot of moving parts is what I'm trying to say. So, where was I ...

#### Step 2: Pick Your Trigger

Right: after you pick you function (good luck with that) you're given this screen:

![](https://blog.bigmachine.io/img/firebase/aws_2.jpg)

Your function is executed based on some type of event. If you know AWS and you know what these services are, you're in luck! If not, say goodbye to the next few hours.

#### Step 3: Get Lost In The AWS Wilderness

We want to choose "API Gateway" for this so we can call our function from the outside world over HTTPS. And then...

![](https://blog.bigmachine.io/img/firebase/aws_3.jpg)

This is where I'm going to hit the fast-forward button. I remember swearing a lot and feeling lost at this point (not hyperbole). I mean: *I know what these things are*, but I don't know the implications fully. We're talking about security here, and staging environments! These aren't to be taken lightly.

I tried to figure it out myself for 2 solid days, and then I just gave up and went with a framework.

### Serverless Framework

The [Serverless Framework](https://serverless.com) is a Node project that automates most of the pain when dealing with AWS. The video on the site is reasonably informative but... clicking on the documentation link (from the home page) gives you a 404, which I think is funny. If you use the menu on the top you'll be OK.

![](https://blog.bigmachine.io/img/firebase/serverless_1.jpg)

So, in short, you use their CLI to generate a YML file and a Node file for your function code. You can use Python or Java with Lambda, but for now we'll stick with Node.

As with most HelloWorld demos, the initial steps look simple. I'm not interested in that, I want to see what complex looks like. Here ya go:

```yaml 
service: bigmachine-checkout

provider:
  name: aws
  runtime: nodejs4.3
  region: us-west-2
  stage: dev
  vpc:
    securityGroupIds:
      - "sg-derptyderp"
    subnetIds:
      - "subnet-herptyherp"
  iamRoleStatements: # permissions for all of your functions can be set here
    - Effect: Allow
      Action:
        - cloudwatch:DescribeAlarms
        - cloudwatch:GetMetricStatistics
        - ec2:DescribeAccountAttributes
        - ec2:DescribeAvailabilityZones
        - ec2:DescribeSecurityGroups
        - ec2:DescribeSubnets
        - ec2:DescribeVpcs
        - ec2:CreateNetworkInterface
        - ec2:DescribeNetworkInterfaces
        - ec2:DetachNetworkInterface
        - ec2:DeleteNetworkInterface
        - sns:ListSubscriptions
        - sns:ListTopics
        - sns:Publish
        - logs:DescribeLogStreams
        - logs:GetLogEvents
      Resource: "*"

functions:
  paypalBraintreeFinalize:
     handler: handler.paypalExpressFinalize
     events:
      - http:
          path: paypal/finalize
          method: post
          cors: true

  paypalBraintreeToken:
     handler: handler.paypalExpressToken
     events:
      - http:
          path: paypal/token
          method: get
          cors: true

  stripeCheckout:
    handler: handler.stripeCharge
    events:
     - http:
         path: charge/stripe
         method: post
         cors: true
```

All in all, *not that bad*. You can read through this and probably figure out that I have functions to handle a Stripe charge and some PayPal stuff. They're exposed via the API Gateway (which the framework does for you) and I'm able to wire up CORS easily.

Unfortunately I also want to **talk to a database that's not DynamoDB**. I like using PostgreSQL with [Compose.com](http://compose.com) which means that if I want my Lambda functions to talk to the outside world I need to set up a gateway, a VPC and all the lovely machinery that goes along with it.

The super silly thing is that I need to do this even if I use Amazon's RDS stuff - you have to have a VPC setup for security reasons. That aint cheap.

![](https://blog.bigmachine.io/img/firebase/aws_4.jpg)

VPCs and gateways are not cheap but, in the grand scheme of things, $50/month isn't so bad either. But if I'm going to pay that... why don't I just use Heroku?

#### Back Where I Started

It took me about 10 days to get things running properly. 2 of those days were spent being very, very frustrated trying to figure out all of the moving pieces and dealing with errors like this:

![](https://blog.bigmachine.io/img/firebase/aws_happiness.png)

This was the final capper for me:

```
servless --help

WARNING: You are running v1.7.0. v1.8.0 will include the following breaking changes:
  ...
```

This doesn't make me feel excited about the team behind this thing. Breaking things on a point release goes against the whole idea of semantic versioning. It wouldn't matter but the framework uses Node/NPM which by general agreement follows semver, so it seems a bit silly to ignore it.

A [bug report was filed](https://github.com/serverless/serverless/issues/3252) and completely ignored, aside from this email response:

>Breaking Changes - We're no longer following strict semver. You can always find the most recent list of breaking changes in the upcoming milestone or in the Serverless CLI.

So there's that then. Would you base a business on this framework? I decided it wasn't for me.

#### Rolling My Own

Once you understand the machinery that goes into AWS Lambda, rolling your own isn't too difficult. I took a weekend to dive in and figure out the bits that confused me prior, and eventually I had a few shell scripts rolled together that orchestrated most of what I needed.

If you're comfortable with scripting, know AWS and can tolerate some head-pounding... AWS Lambda isn't all that bad. A bit more expensive then I'd like but... not that bad.

**Verdict**: Every single time I've used AWS I've had to ditch a weekend or 2 remembering how things worked. It's a powerful system, but in many ways is overkill when compared to something like Heroku (or the services like Heroku). The problem is that Heroku can get expensive, fast.

Then there's what I've been doing for the last 5 years or so that's working great: [DigitalOcean](https://www.digitalocean.com/). It has been my go-to for so long; it takes a lot to justify moving away from them. I have my build scripts down cold and I can whip up a server during lunch, complete with SSL and multiple, managed Node processes. I have the same for Elixir too.

Honestly: serverless with AWS isn't buying me anything. I don't want to use DynamoDB (though I'm sure it's wonderful), I can use a message queue if I want to do things in a "small function" kind of way, and honestly it just takes too much space in my brain.

All of that said, yes I know that new frameworks are popping up daily, so maybe things will change a bit. For now, no AWS Lambda for me.

## And Then: Firebase

I remember reading [this post](https://firebase.googleblog.com/2017/03/introducing-cloud-functions-for-firebase.html) with a groan, thinking "not again"...

>Today we are excited to announce the beta launch of Cloud Functions for Firebase. It lets you write small pieces of JavaScript, deploy them to Google's Cloud infrastructure, and execute them in response to events from throughout the Firebase ecosystem.

I'll admit to a heavy amount of Magpie-ishness. I can't help it... it's just me and I've learned to let me be me... as opposed to you or anyone else.

The [first impression](https://firebase.google.com) I had when looking over the "new" Firebase site was one of immense relief. The page is elegant, focused, easy on the eyes and easy to understand. The console is wonderfully simple, too:

![](https://blog.bigmachine.io/img/firebase/firebase_1.jpg)

Clicking through each of the services made sense to me. But what about the functions? How simple would it be to get code up here? What about hosting? Can I SSL this stuff? Outbound networking? Can I use PostgreSQL instead of Firebase or, maybe, together with it?

I found out the answers to all of these questions was, in short: simple, simple, yes, yes and yes. After working with AWS, Firebase was a very welcome change.

I'll get to all of that in the next post.

---

## [See this series as a video](https://goo.gl/yCliXG)

Watch how I built a serverless ecommerce site using Firebase. Over 3 hours of tightly-edited video, getting into the weeds with Firebase. We'll use the realtime database, storage, auth, and yes, functions. I'll also integrate Drip for user management. I detest foo/bar/hello-world demos; I want to see what's really possible. That's what this video is.
