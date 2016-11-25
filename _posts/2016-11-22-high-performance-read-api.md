---
layout: post
title: "High Performance Read API on Kubernetes using Redis"
ghavatar: 310118
ghname: gronnbeck
jobtitle: Platform Engineer
tags: [api, api-design, go, golang, redis]
---

## Introduction

<div class="message">
  This post is best read with some prior knowledge to Kubernetes. You should be
  familiar with concepts like pods, services, secrets and deployments. Also,
  I'm assuming you've been working with kubectl before. Enjoy!
</div>

At Unacast we spend a lot of time creating web services usually in the form of JSON APIs.
And we've spent a lot of time designing and experimenting and researching to design them.
We've shared what we've learned along the way. A lot of these posts has been theoretical but
in todays post we're getting our hands dirty, and we're going to implement an API
that scales when being subject to massive amount of read requests. And we're doing
this using [Redis](https://redis.io). All the examples will be run using [Kubernetes](https://kubernetes.io).

We assume that the logic to keep the data in Redis updated has been
implemented somewhere else. And we also assume that the rate of adding or updating data (writes) is low.
In other words, we expect to have a multiple orders of magnitude more reads than writes.
Thus, in our tests we'll just contain read requests and no writes.

All code snippets included in this post can be found in its full form
[here](https://github.com/gronnbeck/examples/tree/master/scaling-redis-k8s).

## Redis

Before we get started we need to talk about Redis[.](https://youtu.be/kpk2tdsPh0A) The Redis team has described
Redis quite good on their homepage

> Redis is an open source (BSD licensed), in-memory data structure store,
used as database, cache and message broker.

In my own words, Redis is really fast and scalable in-memory database with a
small footprint on both memory and CPU. What it lacks in features it makes it
makes up for in speed and ease of use. Redis isn't like a relational store
where you use SQL to query. But it is shipped with multiple commands for
manipulating different types of data structures.

Redis is a really powerful tool and should be a part of every developers toolkit.
If Redis isn't the best fit for you, I'll still recommend investing time into
learning how and when to use a in-memory database.


## Architctures

Redis can be used in multiple ways. Each different approach has different
trade-offs and characteristics. We'll be looking at two different models
and test them on scalability. The two models we're testing are:

 1. **Central Redis:** one Redis used by multiple instances of the API.

 2. **Redis as a sidecar container**: Run a read-only slave instance of Redis for every
 instance of the API.

The performance tests will be run against the same service using the
same endpoint for both models. I've extracted the endpoint from *main.go*
and included it below.

<script src="https://gist.github.com/gronnbeck/688330c5bbcf8bd732aa0b28d3433314.js"></script>

The snippet does one simple thing. It asks Redis for a **string** that is
stored using the key **known-key**. And from this simple endpoint we'll
look how Redis behaves under pressure and if it scales. We expect different
behavior from the two different architectural approaches.
This example might seem constructed, a real world examples that is similar to this
approach is verification of api tokens. I agree that this might not be the best
way to do token verification but it's a very simple and elegant design.
For a more elegant solution you should consider [JSON Web Tokens](https://jwt.io/).

### Central Redis

As mentioned above a central Redis architecture is when we use one Redis instance
for all API instances. In our case these API instances are replicas of the same API.
This is not a restriction but it is a recommended architectural principal
to not share databases between different services.

In Unacast we believe in *not hosting your own databases*. We'll rather focus on
building stuff for our core business and not worry about operations. Normally, we use
Google Cloud Platform (GCP) for hosting databases. But hosted Redis isn't publicly
available at GCP so decided to use [compose.io](https://compose.io)'s Redis hosting.

Setting up the service using a single Redis is pretty straight forward using Compose.io.
Compose.io has some [great guides](https://www.compose.com/articles/get-started-with-redis-on-compose/)
on how you to get started with their Redis hosting as well.
The kube manifest for running a kubernetes deployment and service is added
below:

<script src="https://gist.github.com/gronnbeck/bb1af89336f4be490c180769959bcb67.js"></script>

### Redis as a sidecar container

Before we describe how to setup a Redis as a sidecar container. We've to give
short description of what a sidecar is. The sole responsibility of a
[sidecar container](http://blog.kubernetes.io/2015/06/the-distributed-system-toolkit-patterns.html)
is to support another container. And in this case the job of the
Redis sidecar container is to support the API. In Kubernetes we solve this
by bundling the API and a Redis Container inside one [pod](http://kubernetes.io/docs/user-guide/pods/).
And for those of us who don't remember what a Pod is, here is an excerpt for
the Kubernetes documentation:

> pods are the smallest deployable units of computing that can be created and
managed in Kubernetes.

Meaning that if a Redis container is bundled with an API container. They'll
always be deployed together on the same machine. Sharing the same IP and
port ranges. So don't try to bundle two services using the same ports, it'll
simply not work.

The following shows how to bundle the two containers together inside a
Kubernetes pod.

<script src="https://gist.github.com/gronnbeck/2fd6831fdfaac73d4ac0095f9e649854.js"></script>

By deploying this we'll have a Redis instances for each pod replica.
In this specific case we'll have three Redis instances. That means we need
some mechanism for keeping these instances in sync. Implementing sync functionality is
horrible to do on your own <sup>[citation needed]</sup>. Luckily, Redis can be run in master-slave mode
and we've a stable Redis instances hosted by compose.io.
By configuring every Redis sidecar instance as a slave of the master
run by compose.io. We can just update the master and not worry about
propagating the data the slaves. Our unscientific tests showed us that the Redis
master propagates data to the slaves really fast.

**NB! A caveat** is that you've to setup a SSL tunnel to compose.io to be able
to successfully pair the sidecar instances to compose.io's master instance.

We expect this architecture to scale better than the central Redis approach.

## Results

All the tests were run using a Kubernetes cluster:

  * 12 instances of g1-small virtual machines
  * 12 pod replicas

We used [vegeta](https://github.com/tsenart/vegeta) distributed on five
*n1-standard-4* virtual machines to run the performance tests.

The graphs below are the results from the performance tests.
The results focuses on success rate and response times.

### Central Redis

<iframe width="456.8733153638814" height="282.5" seamless frameborder="0" scrolling="no" src="https://docs.google.com/spreadsheets/d/e/2PACX-1vTWzQQ4UlXWlxfn0SAT7MVu3HASEsu4m1XtyShdDOGv8tfYxQpuD4tDBcg96LxdtZOgugagUDfmkIaA/pubchart?oid=736258819&amp;format=interactive"></iframe>

<iframe width="454.985275777447" height="281.26844262295083" seamless frameborder="0" scrolling="no" src="https://docs.google.com/spreadsheets/d/e/2PACX-1vTWzQQ4UlXWlxfn0SAT7MVu3HASEsu4m1XtyShdDOGv8tfYxQpuD4tDBcg96LxdtZOgugagUDfmkIaA/pubchart?oid=977901496&amp;format=interactive"></iframe>

### Redis as a sidecar container

<iframe width="453.9686411149826" height="280.7158333333333" seamless frameborder="0" scrolling="no" src="https://docs.google.com/spreadsheets/d/e/2PACX-1vTWzQQ4UlXWlxfn0SAT7MVu3HASEsu4m1XtyShdDOGv8tfYxQpuD4tDBcg96LxdtZOgugagUDfmkIaA/pubchart?oid=90127573&amp;format=interactive"></iframe>

<iframe width="448.5" height="277.3225" seamless frameborder="0" scrolling="no" src="https://docs.google.com/spreadsheets/d/e/2PACX-1vTWzQQ4UlXWlxfn0SAT7MVu3HASEsu4m1XtyShdDOGv8tfYxQpuD4tDBcg96LxdtZOgugagUDfmkIaA/pubchart?oid=191888955&amp;format=interactive"></iframe>

## Conclusion

As expected we see that the sidecar container scales better than the central
approach. We observe that the central approach is able to scale to about 15 000
reads/second, while the other can handle over 60 000 reads/second without
any problems. Remember that these tests are run on the same hardware and that
only a minor change in the APIs architecture resulted in a major performance gain.

## Closing Notes

One last thing, remember that utilizing multiple read-only slaves will behave
in the same matter as multiple read-only Redis slaves. We prefer using Redis
because of its speed, small footprint and ease of use.

We haven't been running this in production for a long time.
So we don't have any operational experience to share yet. And we intend
to share this in the future.

## Further work

This post didn't cover if the Redis as a sidecar container approach scaled
linearly as more CPU was added. This is outside of the scope of this post.
But our internal testing has shown this to be true. You're welcome to test this yourself.

At Unacast we're obsessed with monitoring. One of our mantras is
"monitoring over testing". And notice we haven't added any monitoring for the Redis
instances inside a pod. However if you're using Datadog, as we do,
it's fairly straight forward to add monitoring by bundling a dd-agent as
another sidecar container inside the same pod.

## Want more?

If you're interested in reading more about API design
I can recommend the following posts from our archive:

 * [Make API documentation great again](http://labs.unacast.com/2016/10/23/make-api-documentation-great-again/)

 * [Best practices for concurrency control in REST APIs](http://labs.unacast.com/2016/04/08/best-practices-for-concurrency-control-in-rest-apis/)

 * [Idempotency in REST APIs](http://labs.unacast.com/2016/02/25/on-idempotency-in-distributed-rest-apis/)
