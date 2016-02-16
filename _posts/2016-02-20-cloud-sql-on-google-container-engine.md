---
layout: post
title: "On Google Container Engine and connecting it Cloud SQL"
ghavatar: 831318
ghname: frodebjerke
jobtitle: Platform Engineer
---

This post is a post-mortem of a two minute job taking us three days. Our two minute job at hand was connecting a Java application running on Google Container Engine (GKE) to Cloud SQL. Normally a straightforward job, but due to several constraints it turned out to be a bit of a hustle.

If you are already working on the Google Cloud Platform you are likely to be familiar with both [GKE](https://cloud.google.com/container-engine/) and [Cloud SQL](https://cloud.google.com/sql/). GKE, short for Google Container Engine is a fully fledged cluster management and container orchestration system, powered by [Kubernetes](http://kubernetes.io/). Cloud SQL is fully managed MySQL database service on demand.

According to the Cloud SQL documentation it is recommended to connect from GKE using a separate [SQL-Proxy](). When running, this proxy will handle authentication to your Cloud SQL instance. Connecting to Cloud SQL from your application will then be as easy as connecting to the host+port  of your SQL-Proxy instance, no password or further authentication necessary.

Using the SQL-Proxy is not strictly necessary, one could connect a GKE application to Cloud-SQL instance in [other]() more or less manual fashions. We did not chase those paths however as using SQL-Proxy is the solution recommended by Google and the Google Cloud Platform.

As the SQL-Proxy would have to run in a separate process there are numerous ways in which we could run it. Deciding upon an approach we gave weight to the following properties to be important: avoiding extra network jumps and transparency &mdash; it should be trivial to understand the purpose of the SQL-Proxy and its connection to our Java application.

## Try One (the future solution)

We liked to avoid adding a network jump between the SQL-Proxy and our application. As our application is replicated on several nodes in our GKE cluster using a Kubernetes [Replication Controller](), we wanted to ensure SQL-Proxy was co-located on all the same nodes as our application.

In [Pods]() on Kubernetes you can run side-car containers in addition to your main application container. Two traits of side-car containers are that they will run on the same node as its main container and be available on the localhost interface.

Being loosely-coupled, transparent and obtaining the two traited just mentioned we believe a side-car container is the preferred way of running SQL-Proxy.

Unfortunately, rolling updates when running multiple containers in a pod is currently not supported on Kubernetes. As we rely on rolling updates to deploy at will, we had to abandon this solution for now. *LINK TO PULL REQUEST THAT HAS BEEN MERGED IN K8S.*

## Try Two

As we currently are unable to run SQL-Proxy in the same Pod, a second best option seemed to run SQL-Proxy as a separate service. This would mean we would have to give up the desired property of ensuring no extra network jumps. As a temporary measure, it seemed a reasonable solution.

The SQL-Proxy however is designed to run on the same node as its application.

````go
# Insert code from sql-proxy 127.0.0.1
````

Then for this solution to be viable we would have to add a separate proxy in a side-car container in the SQL-Proxy Pod. That would leave us with the following flow:

````
Application -> Proxy -> SQL-Proxy -> Cloud SQL
````

Not so elegant anymore, eh?

## Try Three

Using Docker, keeping your containers simple and single purpose is a common best practice. In our third try we decided to devoid from that principle &mdash; running both the SQL-Proxy and our application in the same container.

A feature of [Go]() made this approach more elegant than anticipated: Go-code compiles to binary machine code. The SQL-Proxy is built in Go, therefore we could run its binary in our application's Docker container without adding anything else than the binary itself.

````dockerfile
# EXERPT FROM OUR APPLICATION DOCKERFILE
````

To ensure having an up-to-date SQL-Proxy we added a step in our build script to build the SQL-Proxy from source. We used a separate temporary Docker container to build, this container outputs a tar stream of the binary which we easily could mount inside our final application container.

````dockerfile
# GO BUILD DOCKERFILE
````

## Closing Notes
