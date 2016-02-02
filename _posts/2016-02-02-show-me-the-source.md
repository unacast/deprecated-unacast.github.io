---
layout: post
title: "Show me the source"
ghavatar: 4453
ghname: torbjornvatn
name: Torbjørn Vatn
jobtitle: Senior Platform Engineer
tags: [iBeacon, beacons, writeup, theme song]
---
## Small update

I've gotten a question about how the code 
backing our ["Personal Theme song"]({% post_url 2015-12-14-personal-theme-song %}) looks.
I've create a small Gist of it's two main parts; the `handler.clj` handling the webhook call from [Writeup](https://writeup.com/) 
and the `app.js` running on the RaspberryPi that plays the correct mp3 when it receives a websocket message.

The url of the websocket and our ids has been redacted to protect the innocent.

<script src="https://gist.github.com/torbjornvatn/4835120dbd6156c760d1.js"></script>
