---
layout: post
title: 'Pulling Documents From a Relational Query in Postgres'
image: '/img/relational-documents.jpg'
comments: false
categories: Postgres
summary: "The fuller support for JSONB in Postgres 9.4 makes working with document structures incredibly compelling. Here's an interesting way to have your Relational Peanut Butter play nicely with Document... Chocolate"
---

## JSON, JSONB and Postgres 9.4

Upfront: Postgres isn't the only database system in town to formally support JSON; SQL Server, MySQL, and Oracle do as well. Really - JSON is just text so there's no miracle when it comes to "supporting" it in a relational system.

The fun comes with *how* a system supports JSON. With Postgres you have had the ability to query and manipulate JSON data directly - along with a speedy parser and document validation built right in. Now, with JSONB, you have **binary support** for JSON. For NoSQL lovers out there, this is a godsend.

Full indexing and fast querying are about to become a reality within the Postgres *relational* engine. This is fun news, **but how can you use it, and why should you care?**. Let's take a look at some fun ways to leverage JSON and Postgres.

## Turning Relational Bits into Documents

I'm building out a full system using Postgres and Node right now and I'm doing the typical thing: *querying for a single user and I want all the information back*. With an ORM, this means relying on eager/lazy loading garbage and making sure you have the right relationships defined in your code.

Let's see how we can do this cleaner with Postgres. For this, I'll use a function.

I have a few constraints for this - here they are:

 - I don't want the full data to come back over the wire. This means no hashed password, no admin flags, no tokens that aren't needed, etc. I just want the user info directly.
 - I want role names
 - I want to see all admin notes and logs (which are each 1-many off the Member table)

Let's start by building the skeleton of the function:

```sql
create or replace function get_member(member_id bigint)
as $$

-- bits

$$ LANGUAGE PLPGSQL;
```

This syntax is a bit odd at first. The create/replace stuff is obvious, but the $$ stuff isn't. These are language flags to tell the PG parser "here comes some code" and at the very end we have which language was used. We could use SQL here, but I want the power of PLPGSQL.

Next, let's define the return type. I'll send back only what I need for now:

```sql
create or replace function get_member(member_id bigint)
returns table (
	id bigint,
	email varchar(255),
	first varchar(25),
	last varchar(25),
	last_signin_at  timestamptz
)
as $$

DECLARE

  found_user members;

BEGIN

  select * from members where members.id = member_id into found_user;

  return query
  select found_user.id, found_user.email, found_user.status, found_user.first, found_user.last, found_user.last_signin_at

END;

$$ LANGUAGE PLPGSQL;
```

Note the main additions to the function - the first is to set a return type - in this case it's an "anonymous" table that we declare on the fly - this goes *before* the "as" statement.

Next we set up variable declarations using `DECLARE`. Here we want to play with a member record, so we declare it. Finally we populate that variable and return it below. We're almost there - let's add some additional info!

## Adding JSON

So far the query we have could be written in plain old SQL without the function ceremony - now let's get down to business. I'll add 3 more fields here for roles, logs, and notes:

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

OK we did a bit more work here. I added notes/logs/roles to my return table, then 3 variables to hold the values for me. In the body I used the built-in `json_agg` function to aggregate and parse the passed-in select statements. Note that I can select whatever I values I want returned in these subqueries - for convenience I'm just returning all the fields for each.

It's likely that I'll have many logs and many notes, etc - but the `json_agg` function will drop this into an array for me... which is quite nice.

Finally, down below I'm returning the JSON values back so we can now query it.

## Calling This Using Node

If you use the simple `node-pg` module for Node, you can call this code easily:

```javascript
pg.connect("postgres://rob@localhost/membership", function (err, db, done) {
  assert.ok(err === null, err);
  db.query("select * from get_member($1)", [MY-ID], function (err, result) {
    //release the connection
    done(db);
    //throw on err
    if(err) throw err;
    //return the result
    next(null, result.rows);
  });
});
```

Since we're returning a table from our function, you have to query it like one. We do that with the `select * from get_member($1)` call above. Note the `$1` is a flag for the parameter input.

What do these results look like? That's the fun of working with Node and Postgres. The PG driver will see the JSON return type and parse it for you, so we get back a lovely document:

```json
{ id: '843350353876354049',
  email: 'test@test.com',
  first: 'Joe',
  last: 'Blow',
  last_signin_at: Fri Oct 31 2014 12:33:38 GMT+0100 (CET),
  logs:
   [ { id: 1,
       subject: 'Registration',
       member_id: 843350353876354000,
       session_id: null,
       entry: 'Added to system, set role to User',
       ip_address: null,
       created_at: '2014-10-31 12:33:38.006534+01' },
     { id: 2,
       subject: 'Authentication',
       member_id: 843350353876354000,
       session_id: null,
       entry: 'Activated member during registration',
       ip_address: null,
       created_at: '2014-10-31 12:33:38.006534+01' } ],
  notes: null,
  roles:
   [ { id: 99,
       description: 'User',
       member_id: 843350353876354000,
       role_id: 99 } ] }
```

That there almost looks like a full-blown document doesn't it! And that's the point - we were able to store information in our DB with a nice, tight normalized scheme, and pull it out like a document.

There are a number of other things I can do with this function - setting flags like `is_admin` or `can_login` based on status.

In fact I like this document return style so much, I've taken to wrapping commands (like Register or Authenticate) into documents with fields like "success", "message", and "data" where "data" might be the new record created. This kind of thing lets you pump prepared information right from Postgres out to your API without having to write a ton of intermediate formatting code.

I like it.
