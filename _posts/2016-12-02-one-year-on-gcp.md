---
layout: post
title: "One year on Google Cloud Platform"
ghavatar: 310118
ghname: gronnbeck
jobtitle: Platform Engineer
tags: [cloud, infrastructure, google cloud platform, gcp]
---

First, let me be frank and announce that we’ve been on the Google Cloud Platform (GCP) for little more than a year. And that I’ve not been working full time with GCP for a year, yet. Nonetheless, I feel ready to share some insights and thoughts on building microservices on GCP.

In this blog post will focus on why we at Unacast chose GCP as our cloud provider, why it’s still a good fit for us, and a few lessons learned of using the platform for about a year.

## Why Google Cloud Platform

Today the natural choice of cloud is Amazon Web Services (AWS). And with good reason. AWS pioneered many of the great cloud services out there, S3, EC2, Lambda etc. It has as far as I know the longest list of cloud components you can use to build your platform <sup>1</sup>. And it’s battle tested at scale by Amazon, Netflix, AirBnB and many others. So why did we choose GCP instead?

Actually, we didn’t. Unacast started out building its platform on a combination of Heroku and AWS. And after some fumbling, sessions of banging our heads against the wall, and some help from a consultant<sup>2</sup> we decided to try GCP. And with some effort and a lot of luck it turned out to be the right platform for us. The reason being two fold 1) GCPs big data capabilities and 2) it helps us minimise time used on operations.  

There is no secret that Google knows how to handle large amounts of data. And many of the tools provided at GCP is designed for handling storing and processing big data. Tools like Dataflow, Pubsub, BigQuery, Datastore, and BigTable are really powerful tools for data management. GCP also as great environments for running services like App-, Cloud Engine and Dataflow helps us maximise the time used to build business critical features fast, rather than using developer time on keeping the lights on.

## The Good Parts

#### Pubsub

Pubsub is a distributed publish/subscriber queue. It can be used to propagate messages between services, but at Unacast we've mostly used it to regulating back pressure. And it works great in scenarios where you want to buffer traffic/load between front-line API endpoints and sub stream services. We use this approach designing write-centric APIs that can handle large unpredictable spikes of requests. NB! Pubsub doesn’t provide any ordering guarantees, and it doesn’t provide any retention unless a subscription is created for a topic.

#### BigQuery

BigQuery is a great database for building analytics tools. Storing data is cheap and you only pay for querying and storing data. BigQuery is great because of its out of the box capabilities for querying large amounts of data really fast. To put things into perspective our unscientific tests shows that BigQuery can query 1GB of data as fast as 100GB (and probably even more). One thing to remember when using BigQuery is that it's an append-only database, meaning that you cannot delete single rows only tables<sup>3</sup>. So implementing data retention isn’t straight forward as in databases that allows delete.

#### App Engine

App Engine is a scalable runtime environment for Java designed to scale without having to worry about operations. App Engine is great if you need highly scalable APIs. But you can only use Java 7 and libraries whitelisted by Google. Because of this restrictions I’ve got mixed feelings for App Engine. Getting scale without worrying about operations is great but on the other hand the development process is a lot more complex. I would use App Engine where your API doesn’t need much logic or external dependencies, like an API gateway, but for more complex services I would use Container Engine instead.

#### Container Engine

Container Engine is GCPs answer for hosting linux containers. It’s powered by Kubernetes which is, as of writing, the de facto standard for scheduling and running linux containers in production. On GCP I view Container Engine as the middle ground between Compute and App Engine. Where I believe you get the best tradeoff between operational overhead and flexibility. With Kubernetes you can do interesting things as [bundle databases or other services together to increase performance](http://labs.unacast.com/2016/11/22/high-performance-read-api/) which is impossible in App Engine. However, you have to worry about updating your Kubernetes cluster and keeping the nodes healthy and happy. Adding some operational complexity, work and time spent on not adding features.

#### Dataflow

Dataflow all the things! Dataflow is GCPs next generation MapReduce. It has streaming and batch capabilities. Dataflow is so good that we try to use it every time we need to process a non-trivial amount of data or we just need to run continiously running workers. As of writing Dataflow only has a SDK for Java. And Java isn't necessarily the natural language for defining and working with data pipelines. Needless to say we started to look for non-official SDKs that could suit our needs. We found [Datasplash](https://github.com/ngrunwald/datasplash), a Dataflow wrapper written in Clojure, and are quite satisfied with it. Clojure  syntax and functional approach works very well when defining data processing pipelines. We're currently pretty happy with Datasplash/Clojure, at the time of writing we're running Dataflow pipelines written in Java and Clojure. Time will show if this is the right tool. A caveat with Dataflow on GCP is that it uses Google Compute Engines under the hood. And that means the quota limits for virtual machines can be a show stopper. Make sure to always have large enough limits while you're evolving your platform.

## The not so good

#### Stackdriver
Stackdrivers monitors sucks. At least from my experience of it. Monitoring is hard from the get go. Because its hard to know what to monitor and setting up real good monitors. If the monitor is too verbose and sensitive nobody cares when an alert is triggered, and if it’s too sensitive errors in production will go unnoticed. In my opinion [setting up custom metrics](https://cloud.google.com/monitoring/custom-metrics/creating-metrics) in Stackdriver is a horrible experience. And that is why we use [Datadog](https://datadoghq.com) for monitoring services and setting up dashboards. To be fair, Stackdriver has some good components too, especially if you’re using AppEngine. Stackdrivers Trace functionality is awesome for tracking what is slow in your application. And the logs module are easy to use and query for interesting info. My experience is that these two modules works really great out of the box.

#### CloudSQL
Cloud SQL is a great service for running a SQL database with automatic backups, migrate to better hardware, and easy setup and scale read-only replicas. But the SQL engine behind is MySQL. I’ve much respect for what MySQL achieved back in the day but [those days are over](https://grimoire.ca/mysql/choose-something-else). But because of the ease of use, infrastructure wise, we’ll probably still be using Cloud SQL in the nearest future. However I think we should always consider using Postgres through [compose.io](https://compose.io) or even AWS AuroraDB before settling for Cloud SQL.

## Closing notes

We haven’t been able to test all the features of GCP and some of them looks really promising. I’m really excited about the [machine learning](https://cloud.google.com/products/machine-learning/) module. And I hope they’ll support [Endpoints](https://cloud.google.com/appengine/docs/java/endpoints/) for other services than AppEngine soon.

Choosing the right cloud platform isn’t straight forward. It’s hard to know if the services provided by a platform at hand is the right services. We at Unacast have learned from first hand experience that more isn’t necessarily better. And that your first choice and instinct might not always be correct. We’ve still feel that GCP is the right choice for us, and I hope we don't grow out of it anytime soon, ideally, never.

## Footnotes

    1. Everything is a platform these days. To be honest I’m not sure what a platform is. But that it has to be one
    2. All consultants aren’t evil
    3. Not entirely true. Deletes are expensive not impossible.
