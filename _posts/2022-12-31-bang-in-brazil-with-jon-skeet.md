---
layout: post
title: "Weird Brazil Date Bug with Jon Skeet"
image: "https:/images.unsplash.com/photo-1608370617993-a5c9ee904646"
date: "Sat Dec 31 2022 00:57:53 GMT-0800 (Pacific Standard Time)"
categories: video
summary: "Digging through my archives once again and found this wonderful video with Jon Skeet doing what he loves to do: sleuthing date bugs and answering questions on StackOverflow!"
---

Back in 2011 or so I recorded a series of videos with Jon Skeet, dissecting answers to his StackOverflow questions that he found interesting.

Jon starts things off by sleuthing out a rather hairy Date/Timezone bug which, evidently, only happens in Brazil. To make matters even more interesting, the code is written in Objective-C on iOS6!

Jon is _not_ an iOS developer yet he still managed to get credit for this answer! I love how he digs into a passion of his: _dates_.

Here's the original question:

[Why does NSDateFormatter return nil date for these 4 time zones?Try running this in iOS6 (haven’t tested pre iOS6): NSDateFormatter \*julianDayDateFormatter = nil;julianDayDateFormatter = \[\[NSDateFormatter alloc\] init\];\[julianDayDateFormatter setDateFormat:@”...![](https://cdn.sstatic.net/Sites/stackoverflow/Img/apple-touch-icon.png?v=c78bd457575a)Stack Overflowlpa![](https://cdn.sstatic.net/Sites/stackoverflow/Img/apple-touch-icon@2.png?v=73d79a89bded)](https://stackoverflow.com/questions/12922645/why-does-nsdateformatter-return-nil-date-for-these-4-time-zones)

### Other Links

* [Wikipedia Entry on Julian Dates](http://en.wikipedia.org/wiki/Julian%5Fday)
* [Documentation on NSDateFormatter](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSDateFormatter%5FClass/Reference/Reference.html)