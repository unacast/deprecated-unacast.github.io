---
layout: post
title: "How Datasplash improved our Dataflow"
ghavatar: 4453
ghname: torbjornvatn
name: Torbjørn Vatn
jobtitle: Senior Platform Engineer
tags: [Dataflow, Datasplash, SCIO, Data pipelines]
---


<div class="message">I really want to use Dataflow, but Java isn't my 🍵 <br/> What to do? </div>

## A brief intro to Dataflow

<figure>
  <img src="https://www.gstatic.com/cloud/images/products/artwork/dataflow-diagram.png">
  <figcaption>Image credit <a href="https://cloud.google.com/dataflow/">Google</a></figcaption>
</figure>


[Dataflow](https://cloud.google.com/dataflow/) is

> A fully-managed cloud service and programming model for batch and streaming big data processing.

from Google. It is a unified programming model (recently open sourced as [Apache Beam](https://cloud.google.com/blog/big-data/2016/08/cloud-dataflow-apache-beam-and-you))
and a **managed service** for creating ETL, streaming and batching jobs. It's also seamlessly integrated with
other Google Cloud services like Cloud Storage, Pub/Sub, Datastore, BigTable, BigQuery. The combination of automatic
resource management, auto scaling and the integration with the other Google Cloud

### So how do we use it?

Here at [Unacast](https://unacast.com) we receive **large** amounts of data, through both files and our APIs, that we
need to filter, convert and pass on to storage in e.g. BigQuery. So being able to create both batch (files) and
stream (APIs) based data pipelines using one DSL, running on our existing Google Cloud infrastructure was a big win.
As Ken wrote in [his post on GCP](http://labs.unacast.com/2016/11/30/one-year-on-gcp/#dataflow) we try to use it every
time we need to process a non-trivial amount of data or we just need to run continuously running worker. Ken also mentioned
in that post that we found the Dataflow Java SDK less than ideal for defining data pipelines in code. The piping
of transformations (pure functions) felt like something better represented in a proper functional language. We had
a brief look at the Scala based [SCIO](https://github.com/spotify/scio) by
<img alt="spotify" src="/images/datasplash/spotify.png" style="height: 20px; margin-bottom:2px"/> (which is also donated to [Apache Beam](https://issues.apache.org/jira/browse/BEAM-302) btw).
It looks promising, but we felt that their DSL diverged too much from the "native" [Java/Beam one](https://github.com/spotify/scio/wiki/Scio%2C-Dataflow-and-Beam).

Next on our list was [Datasplash](https://github.com/ngrunwald/datasplash), a thin
<img alt="Clojure" src="https://qph.ec.quoracdn.net/main-qimg-516e5be0cc307adbdc22f811eeed91e4?convert_to_webp=true" style="height: 26px; margin-bottom:4px"/> wrapper
around the Java SDK with a Clojuresque approach to the pipeline definitions, using concepts such as `->>` (threading),
`map` and `filter` mixed with regular clojure functions, what's not to like? So we went with Datasplash and have really
enjoyed using it in several of our data pipeline projects. Since the Datsplash source is quite extensible and relatively
easy to get a grasp of we even have contributed a few [enhancements and bugfixes](https://github.com/ngrunwald/datasplash/graphs/contributors) to the project.

## And in the blue corner, Datasplash!

It's time to see of how Datasplash performs in the ring, and to showcase that I've chosen to reimplement the
[*StreamingWordExtract*](https://github.com/GoogleCloudPlatform/DataflowJavaSDK/blob/master/examples/src/main/java/com/google/cloud/dataflow/examples/complete/StreamingWordExtract.java)
example from the Dataflow documentation. A Dataflow-off, so to speak.
