---
layout: post
title: 'Using Custom Types in Postgres'
image: '/img/youre-my-type.jpg'
comments: false
categories: Postgres
summary: "I'm building out a pretty detailed application using Postgres and Node - mostly Postgres - trying to flex as much of its power as I can. For me, this means kicking ORMs to the curb and relying on Postgres' amazing function features"
---

## Using Types For Fun and Profit

In [my last post about pulling documents from queries](http://wekeroad.com/2014/10/31/pulling-documents-from-a-relational-query-in-postgres/) I showed an interesting way to return a result set using `row_to_json` to crunch down 1-many records into a JSON array. This works pretty well and is really fast - but it's not exactly pretty:

```sql
create or replace function get_member(member_id bigint)
returns table (
  id bigint,
  email varchar(255),
  first varchar(25),
  last varchar(25),
  last_signin_at  timestamptz,
  notes json,
  logs json,
  roles json
)
as $$

DECLARE

  found_user members;
  parsed_logs json;
  parsed_roles json;
  parsed_notes json;

BEGIN
  select * from members where members.id = member_id into found_user;

  select json_agg(x) into parsed_logs from
  (select * from logs where logs.member_id=found_user.id) x;

  select json_agg(y) into parsed_notes from
  (select * from notes where notes.member_id=found_user.id) y;

  select json_agg(z) into parsed_roles from
  (select * from roles
  inner join members_roles on roles.id = members_roles.role_id
  where members_roles.member_id=found_user.id) z;

  return query
  select found_user.id, found_user.email, found_user.first, found_user.last, found_user.last_signin_at,
  parsed_notes, parsed_logs, parsed_roles

END;

$$ LANGUAGE PLPGSQL;
```

Beauty is in the eye of the beholder I suppose - this looks nice to me, but one thing stands out: **I don't like the anonymous table return style**. I think I'll probably want to use that again somewhere so let's set that up.

The first thing to do is resolve it to a type:

```sql
create type member_summary as (
  id bigint,
  email varchar(255),
  first varchar(25),
  last varchar(25),
  last_signin_at  timestamptz,
  notes json,
  logs json,
  roles json
);
```

Lovely. This is a composite type in Postgres - you can define your own base types if you want - but that's a whole other story. This composite type will do nicely.

Now we can rewrite the function to be a bit more concise:

```sql
create or replace function get_member(member_id bigint)
returns setof member_type
as $$

DECLARE

  found_user members;
  parsed_logs json;
  parsed_roles json;
  parsed_notes json;

BEGIN
  select * from members where members.id = member_id into found_user;

  select json_agg(x) into parsed_logs from
  (select * from logs where logs.member_id=found_user.id) x;

  select json_agg(y) into parsed_notes from
  (select * from notes where notes.member_id=found_user.id) y;

  select json_agg(z) into parsed_roles from
  (select * from roles
  inner join members_roles on roles.id = members_roles.role_id
  where members_roles.member_id=found_user.id) z;

  return query
  select found_user.id, found_user.email, found_user.first, found_user.last, found_user.last_signin_at,
  parsed_notes, parsed_logs, parsed_roles

END;

$$ LANGUAGE PLPGSQL;
```

Much better. You'll notice that instead of saying `returns TABLE` I now need to say it's a `setof` a type. A "type" in Postgres can be a base type (like int, varchar, etc) or a table - which is a composite type by itself. `members` is a type. If you want to create your own for reusability - you sure can!

Now we can reuse this type if we like - say by finding a member by email:

```sql
create or replace function get_member_by_email(member_email varchar(255))
returns setof member_type
as $$

DECLARE
  found_id bigint;
BEGIN
  select id from members into found_id where members.email = member_email;
  return query
  select * from get_member(found_id);

END;

$$ LANGUAGE PLPGSQL;
```

## Enums

I also have a logging table that keeps track of things in the system. For that, I like to know what type of log is being stored. If I was being strict, I'd have two tables, like this:

```sql
create table log_types(
  id serial primary key not null,
  description varchar(25)
);
create table logs(
		id serial primary key not null,
		subject_id int not null references log_types(id),
		member_id bigint not null references members(id) on delete cascade,
		entry text not null,
		data json,
		created_at timestamptz default current_timestamp
);
```

This works fine and there's a nice Foreign Key constraint in there to be sure I have some type of description. However there's a simpler way that, to me, is a bit more descriptive:

```sql
create type log_type as ENUM(
  'registration', 'authentication', 'activity', 'system'
);

create table logs(
    id serial primary key not null,
    subject_id log_type not null,
    member_id bigint not null references members(id) on delete cascade,
    entry text not null,
    data json,
    created_at timestamptz default current_timestamp
);

insert into logs (subject, member_id, entry)
values ('registration',11111,'Member registered');
```

This works basically the same way, but instead of having a simple integer in my logs table, I have the description itself with a constraint on it that it must contain one of the specified values.


Lovely. There's a lot more we can do here on the write-side of working with data. I'll cover that in the next post.
