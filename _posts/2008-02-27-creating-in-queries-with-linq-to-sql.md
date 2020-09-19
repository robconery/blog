---
layout: post
title: Creating IN Queries With Linq To Sql
summary: "Props on this one go to Scott Hanselman who pulled me back from the edge of the cliff last night. I was particularly distraught in getting a MIX demo together where I had to do some queries using LINQ, and I couldn't for the life of me figure out how to fashion an IN query!"
date: "2008-02-27"
uuid: "EaSCP7m2-15Qi-fco7-zzP7-qpIUHApbtTuU"
slug: "creating-in-queries-with-linq-to-sql"
categories: Microsoft
---

Props on this one go to Scott Hanselman who pulled me back from the edge of the cliff last night. I was particularly distraught in getting a MIX demo together where I had to do some queries using LINQ, and I couldn't for the life of me figure out how to fashion an IN query! With Scott's help (and patience) I figured it out, and thought I should blog for my own reference, at least.  
   
## It Depends On What Your Definition of "IN" Is...
    

An IN query will pull back a set of results from SQL that is within a given range. This range can be set manually, or can itself be a query. So if you have an eCommerce application and you want to know what products you have in a given user's cart, you could do this (using AdventureWorks):  

```sql
SELECT * FROM Production.Product WHERE ProductID IN (SELECT ProductID FROM Sales.ShoppingCartItem WHERE ShoppingCartID='RobsCart')
```
 
This will return all the Product records that are in my cart. This is a fundamental query structure and up until today I thought, for sure, that Linq To Sql doesn't support it. I was sort of right - but not really.  
   
## LINQ Is People To (Or It's Made From People...)

It's important to remember that the people that made LINQ were trying to approximate a "SQL within Code" sort of thing - this means that they built LINQ to query just about anything, and also built a SQL Translator called Linq To Sql. They ran into limitations with trying to contort a static language structure (VB or C#) into SQL, but for the most part if you think long enough (or Skype Hanselman) you can figure it out.
  
The key here is to think "Top Down" (please, no flames...to alleviate the "Top Down" reference, I'll use LOL Cats to describe the problem statement):  

```
WTF GIMMEH CART
    
CART CAN HAZ PRODUCTS?
    
GIMMEH PRODUCTS (NOM NOM NOM)
```
If you break it down this way (and not in SQL terms as above), you can begin to see how LINQ might make a query out of this: Start with the Cart (pretend my cart is ID=75144):  

```csharp
AdventureWorks.DB db=new DB();

var itemQuery = from cartItems in db.SalesOrderDetails
                where cartItems.SalesOrderID == 75144
                select cartItems.ProductID;
```

Next we need to get the products, but only those that are in the cart. We do this by using our first query, inside the second:

```csharp
var myProducts = from p in db.Products               
where itemQuery.Contains(p.ProductID)
select p;
```

Here is the key to this weirdness:

> Linq To Sql only constructs the query when the Enumerator is tripped.

So as whacky as this structure may look, know that what you're doing here is creating a set of Expressions that Linq To Sql is going to parse into a SQL Statement, and it will only execute that statement when you enumerate over the results, or ask it to actually do something with the result set (like Count(), ToList(), etc). **So despite how it looks - only one query is being executed**.

It might take you 10 different LINQ statements to get what you want - but know that you can nest all of them and only call the database once.

If you've looked over the "101 LINQ Examples" site, you may know this - but I found it really groovy that you can embed anything IQueryable inside of another IQueryable statement (IQueryable is what your "var" is when you do the above query).

Here's the generated SQL for the above query:

```sql
SELECT [t0].[ProductID], [t0].[Name], [t0].[ProductNumber], [t0].[MakeFlag], [t0].[FinishedGoodsFlag], 
[t0].[Color], [t0].[SafetyStockLevel], [t0].[ReorderPoint], [t0].[StandardCost], [t0].[ListPrice], 
[t0].[
Size], [t0].[SizeUnitMeasureCode], [t0].[WeightUnitMeasureCode], [t0].[Weight], 
[t0].[DaysToManufacture], [t0].[ProductLine], [t0].[
Class], [t0].[Style], [t0].[ProductSubcategoryID], 
[t0].[ProductModelID], [t0].[SellStartDate], [t0].[SellEndDate], [t0].[DiscontinuedDate], 
[t0].[rowguid], [t0].[ModifiedDate]

FROM [Production].[Product] 
AS [t0]

WHERE 
EXISTS(
    
SELECT 
NULL 
AS [EMPTY]
    
FROM [Sales].[SalesOrderDetail] 
AS [t1]
    
WHERE ([t1].[ProductID] = [t0].[ProductID]) 
AND ([t1].[SalesOrderID] = @p0)
)
```

Notice that rather than an "IN" statement, we get a "WHERE EXISTS" - which is just about synonymous with the IN statement. I had a bit of a gag reflex when I saw the `SELECT NULL AS [EMPTY]` but that's simply an empty return set - the SELECT lookup is not interested in returning the record - only that it EXISTS. So in terms of efficiency, this is about as good as it gets.

## What If IN Didn't EXIST?


I didn't really generate an IN statement - [but this guy did](http://coolthingoftheday.blogspot.com/2008/01/being-in-in-linq-to-sql-or-how-i.html) and he tipped me off to nesting the query bits. Notice that, in his case, he didn't need to create an IQueryable - he just used an Array. This is where the fun starts with these queries - LINQ is a whole mess of extensions (at it's core) that hang off of IEnumerable. Linq To Sql will (in most cases) parse these expressions out and allow you to work with them in the context of a query.


In other words, I could have written the LINQ query above, like this:

```csharp
int[] productList = new int[] { 1, 2, 3, 4 };
var myProducts = from p in db.Products
                where productList.Contains(p.ProductID)
                select p;
```

And the generated SQL would be:

```sql
SELECT [t0].[ProductID], [t0].[Name], [t0].[ProductNumber], [t0].[MakeFlag], [t0].[FinishedGoodsFlag], 
[t0].[Color], [t0].[SafetyStockLevel], [t0].[ReorderPoint], [t0].[StandardCost], [t0].[ListPrice], 
[t0].[
Size], [t0].[SizeUnitMeasureCode], [t0].[WeightUnitMeasureCode], [t0].[Weight], [t0].[DaysToManufacture], 
[t0].[ProductLine], [t0].[
Class], [t0].[Style], [t0].[ProductSubcategoryID], [t0].[ProductModelID], 
[t0].[SellStartDate], [t0].[SellEndDate], [t0].[DiscontinuedDate], [t0].[rowguid], [t0].[ModifiedDate]

FROM [Production].[Product] 
AS [t0]

WHERE [t0].[ProductID] 
**IN (@p0, @p1, @p2, @p3)**
```

Hey! Look at that! Something I didn't think was possible actually is!

I hope you're starting to see the pattern here - and that the IN statement is built on the reverse thinking of a SQL statement. In other words you're not saying "confine this result set to this range", it's more of a "use this range to confine the result set" - which is just the kind of thing a programmer might thing, and fits right in with the rest of the LINQ syntax. Sounds subtle - but it's very important when you doing this type of querying to remember that LINQ is a programmatic construct - NOT a SQL construct.