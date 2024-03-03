---
layout: post
title: "Importing a CSV Into PostgreSQL Like a Pro"
image: "/img/2022/08/03-csv.jpg"
date: "Tue Feb 22 2022 20:07:00 GMT-0800 (Pacific Standard Time)"
categories: postgres
summary: Importing data into PostgreSQL can be time consuming and painful – unless you toss the GUI tools and use scripts.      
---

## USING HEAD

It all starts with using the head command in the shell in order to pull out the column names:

```sh
head -1 master_plan.csv

```

This will pop out the very first line of the CSV, which is typically the header row. I’m working with Cassini’s mission plan data, so this is what I see:

![](https://blog.bigmachine.io/img/2022/08/head-command.png)

Now I just copy/paste that into VS Code and run a simple replacement using “Change all Occurrences” to build my create table statement.

The final step is to use the copy from command to pull data out of the CSV and into the database. There’s a whole lot more to this (like data types to use and creating an isolated schema) – just watch the video already!