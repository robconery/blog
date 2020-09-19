---
layout: post
title: How To Replace a $600 Piece of Software with 100 Lines of Ruby
summary: "Believe it or not - this title isn't link-baiting. I have to deal with encoding video on a near-daily basis and it can be mind-numbing, frustrating, and time-consuming. I finally got fed up and rolled my own. It took 5 hours and 100 lines of Ruby. This is my story."
date: "2010-12-03"
uuid: "4xKaa0hz-COUd-vBZo-HuFq-nHxlwN4rGGpD"
slug: "video-encoding-rack-attack"
categories: Ruby
---

## The Old Toolset


I've encoded with a ton of tools and I know people will ask "hey did you try X? It's Da BOMB" and... well most likely I did. I've used everything from Camtasia to Adobe Premiere, Apple Final Cut Pro and Express, Any Video Converter, FFMPEGX, and finally Sorenson Squeeze.

Sorenson Squeeze is what I settled on because it offered a bit of workflow to the encoding process - and that's what I needed most. Something I could say "render this MOV to FLV with these settings, push to Amazon, and let me know when it's done." That's the promise anyway.

Turns out that it won't push to Amazon S3 - so I used Transmit (a Mac FTP/Amazon client that rocks) to mount a drive that pointed to Amazon. For some reason it never worked.

Squeeze also gives you a number of nice codecs to use - including their very own flash one. There's a lot of reasons to use the tool - but I needed to get this process a lot more customized so one Saturday a few months ago I wonked out...

## Rake, FFMPEG, and Happiness


The first thing I needed to do is create a rake file to run the ruby tasks. I'm using Ruby 1.9.2 with RVM installed (having RVM and 1.9.2 doesn't really matter - but just in case you want to know). So step one is to create a rake file - I called mine "rakefile.rb" and dropped it into my "viddy-vid" directory - maybe I should put this on Github and release it with that name ;).

The next thing I needed to do was install FFMPEG and make sure it had the codecs I needed. If you're on windows you can [go grab a pre-built binary](http://www.jiang925.com/content/ffmpeg-prebuilt) or you can build it yourself. If you're on a Mac just use Homebrew (or your favorite package manager) and make sure you have LAME installed with it, along with faac - these are needed if you want to stream your stuff. Your package manager should walk you through this.

First thing is to create your FFMPEG "incantations" - or command-line settings that you'll send to FFMPEG so it can encode your source. This can be rather involved and it took me some experimenting to get precisely what I want - and it's our secret sauce if you will - so I'll leave that part out and suggest you do some of your own experimenting :).

When we roll a new episode I push 4 videos up - this is our process:

 - Create a "master" uncompressed file. These are usually about 1.4 gigs or so
 - From that master, render an FLV for streaming (Adobe flash-native), 1280x720 MP4 (H.264) for HD downloads, an iPhone version, and an iPad native resolution version.
 - Once rendered, we zip the HD up to save space and bandwidth
 - Push the files to various buckets on Amazon S3 to be served behind CloudFront
 
The first bit of code needs to call to FFMPEG - and I don't want to do this serially. I want it all to happen at once (all 4 renderings). I have a monster machine here that can run encodings happily here's that code:

```ruby
desc "FLV encoder"
task :flv, :in do |t,args|
  file_in = args[:in]
  puts "Converting #{file_in} to FLV..."
  system "ffmpeg -i #{SOURCE_DIR}/#{file_in}.mov [FFMPEG settings] #{PRODUCTION_DIR}/#{file_in}.flv"
  send_to_secure("#{PRODUCTION_DIR}/#{file_in}.flv", "[bucket name]")
  puts "Done with FLV"
end
```

I should also take a second and mention the required gems/libraries to run all of the code you're about to see (more on these below):

```ruby
require 'rubygems'
require 'aws/s3'
require 'zip/zip'
```

This task takes a single argument - the "stub" if you will of the video file. In our case we have a particular naming scheme - something like "aspmvc_2" - so that's what I'd pass in: "rake flv ['aspmvc_2']". Rake would take that argument and go find the "master" - "aspmvc_2.mov" that's in the SOURCE_DIR directory (something defined somewhere in the rakefile - like "/Users/rob/videos" or something). The final argument is where the rendered file goes.

FFMPEG is invoked here using "system" - which just sends a command to the terminal running the rake task. When I run this it will invoke FFMPEG, which will use my incantations to render the file to my PRODUCTION_DIR - something like "Users/rob/Tekpub/Productions".

The next method is one I wrote - "send_to_secure" and it expects 2 arguments - the file reference and the bucket name. It then pushes that file to that lovely little bucket for me.

Believe it or not - this is pretty simple using the aws/s3 gem:

