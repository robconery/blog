---
layout: post
title: "Massive: 400 Lines of Data Access Happiness"
summary: "In <a href = \"http://rob.conery.io/microsoft/the-super-dynamic-massive-freakshow\">a previous post</a> I showed some fun stuff with System.Dynamic and Data Access. I'm happy to say that I tweaked it, loved it, and pushed it to Github if you want to diddle with it. This post is a tad long and dives into Dynamics at the end - read it if you want a fun mental exercise. Otherwise the code is upfront."
date: "2011-02-16"
uuid: "qdrAC4z2-0Ljp-J2n3-MovJ-0Jo13sLK182v"
slug: "and-i-shall-call-it-massive"
categories: Database
---

![](https://blog.bigmachine.io/img/massive.jpeg)

##  It's Massive Yo

If you want to play with it - here it is: [in my Github repo.](http://github.com/robconery/massive) 

It's a single file - something you can use, change, love, explore, beat up, cuddle, and generally ignore if you feel like it. It's simple data access - just about as simple as it gets. I needed to give it a name (because if I didn't someone else would and I'm afraid of what that would be) - so I decided to call it "Massive".

It started out at 350 lines of code, and then I refactored out `WebMatrix.Data` and pushed it well over 500 until [Dave Cowart](http://twitter.com/#!/davecowart) came along and squeezed it down to a readable 400 lines. Love that! Go Open Source!

I toyed around with calling it "SubSonic 4.0" - because honestly everything I ever tried to do with SubSonic is in here. But I thought the better of it - there are a number of really great people keeping SubSonic up and running, and I don't want to be a sh** and pull the rug out.

I just pushed this as a package to NuGet - so you can grab it right from there if I've packaged it right.

![](https://blog.bigmachine.io/img/massive_nuget.png)

## Design Choice 1: No Dependencies Other Than What's In The GAC

Originally I built this thing to sit on top of WebMatrix.Data. I like that little utility, but it meant that you needed to install MVC 3 etc to be able to use this thing. In addition, WebMatrix.Data does some funky things on it's own with sealed objects (DynamicRecord being one of them).

So I decided to kick that all to the curb and make sure the entire experience pivots on System.Data.Common and System.Dynamic.ExpandoObject. There is no longer a dependency on WebMatrix.Data.

## Design Choice 2: Ridiculously Simple To Use

To work with this thing you'll need...

 - .NET 4.0
 - A Database - SQL Server, SQL CE, MySQL, PostGres - anything with a System.Data.Common Provider
 - A connection to said database in the app or web.config
 - A basic understanding and comfort level working with dynamic "stuff"
 
 Let's use Northwind - because [everyone loves this little database.](http://www.hanselman.com/blog/CommunityCallToActionNOTNorthwind.aspx)
  
Make sure you have a connection to this DB in your app or web.config - call it "northwind".

Now, let's access some data:

```csharp
public class Products:DynamicModel {
    public Products():base("northwind") {
        PrimaryKeyField = "ProductID";
    }
}
```

I could name this class "Steve" if I wanted to  - but I'm using convention here and naming the class the same as the table. If I wanted to change the table name I would set the "TableName" property right under the PrimaryKeyField property.

Now we're ready to roll:

```csharp
var tbl = new Products();
var products = tbl.All();
```

That's the simples thing you can do. This will send a "SELECT * FROM Products" SQL call to the Database. From there a DbDataReader will be kicked up. Massive rolls over the reader, pushing the values into an IList - that "dynamic" being an ExpandoObject.

## Design Choice 3: Close To The Metal


Let's face it - no one likes writing SQL, yet we've sort of failed to abstract that dislike effectively. Spend some time with EntityFramework, NHibernate, or SubSonic and pretty soon you'll be wondering how/why/WTF with the SQL that these tools generate.

In other words: you need to know it anyway, or [your dickhead DBA :)](http://datachomp.com) will crawl right into your dark happy spot and make life miserable for you (OK Rob Sullivan isn't all that bad - I just like to poke fun :).

There's no better DSL for working with databases than SQL. It's concise, it's powerful, it's here to stay. I love the whole NoSQL thing and I wish that we could embrace it and move on. A guy can dream.

Anyway - you can work with any WHERE statement you like - just send it in as a named argument (same with OrderBy and Limit):

```csharp
var tbl = new Products();
var products = tbl.All(where: "CategoryID = 5 AND UnitPrice > 20", orderBy: "ProductName", limit: 20);
```

A few folks have noted that this represents a SQL Injection vulnerability. In truth ... well it doesn't since I'm not concatenating anything here - BUT the point is made that parameters are a good way to go. And indeed - Massive uses parameters:

```csharp
var tbl = new Products();
var products = tbl.All(where: "CategoryID = @0 AND UnitPrice > @1", orderBy: "ProductName", limit: 20, args: 5,20);
```

You can also sidestep, completely, the entire abstraction (hurrah!), and revel in the beautiful simplicity of your soiled code:

```csharp
var tbl = new Products();
var stuff = tbl.Query(@"SELECT ProductName, CategoryName from Products 
INNER JOIN Categories ON CategoryID = Products.CategoryID");
```

It all comes back as dynamic - so you can loop and pull ProductName and CategoryName as properties, strongly typed, and get on with your work.

## Design Choice 4: Working With Data Should Be Easy and Transactionable

One of the main reasons I moved off of WebMatrix.Data is because I couldn't get at the DbCommands that it spun up for each call. I wanted to grab those commands so I could work with multiple objects within a transaction. More on that in a second - for now, you can insert a new record like this:

```csharp
var tbl = new Products();
//Insert() will return the new ID
var newID = tbl.Insert(new {ProductName = "Steve", UnitPrice = 10.50});
```

This is using an Anonymous Object declaration - but you can also do this if you're using a web site:

```csharp
var tbl = new Products();
// Be sure to have a white list check that prevents over-posting!
var newID = tbl.Insert(Request.Form);
```

Update works in much the same way:

```csharp
var tbl = new Products();
tbl.Update(new {ProductName = "Cheesy Poofs", 12});
```

The same rules apply with form posts as well. To delete, you just do "tbl.Delete(12);" or "tbl.Delete('WHERE CategoryID = 5');".

With the move to System.Data.Common as the core rather than WebMatrix.Data, you can now do this:

```csharp
var tbl = new Products();
var products = tbl.All(where: "CategoryID = 5")
foreach(var item in products){item.CategoryID = 6;}
tbl.UpdateMany(products);
```

This will pull the records out (which are ExpandoObjects) with CategoryID of 5, set it to 6, and push the records back into the database within a transaction.

## Dynamics: Let's Talk About This For a Second

I know there are a number of people that don't care much for the dynamic bits coming in C# 4 - or regard them as a novelty. You lose intellisense with them and it's scary hippy code. This is a foundational change to C# - a language that has always relied on static typing and a compiler safety net - and as such can be a bit scary.

Stay with me a bit here. Relying on System.Dynamic has allowed me to remove about 95% of the cruft that would otherwise fill in this tiny little tool. It's 400 lines of code and does everything most other data access tools can do.

The secret sauce is the ExpandoObject. Everything that goes in and everything that comes out of Massive is an Expando - which allows you to do whatever you want with it. At it's core, an ExpandoObject is just an IDictionary - check it out - this is how I roll in the IDataReader from the database:

```csharp
/// 
/// Turns an IDataReader to a Dynamic list of things
///
public static List ToExpandoList(this IDataReader rdr) {
   var result = new List();
   //work with the Expando as a Dictionary
   while (rdr.Read()) {
       dynamic e = new ExpandoObject();
       var d = e as IDictionary;
       for (int i = 0; i 
```

You can cast your ExpandoObject as an IDictionary and work with it quite simply. There's no reflection required - it's actually quite fast.

It might be tempting to think that there's a ton of reflection going on here, which is bad for performance - but that's not the case. We're simply working with an IDictionary and getting away from the casting/boxxing/unboxxing craziness that dominates most data access code.

For instance - how many times have you had to wrestle with short vs. long? Decimal vs. Double? Guid vs. String? Me too - it's no fun when it bites you. You can forget all that with System.Dynamic (well, for the most part) - the DLR will do it's best to work with the CLR and coerce the type you need, WHEN you need it.

If I pull out a single product:

```csharp
var tbl = new Products();
var product = tbl.Single();
var price = product.UnitPrice.ToString("C");
```

The "price" variable there will be typed - but how is that type decided? It's already been decided by System.Data - a translation has happened when the query went off where the Database type was pushed to a System.Type - in this case a System.Decimal. If you type "product.UnitPrice.GetType()" into the Immediate Window in VS - you'll see this.

This is confusing, to say the least. If you've made it this far you'll either be viewing this as a curiosity or as something incredibly annoying. Stay with me.

When you use "var" you're essentially asking for a type to be figured out right then and there. The following, for example, won't work:

```csharp
var notReallyDynamic = new ExpandoObject();
notReallyDynamic.FictionalProperty = "Steve";
```

You'll get a Typing error - saying that "ExpandoObject does not contain a definition for FictionalProperty" - which makes no sense at all. The Expando isn't SUPPOSED TO.

But - if you use the "dynamic" keyword - you essentially tell the compiler you're going to be playing with a different set of rules:

```csharp
dynamic yesReallyDynamic = new ExpandoObject();
yesReallyDynamic.FictionalProperty = "Steve";
```

As Skeet would say: "Hurrah and Jolly Well Done!" So why am I going off on this? Because there's a curiosity at work here - something you'll need to understand if you're going to use Massive, and something that I think is actually kind of interesting.

If using "var" with an ExpandoObject takes the dynamic wind out of its sails - how then are we able to use "var" in this code:

```csharp
var tbl = new Products();
var product = tbl.Single();
var price = product.UnitPrice.ToString("C");
```

Here's the answer, and it's going to make your head hurt: **if you tell "var" that it's dynamic, everything's OK.**

I can hear you know: "WTF?!?!?!" Let's see if I can explain this.

The method "tbl.Single()" returns "dynamic" - NOT an ExpandoObject - "dynamic". A lot of people confuse the "dynamic" keyword to be synonymous with "var", but for dynamic stuff. That's not the case - it's a catch-all for anything and any dynamic type in System.Dynamic. It's a Voodoo Jedi Mind trick from Cthulu himself:

```csharp
/// 
/// Returns a single row from the database
///
/// 
ExpandoObject
public dynamic Single(object key) {
    var sql = string.Format("SELECT * FROM {0} WHERE {1} = @0", TableName, PrimaryKeyField);
    return Query(sql, key).FirstOrDefault();
}
```

Now I could have returned ExpandoObject here - but doing that would mean that all the code that uses "var" to pull a Single() record out would break - in the same way that using "var" with the ExpandoObject above broke - and you would be sad (me too).

## Thanks For The Lecture - Why Do I Care Again?

Good question. What if we worked up an object called "DynamicRequest" for our web site that looked something like this:

```csharp
/// 
/// A class that you can use to access HttpContext.Request a little easier
///
public class DynamicRequest: DynamicObject
{
    public override bool TryGetMember(GetMemberBinder binder, out object result) {
        string key = binder.Name;
        result = HttpContext.Current.Request[key] ?? "";

        return true;
    }
}
```

This is the equivalent of "MethodMissing" in Ruby and allows you work work with HttpContext.Request as if it were a regular old object.

In WebMatrix (or MS WebPages/Razor) - you can set this as a property on the Page object, which itself is dynamic. In _PageStart.cshtml (which gets called before every request to a page in that directory) you could initialize this little pretty:

```csharp
@{
  Page.Post = new DynamicRequest();
}
```

This is where it gets fun. On your Razor page (let's call it "Submit.cshtml") you can now do this:

```csharp
@{
  if(IsPost){
    var tbl = new Products()
    //as many of you will certainly point out - some type of whitelist should be implemented
    //to avoid over-posting.
    tbl.Insert(Page.Post)
  }
}
```

Given that we're using nothing but dynamic, Page.Post might as well be a Product as far as Massive is concerned. Types are out the window, so is the pain of working with them.

"But wait!" you say, "I don't understand because you can already use a NameValueCollection in your Insert() statement! Why is this such a cool thing?". GREAT question - the answer is because I can refactor this how I please, without touching the receiving code:

```csharp
@{
  if(IsPost){
    var tbl = new Products()
    dynamic product = new ExpandoObject();
    
    //let's White list this!
    product.ProductName = Request["ProductName"];
    product.UnitPrice = Request["UnitPrice"];

    tbl.Insert(product)
  }
}
```

Refactoring that was pretty darn simple wasn't it? Moreover - what's missing from the setting of the UnitPrice? CORRECT! Coercing it into a Decimal! Hey dynamics aren't so bad are they :).

## An Open Call For FUD


I know a number of people don't like Dynamics and they're tired of learning Yet Another Shiney New Whatever. All the old arguments apply, and people's noses will get out of joint. This is all good - it's part of the natural order that keeps dorks like me from jumping at Every New Sexxy Thing while at the same time adding some spice the dreck of the same old same old Data Access Story.

So, this is where you get to rev up your fear of how the horrible dev who works down the hall from you will utterly destroy all common sense, black goo dripping from the eyes of the innocent etc.

The short answer to that conundrum is that you're paying your dues. We've had to live with your crappy code, just as others have had to live with mine :). They took the time to educate me just as someone took the time to educate you. Time to pay it forward :).

In all seriousness :) I'd love to hear any thoughts you might have, positive or negative - but do me the courtesy of illustrating your thoughts with details rather than attacking me and my happiness with New and Shiney.