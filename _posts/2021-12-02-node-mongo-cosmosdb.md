---
layout: post
featured: true
title: "Deploying Node and Mongo to Azure Using AZX"
image: '/img/azx-node-mongo-cosmos.jpg'
summary: "Over the holidays I decided I wanted to see if I could improve the Node/Cosmos DB provisioning and deploymment story with AZX. In short: yes, I can."
categories:
  - Azure
  - Fun
  - AZX
---

I’m going through a number of deployment stories with [my little CLI experiment, AZX](https://github.com/robconery/azx). I’ve been focused *solely* on the non-MS developer experience, which means Python, Ruby, Node, etc. Up until now, I’ve been using Postgres as a database (as one should), but I also know that Mongo DB has a massive following - so I decided to focus on that for this latest experiment, specifically with respect to Node.

## Using Cosmos DB Instead of Mongo DB

Azure doesn’t do hosted/managed Mongo DB. Instead, you can work with Cosmos DB using the Mongo DB toolset. When I first learned about this I was confused - I never thought of Cosmos DB as a document store, but [it’s a thing](https://docs.microsoft.com/en-us/azure/cosmos-db/mongodb/mongodb-introduction):

> The Azure Cosmos DB API for MongoDB makes it easy to use Cosmos DB as if it were a MongoDB database. You can leverage your MongoDB experience and continue to use your favorite MongoDB drivers, SDKs, and tools by pointing your application to the API for MongoDB account's connection string.

Cosmos DB is kind of weird this way: *you can work with it using multiple APIs*. The most popular is the SQL API, which allows you to work with it using SQL in the same way you might with a relational database (though it's not relational, it's strictly JSON). There’s also a Cassandra API which makes Cosmos behave as if it were a column store and the Table API, which makes it behave like a key/value store. Wild stuff.

I was intrigued by this so I decided to push Cosmos DB a bit *while also* working on a deployment scenario for AZX. 

## My Node/Mongo App

The first step was to find a sample app that did more than a todo list. I couldn’t find one so I made what I consider to be [a reasonable “starter” site](https://github.com/robconery/node-mongo-start) - something I would use in the future. It has:

- **Tailwind** CSS with the [free starter kit from Creative Tim](https://demos.creative-tim.com/notus-js). Just gorgeous stuff.
- **Authentication** using OAuth (Google and Github) and Magic Links.
- **Email** capability using Nodemailer
- Site-wide **notification system** using flash and Toastr
- Basic modeling using **Mongoose**
- As few of my opinions as possible

Those last two points go together. If you know me, you know [I dislike ORMs](https://rob.conery.io/2015/02/21/its-time-to-get-over-that-stored-procedure-aversion-you-have/) tremendously and you also know that I haven’t, historically, been a big fan of Mongo DB. I do know that it’s used a lot and it’s improved a lot over the years… so I decided to get over myself and get to work.

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638473138607_bip_43.jpg)

## Provisioning Resources

As I mention, I’m using my little CLI experiment, [AZX](https://github.com/robconery/azx), to provision the Azure resources I’ll need for this. If you want to play along, you can:

```sh
npm install -g @robconery/azx
```

Step one is to intitialize the project:

```sh
azx init
```

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638474000174_bip_44.png)


So far, so good. A resource group was created for me (which I think of as a “project” with a generated name. A settings folder (`.azure`) was also created. The next step is to provision the App Service and friends:

```sh
azx app create node
```

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638474138030_bip_46.jpg)

I went over this output in detail in [my previous post](https://rob.conery.io/2021/11/19/a-simpler-way-to-azure/), but to quickly summarize:

- Many knobs were twiddled at Azure. A “plan” was created as well as a web application, sensible logging was turned on and deployment credentials created.
- A local Git remote called “azure” was created with your new deployment credentials and added to your local Git repo for you.
- AZX tried to use the free Linux tier (F1), which is a sensible first step, but as you can see my account isn’t eligible as I already have one of those, so the next level up, B1, was used.

The goal with AZX is to decrease the cognitive load when it comes to working with Azure *while not* backing you into some kind of opinionated corner. You can change any and all of this if and when you need.
Right then… next step is to provision Cosmos DB:

```sh
azx db create mongo
```

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638474452085_bip_47.jpg)


Once again, AZX tried to opt in to the free tier of Cosmos DB ([yes, there is one](https://docs.microsoft.com/en-us/azure/cosmos-db/free-tier)) but since I already have one a regular Cosmos server was created for me.

AZX also queried Azure for the access keys and created the connection string for me, popping it locally into `.azure/.env` which, yes, is guarded by a `.gitignore` so it doesn’t get added to source control.
I can now connect to Cosmos DB using the Mongo DB client:

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638474983299_bip_50.jpg)


I think that’s pretty slick!

## Updating Azure Configuration

Every application will have some kind of environmental configuration, which usually includes a database connection string but can also contain, like mine does, 3rd party access keys.
Specifically: I’m using OAuth for authentication and I’m also using email, which means I need to have SMTP credentials for NodeMailer.

To make this easy, I can add these settings to my `.azure/.env` file:

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638474799098_bip_48.jpg)


The `DATABASE_URL` was already in there, so I didn’t need to change it. Now I can ask AZX to push these settings to Azure:

```sh
azx app write_settings
```

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638474901839_bip_49.jpg)

This command reached out to Azure, specifically my web application's configuration, and added all of the values in my .env file as configuration settings. Easy peasy!

All in all this process took about 5 minutes. We’re not quite there yet as we need to deploy our application, which I can do using Git directly:

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638475039740_bip_51.jpg)

My deployment credentials are stored in my remote connection string, so all I need do is use `git push azure master` (or main, depending) and up it goes.

This process takes about 2 minutes to complete, but when it’s done:

```sh
azx app open
```

And up pops a browser after a 30 second spin up:

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638475144411_bip_43.jpg)


I clocked just over 8 minutes total on this process, which I think is pretty neat. The big test, though, is whether I’ll be able to access Cosmos DB and login. Let’s try it!

I don’t have an account on the site, but I can create one by going to the registration page:

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638475264677_bip_53.jpg)


