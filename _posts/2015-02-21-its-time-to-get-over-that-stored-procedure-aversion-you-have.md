---
layout: post
featured: true
title: "It's Time To Get Over That Stored Procedure Aversion You Have"
slug: its-time-to-get-over-that-stored-procedure-aversion-you-have
summary: "There is a lot of opinion about stored procedures out there that are just... "
comments: false
image: /img/2015/02/sp_pain3.jpg
categories: Postgres Databsae
---

In the .NET world (and beyond), data access is a cluster-fucked echo chamber of half-assed rocket engineering and cargo cultism based on decade-old cathedralized thinking and corporate naval -gazing.

_(Cracks Knuckles...)_

The thought vacuum you encounter when discussing databases and data access is (most of the time) a full-speed face grind. Reminds me of the time in college when I woke up in the middle of the night at a friend's house trying to find the bathroom after a few beers and walking nose-first into the wall: _empty, painful, dark_.

_Damn I am sick of this conversation._

The mental paralysis surrounding Stored Procedures and Functions in your database is hurting you. These things exist for a reason: your database and all of its amazing amazingness is there to _help you_. To **love you** and your data! You need to let this love flow.

Let's move on from this medieval database thinking. Let's embrace SQL and Stored Procedures for what they are, and what they do: _kick ass_.

## Business Logic

Developers don't want Stored Procedures and Functions in their database because _Business Logic in database bad_. This is what they've read in blogs, read on Twitter, heard from a rockstar developer at a conference. This is what _someone else told them_ and it's simply gone too far. **Stored Procedures are not inherently bad** - you've been told this because someone thinks you're not capable of thinking for yourself.

Think on this: **what is Business Logic**? I've had this conversation often with fellow developers and I can say that it's a bit like asking "[so ... what is REST anyway](http://rob.conery.io/2012/02/28/someone-save-us-from-rest/)".

To me, I think you take all the code you write for displaying things to a user, shoving things into a database, caching, configuration and optimization and scrape it away. What you have left is your Business Logic (more or less). At least it's _what you think is Business Logic_. It's really not. Not entirely.

It's your lovely Domain Model that is bent to serve Entity Framework or ActiveRecord or [whatever ORM you're using]. It's the thing you wanted to create, that you tried to create using all of the lovely OO principles you know but eventually had to corrupt and abandon because ORMs are hell and for some reason you can't see just what that ORM has done to your codebase and _OH MY GOD GET THAT STORED PROCEDURE AWAY FROM ME_.

I once read a post by a Rails fanatic deep in the heat of Rails fever describe referential integrity and database normalization as "business logic". Evidently ActiveRecord/ActiveSupport has everything you need to protect your data! At the time I was getting to know and love Rails, and I remember thinking _this person is trying to scare me away from Rails_. My next thought was _I need a beer and a hammer_ OH MY GOD.

You build applications to generate data. That data is your value, that value brings in the money. There is nothing else and if you think safeguards for this data belong anywhere else other than cuddled up next to your data with a machine gun and flamethrower you're out of your fucking mind.

That ORM you're using is destroying your ability to clearly see, feel and love your data and how it is stored.

This mentality: that the database is there to "just hold data" is confoundingly irritating. I say this because I have confoundingly irritated myself by falling into this thinking (with Rails and other platforms) - letting ORMs handle my data needs. ORMs aren't there to protect your data, they exist to ruin your life and destroy what good feelings you have left about your career - that's about it.

## Business Logic In Your Database

There are good reasons to exclude Business Logic from your database, including:

 - SQL is not intelligent enough to describe a business processes. You can do it, but it's extremely crap-filled.
 - A database is for handling data, not executing higher-level logic
 - It's difficult to test SQL

All of these are very valid and I agree with each of them. So let's not do that OK? Now that we agree - **onward**.

## Data Logic vs. Business Logic

Consider the application you're writing right now. It very likely has the concept of a User and you want to remember who that User is. If not, let's just pretend OK?

In Rails if you need membership for your site (logins, passwords, etc) you have a mess of 3rd party gems to use. They're so good at what they do it's ridiculous to write your own - something I've said to many developers who have tried to write their own membership system: "you're prone to make the same mistakes and end up in the same place as Devise. You're not a unique snowflake, just use it".

This is because Devise (and libraries like it) do pretty much the same thing: register users, authenticate them, role management, etc. and they do it well. The people who built Devise (and libraries like it) encountered every problem you will encounter building your own, and they've done a pretty good job.

Membership is what you call a **horizontal concern**. In every application you write with users you want to remember, you'll need this kind of thing and it doesn't change.

So: _is this business logic_? I don't think so. That's a bit of a bold statement but it has a bold bit of reasoning: _if every application needs it, why is it unique Business Logic to your app?_. Answer: **it's not**.

I bring this up because there are decisions and executions that are unique to your business that belong in code. Once those decisions are reached, they need to be remembered. **This is your data logic** - the remembering, the writing it to disk after all decisions have been reached!

Let's see an example of what I mean.

## A Database Membership System

One day I decided to test-drive some crazy ideas regarding databases and membership systems and I fired up Postgres to see if I could emulate Devise with a set of functions. My thinking was this: **if I'm going to let a gem do this for me, why not a set of functions I can debug?**. In other words: **if all of this is hidden from me in a gem, why can't it be hidden from me in the database?**.

