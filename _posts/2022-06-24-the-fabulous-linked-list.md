---
layout: post
title: "The Fabulous Linked List"
image: "/img/2022/08/06_title.jpg"
date: "Fri Jun 24 2022 16:30:00 GMT-0700 (Pacific Daylight Time)"
categories: theory
summary: It’s always fun to study the basics, and in this video we dive into the linked list and how to create one from scratch. Sounds ridiculous, but it can rescue an interview!      
---

The second time I interviewed at Google I was asked to write a linked list from scratch. I was expecting something a little more “difficult” and thought I would breeze through the question. I had been studying for months for this interview, after all, so this should be easy… right?

It didn’t take long before I completely locked up. The logic for inserting and removing was wild… and then I was asked to reverse the linked list, another ridiculous and annoying question.

And yet I couldn’t do it on the first try.

**I failed that interview**, which was humiliating. I had 15 years of experience and I couldn’t reverse a linked list?

## Know Your Basics

I know I’m not the only one to get blindsided by a basic question like this. Turns out, this is a tactic used by a lot of interviewers when interviewing senior people: ask a basic question and see how they handle it. A friend of mine does this kind of thing routinely for a larger tech company. Their thinking is straightforward: if you get grumpy when asked to do something simple or “beneath you”, you might not be the best candidate.

I can see the logic in that.

That’s what today’s video is all about: doing the very basics with a Linked List. Hope you enjoy! If you want to play along, here is some code to get you started:

```javascript
//This is the simplest possible linked list
class Node{
  constructor(val){
    this.value = val;
    this.next = null;
  }
  append(val){
    this.next = new Node(val);
    return this.next;
  }
}
```

---