```ruby
def send_to_secure(file_path, bucket)

  file_name = File.basename(file_path)

  AWS::S3::Base.establish_connection!(
    :access_key_id     => 'YOUR_KEY',
    :secret_access_key => 'YOUR SECRET KEY'
  )

  puts "Sending #{file_name} to #{bucket}"
  AWS::S3::S3Object.store(
    file_name,
    File.open("#{file_path}"),
  bucket  
  )
  puts "It's Up there..."
end
```

It's actually surprising how well this works.

## Gettin Zippy


For our HD MP4s I also need to zip them up - so I use the "zip" gem and have a method called "zip_it":

```ruby
def zip_it(file_path)
  puts "Zippin it up..."
  file_name = File.basename(file_path,File.extname(file_path))
  base_dir = File.dirname(file_path)
  archive = "#{base_dir}/#{file_name}.zip"

  puts "Archiving to #{archive}"

  Zip::ZipFile.open(archive, 'w') do |zipfile|
    zipfile.add("#{File.basename(file_path)}",file_path)
  end
end
```

and then send that zipped file to the bucket in the same way I send the FLV: "send_to_secure(zip_file, bucket)".

## Asynchronous Please


I have a number of individual encoding methods - each handles a single encoding scenario as I mention above (for streams, downloads, iphones and ipad). I want to run these all at once - not one at a time - so to do this I want to invoke them in a "meta" way - not individually.

The first thing is to use a method I copied from Ryan Bates - something that will invoke a rake task for me:

```ruby
def call_rake(task, options = {})
  args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
  system "/usr/bin/rake #{task} #{args.join(' ')} &"
end
```

This will work better than Rake::invoke because that method will run a task synchronously. What I want to do instead is send the command to the command line and fork off the process - which is where the trailing "&" comes into play on the last line.

Finally I just need to wrap a call to each method into a single task:

```ruby
desc "Encode it!"
task :encode, :in do |t,args|
  #delete existing in case something went wrong
  puts "Here we go... Deleting existing..."
  file = args[:in]

  File.delete("#{SOURCE_PATH}#{file}.mp4") if File.exist?("#{PRODUCTION_PATH}#{file}.mp4")
  File.delete("#{SOURCE_PATH}#{file}.zip") if File.exist?("#{PRODUCTION_PATH}#{file}.zip")
  File.delete("#{SOURCE_PATH}480/#{file}.mp4") if File.exist?("#{PRODUCTION_PATH}#480/{file}.mp4")
  File.delete("#{SOURCE_PATH}#{file}_iphone.mp4") if File.exist?("#{PRODUCTION_PATH}#{file}_iphone.mp4")
  File.delete("#{SOURCE_PATH}#{file}.flv") if File.exist?("#{PRODUCTION_PATH}#{file}.flv")

  call_rake("flv",args)
  call_rake("iphone",args)
  call_rake("hd",args)
  call_rake("ipad",args)

  puts "Locked and loaded!"
end
```

This is called in a typically sparse manner: `rake encode['rails3_2']`. This lights up your console with output from FFMPEG output... and you can go have a beer while it renders and loads.

# #Performance


This is one place where I was really, really surprised. Sorenson has some pretty amazing codecs and it's rather fast - usually encoding an FLV in about 30 to 40 minutes. The file size was pretty reasonable as well - and I was generally happy.

FFMPEG, however, runs about 200% faster. It encodes the files - each of them - in about 5 to 10 minutes apiece. I almost fell out of my chair when I saw the encoding finish and I raced to check the file and ... sure enough! It looks great.

The only thing I can figure is that FFMPEG is free to use more system resources and that Sorenson is confined to a memory cap - or perhaps a processor cap. When I view the Activity Monitor I have 2 CPUs at full throttle - so my console is delegating the tasks out... somehow. I'm not a hardware wonk, but I do know that my machine doesn't slow down and the videos encode at light speed.

## 100 Lines, Seriously


When it started to run and work properly I have to say I was skeptical that it would "sustain" - but I've pushed the last 8 episodes we've put together using this script and... all I can say is that it's perfect. In fact I described this code as one of the best pieces of code I've ever written.

I'm serious about that - each time I use it it saves me a total of 3 hours, give or take. Before I'd do something else while Sorenson was running - then I'd come back after it was finished then manually push to Amazon. I'd do this 4 times for 4 files, and I'd never catch it when it was exactly finished - so the process always took longer.

Not only that - it also runs faster. So end-to-end it takes me about 1.5 hours to render/push a whole video set. Prior to this it easily took 3 to 4 hours.

"Best" is a subjective term - so let me define it, just as I did in the title: this 100 lines of Ruby code saves me many, many hours personally, and if I would have had it a year ago - it would have saved me $600 directly out of my pocket.

There's some math there - but I haven't written so little code that did so much in my life, ever.