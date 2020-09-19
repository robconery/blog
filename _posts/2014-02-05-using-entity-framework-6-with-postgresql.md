---
layout: post
title: 'Using Entity Framework 6 with PostgreSQL'
image: '/img/MadScientist.jpg'
comments: false
categories: 
  - Postgres 
  - Microsoft
summary: Postgres is an amazing database and you can EF with it, sort of. If you want to explore something new and have some fun - read on.
comments: true
---


## You Can Do It, Yes You Can... But...

This post is about exploring things and maybe trying something new. This isn't a production-grade solution because, frankly, it's slow and SQL Server is built into the bones of Entity Framework. Swimming upstream is no fun.

BUT! **This is the essence of hacking** - trying to get something to work in a way that it wasn't designed to. So... get your goggles on and prepare the rubber room... here we go...


## Step 1: Install Postgres

Since we're working with EF I'm assuming you're on Windows - [so head on over to postgresql.org](http://www.postgresql.org/download/windows/) and download the latest version. 9.4 isn't due out until Q3 2014 so you'll probably be downloading 9.3.

Run the installer and reflect on [installing SQL Server](http://msdn.microsoft.com/en-us/library/ms143219.aspx). Even if you used Web PI to install express... it takes a while. Make sure you remember your passwords for the root user "postgres" - you'll need this later on.

## Step 2: Create a Database

You should have a GUI tool installed for administering Postgres called "pgAdmin III" - just hit the Windows key and type "pg" and you should see it. It leaves a bit to be desired - but we'll fix that in just a bit. Open it up and poke around - much of this will look foreign to you but as soon as you navigate around a bit, you'll know what's going on.

For now, just double click your server and right-click on "Login Roles" - set one for yourself, and then in the "Role Privileges" tab give yourself access to everything.

Next, close the Roles window and right-click on "Databases", select "New Database" and create one called "petstore", setting your new login as the owner. Yeah... petstore... why not.

![Postgres Database Window](/img/pg_databases.png)

Close it up - you're done.

## Tangent: Tooling

If you haven't used postgres I know you're underwhelmed right now... I would be too. I normally use the command line (psql) as I've learned the commands and find it very useful - but I know that can be a hard sell.

We're at the point where we need to create some tables, and **EF does not support migrations or code-first creation with Postgres**. Or, rather, it _does_ but you need to have a custom SQL generator to do it.

There are some out there - but I'd rather do something a bit different. In the Node/Rails/Python/Everywhere Other Than .NET worlds, Postgres is widely used. Many times you'll see multiple tools used in a single project - Rakefiles in Node projects or Gruntfiles with Rails.

That's what I'm going to do next - I like the simplicity and utility of Node and I think you will too. I hope.

## Step 3: Migrations

There are a number of migration projects out there for .NET. I've written some myself - but they're all a bit complicated. I love the simplicity of Javascript for this so let's try something new.

[Install Node if you haven't](http://nodejs.org), and if you haven't had a chance to play with Node - today's the day!

Now, let's open Visual Studio and create a simple console application - call it what you will. Crack open NuGet and add in:

 - EntityFramework
 - Npgsql (the .NET driver for Postgres)
 - Npgsql.EntityFramework (the EF provider)

Next, go to Tools/Extensions and Updates and find "dotConnect Express for PostgreSQL". This is very nice, free driver for Postgres that will allow us to hook up to Visual Studio - we'll do that in a minute.

![dotConnect for PG](/img/dotconnect.png)

Now let's open up the Package Manager Console in Visual Studio - it's time to work with Node. We want to install the tools we'll be using to migrate our database. The first is `db-migrate` - [a really useful utility](https://github.com/kunklejr/node-db-migrate) that does one thing well: migrate your DB.

```sh
npm install db-migrate -g
```

`db-migrate` is an executable so we need to be sure we can access it from our command line in the Package Manager Console - so we'll install it globally - thus the `-g` flag above.

Let's to the same thing with the Node postgres driver:

```sh
npm install pg -g
```

_If you get an error about "node-gyp" this is because it wants to use Python to compile some optimizations - you can ignore this._

Now we need to setup our database config - flip over to Visual Studio and create a file in the root of your project called "database.json". In this file we can add some connection info:

```json
{
  "dev": "postgres://rob:password@localhost/petstore",
  
  "test": {
    "driver": "sqlite3",
    "filename": ":memory:"
  },
  
  "prod": {
    "driver": "pg",
    "user": "joe",
    "password": "toottoot",
    "database": "petstore"
  }
}
```

Two nice things about this - you can separate connections based on environment, and you can be flexible in terms of connection string format. The one I'm using (`dev`) is a nice, concise format that's easy to remember - just replace "rob" and "password" with the login you created.

Now let's run it!

```sh
db-migrate create monkey
```

Now head over to Visual Studio and "Show All Files" - you should see a new directory call "migrations" with a file in there, like this:

![migrations](/img/db-migrations.png)

Now open it up and take a look at the familiar "up" and "down" functions. Let's fill those out with the examples from the [Github repo](https://github.com/kunklejr/node-db-migrate) with one minor change - I want my key to be of type "serial", which is how you setup auto-incrementing keys in Postgres:

```javascript
exports.up = function (db, callback) {
  db.createTable('pets', {
    id: { type: 'serial', primaryKey: true },
    name: 'string'
  }, callback);
};

exports.down = function (db, callback) {
  db.dropTable('pets', callback);
};
```

Save the file, and let's migrate!

```sh
db-migrate up
```

If you get an error here that says "Can't find module database.json" it's because you're a) not running in the same directory as your database.json file or b) you have a JSON error.

