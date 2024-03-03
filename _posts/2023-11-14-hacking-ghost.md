---
layout: post
title: "👻 Hacking Ghost for Fun and Profit"
image: "https:/images.unsplash.com/photo-1633826523932-fb137c3353b5"
date: "Tue Nov 14 2023 02:13:36 GMT-0800 (Pacific Standard Time)"
categories: frontend
summary: I've been using Ghost for many years and recently I decided to see just how far I could push it.      
---

Back in 2014 I created a course for Pluralsight called [_Hacking Ghost_](https://www.pluralsight.com/courses/hacking-ghost), which is the CMS platform you're reading this post on (or maybe got an email from). I had a good time putting that course together, but **Ghost has grown up a lot** since then.

I've been using it on my personal site (this one) for the last year or so and I really, really like it. Recently, however, I decided to see just how far I could push this platform to do a few things it was never meant to do.

Allow me to share, because some of y'all might benefit!

## Hosting Video Courses

One of the things I have wanted for a long time is a site that's all about content production while at the same time capable of **hosting video courses**. You can do it in WordPress, of course, and there are a few services out that there come close... but nothing like Ghost.

It's wasn't all that hard to do and, moreover, it was kind of fun. One thing that's extremely simple to do is to [create your own theme](https://ghost.org/docs/themes/). Ghost uses Handlebars under the hood (a Node/JS templating engine) and exposes a ton of helpers to you that allow you to create what you need. They also give you access to routing using a simple YAML file.

I have quite a few templates laying around, so I took one of them and made a blog theme that I like based on Bootstrap 5\. I also did something that I've wanted to do for years: **I wedged in a Vue application so people can watch the courses I've made**.

Here's one that I just launched: [_The Imposter's Frontend Accelerator_](https://sales.bigmachine.io/accelerator/). I think it works pretty well so far, though there might be a few bugs here and there.

Point is: Ghost is flexible enough that I could write up a Vue app, drop it into my theme, and show some courses! But there's a little more here too...

## Hooking Up Supabase

Ghost doesn't give you access to its database, unlike WordPress (thank god). That means that if you need to access some data, like whether someone has bought one of your courses, you need to do something different.

For this, I used [Supabase](https://supabase.com/). It's basically a "backend in a box" that runs on Postgres and for me, _say no more,_ I'm all over it. All of my business data is in there going back years and if you bought something from me, you're in there!

![](https://blog.bigmachine.io/img/2023/11/screenshot_205.jpg)

One service that Supabase offers is user authentication. They do this using magic links, email/password, and social. This presents a problem with Ghost because Ghost provides authentication too - so how do you synchronize the two?

_By the way: Supabase has a very generous free tier but I pay them money anyway because I love the service. **I get no consideration for this post**. Same with Ghost._

Here's the fun part - and I think it works pretty well. Every user of this Ghost site has an account with a GUID as an ID. When you're logged in, Ghost gives me access to your information from my theme:


```javascript
{% raw %}
const email="{{@member.email}}";
const password="{{@member.uuid}}";
{% endraw %}
```

Now this might make you want to puke, especially seeing the `password` reference there - but just think of it as an access token. I have a routine that fires when you visit the site that tries to log you in to Supabase (if you're logged in to Ghost). If that fails, I send your credentials to an edge function (another Supabase service) which adds you on the fly.

This is some simple JavaScript I have in my theme. It's a simple wrapper for Supabase that does the "heavy" lifting:

```js
class DB {
  constructor(){
    const {createClient} = supabase;
    this.client = createClient("[credentials]", {
      persistSession: true,
      autoRefreshToken: true,
    });  
  }
  async login(email, uid){
    return this.client.auth.signInWithPassword({
      email: email,
      password: uid
    });
  }
  async getUser(){
    return this.client.auth.getUser()
  }
  async ensureLogin(email, uid){
    //if they're logged in, return
    const exists = await this.getUser();
    if(exists.data.user) return true;

    //if not, let's try and log them in
    console.log("Logging in...");
    const {data, error} = await this.login(email, uid);

    if(error) {
      //if we're here then the user is logged in and we need to sync things
      console.log("Syncing...");
      const res = await fetch("[supabase function url]", {
        method: "post",
        body: JSON.stringify({email: email, uid: uid})
      });
      await this.login(email, uid);
      return true;
    }
  }
}
```

In my Ghost theme I check to see if a `member` is logged in right in my layout at the top of the page. If they are logged in, I sync things up with Supabase (yes that's jQuery don't judge me):

```hbs
{% raw %}
{{#if @member}}
<script>
	$(async () => {
		const db = new DB();
		await db.ensureLogin("{{@member.email}}", "{{@member.uuid}}");
	});
</script>
{{else}}
<script>
	localStorage.removeItem("[token key]");
</script>
{{/if}}
{% endraw %}
```

The result of `db.ensureLogin` will be a JWT that's kept in `localStorage` for the Supabase SDK to use when I make API calls.

The Supabase function that creates an auth record if a user isn't there is a Deno endpoint that has one job only: _adding a user to the authentication backend:_

```js
const client = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
)
const {email, uid} = await req.json();

const { data, error } = await client.auth.admin.createUser({
  email: email,
  password: uid, 
  email_confirm: true
});
```

I've thought a lot about this and also asked a few friends if this seemed "secure". Sure it's possible to log yourself in if you know one of my user's email address and `uid` (which is a GUID). Doing that will allow you to watch some videos, if they bought any - but that's it.

To me, it's akin to calling an API endpoint with a user's unique id and asking for some data. Maybe I'm wrong on that, but there's no sensitive user information that you would have access to. Supabase's client access is locked down, so authentication here simply means you can see videos. That's it.

**Do let me know if there's something I'm missing**. These credentials aren't stored on the client, by the way, that's all done with JWTs coming from Supabase. All of the data in the Supabase database is protected by PostgreSQL's row-level security, which is based on your JWT, so I think we're good here but then again... I'm not a security expert.

Is it a hack? Sure! Does it work? Yes!👨🏻‍🎤

## Building Your Own Theme

Ghost has extensive documentation on building a custom theme, which you can [read here](https://ghost.org/docs/themes/). In summary: **a theme is a bunch of Handlebars pages with data available to them**. Things like `post`, `page`, `member` and so on.

For my site, I decided to buy a theme from [Bootstrap](https://themes.getbootstrap.com/) called [Eduport](https://themes.getbootstrap.com/product/eduport-lms-education-and-course-theme/). It has every single page you could need, and splitting it out into a Ghost theme took me about 3 days over a long weekend.

One really nice thing about Ghost themes is that membership popup screens are part of Ghost itself - you don't need to style that stuff. You can, if you want to, but logging in, subscribing, and profile pages are already there.

That's the easy part - the video app is a whole different deal!

## The Vue App

This is where things got tricky. I needed a literal single-page app with routing and data access to Supabase. I tried to just drop Vue into a template page, but the routing and other things quickly made a mess.

![](https://blog.bigmachine.io/img/2023/11/screenshot_203.jpg)

To get around this, I created a standalone Vue app with the CSS for the template as part of it. I kept the directory for the Vue app _outside_ of the theme directory - in fact I put it in the root of my local Ghost instance.

For convenience, I reset the build output to be my theme's assets directory. This is my Vue app's `vite.config.js`:

```js
export default defineConfig({
  build: {
    outDir: '../content/themes/bootstrap/assets/app',
    rollupOptions: {
      output: {
        entryFileNames: `assets/[name].js`,
        chunkFileNames: `assets/[name].js`,
        assetFileNames: `assets/[name].[ext]`
      }
    }
  },
  //...
```

Also notice that I renamed the output files. Normally these have "cache-busting" hashes appended to them, but that became a pain in the butt so I'm going with the same name for each asset, every time which seems to work pretty well.

### Routing

I decided to go with hash-based routing because I didn't want permalinks to freak out Ghost, which would try and serve any request coming in. That's a simple thing to do with Vue's router:

```js
const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/:slug',
      name: 'lesson',
      component: LessonView
    }
  ]
});
```

The app itself is pretty simple. There's a main course page that shows summary information and a list of lessons, and then there's actual lesson page with the videos on it. 

### The Build

Admittedly, there are a lot of moving parts with this and I really don't like that. I know that in a year's time I'll forget everything I've done and I'm pretty good at leaving myself notes and comments in the code, but I also know myself really well... this is going to make me cranky.

Case in point: my local build process. As I mention, I have my CSS, images and Bootstrap JS stuff in my Vue project because I need to see how things look separate from my Vue theme. These are all stored in the Vue app's `public` directory as I don't want them built with the Vue app because it would double up the CSS and JS files I need.

I also need to be sure that I replace all of the built files in my theme with the new ones coming in. Here, let me just show you the code from my `package.json`:

```js
  "scripts": {
    "dev": "vite",
    "build": "rm -R ../content/themes/bootstrap/assets/app && vite build && rm -R ../content/themes/bootstrap/assets/app/assets/images",
    "preview": "vite preview"
  },
//...
```

The `build` task does the work here. It's removing my themes `assets/app` directory, which is where my app lives, building the local project which pushes the code to the theme, and then it's deleting the images that get pulled over.

It feels a bit janky, but it's working and it's just a few bash commands so... I guess it's OK.

## Publishing Your Theme

It's pretty simple to upload your finished theme, including your Vue app, using the Admin UI. It works, but it involves a lot of clicks and I like scripts so I went hunting for one a few years ago.

It turns out you can post a zip file to the Ghost API and it will do the needful, popping the theme files you need in place. I can't remember where I found this script - I think it might have been on the Ghost forums. Normally I pay close attention to crediting people as there no way I could have figured this out myself!

Anyway, [here's a script](https://gist.github.com/robconery/78ed337a4a049057aafa560de7b0af1c) that will push your theme when run:

You just need to add your admin key, theme location and blog URL. This script has saved me so, so much time!

Well that's it! If you use Ghost, I do hope you've picked up some helpful tips here. If you have a comment or question, they're open so ask away!