---
layout: post
title: "What’s the Best Hashing Algorithm for Storing Passwords?"
image: "/img/2022/08/01-hashing.jpg"
date: "Mon Jan 10 2022 20:13:00 GMT-0800 (Pacific Standard Time)"
categories: theory
summary: "Most people will default to bcrypt when choosing a hashing algorithm for storing sensitive information - but why? Are there other choices? Indeed! In this video we'll take a look at scrypt, PBKDF2 and my favorite: argon2"
---

If you’ve had to store sensitive user information in a database, you’ve probably heeded the advice to “**just use bcrypt**”. But do you know why? What other choices are there? In this video we take a deep look at **bcrypt, pbkdf2, scrypt** and **argon2**!

Crypto is a major weakness of mine and a subject I’ve put off learning about for ages. I’ve spent a few months with it now and it’s so much fun to learn about – specifically hashing. Here’s what I founMost developers just let their authentication library (or service) dictate which hashing algorithm to use, and normally that’s just fine. Well… until you get hacked and lose your user’s sensitive data.

Understanding hashing algorithms means understanding their resilience against certain kinds of attacks. That resilience is brought about by how difficult it is to calculate the hash. Algorithms like MD5 and SHA-x are all about speed, because that’s how they’re used! When you commit to Git, a SHA-1 hash is created for you and you certainly don’t want to be slowed down.

But when an attacker tries to brute force a rainbow table attack on your stolen data, you want that hashing algo to be damn slow!

In this video we’ll take a look at the most popular algorithms, including my new favorite, [Argon2](https://github.com/P-H-C/phc-winner-argon2).