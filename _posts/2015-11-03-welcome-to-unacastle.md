---
layout: post
title: "Welcome to Unacastle"
ghavatar: 4453
ghname: torbjornvatn
jobtitle: Senior Platform Engineer
---

When I started here at Unacast on Monday I got thrown at the deep end right away.

> Could you please write a blog post about some interesting tech stuff by Thursday? — Romet Kallas

Since it was my first day I hadn't done a whole lot worthy of blog post yet, except some fooling around with beacons to test different ways to greet visitors to our venerable [Unacastle](http://unacast.com/contact/). 
So I dived right in, did some more experiments and here's what I found out.


### Approach #1: Apple Wallet aka. Passbook
I found out that a really simple and straight forward way to interact with [iBeacons](https://en.wikipedia.org/wiki/IBeacon) is via the Wallet app (formerly know as Passbook) in iOS.

A card in Wallet can be associated with one or several iBeacons via it's UUID (and optionally the major and minor values for better precision). 
My contrived use case for this was that we could make Wallet based business cards for our selves that we could send to/share with potential business partners. 
When they later come to visit us at the Unacastle something like this would happen:

<div class="message">
  The white cube you see in the GIFs is an iBeacon with a on/off switch that I use to simulate that I'm entering the office and get in range of our welcome message beacon.
</div>

![wallet](/public/images/wallet_loop.gif) 

### The Google Chrome notification center scheme 
An alternative to Apple's iBeacon standard is the new kid on the block; [Google's Eddystone](https://github.com/google/eddystone). 
Contrary to iBeacons which only broadcast a data packet identifying the beacon with an UUID, the Eddystone specification supports URL and telemetry packets as well. 
The iOS version of Google Chrome has some limited support for interacting with so called Physical Web
objects broadcasting Eddystone-URLs, and a (somewhat useless) example of a Unacastle greeting using this approach could look something like this:

![chrome](/public/images/chrome_loop.gif)

These notifications doesn't trigger a notification of any kind, so it wouldn't be much of a greeting.

### Behind door number 3
Last but not least, we have the full-fledged native app way of doing things. If you develop a native iOS app, you're in full control of the beacon interaction (both iBeacons and Eddystone), and you could trigger notifications or modals to get the users attention when the encounter a beacon of interest. 
For my greeting experiment I chose to implement a mock Unacast employee app that would gives us small motivational quotes when we get in to the office in the morning. I used [Facebook's React Native](http://facebook.github.io/react-native/) with [iBeacon support](https://github.com/frostney/react-native-ibeacon) to make this rather crude example (skipping notifications or modals for simplicity)

![app](/public/images/app_loop.gif)

### Wrapping up
Out of the three techniques I've described in this post I would only consider the native app one to be usable for my Unacastle greeting use case. 
That's the only way I could give the user a real notification, not just a silent card on the lock screen (or worse, in the notification center). 
But if Chrome or [Opera](https://dev.opera.com/articles/release-the-beacons/) takes their Eddystone-URL support a bit further and ads notification possibilities of some kind, it would be an easy and wide-reaching alternative to native apps.
These are examples of the kind of interactions that Unacast helps integrate into the digital world.



