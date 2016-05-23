---
layout: post
title: "Heterogeneous Kubernetes-clusters on Google Cloud Platform with node-pools"
ghavatar: 53291
ghname: heim
jobtitle: Lead Platform Engineer
---

Up until recently <a href="https://k8s.io/">Kubernetes</a> clusters running on GCP have only supported one machine-type per cluster. It is easy to imagine situations where it would be beneficial to have different types of machines available to applications with different demands. This post will detail how to add a new node-pool and ensure that specific pods are deployed to the preferred nodes.

<img src="/images/heterokube/eminems.png" alt="k8s logo" width="400px">

## Why not a cluster with different machines?

There is at least one good reason to run a cluster with a homogeneous machine pool, it is the simplest thing. And up to a certain level, that is the smartest thing to do. If all your applications running on k8s has roughly the same demands to e.g. CPU and memory, it is also something you can do for a long time.

What pushed us to explore heterogeneous clusters was mainly two things:
1. We had some apps demanding a much higher amount of memory than others
2. We had some apps that need to run on privileged GCP machines.

We could solve #2 by giving all machines the privileges needed, and we also did for a while. But to solve #1 it would be very expensive to upgrade all machines in the cluster to high memory instances.

Enter [node-pools](https://cloud.google.com/sdk/gcloud/reference/alpha/container/node-pools/).

## Node pools

Node pools is a fairly new, and very poorly documented, alpha feature on Google Container Engine that lets you run nodes with different machine types. Earlier you were stuck with the initial machine type, but with node-pools, you are also able to migrate your cluster from one machine type to another. 
This is a great feature, as migrating all your apps from one cluster to another is nothing I would recommend doing more than once.

All clusters come with a default pool, and all new pools need to have a minimum size of 3 nodes.

### Creating a new node pool

Creating a node pool is pretty straight forward, use the following command 

{% highlight bash %}
  $> gcloud alpha container node-pools create <name-of-pool> \
  --machine-type=<machine-type> --cluster=<name-of-cluster>
{% endhighlight %}

### Scheduling pods to specific types of nodes

To schedule a pod to a specific node or a set of nodes, one can use a `nodeSelector` in the pod spec. The `nodeSelector` needs to refer to a label on the node, and that's pretty much it. An alpha feature in Kubernetes 1.2 is [node affinity](https://github.com/kubernetes/kubernetes/blob/release-1.2/docs/design/nodeaffinity.md), but more on that in a later post.

There are a couple of ways to approach the selection of nodes. We could add custom labels to the nodes with the `kubectl label node <node> <label>=<value>` command, and use this label as the `nodeSelector` in the pod spec. The disadvantage of this approach is that you will have to add the new labels as you resize the node pool. The other and simpler solution are just to refer to the node-pool itself when scheduling a the pods.

Let us imagine that we added a node-pool with high memory machines to our cluster, and we called the new node-pool `highmem-pool`. When creating node-pools on GKE, a label is automatically added. If we do a `kubectl describe node <node-name>` we can see that the node has the following label: `cloud.google.com/gke-nodepool=highmem-pool`.

To ensure that a pod is scheduled to the node pools, we need to add that label in the `nodeSelector` like this:

{% highlight yaml %}
  apiVersion: v1
  kind: Pod
  metadata:
    name: nginx
   spec:
    containers:
    - name: nginx
      image: nginx
      imagePullPolicy: Always
    nodeSelector:
      cloud.google.com/gke-nodepool: highmem-pool
{% endhighlight %}

## Summary

Node-pools are a great new feature on GKE and something that makes Kubernetes much more flexible and also let you run different kinds of workload with different requirements.

