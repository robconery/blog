---
layout: post
title: "🤖 Does Functional Programming Matter To You?"
image: "/img/2023/12/screenshot_251.png"
date: "Tue Dec 05 2023 20:47:59 GMT-0800 (Pacific Standard Time)"
categories: software-design
summary: Learning Elixir changed me as a programmer, and learning functional concepts changed the way I think about writing software. How about you? Is functional proogramming a useful thing to learn?      
---

It seemed like functional programming got a boost back in the mid to late 2010s when [Elixir](https://elixir-lang.org) started gaining in popularity. I, for one, had my entire professional outlook turned inside out by getting to know this language and the underlying BEAM runtime and OTP framework.

I couldn't understand why we hadn't always worked this way. I didn't understand why OTP and frameworks like it weren't the norm! I began to understand, however, why functional programming people tend to be ... passionate functional programming people.

Now you might be wondering if the title is clickbait and I don't think it is because I am genuinely curious about your answer. If you're receiving this via email, I would love a reply! I found functional concepts to be life-changing, literally, changing the way I think about code, tests, and putting applications together.

What do I mean? Here are a few things...

## Purity

You might know this already but "pure code" is completely self-contained and doesn't rely on anything outside of its scope. A simple example would be a math function (using JavaScript here):

```js
const squareIt = function(num){
  return num * num;
}
```

I know there are more elegant ways to do this and guards to put on here but you get the idea: this is a _pure_ function.

Let's change the above function to be _impure_:

```js
const RobsConstant = 2.58473;

const squareItRobsWay = function(num){
  return num * num * RobsConstant;
}
```

My function will now _behave differently_ if the value of `RobsConstant` changes, which it shouldn't because it's a constant and all, but it's possible that I could redefine this value and pull it from a database, who knows! My function sure doesn't, and it's possible that we could introduce an error at some point (turning `RobsConstant` into a string, for instance) which is really, really annoying.

If we were being good functional people, we would use two functions and shove them together:

```js
const RobsConstant = function(){
  return 2.58473;  
};

const squareIt = function(num){
  return num * num;
}
const squareItRobsWay = RobsConstant() * squareIt(4); 
```

This seemingly small change is profound! We can test both functions to make sure they do what they're supposed to, which means we can have full confidence that our `squareItRobsWay` value should _always_ return what we expect (again: assuming we have tests in place).

## Currying. Crazy Talk.

You may have heard this term when talking to a functional person and thought it sounded a bit _mathy_. I know I did. Currying is splitting a function with multiple arguments into a chain of smaller functions with only a single argument. 

Dig this:

```js
const buildSelect = function(table, criteria, order,limit){
  let whereClause="", params=[];
  if(criteria){
    whereClause = "where 1=$1" //pseudo code, obvs
    params=[1] //placeholder for this example
  }
  const orderClause = order ? `order by ${order}` : ""
  const limitClause = limit ? `limit ${limit}` : ""

  const sql = `select * from ${table} ${whereClause} ${orderClause} ${limitClause}`;
  return {sql: sql, params: params};
}
```

I'm punting on writing out the `where` stuff because it's not important. What _is_ important is the idea that we have code here that we can use elsewhere. If we put our functional hats on, focus on _purity_, we can actually _curry_ this into a set of smaller functions that only do one thing:

```js
const where = function(item){
  //build a where clause by inspecting the item
  return item ? `where 1=$1` : "";
}
const params = function(item){
  //create parameters from the criteria item
  return item ? [1] : "";
}
const orderBy = function(clause){
  return clause? `order by ${clause}` : ""
}
const limitTo = function(clause){
  return clause ? `limit ${clause}` : "";
}

const selectQuery = table => criteria => order => limit => {
  //create a where statement if we have criteria
  const sql = `select * from ${table} ${where(criteria)} ${orderBy(order)} ${limitTo(limit)}`;
  return {sql: sql, params: params(criteria)};
};
```

Believe it or not, this works! We can invoke it like this:

```js
const sql = selectQuery("products")({sku: "one"})("cost desc")(100);
console.log(sql);
```

```sh
❯ node query.js
{
  sql: 'select * from products where 1=$1 order by cost desc limit 100',
  params: [ 1 ]
}
```

In functional languages you typically chain methods together, passing the result of one function right into another. In Elixir, we could build this exact function set and start with the table name, passing along what we need until we have the select statement we want:

```elixir
"products"
  |> where({sku: "one"})
  |> orderBy("cost desc")
  |> limitTo(100)
  |> select
```

This, right here, is a _functional transformation._ You have a bunch of small functions that you pass a bit of data through, transforming it as you need.

## Partial Application

The first draft of this post went out as an email so if you're here from that email you didn't see this section! Sorry - it happens.

You might be looking at that invocation wanting to barf, but that's not how you would use this code. Typically, you would build up a _partial_ use of the functions, like this:

```js
//assuming there's a sales_count in there
const topProducts = selectQuery("products")()("sales_count desc");
```

We're _partially applying_ our functions to create a new one that shows us the top _n_ products, which we can specify in this way:

```js
const top10Products = topProducts(10);
console.log(top10Products);
```

This is where things get really, really interesting. Functional composition is at the heart of functional programming, and damned fun to use, too! Here's what our code will generate for us:

```sh
{
  sql: 'select * from products  order by sales_count desc limit 10',
  params: ''
}
```

Small, simple functions, easily testable, composable, and the clarity is wonderful.

So: what do you think? Is this style of programming interesting, simpler, elegant or horrid? Or is everything just React these days :D.

There's more, of course, and I made a fun video many years ago for [_The Imposter's Handbook_](https://sales.bigmachine.io/imposter-second)which you can watch right here, if you like!