I can write the code that validates inputs, makes basic decisions about who can enter when, why, etc (even charging money) but when the time comes - I'll need to write their record to the system. Again: **Data Logic**.

The first step was to add hashing to my database (this is psql in action below):

```sql
 create database crazytalk;
 \c crazytalk;
 create extension pgcrypto;
```

[pgcrypto](http://www.postgresql.org/docs/8.3/static/pgcrypto.html) is a set of hashing and encryption functions that allow you to do things like hash a password using blowfish (bcrypt) - the same hashing algorithm that Devise uses.

Long story short, I created it over the course of 3 weeks - a set of 12 different functions and 9 tables. I love it, dearly.

The main reason is it goes well, well beyond registering and logging people in. It handles the notion of sessions, logging and activity, notes, roles, and a [kickass way of handling id generation](http://rob.conery.io/2014/05/29/a-better-id-generator-for-postgresql/).

I still have a few things to do with it - but my goal was satisfied: **can I create a full database implementation of a membership system without wanting to throw up?**. And yes, I can. But that's me, [I love Postgres](http://rob.conery.io/category/postgres/) and I love thinking about all the data I'll need in the years to come **and how I'll protect it**.

No it doesn't send emails or any crazy crap like that - _it just moves data around_ efficiently, transactionally. Just like Devise, but better.

## Stored Procedures, Functions, Whatever Get Over It

The main thing I came away with is just how powerful these functions can be. And with power comes the lure of abuse, of course, but let's just have a think on it.

When a new User registers into your system, what happens? Do you know? In mine a number of things go off:

 - The user record is written
 - A log entry is created
 - A note is added describing when/how/where
 - A role is assigned
 - A mailer is prepared and the mailer record attached to the user (a Welcome! email)
 - A validation token is created and two separate logins (auth token and local user/password)

If I was to use an ORM, this would be a lot of writes. If I was careless (or using Rails - take your pick) I wouldn't put this into a transaction, which it very much should be.

Do you think the above is Business Logic? I don't - it's simple execution of writing some data which is quite easily facilitated by Postgres:

```sql
CREATE OR REPLACE FUNCTION register(login varchar(50), email varchar(50), password varchar(50), ip inet)
returns TABLE (
  new_id bigint,
  message varchar(255),
  email varchar(255),
  email_validation_token varchar(36)
)
AS
$$
DECLARE
  new_id bigint;
  message varchar(255);
  hashedpw varchar(255);
  validation_token varchar(36);
BEGIN

  --hash the password using pgcrypto
  SELECT crypt(password, gen_salt('bf', 10)) into hashedpw;

  --create a random string for the
  select substring(md5(random()::text),0, 36) into validation_token;

  --create the member. Email has a unique constraint so this will
  --throw. You could wrap this in an IF if you like too
  insert into members(email, created_at, email_validation_token)
  VALUES(email, now(), validation_token) returning id into new_id;

  --set the return message
  select 'Successfully registered' into message;

  --add login bits to logins
  insert into logins(member_id, provider, provider_key, provider_token)
  values(new_id, 'local',email,hashedpw);

  --add auth token to logins
  insert into logins(member_id, provider, provider_key, provider_token)
  values(new_id, 'token',null,validation_token);

  -- add them to the members role which is 99
  insert into members_roles(member_id, role_id)
  VALUES(new_id, 99);

  --add log entry
  insert into logs(subject,entry,member_id, ip, created_at)
  values('registration','Added to system, set role to User',new_id, ip, now());

  --return out what happened here with relevant data
  return query
  select new_id, message, new_email, success, validation_token;

END
$$ LANGUAGE plpgsql;
```

This is a Stored Procedure. I wrote it, and I love every part of it. It writes the data I need after I've decided the User is good to go - _after my app has made the decision to let them in_. No additional logic or decisions here, just a bunch of writes executed in a transaction - precisely what a Stored Procedure is good for.

My goal with this exercise is not programmatic purity. **My goal is data correctness and accuracy** which I hope is your goal too. That should be everyone's goal! Your app is there to produce data, no one gives a damn about your code but you.

## Of Course You Can Take This Too Far

That's the argument I hear most often: _it's a slippery slope to keep dumping logic in your database!_. Sigh.

Once you start writing code you're surrounded by slippery slopes falling away from Slick Demo Mountain - I don't care what the platform or tool is. The only thing you can do is to study up and know what tools do what, and what they're good for and how they're could hurt in the end.

postgres as it turns out, is an excellent transactional data engine (and yes, SQL Server as well). What it's not so good at is providing a descriptive language that I can screw myself into a corner with (PLPGSQL is brutal).

Why do I need to monkey with an ORM when I can let Postgres elegantly handle this for me with SQL that's pretty damn simple to understand? Are `SELECT` statements and parameters really that scary?

I don't understand the mentality of spending a twice the time to learn an ORM rather than learning the SQL of your current database system. You _think_ you're moving faster in the beginning, but as time goes on debugging that ORM will change your mind... and then you try to rip it out and end up writing a blog post late at night ranting about ORMs and then...

I want to vault every ORM into the heart of the sun or, preferably, go back in time and smash all the computers responsible for their genesis. **It's 2015, let's wake the fuck up to the power of SQL and our relational systems.**
