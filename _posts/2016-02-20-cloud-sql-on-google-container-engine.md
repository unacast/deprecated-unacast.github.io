---
layout: post
title: "On Google Container Engine and connecting it Cloud SQL"
ghavatar: 831318
ghname: frodebjerke
jobtitle: Platform Engineer
---

This post is a post-mortem of a two minute job taking us three days. Our two minute job at hand was connecting a Java application running on Google Container Engine to Cloud SQL. Normally a straightforward job, but due to several constraints it turned out to be a bit of a hustle.

If you are already working on the Google Cloud Platform you are likely to be familiar with both [Google Container Engine](https://cloud.google.com/container-engine/) and [Cloud SQL](https://cloud.google.com/sql/). Google Container Engine, henceforth GKE, is a fully fledged cluster management and container orchestration system, powered by [Kubernetes](http://kubernetes.io/). Cloud SQL is fully managed MySQL database service on demand.

According to the [Cloud SQL documentation](https://cloud.google.com/sql/docs/compute-engine-access) it is recommended to connect from GKE using a separate [SQL-Proxy](https://github.com/GoogleCloudPlatform/cloudsql-proxy). This proxy will handle authentication to your Cloud SQL instance. Connecting to Cloud SQL from your application will then be as easy as connecting to the host+port  of your SQL-Proxy instance, no password or further authentication steps necessary.

Using the SQL-Proxy is not strictly necessary, one could connect a GKE application to a Cloud SQL instance in [other](https://cloud.google.com/sql/docs/compute-engine-access#gce-connect-ip) more or less manual fashions. We did not chase those paths however as using SQL-Proxy is the solution recommended in the Cloud SQL docs.

As the SQL-Proxy is to run in a separate process there are numerous ways in which we can run it. Deciding upon an approach we gave weight to the following properties to be important: avoiding extra network jumps and transparency &mdash; it should be trivial to understand the purpose of the SQL-Proxy and its connection to our Java application.

## Try One (the future solution)

We liked to avoid adding a network jump between the SQL-Proxy and our application. As our application is replicated on several nodes in our GKE cluster using a Kubernetes [Replication Controller](https://cloud.google.com/container-engine/docs/replicationcontrollers/), we wanted to ensure SQL-Proxy was co-located on all the same nodes as our application.

In [Pods](https://cloud.google.com/container-engine/docs/pods/) on Kubernetes you can run side-car containers in addition to your main application container. Two traits of side-car containers are that they will run on the same node as its main container and be available on the localhost interface.

Being loosely-coupled, transparent and obtaining the two traits just mentioned we believe a side-car container is the preferred way of running SQL-Proxy.

Unfortunately, rolling updates when running multiple containers in a pod is currently not supported on Kubernetes. As we rely on rolling updates to deploy at will, we had to abandon this solution for now. This feature is however [merged](https://github.com/kubernetes/kubernetes/pull/17111) in the Kubernetes source, so it should be available in one of the next releases.

## Try Two

As we currently are unable to run SQL-Proxy in the same Pod, a second best option seems to run SQL-Proxy as a separate service. This entails giving up the desired property of ensuring no extra network jumps. As a temporary measure, it seemed a reasonable solution.

The SQL-Proxy however is designed to run on the same node as its application.

````go
var err error
if l, err = net.Listen(spl[0], "127.0.0.1:"+spl[1]); err != nil {
  return nil, err
}
````
*Snippet from [SQL-Proxy source](https://github.com/GoogleCloudPlatform/cloudsql-proxy/blob/1274cd3d89ac8826e1882355d60ffb2a0cdff116/cmd/cloud_sql_proxy/proxy.go#L133-L135)*

Then for this solution to be viable we would have to add a separate proxy in a side-car container in the SQL-Proxy Pod. That would leave us with the following flow:

````
Application -> Proxy -> SQL-Proxy -> Cloud SQL
````

Adding another step, the extra proxy, means adding complexity to an already at best mediocre solution. There must be something better.

## Try Three

Using Docker, keeping your containers simple and single purpose is a common best practice. In our third try we decided to devoid from that principle &mdash; running both the SQL-Proxy and our application in the same container.

A feature of [Go](https://golang.org/) make this approach more elegant than anticipated: Go-code compiles to binary machine code. The SQL-Proxy is written in Go, therefore we could run its binary in our application's Docker container without adding anything else than the binary itself.

To ensure having an up-to-date SQL-Proxy we have included a step in our application build script to build the SQL-Proxy from source. Building the SQL-Proxy we start a separate docker container which builds from source, then outputs a tar stream of the binary. We used [Dockerception](https://github.com/jamiemccrindle/dockerception) as inspiration for this pattern. Unpacking and mounting the binary file to our final application container is then trivial.

**Build application container script:**
````BASH
#!/bin/bash

set -e

docker build -t sql-proxy /path/to/sql-proxy-build-dockerfile
docker run sql-proxy > cloud_sql_proxy.tar
tar -xvf cloud_sql_proxy.tar -C bin/
chmod +x bin/cloud_sql_proxy
rm cloud_sql_proxy.tar

if [ ! -f bin/cloud_sql_proxy ]; then
  echo 'cloud_sql_proxy binary not created.'
  exit 1;
fi

docker build -t your_container_name .
````

**SQL-proxy build dockerfile:**
````dockerfile
FROM golang

RUN go get github.com/GoogleCloudPlatform/cloudsql-proxy/cmd/cloud_sql_proxy

CMD cd $GOPATH/bin/ && tar -cf - cloud_sql_proxy
````

**Exerpt from application dockerfile:**
````dockerfile
COPY 'bin/cloud_sql_proxy' '/opt/bin/cloud_sql_proxy'

CMD /opt/bin/cloud_sql_proxy -dir=/cloudsql -instances=some_instance_name:some_region:some_db_name=tcp:3306 & \
 java -jar application.jar
````

Of the thinkable solutions, this solution provides several desirable properties. Firstly, there will be no extra network jump as SQL-Proxy and application runs in the same container. Furthermore, it is quite transparent in design. If you inspect the application' Dockerfile you cannot fail to spot the SQL-Proxy being started before the application itself.

## Closing Notes
