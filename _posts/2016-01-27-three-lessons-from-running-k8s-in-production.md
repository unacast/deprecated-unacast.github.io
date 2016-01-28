---
layout: post
title: "Three lessons from running Kubernetes in production"
ghavatar: 53291
ghname: heim
jobtitle: Lead Platform Engineer
---

<div class="message">
  We have been running a handful of services on <a href="https://k8s.io/">Kubernetes</a> for the last 6 months. Here I will summarize some takeaways and patterns that have arisen.
</div>

<img src="/images/k8s/k8slogo.png" alt="k8s logo" width="300px">


## Some words about our setup
We are running Kubernetes (K8S) on Google Container Engine (GKE). GKE is hosting the Kubernetes master so we don't need to worry about it going down. We also run different clusters for different environments, to ensure that if we screw up in development, it does not affect production. It should be noted that this post is not to be considered an introduction to Kubernetes, and will not necessarily explain concepts in detail. Please refer to the excellent [Kubernetes documentation](https://k8s.io) for an introduction.

## 1. Environment detection

As we run one cluster per environment we cannot use Kubernetes namespaces to detect what environment we are running in. We have tried a few different approaches to this. The most intuitive approach was to use environment variables in the ReplicationControllers, but this meant that we would have to interpolate the correct environment variable at deploy time. To do this, we wrote a script that generated the correct ReplicationController at deploy-time. 

<script src="https://gist.github.com/heim/31c619e95fb110c800cf.js"></script>

Since almost all of our apps need some way to identify what environment it is running in this would have to be replicated for each application. Because of this, we came up with a second solution where we create a Kubernetes `secret` in each environment. The secret contains a file with one line of text in it, and that is the environment the cluster is running in. We then mount that secret on all pods and the pods themselves are free to read the environment at startup.

This is usually done in the Dockerfile when the containers start, like this:

`CMD ENVIRONMENT=$(cat /etc/secrets/environment) ./run.sh`.

This is a bit more flexible and ensures that the environment is perceived as the same for all applications in the cluster.



## 2. Deployment
As we do [all our deployments through Slack](http://labs.unacast.com/2015/10/26/chatops-at-unacast/) we needed some way of automating deployment to K8S. This is still much a work in progress, but we have ended up with a pretty stable default script to do this. The goal is to be able to update the ReplicationController at each deploy so that we can mount volumes, open ports, update labels etc. 

Updating the image in the ReplicationController does not automatically update already running pods, so to actually deploy a new version we also need to do a [rolling update](http://kubernetes.io/v1.1/docs/user-guide/update-demo/README.html). We also want the script to conditionally update the ReplicationController or create it if it does not exist in the given environment.

The following gist shows a simplified version of our deploy script. It assumes that you already are authenticated to the correct cluster and that the image is passed as a parameter. It also assumes that you have a script that creates a ReplicationController YAML file with the correct image.

<script src="https://gist.github.com/heim/ce686b7d74d222d82611.js"></script>

This is by no means a fail-proof script, and this only proves the point that the Kubernetes authors really need to finish their 
[Deployment API](https://github.com/kubernetes/kubernetes/blob/release-1.1/docs/proposals/deployment.md) really soon.

## 3. Monitoring
GKE comes with a monitoring solution from Google (Google Cloud Monitoring), that gives insight into amongst others cpu and memory usage for your pods. We have found the bundled monitoring solution to lack some important aspects, so we opted to use [DataDog](http://datadoghq.com/) for our monitoring needs. 

DataDog provides a really good integration with Kubernetes that we have found very useful, so it is something we would definitely recommend looking into. A small caveat does exist if you run K8S on GKE since GKE does not support the Kubernetes Beta API in general, and more specifically does not have support for [DaemonSets](http://kubernetes.io/v1.1/docs/admin/daemons.html).

The DataDog-agent depends on DaemonSets to run exactly one agent on each Kubernetes node, but a small hack will fix this. The trick is to create a ReplicationController with `replicas = number of nodes` and specify a hostPort in the template spec. This prevents that two Datadog agents run on the same node.

<script src="https://gist.github.com/heim/bf408f319d0ee38b6002.js"></script>

To get the most out of your monitoring solution, it is important to use consistent labels on your pods. This enables you to group metrics across tiers and applications and get better insights into your metrics.

We have landed on a set of fairly simple, but flexible label conventions that gives us the insight we need.
Let's imagine we have an app called "Awesome" which consists of two pods.  One pod that is running a backend API and one frontend-pod serving HTML. Those would then have the following labels. For 

**Backend pod:**

`name=awesome-api, app=awesome, tier=backend, role=api`

**Frontend pod:**

`name=awesome-frontend, app=awesome, tier=frontend, role=web`

Further, let's imagine we have 20 different apps that adhere to the same labeling conventions. Now we can collect metrics across apps and across tiers. If we also apply a "language"-label to our pods we can, for instance, graph the memory usage of all JVM-based apps, or all our NodeJS-apps.


## Summary
Kubernetes is in our experience a solid platform to run micro services on, and it is under heavy development. There is also many exciting features in progress, amongst others the Deployment API. If you are already running Kubernetes or consider doing so, I would recommend that you join  [Kubernetes on Slack](http://slack.kubernetes.io/) and also the [Google Cloud Platform Community](https://gcp-slack.appspot.com/).
