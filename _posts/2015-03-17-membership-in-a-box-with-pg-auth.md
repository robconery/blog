---
layout: post
title: "Membership In a Box with PG-Auth"
slug: membership-in-a-box-with-pg-auth
summary: ""
comments: false
image: /img/2015/03/pg_auth_cover2.jpg
categories: Postgres
---

I [mentioned in a previous post](http://rob.conery.io/2015/02/21/its-time-to-get-over-that-stored-procedure-aversion-you-have/) that I threw together some ideas one weekend on how to do membership completely within Postgres (users, roles, logs etc).

It was fun and quite a few people asked if they could have a look at it - so I tidied it up and wrapped it with a Node project (for test/build) and [popped it up on Github](https://github.com/robconery/pg-auth).

You see, I don't have enough people calling me names. More than that - [since I've been traveling with my family](http://rob.conery.io/2014/09/18/being-a-nomad-for-a-year/) I've started to have some fun and feel good about my career and what I'm doing. So I experiment and come up with weird ideas **because, in short, I'm having too much fun**.

I'm leaving it to you all to rip me apart. Bathe yourself in [this logic-filled function](https://github.com/robconery/pg-auth/blob/master/build/src/functions/register.sql) that I planted **deep into the heart of my database**:

```sql
create or replace function register(
    new_email varchar(255),
    pass varchar(255),
    confirm varchar(255)
)

returns TABLE (
    new_id bigint,
    message varchar(255),
    email varchar(255),
    success BOOLEAN,
    status int,
    email_validation_token varchar(36))  
as
$$
DECLARE
    new_id bigint;
    message varchar(255);
    hashedpw varchar(255);
    success BOOLEAN;
    return_email varchar(255);
    return_status int;
    validation_token varchar(36);
    verify_email boolean;

BEGIN
    -- default this to 'Not Approved'
    select 30 into return_status;
    select false into success;

    select new_email into return_email;

    -- validate the passwords match
    if(pass &lt;> confirm) THEN
        select 'Password and confirm do not match' into message;

    -- make sure user doesn't exist
    elseif exists(select membership.members.email from membership.members where membership.members.email=return_email)  then
        select 0 into new_id;
        select 'Email exists' into message;
    ELSE
        -- we're good, do the needful
        select true into success;

        -- hash password with blowfish
        SELECT membership.crypt(pass, membership.gen_salt('bf', 10)) into hashedpw;

        -- create a random value for email validation
        select membership.random_value(36) into validation_token;

        -- add the new Member record
        insert into membership.members(email, created_at, membership_status_id,email_validation_token)
        VALUES(new_email, now(), return_status, validation_token) returning id into new_id;

        -- the return message to be passed back out
        select 'Successfully registered' into message;

        -- add login bits to member_logins
        insert into membership.logins(member_id, provider, provider_key, provider_token)
        values(new_id, 'local',return_email,hashedpw);

        -- add auth token
        insert into membership.logins(member_id, provider, provider_key, provider_token)
        values(new_id, 'token',null,validation_token);

        -- add them to the members role
        insert into membership.members_roles(member_id, role_id)
        VALUES(new_id, 99);

        -- add log entry
        insert into membership.logs(subject,entry,member_id, created_at)
        values('registration','Added to system, set role to User',new_id,now());

        -- if the settings say we don't need to verify them, then activate now
        select email_validation_required into verify_email from membership.settings limit 1;

        -- if the email doesn't need verification, set their status to active
        -- this is in the settings table
        if verify_email = false then
          perform membership.change_status(return_email,10,'Activated member during registration');
        end if;

    end if;

    -- all done here, pass back what happened
    return query
    select new_id, message, new_email, success, return_status, validation_token;
END;
$$ LANGUAGE PLPGSQL;
```

Mmmmmm LOGIC. [How will I ever test this](https://github.com/robconery/pg-auth/blob/master/test/registration_spec.js)?

## OK Seriously What Is This Why Is This WTF?

First: this is just a first stab at an idea. I have used [Devise for Rails](https://github.com/plataformatec/devise) for a really long time because it does its job well. The only bad part is that I don't really use Rails anymore and there's nothing like this for Node.

Or ASP.NET MVC or Django. And really - should Rails have all the fun?

The main thing I need is just the data interactions - registering a user, authenticating, role management etc. I don't care much for the way Devise shoves all of this into a gem and I get to configure it - I'd much rather have it somewhere where I can change the stuff.

There are no views or mailers here - just routines for you to use if you like **with whatever platform you want**. That, to me, is important.

## Over My Dead Body?

I know that people will have some pretty strong reactions to this - I say this only because my last few posts on Postgres and Stored Procedures made some people really mad at me on Twitter and other places.

If you're one of those people, consider this repo a mirror. *Why does it make you so upset?*. I'm happy to talk about all of the issues as long as you're willing to hear my answers. In fact I've [setup a Discourse board for my blog](http://discourse.conery.io) to see if will help improve the comment situation!

I really do want to hear from you; but only if you're willing to understand that I wasn't born yesterday. If it helps: **consider this project a 'Paleo Project'** - something that flies in the face of conventional wisdom and that may just help you lose 50 pounds.

## Work In Progress

I'm still working on some things, of course. If you want to have a play all you need do is:

 - Install Postgres (9.4 is best)
 - Create a `pg_auth` database
 - Clone the repo (https://github.com/robconery/pg_auth) and run the tests

I'm sure there's a ton I can improve - I'm not a great PLPGSQL programmer and I've only recently (in the last 4 years) gotten into Postgres. Would love to hear your thoughts if you have any!
