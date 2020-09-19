---
layout: post
title: 'Repositories On Top UnitOfWork Are Not a Good Idea'
image: '/img/darth_swimming.jpg'
comments: false
categories: Opinion
summary: "There is <a href='http://www.asp.net/mvc/tutorials/getting-started-with-ef-5-using-mvc-4/implementing-the-repository-and-unit-of-work-patterns-in-an-asp-net-mvc-application'>a trend in the .NET space</a> of trying to <a href='http://www.johnpapa.net/spapost3/'>abstract EF behind a Repository</a>. This is a fundamentally bad idea and hopefully I'll explain why."
---

## The Rationale

It's generally believed that by using the Repository pattern, you can (in summary) "decouple" your data access from your domain and "expose the data in a consistent way". 

[If you look at any of the implementations of a Repository working with a UnitOfWork (EF)](http://www.asp.net/mvc/tutorials/getting-started-with-ef-5-using-mvc-4/implementing-the-repository-and-unit-of-work-patterns-in-an-asp-net-mvc-application) - you'll see there's not all that much "decoupling":

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using ContosoUniversity.Models;

namespace ContosoUniversity.DAL
{
    public class StudentRepository : IStudentRepository, IDisposable
    {
        private SchoolContext context;

        public StudentRepository(SchoolContext context)
        {
            this.context = context;
        }

        public IEnumerable<Student> GetStudents()
        {
            return context.Students.ToList();
        }

        public Student GetStudentByID(int id)
        {
            return context.Students.Find(id);
        }

        //<snip>
        
        public void Save()
        {
            context.SaveChanges();
        }

    }
}

```

This class can't exist without the `SchoolContext` - so what exactly did we decouple here? **Nothing**.

In this code, from MSDN, what we have is **a reimplentation of LINQ**, with the classic problem of the "ever-spiraling Repository API". By "spiraling API" I mean fun things like "GetStudentByEmail, GetStudentByBirthday, GetStudentByOrderNumber" etc.

But that's not the primary problem here. The primary problem is the `Save()` routine. It saves a Student... I think. What else does it save? Can you tell? I sure can't... more on this below.

## UnitOfWork is Transactional

A Unit of Work, as it's name applies, is there to **do a thing**. That thing could be as simple as retrieving records to display, or as complex as processing a new Order. When you're using EntityFramework and you instantiate your DbContext - you're creating a new UnitOfWork.

With EntityFramework you can "flush and reset" the UnitofWork by using `SubmitChanges()` - this kicks off the change tracker comparison bits - adding new records, updating and deleting as you've specified. **Again, all in a transaction**.

## A Repository Is Not a Unit of Work

Each method in a Repository is supposed to be an atomic operation - once again either pulling stuff out, or putting it back in. You could have a SalesRepository that pulls catalog information, and that transacts an order. 

The downside to using a Repository is that it tends to spiral, and pretty soon you have one repository having to reference the other because you didn't think the SalesRepository needed to reference the ReportsRepository (or something like that).

This quickly can become a mess - **and it's why people starting using UnitOfWork**. UnitOfWork is an "atomic operation on the fly" so-to-speak. 

## The Only Thing You Could Do Worse: Repository < T >

This pattern is maddening. It's not a Repository - it's an abstraction of an abstraction. Here's one that's quite popular for some reason:

```csharp
public class CustomerRepository : Repository < Customer > {
  
  public CustomerRepository(DbContext context){
    //a property on the base class
    this.DB = context;
  }

  //base class has Add/Save/Remove/Get/Fetch

}
```
 On the face of it: _what's wrong with this?_ It's encapsulating things and the Repository base class can use the context so... what's the problem?

The problems are Legion. Let's take a look...

### Do You Know Where That DbContext Has Been?

No, you don't. It's getting injected and you have no idea which method opened it, nor for what reason. The idea behind Repository<T> is code "reuse" so you'll probably be calling it from a Registration routine, maybe a new order transaction, or from an API call - who knows? Certainly not your Repository - **and this is the main selling point of this pattern!**. 

The name says it all: **UnitOfWork**. When you inject it like this you don't know where it came from.

### "I Needed The New Customer ID"

Consider the code above in our `CustomerRepository` - it will add a customer to a the database. But what about the new CustomerID? You'll need that back for creating a log file and so you what do you do? Here's your choice:

 - Run `SubmitChanges()` right in your Controller so the changes get pushed and you can access the new CustomerID
 - Open up your CustomerRepository and override the base class `Add()` method - so it _runs `SubmitChanges()`_ before returning. This is the solution that the MSDN site came up with, and it'a bomb waiting to go off.
 - Decide that all Add/Remove/Save commands in your repo should `SubmitChanges()`

Do you see the problem here? The problem is in the implementation itself. Consider _why you need the new CustomerID_ - it's likely to do something else such as pop it onto a new Order object or a new ActivityLog.

What if we wanted to use the StudentRepository above to create a new student when they bought books from our book store. If you pass in your data context and save that new student... uh oh. You're entire transaction was just flushed.

Your choice now is to a) not use the StudentRepository (using OrderRepository or something else) or b) remove SubmitChanges() and have lots of fun bugs creep into your code.

If you decide to not use the StudentRepo - you now have duplicate code...

> But Rob! EF does this for you transactionally - you don't need to SubmitChanges just to return the new ID - EF does it in the scope of the transaction already!

**That. Is. Correct**. And it's also my point - which I'll come back to.

### Repositories Methods Are Supposed To Be Atomic

That's the theory anyway. What we have in Repository<T> is not a repository at all - it's a CRUD abstraction that doesn't do anything business-related. Repositories are supposed to be focused on specific operations - this one isn't.

If you're not using Repository<T> then you know it's almost impossible to avoid having "Repository Overlap Insanity" - losing all transactionality (and sanity) as your app grows.

## OK Smart Guy - What's the Answer?

There are two ways to stop this over-abstraction silliness. The first is Command/Query separation which at first might look a bit odd - but you don't need to go Full CQRS - just enjoy the simplicity of doing what's needed and no more...

### Command/Query Objects

Jimmy Bogard wrote a great post on this and I've tweaked his example a bit to use properties: but basically you can [**use a Query or Command object**](http://lostechies.com/jimmybogard/2012/10/08/favor-query-objects-over-repositories/):

```csharp
public class TransactOrderCommand {
  public Customer NewCustomer {get;set;}
  public Customer ExistingCustomer {get;set;}
  public List<Product> Cart {get;set;}
  //all the parameters we need, as properties...
  //...

  //our UnitOfWork
  StoreContext _context;
  public TransactOrderCommand(StoreContext context){
    //allow it to be injected - though that's only for testing
    _context = context;
  }

  public Order Execute(){
    //allow for mocking and passing in... otherwise new it up
    _context = _context ?? new StoreContext();

    //add products to a new order, assign the customer, etc
    //then...
    _context.SubmitChanges();

    return newOrder;
  }
}
```

You can do the same thing with a QueryObject - read Jimmy's post for more on this but the idea is that a query as well as a command has a specific reason for existence - you can change as needed and mock as needed.

### Embrace Your DataContext

This is an idea that [Ayende came up with] and I absolutely love it: wrap what you need in a filter or, use a Base Controller (assuming you're using a web app):

```csharp
using System;
using System.Web.Mvc;
 
namespace Web.Controllers
{
  public class DataController : Controller
  {
    protected StoreContext _context;
 
    protected override void OnActionExecuting(ActionExecutingContext filterContext)
    {
      //make sure your DB context is globally accessible
      MyApp.StoreDB = new StoreDB();
    }
 
    protected override void OnActionExecuted(ActionExecutedContext filterContext)
    {
      MyApp.StoreDB.SubmitChanges();
    }
  }
}

```

This will allow you to work with the same DataContext in the scope of a single request - you just need to be sure to inherit from DataController. This means that each request to your app is considered a UnitOfWork... which is quite appropriate really. In some cases it may not be - but you can fix that with QueryObjects above.

## Neat Ideas - But I Don't See What We've Gained

We've gained a number of things:

 - **Explicit Transactions**. We know exactly where our DbContext has come from, and what Unit of Work we're executing in each case. This is helpful both now and into the future.

 - **Less Abstraction == Clarity**. We've lost our Repositories which didn't have a reason to exist other than to abstract an existing abstraction. Our Command/QueryObject approach is cleaner and the intent of each one is clearer.

 - **Less Chance of Bugs**. The Repository overlap (and worse yet: Repository<T>) increases the chance that we could have partially-executed transactions and screwed up data.

So there it is. Repositories and UnitOfWork don't mix and hopefully you've found this helpful!


