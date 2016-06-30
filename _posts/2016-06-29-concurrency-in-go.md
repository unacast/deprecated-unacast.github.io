---
layout: post
title: "Introduction to concurrency in Go"
ghavatar: 310118
ghname: gronnbeck
jobtitle: Platform Engineer
tags: [go, golang, concurrency]
---

## Introduction
Today, I’m writing about concurrency and concurrency patterns in Go. In this blog post I will outline why I think concurrency is important and how they can be implemented in Go using channels and goroutines.

Disclaimer: This post is heavily is inspired by [“Go Concurrency Patterns”](https://www.youtube.com/watch?time_continue=3&v=f6kdp27TYZs) a talk by Rob Pike.

## Why is concurrency important?
Web services today is largely dependent upon I/O. Either from disk, database or an external service. Running these operations sequentially and waiting for them to finish will result in a slow and underperforming system. Most modern web frameworks solves the basic issues for you. That is, without setup it handles each http request concurrently. But if you need to do something out of the ordinary, like calling a few external services and combine the results you are mostly on your own.

The two most common models for concurrency that I’ve used is shared-memory model using Threads like in Java. Or callbacks used in asynchronously languages like in Node.js. I believe that both approaches can be insanely powerful when done right. However, that they’re also insanely hard to get right. Shared-memory model sharing state/messages through memory using locks and is error-prone to say the least. And asynchronous programming is, at least in my experience, a hard programming paradigm to reason about and especially to master.

## Concurrency in Go
Go solves concurrency in a different manner. It’s similar to Threads but instead of sharing messages through memory, go shares memory through messages. Go uses goroutines to achieve concurrency and channels for passing data between them. We will dig into these two concepts a bit further.

### Goroutines

Goroutines is a simple abstraction for running things (functions) concurrently.  This is achieved by prepending ``go`` before a function call. E.g.

<script src="https://gist.github.com/gronnbeck/d80cad16aff1514d32689bb3f11c5cdf.js"></script>

A good example of the concept can be found [here](https://tour.golang.org/concurrency/1)

### Channels

Channels is the construct for passing data between routines in Go. A channel blocks both on the sending and receiving side until both are ready. Meaning a channel can be used for both synchronising goroutines and passing data between them. Below we see a simple example of how to use channels in Go. The basic idea is that data flows the same directions as the arrow.

<script src="https://gist.github.com/gronnbeck/9c363b773e7bb43b4e58cea67ba8cb89.js"></script>

In the example below we see how channels and goroutines can be used to create a function utilising concurrency that is easy to understand and reason about.

## Example: using goroutines and channels

First let’s assume we want to create a service that asks three external services and return them. Let’s call these three services Facebook, Twitter and Github. For simplicity, we a fake communication with each of these services, such that the result of each service can be found at ``https://localhost/{facebook, twitter, github}``, respectively.

The behaviour for ``GetAllTheThings`` is to fetch data from all services defined and combined them into a list. Let’s start with a naive approach.

<script src="https://gist.github.com/gronnbeck/6caa0bac97e217e9542d41ab35398da4.js"></script>

Above we see an example implementation of the naive approach. In other words we query each service sequentially. That means that the call to the Github service has to wait for the Facebook service. And the Twitter service needs to wait on both Github and Facebook. Since each of these services are not dependent on each other. We can improve this by performing the requests concurrently. Enter channels and goroutines.

<script src="https://gist.github.com/gronnbeck/4feddc7018cd917aceea0e2d471bc978.js"></script>

(PS: I’ve ignored handling errors in the concurrent examples. Don’t do this at home. It’s just for pure readability).

We’ve now modified the naive approach using channels and goroutines. We see that each call is being issued inside a goroutine. And that the results are being collected in the for-loop at the end. The code can be read sequentially and therefore easy to reason about. It’s also explicitly concurrent since we explicitly issue several goroutines. The only caveat is that the results may not be returned in the same order as the routines were issued.

Notice that we can still are able to use the naive approach for fetching a resource: ``naive.Get(path string)``. And that the signature of the function is exactly the same as before. That is powerful! But does it actually run faster?

In ``main.go`` we put everything together and do measure execution time to see if its actually faster.

<script src="https://gist.github.com/gronnbeck/f40f95750c5ace8337afe03b1664c275.js"></script>

<script src="https://gist.github.com/gronnbeck/6c58e8cec31565c5f70f96577b93b327.js"></script>

The conclusion is yes, it runs faster. Actually, it runs an order of magnitude faster. If you want to run these experiments your self or just curious about the implementation. The full example project can be found [here](https://github.com/gronnbeck/concurrencypatterns).

## Closing notes

We have shown that it’s easy to utilise concurrency in Go using channels and goroutines. However, this post has simplified a lot and the caveats you may encounter using channels and goroutines are not fully addressed here. So use channels and goroutines with caution. They can cause a lot of headache if over used. The general advice is to always start by building something naive before optimising.

I hope you have enjoyed reading this post. If I’ve done something unidiomatic please tell me so in the comment below or on twitter ([@gronnbeck](https://twitter.com/gronnbeck)). I’m still learning and having fun with Go. And I’m always eager to learn from you as well.
