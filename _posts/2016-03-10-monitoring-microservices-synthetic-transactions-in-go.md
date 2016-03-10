---
layout: post
title: "Monitoring microservices with Synthetic Transactions in Go"
ghavatar: 310118
ghname: gronnbeck
jobtitle: Platform Engineer
tags: [rest, api, microservices, go]
---

<div class="message">

In this post we look into the concept of Synthetic Transactions, and how to
get started with the implementation of a Synthetic Transaction tester.

</div>


At Unacast we are building software that scale to process millions of
proximity interactions each day. We believe the best approach for building
scalable and agile systems is microservices. Meaning, we believe in small,
smart and focused applications over large ones. It also
enables us to continuously experiment with new stuff, have fun,
learn things and always choose the best tools to achieve a specific task
rather than to make unnecessary or boring tradeoffs.

I have lately been looking into Go and wanted to gain some experience
with building software in it. So I used this opportunity to build a real
system using Go.

### Monitoring Microservices

However, as you might already know, running and keeping track of multiple
services is hard, and monitoring is therefore essential. Since most of our
services run using Docker, we use Kubernetes to help us keep our services
running if they crash unexpectedly, and we couple
Kubernetes together with [DataDog](https://www.datadoghq.com/) to help
us monitor all our software environments.

Yet, when bugs, that does not crash a service, find their way into production
Kubernetes' monitoring is of no use. With that in mind it is easy to see that
we are in need of some other type of monitoring to see if our services are
healthy. We decided on experimenting with a concept called
[Synthetic Transactions](http://martinfowler.com/articles/microservice-testing/).

### Synthetic Transactions

Synthetic Transactions is a monitored transaction that is performed on a
system running live in production. Such transactions are used to monitor
that the system at hand performs as expected.

In the world of e-commerce a synthetic transaction can be a transaction that
continuously tries to place an order and monitors if that order succeeded or not.
If it does not succeed, it is an indicator that something is wrong and should get
someone’s attention immediately.

At Unacast we use synthetic transactions to monitor our Interactions API.
The single purpose of the Interactions API is to accept and ingest interactions
for further processing. Since we are a data-oriented company, we are in big
trouble if the Interactions API starts failing silently.

### Building synthetic transaction tester

Usually we buy such services and there are a lot of great tools out there,
such as [NewRelic Synthetics](http://newrelic.com/synthetics) and [Pingdom](https://www.pingdom.com/).
But since the ``synthetic transactions`` has to know the inner workings
of our infrastructure we decided to try to build it our self.

There are several ways of building synthetic transactions. Ideally, they
should be represent a complete transaction. However, I would argue that it
is smarter and more pragmatic to build step by step. In this post we will
go through the first step of building a synthetic transaction tester.
We will share the subsequent steps in future posts.

### Step 0: Monitor for expected response

The first natural step is to create a monitor that runs regularly and checks if
a known request gets the expected response.

Performing a HTTP request is simple and is easily done with the
stdlib alone:

<script src="https://gist.github.com/gronnbeck/452cb79403bf4b4862e4.js"></script>

In the code above we specify a ``SyntheticPayload`` that is the specific request
object we want to send. We specify and send the payload in ``syntheticHttpRequest``
and parse the ``http.Request`` to specifically
check if the http status code returned is 202. If it is not, or the request fails,
we suspect that there is something wrong with the API, and returns error codes
indicating that some further action should be taken.

In the event where a synthetic transaction fails we use DataDog,
integrated with Slack and PagerDuty, to notify us that something fishy is going on.
Specifically, we send Events to DataDog using their API from the synthetic
transaction tester. We did this using an unofficial DataDog Go library by
[zorkian](https://github.com/zorkian/go-datadog-api) and it looked something like this:

<script src="https://gist.github.com/gronnbeck/236e8f68d2b0d13ad3ce.js"></script>

This is a simple way of telling DataDog that everything is OK. We use the event
tags to separate between error events and events coming from non-critical
environments. This is important because no one wants to get a call in the
middle of the night because the development or staging environment is
not working as optimal.

Finally, we need to be able to schedule these request. For that we used
[cron for go](https://godoc.org/github.com/robfig/cron). Putting all the parts together we got something
that looked like the following code snippet.

<script src="https://gist.github.com/gronnbeck/601f353875f89334b52a.js"></script>

Disclaimer: The code above is just an  a simplification of how it can be implemented, and does not show a complete implementation.

#### Monitoring the synthetics transaction tester

As you might have guessed the synthetic transaction tester is also a microservice.
So how should we proceed to monitor it? It is obvious that it cannot monitor itself.
The solution was to monitor the "OK" events we described earlier.
If these events suddenly stop arriving at DataDag we know that something
is wrong and we can react accordingly.

### Further steps

A simple but powerful extension of step 0 is to log metrics such as response time
for each request. Such external metrics will be a more accurate measure
of response time than just calculating the process time internally in a service.
It can also be used to trigger alerts if the system is slow to respond,
indicating a more critical issue that requires further investigation.

In the future it will be natural to extend the synthetic transaction service by verifying
that data has been processed. In our case, interactions are processed and safely
persisted when they reach one of our [BigQuery](https://cloud.google.com/bigquery/) tables after passing
through [AppEngine](https://cloud.google.com/appengine/), [Pub/Sub](https://cloud.google.com/pubsub/) and [Dataflow](https://cloud.google.com/dataflow/).
It is therefore natural for us to extend the synthetic transactions monitorer
to check and verify that the transactions has been persisted as expected.

In addition to verifying that transactions has been persisted as expected.
We could also start to measure and deduce the expected processing time
of an interaction and use this measurement to monitor if our system as a whole
works efficiently. Also, we can use the same numbers to verify if the system
delivers as promised according to the SLA.

Finally, an extension  could be to support live
[consumer-driven contract testing](https://www.thoughtworks.com/radar/techniques/consumer-driven-contract-testing). That is, explicitly check and verify that
the response payload was correct. By doing so we can go to bed at night without
worrying if we have broken the API for any of its consumers.  

### Enjoyed this post?

We are still learning and eager to share what we are learning along the way.
If you enjoyed this post I recommend that you keep in touch because it is a
lot more to come. Also, check out some of the posts about microservices
 written by my awesome colleges:

* [Building microservices with Scala and akka-http](http://labs.unacast.com/2016/03/03/building-microservices-with-akka-http/)
* [Three lessons from running Kubernetes in production](http://labs.unacast.com/2016/01/27/three-lessons-from-running-k8s-in-production/)

[synthetic-transactions]:http://martinfowler.com/articles/microservice-testing/
[datadoghq]:https://www.datadoghq.com/
[nr-synthetics]:http://newrelic.com/synthetics
[pingdom]:https://www.pingdom.com/
[unacast-k8s-lessons]:http://labs.unacast.com/2016/01/27/three-lessons-from-running-k8s-in-production/
[zorkian]:https://github.com/zorkian/go-datadog-api
[go-cron]:https://godoc.org/github.com/robfig/cron
[gle-appengine]:https://cloud.google.com/appengine/
[gle-pubsub]:https://cloud.google.com/pubsub/
[gle-bigquery]:https://cloud.google.com/bigquery/
[gle-dataflow]:https://cloud.google.com/dataflow/
[cdc-testing]:https://www.thoughtworks.com/radar/techniques/consumer-driven-contract-testing
