---
layout: post
title: How To Backup Your Postgres DB To Amazon Nightly
summary: "We just recently pushed Tekpub over to Posgres and all in all, it was very simple. I won't talk about the reasons we moved from MySQL - that's another post. This one is all about making sure your backups go off nightly."
image: /img/postgres.jpeg
date: "2011-11-01"
uuid: "iU3VpPeX-vZkk-94gm-ATF9-HfFCyKmxhSlw"
slug: "how-to-backup-your-postgres-db-to-amazon-nightly"
categories: Postgres Node
---

## Hello Postgres

You've setup Postgres and your new awesome website is banging away at one of the top database engines out there - hurrah! But that's not the end of the story - you need to back up your data before you do anything else! So let's get to it...

There are two ways to dump the data from Postgres - the first is dumping the entire database contents (tables, sequences, indexes, logins - aka "roles" - etc) - the second is just your database:

```
  pg_dumpall #dumps everything
  pg_dump myDb > my_backup.sql #dumps schema and data from myDb into my_backup.sql
```

Simple enough. Yes, it's command line. Run for the hills.

## Automation

One of the nice things about Postgres is that it tries very hard to get you to do the right thing. MySQL doesn't care as much. Again, another post - but the thing we care about here is that Postgres won't let you dump the contents of a database out unless... gasp... you have permission to do so. 

The problem is that, unlike MySQL, you can't just pop the username and password inline like you would with MySQL:

```
  mysqldump -u root -p[OH NO YOU DIN'T] myStolenDatabase > dumpfilename.sql
```

As I said, MySQL is cuddly and sweet. Postgres won't stand for this shit and wants you to do your best to try and not shoot yourself in the foot. Now, for some this means enduring some pain. For others... well it's kind of nice to know Postgres has my back.

"But wait a minute - if I can't send in the password to my database... well how do I automate the backup?" Good question. There's an answer...
  
## Setting Up .pgpass

Postgres has an interesting way to allow you access to a database, and it's through a hidden file in your home directory called ".pgpass". Simply put - it's a bunch of settings that you can protect as needed (of course allowing Postgres to see it) - and mainly has that password that is required for running backups.

Here's what it looks like:

```
  hostname:port:database:username:password
```

A very utilitarian, Linux-y file format but... it works. The deal with this file is that Postgres will access it whenever the local user tries to do something with the Postgres server, and it will try to match up hostname, port, and database. If everything is a match, it will grab the username:password combination and see if you have rights to do what you want to do.

So if you want to set yourself up to have access to your super_whammadyne database running locally, you would pop this command into your terminal:

```
  echo "localhost:*:super_whammadyne:joe_user:secret_password" > .pgpass
  sudo chmod 0600 .pgpass
```

<p class="note">The * character means "any"</p>

That little command will create a .pgpass file for you (make sure you're currently in your home directory) and set the appropriate permissions on it so that another user can't just waltz in and steal it (that's the CHMOD part). In fact Postgres will ignore this file entirely if you didn't set permissions to 0600. Neat.

Now, when you SSH into your system and want to play with your database:

```
  psql super_whammadyne
```

Postgres will snoop your home directory for a .pgpass file. Then it will see which host you're calling in from... which in this case would be "localhost" since we've SSH'd in. We've matched up localhost, the port (since it's a wildcard), and the database name - now Postgres will try to login using "joe_user" and "secret_password" - and it will work nicely.

This works for DB interactions using the psql shell - but you can use it to do other things ... assuming you have rights. Like back your stuff up!
  
## Running pg_dump with Rake

Let's assume you have an Amazon S3 account and you want to use it to back up your Rails app. There are a number of ways to do this - but one way I like is using Ruby and Rake since I can use the aws-s3 gem to talk to Amazon.

First thing to do is create a task for this (assuming you're in the root of your Rails app):

```
  mkdir lib/tasks/backup.rake
```

Next, in your Gemfile make sure you add references to the "aws-s3" gem, and the "zip" gem. We're going to Zip our DB up and push it to S3 every night:

```ruby
  gem 'aws-s3'
  gem 'zip'
```

Now, let's create the Rake task:

```ruby
  desc "PG Backup"
  namespace :pg do
    task :backup => [:environment] do
      #stamp the filename
      datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")    
      
      #drop it in the db/backups directory temporarily
      backup_file = "# {RAILS_ROOT}/db/backups/db_name_# {datestamp}_dump.sql.gz" 
      
      #dump the backup and zip it up
      sh "pg_dump -h localhost -U joe_user super_whammadyne | gzip -c > # {backup_file}"     
              
      send_to_amazon backup_file
      #remove the file on completion so we don't clog up our app
      File.delete backup_file
    end
  end
```

All in all a pretty straightforward operation. But what about pushing to Amazon? That's in the send_to_amazon method:


```
  def send_to_amazon(file_path)
    bucket = "db-backups"
    file_name = File.basename(file_path)
    AWS::S3::Base.establish_connection!(:access_key_id => 'YOUR KEY',:secret_access_key => 'YOUR SECRET')
    #push the file up
    AWS::S3::S3Object.store(file_name,File.open("# {file_path}"),bucket)
  end
```

And your done.
  
## Run It Nightly

We're using Linux, which means that at some point we'll have to put our rubber gloves on and stick our fist deep inside Cron. Some people like it, some don't. I'm the don't people.
.note
There's also the [whenever gem](https://github.com/javan/whenever) that's a gift from above when it comes to working with Cron and Rails. I love it and you can use it easily to run this backup. I'm going to show you the hard way :).

SSH into your server and open up Cron:

```
  crontab -l
```

If you don't know what "cron" is or does, it's simply a text-based set of rules for running periodic tasks. The incantations can be a bit opaque - so if you can use Whenever to write this for you, you'll be better off.

You might have one or more cron tasks in there already - make sure you don't mess them up :). These tasks are user-specific, so you won't mess up any system ones, but take care if you see something else in there.

OK - now let's open up crontab and edit it:

```
  crontab -e
```

The lovely VI terminal should open up in front of your loving eyes. Now we get to enter our incantation:

```
  0 0 * * * /bin/bash -l -c 'cd /home/joe_user/web_app/current && RAILS_ENV=production rake pg:backup --silent'
```

<p class="note">
If you're running VI and you're completely lost here - hit "I" to insert text then past, or copy in, the command above. When you're done hit "escape", then enter ":x" to give the command to save and exit.
</p>

This command tells Linux to run a command at midnight (0 minutes, 0 hours - or 0:00) every day of the month, every month, every day of the week (the wildcards) and then gives it the command to execute. Which in our case is changing into our app's directory and running our rake task.

Adorable isn't it? 
