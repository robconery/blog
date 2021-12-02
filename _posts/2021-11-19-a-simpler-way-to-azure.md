---
layout: post
title: "A Simpler Way to Azure"
image: '/img/azx_init.jpg'
summary: "I have loved working with Heroku for years and have long wished Azure had a similar offering. Many people have tried this, here's my effort."
categories:
  - Azure
  - Fun
  - AZX
---

**TL;DR:** [I made a fun CLI “wrapper”](https://github.com/robconery/azx) for working with web apps and Azure in a very Heroku way. It’s called “AZX” and you can read a full walkthrough and installation instructions from the GitHub repo.

One of my jobs at Microsoft is to help product teams understand how developers work in other ecosystems. In other words: *places other than the .NET/Azure world*. That’s a pretty big place, so I’ve decided to stay focused on an experience I love: [Heroku](https://heroku.com).

I’ve used Heroku for years and years and love the simplicity. You can do similar things nowadays with AWS, DigitalOcean, Netlify and yes, even Azure. The whole idea of `git push` deployment is pretty standard - in fact it’s kind of passé.

Either way, the experience that Heroku pioneered is still compelling. Once you install the CLI and login you simply:

- Create a project locally with `heroku create`
- Work on your app and when you’re ready
- Deploy your app using Git: `git push heroku main`

That’s it. Heroku will “guess” what stack it needs to use, provision a set of free resources for it, and before you know it you’re up and running.

## Scaling With You

Of course applications are much more complex than that. You’d likely want a database, a cache of some kind (like Redis), more capable logging and so on. You’re also going to quickly outgrow the free tier - and this, to me, is what’s super groovy about Heroku: *it’s there with you for all of this.*

When you want to scale things up you can use `heroku ps:scale web=1` from your local dev directory and boom, you’re scaled. To add better logging you simply `heroku addons:create papertrail`.

Adding a database, such as PostgreSQL (because… why wouldn’t you?) you need to look up the plan name you want and then `heroku addons:create heroku-postgresql:<PLAN_NAME> --version=12`. 

The fun part is that everything is configured and wired for you on the back end - there’s nothing you need to do aside from make sure you use “conventional” environment variables (like `DATABASE_URL`, `REDIS_URL` etc).

You can access all of these resources locally with the `heroku` tool. For instance, to read your logs you can `heroku addons:open papertrail` and there are your app logs!
Cool service - and it got me wondering how difficult would it be to do this with Azure?

## A Rite of Passage

I told Burke Holland my idea and he started laughing and quipped:

> I think that’s a rite of passage here at Microsoft - everyone wants to create a Heroku clone!

Fair enough! _Challenge accepted_. 

To be honest I never thought this would see the light of day but my fellow friends in Cloud Advocacy pushed me to open it up, so here goes.

## A Localized Azure Experience

The idea with this project is straightforward: *let’s bring Azure to you instead of you to Azure*. The Azure CLI is outstanding but, if I’m honest, it’s aimed at IT people and not developers. The good news is that, with a little love and imagination, you can leverage the CLI and have a little magic happen. Let’s see…

I have a local Python application, the Tailwind Starter site that I’ve been working on and I want to get it up and live on Azure. I’ve installed `azx` using NPM:

```sh
    npm install -g @robconery/azx
```

I then head into my project directory and run `azx`:

```sh
    cd ~/Tailwind
    azx
```

This will display the help screen:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637349323822_bip_17.png)


AZX is seeing that there’s no local settings file, which would be saved in `.azure` so it’s telling me what choices I have at this point and offering me a tip. My goal with this is to decrease the cognitive load that comes with something as complex as Azure (or any cloud service). 

Here, we have 3 choices:

- `init` which creates our project
- `get` which will load an existing project (more on that in a minute) and
- `lookup` which provides supporting information like regions, runtime names and SKUs.

That’s it - and I love the sparseness of it. Let’s keep rolling by creating our project.

## Creating an Azure Project

An “Azure project” is something I made up - it’s not an Azure term. To create one, we just need to run `azx init`:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637349603238_bip_18.png)


