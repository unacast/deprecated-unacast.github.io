---
layout: post
title: Creating background services in Android
ghavatar: 2993240
ghname: jarlefosen
jobtitle: Platform Engineer
tags: [android, sdk]
---

## Introduction

[@torbjornvatn](https://github.com/torbjornvatn) wrote in his blogpost [Welcome to Unacastle](/2015/11/03/welcome-to-unacastle/) about how to interact with beacons so your phone can greet you when you enter our office. Later he decided that a greeting message wasn't good enough, and that everybody should have their own personal theme song as described in [Your own personal theme song](/2015/12/14/personal-theme-song/) via a 3rd party application.

In this blogpost I will describe how you can setup your own background service in any Android application to enable this without using 3rd party applications.

<div class="message">
    How do you create a background service in Android that lives its own life?
    And can you communicate with it?
</div>

## Android background service?

> Scenario:
> I really want my application to check the time every second, even if the application is closed.
> And when the application is open, it should be able to display the current time from the service.

This isn't really a useful scenario, but the process of getting this up and running is the same as other more useful tasks.

So how do you create a long running background service in Android?

We will build a background service that fires a callback every second to anyone listening.
To avoid too much work on the `main thread`, the service will do all its work on a separate low priority thread.
And it should be kept running in the background at all times, even when the application is closed.

### Let my service run - always

In the `onStartCommnd` method inherited from `Service` you can define how the service should behave, and we want it to stick around, so we will return `START_STICKY`.

This doesn't mean it won't be killed, but the service will restart whenever the application is closed, or the device boots.

<script src="https://gist.github.com/jarlefosen/6325f3cde50d95a2805f9689dc101ebb.js?file=MyService.java"></script>

We don't want to add extra work on the main thread as this is sacret and intended for the UI.
A way of doing this is to initialize a looper on a different thread.

<script src="https://gist.github.com/jarlefosen/6325f3cde50d95a2805f9689dc101ebb.js?file=MyService_handler.java"></script>

Now we can schedule our work on this thread instead, which has a low priority giving the main thread the resources needed to avoid unecessary UI lag.

Let's check the time. Since we want to do this every second or so, I suggest implementing a `Runnable` that does the scheduling for you.

<script src="https://gist.github.com/jarlefosen/6325f3cde50d95a2805f9689dc101ebb.js?file=RepeatRunnable.java"></script>

Now we can utilize this to execute time checking every second.

<script src="https://gist.github.com/jarlefosen/6325f3cde50d95a2805f9689dc101ebb.js?file=MyService_schedule_time.java"></script>

Let's make sure this starts up when the application starts for the first time.

<script src="https://gist.github.com/jarlefosen/6325f3cde50d95a2805f9689dc101ebb.js?file=MyApplication.java"></script>

If you look in the log you should see the date printed every second.

### Setting up communication interface

What we're doing now isn't very useful. We should probably define an interface for the service to talk to other parts of the application.
And for that we need two parts, an interface to listen for updates and an interface to communicate to the service.

<script src="https://gist.github.com/jarlefosen/6325f3cde50d95a2805f9689dc101ebb.js?file=MyService_interfaces.java"></script>

To be able to utilize these interfaces our service also has to handle them, and for that we use the `onBind` method in our service.

<script src="https://gist.github.com/jarlefosen/6325f3cde50d95a2805f9689dc101ebb.js?file=MyService_bind.java"></script>

And let our previous time checker runnable update listeners every time we're fetching a new Date object.

<script src="https://gist.github.com/jarlefosen/6325f3cde50d95a2805f9689dc101ebb.js?file=MyService_time_checker.java"></script>

Notice that we're pushing callbacks on the main thread, this is so we don't end up with



### Now we're ready to invite Activities to listen for updates

<script src="https://gist.github.com/jarlefosen/6325f3cde50d95a2805f9689dc101ebb.js?file=MyActivity.java"></script>

We know that the service will send messages to the listener on the main thread, so we can safely update the UI directly when the listener is called.
By registering and unregistering on `onResume` and `onPause` we also make sure its safe to update the UI.
