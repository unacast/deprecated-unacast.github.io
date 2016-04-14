---
layout: post
title: "Monitoring microservices with Synthetic Transactions in Go: Part 2"
ghavatar: 310118
ghname: gronnbeck
jobtitle: Platform Engineer
tags: [rest, api, microservices, go]
---
In this post we will extend synthetic, a synthetic transaction tester, I wrote about in late February. The previous post can be found [here](). This post will focus on some pain points we have had with synthetic, and how we solved those problems. Specifically, we will look into two things.

1. How can we specify synthetic tests more declaratively using YAML
2. Automate setup of Datadog Monitors

I will go through these in order and provide Go code where it is suitable. Bear in mind that the code has been added for illustrative purposes, and might be out of context. I hope that is OK. And I’m still learning Go so the code provided might not be perfect, I appreciate any feedback.

## Declarative Synthetic Test Spec
In the previous [post]() every test had to be written in Go code. At the time of writing that made sense since we only had two running synthetic tests. As we started to add more tests to synthetic a test pattern emerged. Most of our tests performed multiple HTTP request and checked each request returned the expected response. Mostly checking if the status code was correct and that the JSON body contained certain elements. With that in mind we set out to create a declarative way of specifying such tests.

After tinkering a bit we landed on the following data structures and code to run the job specified.

<script src="https://gist.github.com/gronnbeck/bb3dcb6bfc3edd53e308a3c3e4ca67b7.js"></script>

<script src="https://gist.github.com/gronnbeck/a3f0b97b13cc8589fa3cbe3505156a8c.js"></script>

Notice that ``Schedule`` does not handle the events outputted by ``job.Run()``. We have omitted this due to readability.  ``leftContains`` which checks if the map on left-side are fully contained in the map on the right side, also omitted because it was very complex and way too embarrassing to open source as it is right now.

The following example uses the the structure defined above to specify a test job using Go code.

<script src="https://gist.github.com/gronnbeck/742b2e082e3c8fa6562e85e6a85506df.js"></script>

Which is quite much better than to imperatively specify each test. However, you are still writing Go code. And in case you did not remember, our goal is to be able to specify jobs using YAML. Wouldn’t it be great if we could specify something like this instead:

<script src="https://gist.github.com/gronnbeck/ebfd0a7a88a43e85d7d3e8645923b6da.js"></script>

It turns out that is quite easy, if you are willing to use a third-party library. Go does not have a standard library for parsing YAML. But luckily someone has already written a library for it called [gopkg.in/yaml.v2](https://github.com/go-yaml/yaml/tree/v2). Great!

A big drawback with the YAML approach is that we cannot specify different URLs or other variables for each environment. As described earlier each job is specific to each environment since the URL attribute is fixed per file. One way of fixing this is to specify a job for each environment. This will cause us to update every file when a job changes. That is not scalable.  Another approach is to add variables to the YAML specification. And that is exactly what we did.  We extended the YAML spec to the following

<script src="https://gist.github.com/gronnbeck/0003b16f49a781f0b2dad9b67d1f240a.js"></script>

And then we parse and replace envvars using the following code

<script src="https://gist.github.com/gronnbeck/0bcdf3c070191bcb13c49d9182a238b5.js"></script>

In other words, we solved the problem by reading envvars from the YAML file and then string replacing the variables with the correct values.

Putting everything together we are now able to specify a test using YAML and run it without having to write Go code.

## Automate Datadog Monitor Setup

Setting up a [Datadog]() Monitor for every environment for every test manually was tedious and caused a lot of errors. Even for three tests it was a crap. It is fair to say that it did not scale. So we decided to automate it! And luckily for us, both DataDog and the [DataDog third-party library]() we are using supports creating and updating Monitors using DataDogs API. The process is quite straight forward and is illustrated below

<script src="https://gist.github.com/gronnbeck/80b7f83b5b1367aa8745239881eba491.js"></script>

``SetupDatadogMonitor`` ensures that the monitor  is setup either by creating it or updating it. A monitor already exists if the ``title`` exists at DataDog. This check is quite weird but the monitor ids at DataDog is integers. And we didn’t want to waste time coming up with a scheme for creating unique integer ids. It’s weird but it works.

## Closing thoughts
In this post we looked into how we simplified the process of writing test jobs in synthetic by introducing YAML specifications and automate DataDog monitor setup. Yet, there are a lot of improvements to be done. I have lately been playing around with other hosted services for synthetic transactions. And there is a lot of inspiration to be drawn from these services.

Also, when we are ready we will be extracting synthetic from our code base and open source it.
