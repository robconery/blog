---
title: PostgreSQL Tools for the Visually Inclined
date: '2019-03-04'
image: /img/2019/03/screenshot_1451-825x510.png
layout: post
summary: "I started my career on the Microsoft stack building forms and websites using drag and drop tools. Over time that became a punchline, which is unfortunate because honestly, the productivity was insane..."
categories:
  - Postgres
  - Syndication
---

I started my career on the Microsoft stack building forms and websites using drag and drop tools. Over time that became a punchline, which is unfortunate because honestly, the productivity was insane.

In 2008 I made the jump to the Linux world and I was completely disoriented. _Everything was a damn text file_. Yes, you could use a Mac or Ubuntu or whatever Unix Desktop du Jour seemed fun but there simply was no getting around the need to know your commands, which I did.

Just like learning SQL, learning your text commands makes you more efficient. _I promise you that I'm not about to flip the l33t bit_. I'm not here to convince anyone of anything – what I do want to do is to share how I embraced the command line with respect to PostgreSQL and was damn happy for it.

## Friendly vs. Friendly

I've been meaning to write this post for years but it was [this post](https://www.softwareandbooz.com/postgresql-for-a-sql-server-dba-the-tooling-stinks/) from Ryan Booz that made me fire up the editor. Ryan is a SQL Server DBA that is writing a series on how [he's learning PostgreSQL](https://www.softwareandbooz.com/postgresql-for-a-sql-server-dba-a-series/) after a 15 year (!) career as a SQL Server DBA. I can't imagine that change is an easy one.

Basically, Ryan has concerns (which I understand):

> In the case of PostgreSQL, I’ve quickly come to the conclusion that bad tooling is one of the main reasons the uptake is so much more difficult and convoluted coming from the SQL Server community. Even the devs I’m currently working with that have no specific affinity for databases at all recognize that PostgreSQL just feels like more of a black box then the limited experience they had previously with SQL Server.

I can't say he's wrong on this, although I will say the term "bad" is a bit subjective.

Let me get right to it: jumping from SQL Server to PostgreSQL is _much more_ than changing a tool. **PostgreSQL was built on Unix**, with Unix in mind as the platform of choice, and typically runs best when it's sitting on some type of Unix box. **The Unix world has a pretty specific idiom** for how to go about things and it **certainly isn't visual**!

As someone who learned to code visually, I had to learn what each icon meant and the visual cues for what happens where. I came to understand property pains, the lines under the text of a button that described shortcuts, and the idiomatic layout of each form. Executing a command meant pressing a button.

In the Unix world you write out that command. The check boxes and dialogs are replaced by option flags and arguments. You install the tools you need and then look for the binaries that help you do a thing, then you interrogate them for help, typically using a `--help`command (or just plain `help`).

The same is true for PostgreSQL. This is the thing that I think was stumping Ryan. He's searching for visual tooling in a world that embraces a completely different idiom. It's like going to Paris and disliking it (and France) because the barbecue is horrible.

Let's walk through some common PostgreSQL DBA "stuff" to show what I mean.

## Your Best Friend: psql

When you encounter a new Unix tool for the first time (and yes, I'm labeling PostgreSQL that) you figure out the binaries for that tool. PostgreSQL has a number of them that you'll want to get to know, including `pg_dump` and `pg_restore`among others. The one we want right now is `psql`, the interactive terminal for PostgreSQL that gets installed along with the server. Let's open it and ask it what the hell is going on:

![](https://i1.wp.com/rob.conery.io/img/2019/03/screenshot_1430.png?fit=1024%2C731&ssl=1)

Hello psql

I'm using Mac's Terminal app but you can use any shell you like, including Powershell and the Windows command line. I would strongly urge you, however, to crack open a Linux VM or Docker to get the "flavor" of working with PostgreSQL. You can, indeed, find barbecue in Paris but it might help to explore the local cuisine.

Reading through this list of options and commands will take some patience the first time – but it's worth it! At the top of the list are the common options, like using `-c`for running a command and `-d`for the database to run the command in. There's a key statement, however, at the very end of this help screen:

![](https://i1.wp.com/rob.conery.io/img/2019/03/screenshot_1432.png?fit=1024%2C731&ssl=1)

psql: it's interactive!

The `psql` tool is interactive! This will help us - so let's log in to a database and have a look around. But which database? We'll create one by running this on the command line:

```
createdb redfour
```

The `createdb`binary has one job, in typically Unix fashion: _create a database on the local server_. It has a counterpart binary as well: `dropdb`. How do I know this? It's one of those things you get used to as you work with Unix systems - figure out the binaries and what they do.

How do you do that? We know about one binary so far, `psql`, so let's figure out where that lives and hopefully the other binaries live there too:

![](https://i1.wp.com/rob.conery.io/img/2019/03/screenshot_1433.png?fit=1024%2C561&ssl=1)

Using which and ls to tell us more

This is one of those things you learn over time: asking Unix `which` version of a tool/binary/runtime it's using and where it's located. The result of that command is telling me that `psql` lives in the `/Applications/.../bin` directory, which is pretty standard for binary tools. I copy/paste the result to the `ls` command (list contents) and we can see the binary tools at our disposal.

Yay. Let's log in and play around.

![](https://i1.wp.com/rob.conery.io/img/2019/03/screenshot_1436.png?fit=1024%2C360&ssl=1)

## What the Hell Is Happening?

Right now I'm at an interactive terminal within my database... and have no idea what to do next. This is the major upside of visual tooling: you have cues that you can follow which inform you as to what's happening. It's the difference between Halo on the Xbox and an old school MUD – it feels outdated and silly.

Let's keep going and see if that's true. When we ran the `--help` command before, it told us to use `\?` to figure out commands within psql, so let's try that first:

![](https://i2.wp.com/rob.conery.io/img/2019/03/screenshot_1437.png?fit=1024%2C543&ssl=1)

Hello sea of text crashing over me!

There is _so much to absorb here_. All of these cryptic little commands _do something_ but what they do, at first, will likely be opaque to you. This is Yet Another Patient Deep Breath point, because pretty soon we're about to light this shit on fire (in a good way). What you have, right here, is a lot of raw _power_ right at your fingertips. It just takes a few hours to understand the cadence of these commands as well as their modifiers. I'll show you exactly what I mean in just a few minutes, for now let's ground ourselves.

Scroll down (using down arrow or your mouse) to the Informational command section. This is your bread and butter - here you can see what's in your database at a quick glance. We can do that by using `\d` (press Q to get out of the text view of the help page):

![](https://i1.wp.com/rob.conery.io/img/2019/03/screenshot_1438.png?fit=1024%2C536&ssl=1)

Our database is empty. Let's fix that by creating a quick table for our users:

![](https://i1.wp.com/rob.conery.io/img/2019/03/screenshot_1439.png?fit=1024%2C539&ssl=1)

When you write a SQL command within psql you can wrap the lines. Notice that the prompt changes as well, telling you that you currently have an open paren. To finish the command add a semi-colon and we're done. _Note: I'm not going to get into SQL but [it's really worth your time](http://www.craigkerstiens.com/2019/02/12/sql-most-valuable-skill/) to learn._

Now let's list out our relations again:

![](https://i2.wp.com/rob.conery.io/img/2019/03/screenshot_1440.png?fit=1024%2C539&ssl=1)

Lovely. We have our table and the thing that handles the id generation for that table, called a _sequence_. Let's ask psql more about this table using `\d users`:

![](https://i0.wp.com/rob.conery.io/img/2019/03/screenshot_1441.png?fit=1024%2C422&ssl=1)

The structure of our table is laid out in glorious ASCII, heavy with information and completely bereft of anything resembling prettiness. For visual people, this is a turn off as it's completely different than what they're used to (which I understand). For people used to working in a text-based idiom, this is heavenly.

Why? _It's the speed of the thing_. Let's put a clock to the problem. One of your appdevs just did something ill-advised with their ORM and they think they might have broken the `users` table. You decide to investigate:

```
psql redfour
\dt users
```

When you're just starting out with PostgreSQL (and psql), you'll need to squeeze your memory a bit for the commands to inspect a table. After a while your fingers will be done typing before your next breath.

_This is the power you want as a DBA_.

At this point I could go off on all of the psql commands available to you, however I would encourage you to explore these for yourself and see what's possible, and how blazingly fast you can get it done. My coworker (ha ha so fun to say that now) Craig Kerstiens has written extensively on PostgreSQL, and [this post is extremely helpful](http://www.craigkerstiens.com/2013/02/13/How-I-Work-With-Postgres/) for people getting used to the command line aspect of it.

I want to get into why this kind of thing matters.

## Text is a Helluva Drug

If I asked you to move data from one server to another using your favorite visual tool, how would you do it? If you do it often then the process would be a simple one and likely involve some right-clicking, traversing a menu, and kicking off a process in your tool of choice.

In Unix land (and therefore Postgres land) it's a matter of remembering a few commands. But this is where it gets interesting because _everything in Unix is a text file._ Almost every task you can think of in Unix can be done using a text-based command. It would be like trying to find barbecue in Paris when every building is made of meat and the Seine is a river of hot coals.

To show you what I mean, here's how you might pull your production database down to your local server:

```
pg_dump postgres://user:password@server/db > redfour.sql
createdb redfour
psql redfour < redfour.sql
```

The `pg_dump` binary has the singular task of turning a database into a SQL file. You can, of course, tweak and configure how this works and to find out all of the options you would use... can you guess? `pg_dump --help` . So we're dumping the structure and data to a SQL file, creating our database and then pushing that SQL file as a command into our new database.

This entire process will execute in < 5 seconds on a smaller sized database (~20mb). This is why we like text and text-based interfaces - SPEED!

## There's Always a Way

As you might be able to tell, I've had this conversation more than a few times. Visuals are very important, to be sure! But they have their place when it comes to your daily workflow as a DBA. I would argue that double-clicking, right-clicking, and drag/drop are much slower than taking the time to memorize some common commands.

One place that psql sucks, however, are visuals. Executing a query on a large table can look horrible:

![](https://i0.wp.com/rob.conery.io/img/2019/03/screenshot_1443.png?fit=1024%2C667&ssl=1)

Yuckity Yuck

This is DVD Rental sample database, running a `select * from film;` query. It looks like crap! The good news is that we _should_ be able to fix this. Let's ask psql what's going on using `\?` :

![](https://i1.wp.com/rob.conery.io/img/2019/03/screenshot_1442.png?fit=1024%2C575&ssl=1)

There are two things to notice here. The first is `\x` which allows for expanded output, or vertical alignment of data. That looks like this:

![](https://i1.wp.com/rob.conery.io/img/2019/03/screenshot_1444.png?fit=1024%2C667&ssl=1)

Using expanded output

The other thing you can do is to set HTML as the output using `\H`. This will execute the query, returning the results in HTML:

![](https://i2.wp.com/rob.conery.io/img/2019/03/screenshot_1445.png?fit=1024%2C667&ssl=1)

This is interesting but I want this saved to a file. To do that, I can use `\o` (which you can see in the help menu) and specify which file:

![](https://i0.wp.com/rob.conery.io/img/2019/03/screenshot_1448-1.png?fit=1024%2C525&ssl=1)

The file produced isn't terribly exciting, but it's somewhat useful:

![](https://i0.wp.com/rob.conery.io/img/2019/03/screenshot_1449.png?fit=1024%2C648&ssl=1)

This is where we can embrace the texty nature of Unix and see what's possible if we start jamming binaries together with some core Unix commands, which are all based on text.

Let's use psql to execute a query, but this time we'll format things using Bootstrap:

```
echo "<link rel='stylesheet' href='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css'>" > report.html && psql chinook -c "select * from film" -H >> report.html && open report.html 
```

![](https://i1.wp.com/rob.conery.io/img/2019/03/screenshot_1450.png?fit=1024%2C608&ssl=1)

OK it's certainly not crazy amazing but for a quick report it's not so bad. You can alter the SQL statement to output only the columns you want, and you could formalize the call using a bash function to make it all pretty.

## Yeah But It's Not Management Studio!

Very true. You can't double-click a table and edit the rows, for instance, and there are no spiff icons. Altering data is done with INSERT and UPDATE commands, deleting is done with DELETE. This is something that you do have to get used to, for sure, and if this is a common task for you than you might want to focus on a tool that allows that (such as [Postico](https://eggerapps.at/postico/), which is free).

If there's one reason to use psql it's _speed_. I would also argue _power_ but for now I'll go with speed as the primary reason. You're done before you know what happened and, if you have repetitive tasks, you can save your commands as text files to run as you need, when you need.

Change isn't easy, but the people I know that have made the change use psql on a daily basis and absolutely love it. They also flip into a visual tool as needed. One thing they all agree on, however, is that they don't miss the visual stuff at all.
