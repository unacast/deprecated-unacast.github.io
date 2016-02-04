---
layout: post
title: "Pi-LITE up your day"
ghavatar: 4453
ghname: torbjornvatn
name: Torbjørn Vatn
jobtitle: Senior Platform Engineer
tags: [iBeacon, beacons, writeup, theme song, greeting, raspberrypi, Pi-LITE, Tibe]
---

<div class="message">Everybody should have their own personal light show</div>

## The usual recap

In my two previous post (["Welcome to Unacastle"]({% post_url 2015-11-03-welcome-to-unacastle %}), ["Your own personal theme song"]({% post_url 2015-12-14-personal-theme-song %})) 
I've been writing about a little side project I've got going here at [Unacast](http://unacast.com) were I try to leverage beacon technology to create personalized greetings when we enter 
the office.

As my previous attempts have included smart phones, webhooks and third party
apps that has to be installed, I wanted to try something a little more low tech and offline.

## Introducing the Pi-LITE + Ti'Be combo

When Birte, our VP of Strategic Partnerships, came back from one of her
partner meetings with one of these:
![tibe](/images/pilite/tibe.jpg)
It was just what I needed to make this work. 
The [Ti'Be](https://www.mytibe.com/home) is a small beacon that you can attach
to your keys (or anything that you tend to missplace) that connects to an app
that among other things can locate the keys for you. Since this is a beacon
that I carry with me when I go to work every day, my plan was to create a
scanner that triggers an action when the Ti'Be gets in range. 
This is actually the opposite way of doing things compared to my last
experiment.

I remembered that I had a [Pi-LITE](http://openmicros.org/index.php/articles/94-ciseco-product-documentation/raspberry-pi/280-b040-pi-lite-beginners-guide) 
board for my RaspberryPi laying around, so I decided to make my "own personal light show".

## How it works

I wrote a small Node.js app to run on the RaspberryPi that scans for
iBeacons (in this case, just my Ti'Be identified by it's UUID) and on encounter
triggers the LED matrix of the Pi-LITE. The source code can be found on
[GitHub](https://github.com/unacast/beacon-greeter), feel free to play around
with it. I use [node-pilite](https://github.com/woodyrew/node-pilite) to
display stuff on the Pi-LITE and
[node-bleacon](https://github.com/sandeepmistry/node-bleacon) to scan for
beacons. 

## Demo time

_sorry about the cheesy music ;)_
<iframe width="560" height="315"
src="https://www.youtube.com/embed/fITL4kxQpYk" frameborder="0"
allowfullscreen></iframe>
_and a closeup to see the details better_
<iframe width="560" height="315"
src="https://www.youtube.com/embed/Y7LJ0A5yWOQ" frameborder="0"
allowfullscreen></iframe>


