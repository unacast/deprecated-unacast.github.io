---
layout: post
title: "Your own personal theme song"
ghavatar: 4453
ghname: torbjornvatn
name: Torbjørn Vatn
jobtitle: Senior Platform Engineer
tags: [iBeacon, beacons, writeup, theme song]
---

<div class="message">Everybody should have their own personal theme song</div>

### Recap

In my last post ["Welcome to Unacastle"]({% post_url 2015-11-03-welcome-to-unacastle %}) I described different ways we could greet someone who enters our 
humble [Unacastle](http://unacast.com/contact/). None of them are particularly elegant, ubiquitous or fun, so I wanted to find some other way to showcase
proximity based greetings.

The solution revealed it self after we had a meeting with a couple of the guys at [Writeup](https://writeup.com/). They are a Norwegian proximity focused startup with the tagline:

> Create your own proximity message service with iBeacons

They gave us one of their beacons to play around with (the white one to the right) 

![writeup beacon](/images/themesong/writeup-beacon.jpg) 

and when I discovered that Writeup allows you to specify a webhook, that will fire upon interaction, I got an :bulb:

<div class="message">
  What if I could make our dashboard TV in the hallway play a personalized theme song when we get into the
  office in the morning!
</div>

## Make it work

The first thing I had to do was to create some kind of service that would receive the webhook triggered by the Writeup app. As I belive in 
polyglotting when developing side projects like this, I deployed a small `Clojure/Compojure` app on `Heroku`. When it gets triggered by the 
webhook it looks like this. (`INFO: Account id: 96` is me trigging the beacon)

<script type="text/javascript" src="https://asciinema.org/a/31891.js" id="asciicast-31891" async></script>

The dashboard TV is powered by a Raspberry Pi, and I figured out that it can play mp3s using the TV's speakers. So all I had to do now 
was to write a small `node.js` app that connects to the `clojure` app via a websocket so it can get notified when the latter receives a beacon-interaction-webhook call.
It goes a little something like this.

<script type="text/javascript" src="https://asciinema.org/a/31770.js" id="asciicast-31770" async></script>

The last thing we needed to sort out was what songs to play and map them to our ids. We ended up with a quite interesting collection of tunes, e.g:

- :notes: Imperial March :notes:
- :notes: Every day I'm Hustlin' :notes:
- :notes: My Heart Will Go On :notes:

And this is what Andreas' personal theme song sounds (and looks) like.

<iframe width="420" height="315" src="https://www.youtube.com/embed/yWMJz8nfBHE" frameborder="0" allowfullscreen></iframe>
