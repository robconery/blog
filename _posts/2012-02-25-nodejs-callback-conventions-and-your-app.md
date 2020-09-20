---
layout: post
title: NodeJS Callback Conventions and Your App
summary: "NodeJS has a pretty specific convention when implementing callbacks in modules - function(err,result). Does this always make sense?"
image: "/img/12530441941910_Conventional_Logic_Vs_Religious_Logic-s624x481-29617-580.jpeg"
date: "2012-02-25"
uuid: "E07Q79pw-R2w1-BXJf-RtD9-IaC380FQQEsd"
slug: "nodejs-callback-conventions-and-your-app"
categories: Node JavaScript
---

## Did It Work Or Didn't It?

I have a method on my Customer module where I add a customer to MongoDB:

```javascript
var customer = require('./lib/customers');
customer.register("test@test.com","password","confirm", result, success);
```

The last two arguments here are callbacks. If you're new to JavaScript - keep in mind it's asynchronous which means that nothing really happens _right now_. If you need to know when something is done, you sending a callback function (which is probably better thought of as a continuation) which gets fired when the operation completed.

**But how do you structure your callback?**

In some circles (like Backbone and jQuery) you use a success/fail approach - like I did above. You pass one callback in that fires if everything succeeds, another that fires if it fails. This convention is rather clean:

```javascript
//you can also make these anonymous functions inline
success = function(result){  
  alert("Yippee Skippy: " + result.email + " was added to the DB");
}
fail = function(err){  
  alert("Something bad happened: "+err);
}
customer.register("test@test.com","password", "password", success, fail);
```

Node's convention is a little different and (keeping in mind that I'm very new to Node) I can only guess that this convention came about to avoid deep nesting and excessively callback-heavy code. In Node, the style is thus:

```javascript
//inline this time
customer.register("test@test.com","password","password",function(err,result){  
  if(err){    
    alert("Oh noes! " + err);  
  }else{    
      alert("yippee skippy...");  
  }
});
```

This code is clean and readable - and it's also **less** so that makes us happy. But in our method we have to do this... which is a bit wonky:

```javascript
var register = function(email,password,confirm,callback){   
  //pseudo code - instance and assign vals  
  var newCustomer = new _model();  
  //save it  
  newCustomer.save(function(err){    
    if(err){      
      callback(err,null);    
    }else{      
      callback(null,newCustomer);    
    }      
  });
}
```

Now if the save() method on newCustomer had followed the Node convention - then I could have just passed the callback directly into it:

```javascript
var register = function(email,password,confirm,callback){   
  //pseudo code - instance and assign vals  
  var newCustomer = new _model();  
  //save it  newCustomer.save(callback);
}
```

... which is almost certainly why this standard was adopted (and I like it!). But it doesn't so we have to write some extra code to handle it. And I could spend another few paragraphs musing on the goods and bads - but I don't know nearly enough to do such a thing, so let's move on...

## What To Do?
If I learned anything from working with Rails over the last 6 years - it's to let Rails be Rails. This isn't a bad thing. Every time I try to get clever, I pay for it.

On the other hand, when I was talking to Batman yesterday (Dave Ward) he suggested the success/fail thing was a more widely-accepted way of doing things. Which I think I agree with... but the Node community doesn't. Thus my post.

Anyway - if the convention for NodeJS is to use callback(err,result) and I'm using NodeJS well - that's what I'll do. In fact I've already run into an interesting situation with Vows (the testing framework I talked about yesterday) where it **expected that I was using this structure**.

I'll have more to say about Vows in another post (I like it a lot) - but the fact that it (basically) wouldn't execute more than one callback nudged me into this entire discussion.I'd love to hear your thoughts.
