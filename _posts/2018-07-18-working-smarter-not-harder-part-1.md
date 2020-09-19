---
title: 'Working Smarter, Not Harder, Part 1'
date: '2018-07-18'
image: /img/2018/07/son-2935723_1280.jpg
layout: post
summary: "This last month has been intense. I'm writing the second volume of The Imposter's Handbook﻿ with Scott Hanselman, I moved back to Hawaii, and I'm trying to finish up a sprint for a contract I've been..."
categories:
  - Career
---

I'm sitting here at this very moment in our new, just-moved-in-and-insanely-messy apartment in Kaka 'Ako, with 90 minutes to write this post, according to my calendar on Outlook. My youngest (13) is staring at the walls as my wife and oldest (16) are on a road trip in the Pacific Northwest. Oh yeah: I'm also trying to workout every day with P90X. 

To pull this off, I needed to streamline. Seeing that I have a 90-minute break to write a blog post, I thought I would share with you some of my strategies.

## Shell Scripts as Employees

One of the recurring discussions I have with friends who have started businesses centers around a single question: _when do you hire someone to help you?_﻿ One of my friends doesn't want to do anything but sell, so he hires help immediately from Upwork. Another friend refuses to hire anyone at all and enjoys turning work away in an effort to remain small.

I like to write shell scripts.

Let me give you an example. If you go through your day and document the tasks that:

1. Take the longest
2. Are the most repetitive and
3. The easiest to delegate

These, to me, are prime candidates to offload to an assistant. Yes, I realize that's different than an employee who could do specialized tasks (such as edit and render a video, for instance) but right now what I need is an assistant.

I did this last month, and it was surprising how much time I spent rolling together demos for [the book I'm writing](https://bigmachine.io/projects/imposters-handbook-presale/). I'm using Ruby (as well as JavaScript), and for each demo, I'm creating a dedicated project. This is time-consuming!

It's a long story, but I was creating a mess of Sinatra apps and setting up my Gemfile, RSpec and so on was taking way too long. Yes, I could copy/paste, but I decided to do it a bit cleaner and spent 15 minutes writing up a shell script:

```sh
alias spec="bundle exec rspec spec --format documentation"
ruby_app() {
  if [ $# -eq 0 ]
    then
      echo "Need an app name dope"
  else
    APP_DIR=$1

    #create the directory
    mkdir $APP_DIR
    cd $APP_DIR

    #main app bits
    touch app.rb

    #Gemfile
    cat <<gemfile > Gemfile
source 'https://rubygems.org'

gem 'rspec'
#gem 'pg'
#gem 'sinatra'
#gem 'sinatra-contrib'
gemfile

    #Rbenv
    rbenv local 2.3.3

    #Makefile
    echo "gems:\r\n\tbundle install --path=vendor\r\ntest:\r\n\trspec spec" > Makefile
    cat <<makefile > Makefile
all:

app:
    ruby app.rb

test:
    rspec spec

gems:
    bundle install --path=vendor

db:
    #psql stuff here

.PHONY: all web test
makefile

    #get the gems
    bundle install --path=vendor

    #initialize rspec
    rspec --init
  fi
}
```

This script does a few things:

- It creates the application directory and sets the local Ruby using rbenv local
- It sets up RSpec and the test directory
- It tells bundler to use a local directory for gem installs
- It creates my standard Makefile that I like to use with web projects

At the very top there, you can see an `alias` command as well that will run RSpec using bundler. I use [Robby Russel's Oh My ZSH](https://github.com/robbyrussell/oh-my-zsh)! so this entire script is loaded into the shell when I start up the terminal.

I have a few other shell scripts (written in bash and Ruby) that I use to optimize my time. I have one that CURL's out to my Shopify site and pulls down the daily sales numbers, another that creates a Jekyll blog post for me. There is a lot more I can do this way, and I'll share when I can.

## Back to Outlook

This one is probably obvious to a lot of people and repulsive to others. A huge chunk of my day centers around email (still), and I can't afford to use the "just check it twice" strategy as I am also the sole support person for my company.

The best email experience I've had, ever, is with Outlook. I learned how to use it many years ago, and I had a nice mess of rules set up to help me organize my day. There are countless strategies out there, but if you're like me, giving yourself completely over to a single method just doesn't work.

Here are the things I need to have happen:

- Support emails need to bubble up
- List emails run the gauntlet
- Family Friends are moved to "Social Time"
- Everything else dies

This is the process I've pulled together over the last 3 months, which seems to be working:

- Go through my inbox every 2 hours or so and highlight the crap, deleting it immediately.
- If it's not support/family, I decide whether to read it quickly. If I won't, it's gone.
- Family gets a quick read. My wife will always get a reply, others get Shift-CMD-T'd (mark unread) unless I have time to read them.
- Support emails get a quick read/response. If I can't answer a question, it gets a CTRL-1 (create a task from email due today). If it's something that can wait, CTRL-2 (create a task due tomorrow)

I'll take the time to handle support emails when they come in, which means I do them every 2 hours or so. The unread bits from my family get dealt with at lunch and finally at 4 pm, toward the end of my day.

I reply immediately to the support emails that I can't solve and that have been CTRL-1'd, and I let the customer know I'm working on it. I usually handle these things right away, but if it's not pressing I'll wait until lunch or later in the day around 4. If it's really not pressing (like "hey I have some spelling suggestions for you") I'll CTRL-2 it for the next day.

I'm kind of lucky this way, as I don't have a flood of meeting requests and emails from co-workers. If so, I [might have to adopt some of Hanselman's rules](https://www.hanselman.com/blog/TheThreeMostImportantOutlookRulesForProcessingMail.aspx).

## 2 Hour Lunches

Of all the things! How can I possibly justify taking 2-hour lunches when my time is so very limited! **Because I'm not a sack of meat**. I can't burn myself up like I did when I was younger. _I need to work smarter, not harder_ and that means being refreshed and ready to go when I sit down to do something.

I start work right around 8:30 or 9 am, and then stop at 12 (which is in 30 minutes as I write this). During the hours from 12 until 2pm, I exercise, go for a walk or if it's summer vacation, do something with my kids if they're home. Today we're going to Office Depot to get school supplies.

I'll also be sure to flop on my back and read a book for at least 30 minutes. Yesterday it was _The Code Book_ by Simon Singh, where I read up on RSA and asymmetric key encryption. Sometimes I even doze off!

I'm back at it by 2:30 or so, then quit by 6. And yes: _I know I'm lucky_ to set my own hours like this. [I really like working on my own](https://bigmachine.io/products/going-solo/) and I've fought quite hard over my career to be as independent as I can.

OK - time's up! Gotta run to Office Depot and get some school stuff!
