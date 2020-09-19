---
layout: post
title: "Inserting And Using A New Record In Postgres"
slug: inserting-using-new-record-postgres
summary: ""
comments: false
image: /img/2015/02/ctes_rock.jpg
categories: Postgres
---

## A Problem Postgres Can Solve Easily

Let's say you need to insert a record into a table and then use that record immediately to push data into *another table*. This happens a lot with parent/child relationships (think about users and roles - add a user, add to a role, and log it - 3 queries!) and, typically, developers will shove that into the app layer and let Rails/Node/ASP.NE T execute multiple queries.

But you don't have to! Just know you some SQL and you're good to go.

## Common Table Expressions

These are not new and have been around for a while - and yes SQL Server fans you can do what you're about to see in SQL Server, however you won't have the syntactic niceties.

First, let's create some tables in a demo database:

```sql
create table things(
  id serial primary key,
  name varchar(50)
);

create table thing_logs(
  id serial primary key,
  thing_id int not null references things(id),
  entry varchar(50)
);
```

In the example above you can see the use of `serial`, a great shortcut for creating a primary key. This is example is pretty stupid, but hopefully it gets the point across.

Let's insert some data with a common table expression. I'll insert the record, pull the record out, and insert the new values into the logs table:

```sql
with inserted as (
  insert into things(name)
  values('Rob') returning *
)
insert into thing_logs(thing_id,entry)
select inserted.id, 'New thing created: ' || inserted.name from inserted;
```

If you've never used them, Common Table Expressions (CTEs) can look quite foreign at first. Basically, they create a table on the fly that you can then query against. Here I'm using Postgres syntactic shortcut for returning the inserted record: `returning *`. If I only wanted the id I could use `returning id`.

I wrap in a `WITH inserted` and I can use it in a subsequent query (I can call it whatever I like). In this case I drop an entry into the `thing_logs` table.

But why would I do this?

Two reasons: *performance* and *transactions*. In the above query performance doesn't really matter, but as your database grows you'll want to streamline the connections to the database and make them as reasonable as you can.

Transactions are something many developers just don't think about until they realize they're not trapping all the data they should. In this case we're only executing two writes - but in the real world you might have 5 or 6. Perhaps when a user is created. 

You can use CTEs for this as well (UPDATE: I originally wrapped this with a BEGIN/COMMIT but CTEs, even chained like this, encompass a transaction):

```sql
with new_user as(
  insert into users(email,created_at, password)
  values('test@test.com',now(),'hashed_password')
  returning id
), role_assignment as(
  insert into users_roles(user_id, role_id)
  select new_user.id, 10 from new_user
  returning user_id
), log_entry as(
  insert into user_logs(user_id, entry)
  select role_assignment.user_id, 'Added to system' from role_assigment
  returning user_id
)
--return the new record with the assigned role for niceties
select users.email, users.created_at, roles.name
from users 
inner join users_roles on users.id = users_roles.user_id
inner join roles on roles.id = users_roles.role_id
where users.id=(select user_id from log_entry);
```

This example shows a *killer feature* of CTEs - they're chainable. I've also wrapped everything inside a `BEGIN` and `COMMIT` so if there's an error here for whatever reason, nothing gets written.

At the end there I'm returning the new `users` record along with the role assignment -but you can return whatever your application needs data-wise. This is why we SQL people!

Of course there are different ways of doing this (functions come to mind) but sometimes the syntactic niceties of Postgres make writing queries like this quite fun.