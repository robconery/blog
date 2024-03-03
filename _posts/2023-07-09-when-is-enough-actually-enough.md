---
layout: post
title: "What Is Your Yeet Threshold?"
image: "https:/images.unsplash.com/photo-1614638485257-7efdbb2f9495"
date: "Sun Jul 09 2023 19:24:42 GMT-0700 (Pacific Daylight Time)"
categories: frontend
summary: Solving problems is what we do, but sometimes the solution is to burn it all down and start again, learning from your mistakes. How do you make this choice?      
---

I'm wrapping up a **2.5 day, 9 hour thrashfest** where trying to fix this bug, right here:

![](https://blog.bigmachine.io/img/2023/07/screenshot_17.jpg)

I'm working with Nuxt 3, Vue 3 and Vuetify for the [Accelerator Walkthrough](%5F%5FGHOST%5FURL%5F%5F/frontend-accelerator/) production I'm putting together and hit this little snag on Friday. It's now Sunday, right before noon PDT, and **I finally fixed it.**

I'm frustrated, of course. I did learn a few things, which is obviously groovy (and I'll share those)... but overall I think the thing that I exercised the most was my patience.

**I tend to pivot, quickly, when shit hits the fan**. Especially when dealing with three things as complex as Vue, Nuxt, and Vuetify.

I think [this quote from Adam Wathan](https://adamwathan.me/renderless-components-in-vuejs/), creator of Tailwind CSS, nails it:

![](https://blog.bigmachine.io/img/2023/07/screenshot_18.jpg)

I have an extremely low tolerance for nonsense and I faced a non-stop parade of nonsense this weekend that forced me to go outside and breath fresh air _far more_ than I wanted to.

Here's what happened...

## A Simple Tweak Explodes

I'm wrapping up the section of the walkthrough where we plug in authorization using an API call. Everything had started to click and I was breezing through the backend code stuff, and the final bit was to change the icon in the navigation list when the user logs in and verified as an owner of the given video course:

![](https://blog.bigmachine.io/img/2023/07/screenshot_19.jpg)

As you can see, the icons are laying out just fine and everything should work, right? This is when things fell apart and this fun little error showed up, destroying everything:

![](https://blog.bigmachine.io/img/2023/07/screenshot_17-1.jpg)

Everything stopped rendering properly when error triggered. The videos wouldn't load, the logout button stopped working, text didn't show up... painful.

Clicking through for more info led nowhere. No stack trace, nothing. Eventually **I tried a different browser (Brave) and saw something weird**. Instead of a "TypeError: child is null" error, I saw this:

![](https://blog.bigmachine.io/img/2023/07/screenshot_20.jpg)

Clicking through there I was able to set a few breakpoints and see what Vue was up to under the hood:

![](https://blog.bigmachine.io/img/2023/07/screenshot_21.jpg)

Vue is trying to remove an element from the DOM that it thinks shouldn't be there. But which one? Reading the `child` value didn't help at all as I couldn't tell what was being called to begin with.

Eventually I started removing everything, bit by bit, to see if the error would go away.

## Cut, Cut, Cut, Cut... Where Is This Coming From!?!

It took me 90 minutes to slowly and methodically slice out every single component in my application, and eventually I got to this:

![](https://blog.bigmachine.io/img/2023/07/screenshot_22.jpg)

This is the login modal that I've been using to log people in, which looks like this:

![](https://blog.bigmachine.io/img/2023/07/screenshot_23.jpg)

It pops up and, like so many sites out there, you get a code in your email and pop it in place. It looks great, sliding back and forth... but **using it in a modal window is, apparently, problematic**.

The solution? _I have no idea_. There is something in the way these windows are loaded into the DOM and removed from the DOM that is blowing up Vue. I didn't write any tricky code here - [I used exactly what was on the documentation page](https://vuetifyjs.com/en/components/windows/). In fact, if you scroll down that page you'll see the exact form I used for this login dialog.

_My_ solution turned out to be creating my own login page and ditching the modal. I could reuse most of the code and didn't need the sliding windows so ... what the hell. Turns out that it worked.

## Oh But It Wasn't Done With Me Yet

Creating my own page led to the next error, which was a new one, that happens when you click "Next" after entering your email:

![](https://blog.bigmachine.io/img/2023/07/screenshot_24.jpg)

Same deal - click through, no help. Try Brave, see a whole different error report:

![](https://blog.bigmachine.io/img/2023/07/screenshot_25.jpg)

This one, however, came with a crucial detail that I missed with Firefox:

![](https://blog.bigmachine.io/img/2023/07/screenshot_28.jpg)

Vue doesn't like a type I'm using with... an avatar? On my login page? Oh... right...

![](https://blog.bigmachine.io/img/2023/07/screenshot_26.jpg)

This is the little step number indicator in the top left. It doesn't like that I'm sending a number into `v-text`. So it blew up the application.

Wait a minute... where did this code come from? Oh, right, the Vuetify documention which is quite extensive and apparently full of weirdness:

![](https://blog.bigmachine.io/img/2023/07/screenshot_29-1.jpg)

I know they're doing their best and, if I'm honest, Vuetify has saved me mountains of time over the years. Except when I hit walls like this and end up giving that time back.

I was able to fix this by moving the `loginForm.step` to the slot, which is stupid, but it fixed the problem.

## Serious Q: How Long Do I Keep Beating On This?

I'm so, so close to being done with the UX "heavy lifting" but it's errors like this that stop me for _days_ that kill my motivation. I**'m trying to approach this whole walkthrough effort as real as I can make it** \- which means that I can't be afraid to stop and rebuild if I get cornered.

How long do _you_ wait? There are some great frameworks out there with ready-made templates that I could plug in and move on. I do know that they, just like any framework, come with their own quirks and ramp-up time too. I can't expect to just change and have it all work, but I _can_ expect troubleshooting to be easier the closer I get to pure CSS and HTML.

I really would love your feedback on this. Reply (if you get this via email) or pop a comment - I'd love to hear from you!