Wahoo! Migrated!

Now let's take a look at our handiwork in Visual Studio. Open up the Server Explorer and right click on "Data Connections". You'll see the familiar dialog for DB credentials - but here you want to change the driver from Microsoft SQL Server to "PostgreSQL". Click the "Change" button and select "PostgreSQL".

You can see this selection here because you installed the dotConnect Express tool above. If you don't see Postgres as an option - the install went wrong.

Set your connection information up, and test the connection. It should look like this:

![Connecting to Postgres](/img/dotconnect-connection.png)

You'll notice that you can query and browse data, but not much else. This is because the Express version is limited - if you upgrade you get all kinds of goodness... still cheaper then SQL Server. I don't use this tool... I just use Npgsql myself.


## Setting up EF

Believe it or not - this is the easy part! Flip back over to Visual Studio and confirm that you have EF installed from Nuget. Now, let's configure our App.config:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <configSections>
    <!-- For more information on Entity Framework configuration, visit http://go.microsoft.com/fwlink/?LinkID=237468 -->
    <section name="entityFramework" type="System.Data.Entity.Internal.ConfigFile.EntityFrameworkSection, EntityFramework, Version=6.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" requirePermission="false" />
  </configSections>
  <startup>
    <supportedRuntime version="v4.0" sku=".NETFramework,Version=v4.5" />
  </startup>
    <system.data>
        <DbProviderFactories>
            <add name="Npgsql Data Provider"
                  invariant="Npgsql"
                  description="Data Provider for PostgreSQL"
                  type="Npgsql.NpgsqlFactory, Npgsql" />
        </DbProviderFactories>
    </system.data>
    <connectionStrings>
        <add name ="MonkeyFist" connectionString="server=localhost;user id=rob;password=password;database=petstore" providerName="Npgsql"/>
    </connectionStrings>
  <entityFramework>
    <defaultConnectionFactory type="System.Data.Entity.Infrastructure.SqlConnectionFactory, EntityFramework" />
    <providers>
      <provider invariantName="Npgsql" type="Npgsql.NpgsqlServices, Npgsql.EntityFramework" />
    </providers>
  </entityFramework>
</configuration>
```

Two things to note here - the first is that we needed to add a Provider to the DbProviderFactories (Oh I just love saying that out loud). Next, we needed to tell Entity Framework to use the Npgsql provider that we installed. Not all that much wiring... 

Finally I added a connection string pointing to my PG database (be sure to set your password as needed).

OK let's write some code already!

## Querying with EF

Let's drop in some code for accessing our data. We need the usual thing - a Context and a Class:

```csharp
[Table("pets",Schema="public")]
public class Pet{
  [Key]
  [Column("id")]
  public int ID { get; set; }
  [Column("name")]
  public string Name { get; set; }
}
public class DB : DbContext {
  public DB(): base(nameOrConnectionString: "MonkeyFist") {}
  public DbSet<Pet> Pets { get; set; }
}
```

I had to make a few concessions here because I'm working with Postgres. The first is that I needed to tell EF to use "public" instead of "dbo", which is ridiculous. Postgres is case-sensitive by default, so I also needed to tell EF column names and table names - as well as the primary key.

A bit of a bummer, but it's nice that I can do that.

The DbContext is nothing scary - I just pass in the connection string name here and we're set.

Now let's run it!

```csharp
  class Program {
    static void Main(string[] args) {

      var db = new DB();

      var pet = new Pet { ID = 1, Name = "Stevie" };
      db.Pets.Add(pet);
      db.SaveChanges();

      var pets = db.Pets;
      foreach (var p in pets) {
        Console.WriteLine(p.Name);
      }
      Console.Read();
    }
  }
```


And that should pop up a console for you:

![Stevie](/img/stevie.png)

## Final Thoughts

So, would I ever do this? **Nope.** Well, that's not exactly true - I love using Node to help out with projects, Grunt (or Gulp) in particular. I really like the way migrations work here as well - so yes I'd use that.

But EF is a monster. If you're not using SQL Server all kinds of fun little things pop up to trip you - such as the way I got to decorate my class above with all kinds of lovely attributes.

It's also a bit slow, for some reason. I know this isn't LINQ, and I know it's not the driver - for the last week I've been playing around with ... shall we say a fun little library that might see the light of day. It's super fast and uses LINQ against Postgres (with Unit of Work even!).

All the same, this is a fun exercise if only to investigate new things. Might not be ready for prime time, but if it helps you to try new things and gets your mind fired up, yay!