Once I click “register”, I get this notice:

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638475307097_bip_54.jpg)


It’s a little smushed in there because I collapsed the window - but you can see at the top there’s a blue box that confirms an email is on its way to me. This is [Toastr](https://johnpapa.net/toastr100beta/#:~:text=toastr%20is%20a%20simple%20JavaScript,toastr.), something my colleague John Papa helped create. It’s wired into `express-flash` and will pop open if there’s a message to be shown.

Checking my email, I have a link!

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638475493852_bip_55.jpg)

I know a few people who don’t like the whole magic link thing, but as a site owner I *really like it*. No storing passwords at all and, as a bonus, you get 2FA and email verification.
Clicking on that link I’m taken back to the site where I’m logged in:

![](https://paper-attachments.dropbox.com/s_3AAE70EFA8602A8C9CD5ED6DB9E53DAEFBD7B03A9AC4C298AF090CEEFEA60F18_1638475692916_bip_56.jpg)


I’m also shown a nice “welcome back” message - but I wasn’t quick enough with my screenshot to get it.

## So What's This All About, Anyway?

I like [this little starter app](https://github.com/robconery/node-mongo-start) - I’ve been having lots of fun with it and if you want to help build it out, please do. It’s likely a little rough around the edges as I made it in a short period of time, but I’ll keep improving it. I do think it can be useful for people learning Node who might need a leg up on their project.

What would be extra double-secret-probation fun is if you tried to deploy it to Azure to see if you could break something. Instructions are in the README.

Finally - there is a lot of interest internally at Microsoft regarding a more comprehensive developer-focused experience. That’s why I made AZX, as a thought experiment that I hoped would generate feedback. If you have some, please do [hit me up on Twitter](https://twitter.com/robconery).

It's not my intention to create a full-blown toolset here, **this is just a thought experiment**. I'm hoping to help the internal teams as much as I can, and that's about all.

Hope you have some fun!