Running `azx init` does a couple of things, most notably:

 - It creates a “Resource Group” on Azure for us, which is a virtual “bucket” for all the Azure stuff we’ll be creating for this project.
 - It decides a name for us because naming is hard. You can override this if you want, but I like Heroku’s way of doing this - it keeps things simple.
 - Our local project settings directory, `.azure` is created and in it is a JSON file with our project settings. We’ll see that in a minute.

Notice also that we’re given a tip about what to do next: `azx app create`. That wasn’t a choice before, but it is now:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637349831023_bip_19.png)


Another example of keeping the cognitive load to a minimum - it just doesn’t make sense to show a command choice if you can’t run that command, which we couldn’t before. Now that we have a project, we can setup our application on Azure.

## Setting Up Our App Service

Each subcommand, just like the Azure CLI, has a help screen dedicated to it. If we run `azx app create` `--``help` we’ll see that we have only one command available to us: `azx app create <runtime>`. Once again, this is by design.

Following our tip, we can now create setup where our app is going to live on Azure. If we don’t know the runtime choice to enter we can ask the CLI by using `azx lookup runtimes` and we’ll see a list. In my case I need `azx app create python` because I’m using Django:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637350082952_bip_20.png)


A bunch of goodness happened here:

 - An App Service “Plan” was created and you’re told that this is basically a VM. It tried to create a free one as a logical first step but couldn’t because my account is limited to only 1 free (F1) App Service. You don’t care about any of that - so AZX just set it up for you. All of this can be overridden by specifying `--sku`.
 - The location of the App Service, something you normally need to specify, was set to `West US` by default. You can override that too - but if you’re kicking the tires on Azure … why think about this stuff?
 - A web application, on Azure, was created with local Git deployment - meaning you can `git push` just like with Heroku. This can be changed, easily, later on.
 - Comprehensive logging was set up, which is not turned on by default.
 - Deployment credentials were created for you using a random name and a GUID for a password. These credentials were added to your local Git repository under the `azure` remote.

That’s a lot of stuff you would have needed to understand before deploying your application. It’s a good idea to understand it at some point, but often if you’re coming to a service for the first time, it’s kind of nice if you don’t have to fiddle with every knob. In our case, a lot of this stuff is basic (like logging) and can just be turned on.
Notice that we’re given another tip - how to set up our database. We didn’t have an `azx db` choice before, but now we do because we have an application!

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637350578603_bip_21.png)

## Setting Up the Database

We have three choices (as of now) for databases: PostgreSQL (the correct choice), MySQL or Mongo DB (which is actually Cosmos DB using the Mongo DB driver). As you might expect, my database will be PostgreSQL.

To set that up, we can follow the tip that you see there at the top of the help screen. Notice that, just above the tip, we can see the basic description of our application. We see the name (cold-dust-76) and also that it’s a web application.

Let’s push on and create the database using `azx db create postgres`. If we wanted to know more about our choices we could use `azx db create` `--``help` and see that the only choice we have is to create a database with the specified engine.
Off we go…

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637350862052_bip_22.png)


This takes a few minutes to run and you’re told that straight off. On average, provisioning a PostgreSQL server takes about 3-4 minutes. Cosmos DB takes a bit longer - up to 6 minutes - but the nice thing is what comes next: *all the minutiae is handled for you.* You can, if you want, get up and go for a walk or write in your bullet journal - this time is given back to you!

So, what happened here? A lot of things that would normally take you 20 clicks in the portal, or more:

 - A PostgreSQL server was created for you with a conventional name that you can override (a “-db” was added to the end of your project name).
 - A firewall rule was added so your web app can see your database. 
 - Another firewall rule was added using your local IP address so that *you* could see your database.
 - Admin credentials were created for you, which is the way (in my mind) it should be. Once again, a semi-randomized name (like `admin-451`) was used with a GUID password. These credentials were then used to construct access credentials for your application (a `DATABASE_URL`) and those credentials were added to your Azure web app configuration settings for you.
 - Those same credentials were added to a local `.env` file inside of the `.azure` directory. 

We can now access our database using `azx db connect`:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637351478083_bip_23.png)


**Note**: *this only works if you have the PostgreSQL binaries installed locally*.
From here we can, once again, follow the tip and set up our application database by sending in a SQL file. Given that we’re working with the local client binaries, we can redirect STDIN in the same way we might with `psql`:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637351597738_bip_24.png)


