---
layout: post
title: "How Datasplash improved our Dataflow"
ghavatar: 4453
ghname: torbjornvatn
name: Torbjørn Vatn
jobtitle: Senior Platform Engineer
tags: [Google Dataflow, Datasplash, SCIO, Data Pipelines, BigQuery, PubSub]
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
around the Java SDK with a Clojuresque approach to the pipeline definitions, using concepts such as *->>* (threading),
*map* and *filter* mixed with regular clojure functions, what's not to like? So we went with Datasplash and have really
enjoyed using it in several of our data pipeline projects. Since the Datsplash source is quite extensible and relatively
easy to get a grasp of we even have contributed a few [enhancements and bugfixes](https://github.com/ngrunwald/datasplash/graphs/contributors) to the project.

## And in the blue corner, Datasplash!

It's time to see of how Datasplash performs in the ring, and to showcase that I've chosen to reimplement the
[*StreamingWordExtract*](https://github.com/GoogleCloudPlatform/DataflowJavaSDK/blob/master/examples/src/main/java/com/google/cloud/dataflow/examples/complete/StreamingWordExtract.java)
example from the Dataflow documentation. A Dataflow-off, so to speak.

The example pipeline reads lines of text from a PubSub topic, splits each line into individual words, capitalizes those
words, and writes the output to a BigQuery table

Here's how it the code looks in it's [entirety](https://gist.github.com/torbjornvatn/89804fe22277ac79f5ca7ab22ebf7b71), and I'll
talk about some of the highlights specifically about the the pipeline composition bellow.

First we have to create a pipeline instance, and it can in theory be use several times to create parallel pipelines.
<code data-gist-id="89804fe22277ac79f5ca7ab22ebf7b71" data-gist-file="streaming_word_extract.clj" data-gist-line="71-74"/>

Then we apply the different transformation functions with the pipeline as the first argument.
Notice that the pipeline has to be run in a separate step, passing the pipeline instance as an argument.
This isn't very functional, but it's because of the underlying Java SDK.
<code data-gist-id="89804fe22277ac79f5ca7ab22ebf7b71" data-gist-file="streaming_word_extract.clj" data-gist-line="81-82"/>

Inside *apply-transforms-to-pipeline* we utilize the [Threading Macro](http://clojure.org/guides/threading_macros)
to start passing the pipeline as the last argument to the *read-from-pubsub* transformation.
The Threading Macro will then pass the result of that transformation as the last argument of the next one, and so on
and so forth.
<code data-gist-id="89804fe22277ac79f5ca7ab22ebf7b71" data-gist-file="streaming_word_extract.clj" data-gist-line="45,47"/>

Here we see the actual processing of the data. For each message from PubSub we extract words (and flatten those lists
with mapcat), uppercase each word and add them to a simple row json object. Notice the different ways we pass functions
to map/mapcat.
<code data-gist-id="89804fe22277ac79f5ca7ab22ebf7b71" data-gist-file="streaming_word_extract.clj" data-gist-line="50,53,57"/>

Last, but not least we write the results as separate rows to the given BigQuery table.
<code data-gist-id="89804fe22277ac79f5ca7ab22ebf7b71" data-gist-file="streaming_word_extract.clj" data-gist-line="60-65"/>

And that's it really! No
<code data-gist-id="89804fe22277ac79f5ca7ab22ebf7b71" data-gist-file="java-examples.java" data-gist-line="1-3"/>
to apply a simple, pure function.

Here's a quick look at the graphical representation of the pipeline in the Dataflow UI.
<figure>
  <img src="/images/datasplash/dataflowui.png"/>
  <figcaption>This is the Dataflow UI view of the pipeline. 27.770 words have been added to BigQuery</figcaption>
</figure>

## Conclusion
To summarize I'll say that the experience of building Dataflow pipelines in <img alt="Clojure" src="https://qph.ec.quoracdn.net/main-qimg-516e5be0cc307adbdc22f811eeed91e4?convert_to_webp=true" style="height: 26px; margin-bottom:4px"/>
using Datasplash has been a pleasant and exciting experience. I would like to emphasize a couple of things I think have turned out
to be extra valuable.

- The code is mostly known Clojure constructs, and the Datasplash specific code try to use the same semantics. Like *ds/map* and *ds/filter*.
- Having a [REPL](http://www.tryclj.com/) at hand in the [editor](https://atom.io/packages/proto-repl) to test small snippets and function is very underestimated,
I've found my self using it all the time.
- Setting up aliases to run different pipelines (locally and in the ☁️ ) with different arguments via [Leiningen](http://leiningen.org/) has
also been really handy when testing a pipeline during development.
- The conciseness and overall feeling of "correctness" when working in an immutable, functional LISP has also been something
that I've come to love even more now that I've tried it in a full fledged project.