We’re ready to go! At this point we have about 7 total minutes elapsed. But what do we do now?

One of my main goals with this tool is to have it *help you* as much as possible, without doing too much or overloading you with concepts. The only thing you need to remember is to run `azx` when you don’t know what to do next:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637351807989_bip_25.png)


Things have changed once again, and this is because we have a database to go with our application. We have a few tips at the top - the first of which is telling us how we can deploy our application using Git. We’ll talk about scaling and other things in just a minute.

## Deployment

We have Git deployment set up and an `azure` remote has been added for us with our deployment credentials embedded in the remote URL, all that’s left to do is `git push azure master` (or `main`):

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637352040705_bip_26.png)


Off we go. What you see here is Oryx, the build tool used by Azure’s App Services. It’s received our code and, using a post-receive hook, is setting things up for us. In this case it’s a Python environment but this also works with Node and Rails, etc.

It takes a minute - for Django it takes about 4 minutes for a full deployment to happen. This is due to the project settings and packages being setup completely on the first run.
After a few minutes we’re done and, hopefully, ready to go!

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637352629414_bip_27.png)


Ready to go… where exactly? What do we do now? Hopefully at this point you get the idea: *ask AZX:*

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637352846170_bip_28.png)


Our app menu has a bunch of new choices. We can change configuration settings on Azure, scale things, look at the logs (which we’ll do in a minute) and finally `open` it! That’s what I want to do…

**Note**: *if you’re running this inside WSL you’ll get an error due to access permissions to Windows executables. If that happens, you can use* `*azx app get_settings*` *to see your app’s URL.*

It takes a few seconds to load up on first run, but here we go!

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637353058177_bip_29.png)


We’re live and our site is happily pulling data from our database. We have a problem, however, in that our images aren’t showing up for some reason. Let’s troubleshoot.

## Troubleshooting and Moving On

This CLI has gone through a few iterations and I showed it once to executive types at Microsoft, which went pretty well, but there was one very important bit of feedback:

> Helping people use Azure is great, but we need to be sure we support them into the future and not back them into the corner

Makes perfect sense. To that end, I added as much as I could to help you out as you work with your application, specifically:

 - The ability to scale your App Service up or down.
 - The ability to scale your Database Server up or down.
 - Rotating your database password (which also updates your web app).
 - Viewing your application logs.

That last is what we need now because our images aren’t showing up. Let’s see what happened using `azx app logs`:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637353465498_bip_30.png)


Doing this will `tail` the logs so you can see what’s happening realtime and, digging in, I shortly find out that I didn’t set my `STATIC_ROOT` properly so my images aren’t showing. I need to have that set for production… but how?

Let’s take a look at our web app configuration settings using `azx app get_settings`:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637353683663_bip_31.png)

What we need to do is update these settings with a `STATIC_URL` that points to a CDN somewhere that stores our images. How do we write these settings? Let’s ask AZX!

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637353833516_bip_33.png)


As I mentioned (briefly) before, a `.env` file containing all of our application secrets lives inside of our `.azure` directory. We can update that file and then save it up to Azure. Here’s what it looks like:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637353923099_bip_34.png)


All of these settings were created when our database was created and, yes, there’s a `.gitignore` file that was created as well to ensure that we don’t commit this to source control. All we need to do now is to add a setting in here for `STATIC_ROOT`:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637354131179_bip_35.png)

Now we just need to use `azx app write_settings`:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637354176096_bip_36.png)


Heading to the Azure portal to confirm:

![](https://paper-attachments.dropbox.com/s_39654B13F38E173EF27924C19AFCEC4939F6BB36F87440CDAEC9E9D9A2568BF0_1637354268783_bip_37.png)


Great! We just saved ourselves another 10 or so clicks, including restarting our App Service so these changes are picked up.

## There’s More To Do!

I’ve had tons of fun putting this project together. It was supposed to be a quick prototype but I figured it could also help someone too. There are a few more things I’d like to get done, including caching, deployment slots and more.

The main thing is that you can get to a solid point with your application and then jump over to the regular CLI or to the portal… the hard part being behind you.

