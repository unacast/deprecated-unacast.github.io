---
layout: post
title: "Trigger Dataflow pipelines with Cloud Functions written in Clojurescript"
ghavatar: 4453
ghname: torbjornvatn
name: Torbjørn Vatn
jobtitle: Senior Platform Engineer
tags: [clojure, clojurescript, dataflow, datasplash, cloudfunctions]
---

## What's the challenge?
Here at Unacast we utilize [Cloud Dataflow](https://cloud.google.com/dataflow/) from Google quite extensively and
we have both batch based and streaming pipelines. While the streaming pipelines are started on deploy and streams
messages from [PubSub](https://cloud.google.com/pubsub/), the batching pipelines need to be created and started by some external system. This is typically an application that either has some CRON-like schedule or that listens
for changes in a [Cloud Storage](https://cloud.google.com/storage/) bucket.
I must admit it feels a bit cumbersome to set up a separate app for triggers like this, as the Dataflow code itself is uploaded and run in its entirety in the Cloud.

_Wouldn't it be nice if we could use some Google Cloud hosted service for these triggers as well?_

## Enter App Engine CRON Service and Cloud Functions

This [blog post](https://cloud.google.com/blog/big-data/2016/04/scheduling-dataflow-pipelines-using-app-engine-cron-service-or-cloud-functions) by Google demonstrates how one can use [App Engines CRON functionality](https://cloud.google.com/appengine/docs/flexible/go/scheduling-jobs-with-cron-yaml) to trigger Dataflow periodically or [Cloud Functions](https://cloud.google.com/functions/docs/) to start pipelines when a file is uploaded/changed in a Cloud storage bucket.
The latter was exactly what I needed for my latest Dataflow project so I sat out to create a POC of this approach. The rest of this post is a summary of what I discovered.

## Prerequisites

The setup consists of three moving parts:

- A self-executable Dataflow pipeline jar file.
- A Cloud Storage bucket that where files get added periodically by a partner of ours.
- A Cloud Function configured to run each time something changes in that bucket.

I had already written the actual Dataflow pipeline code in [Clojure using Datasplash](http://labs.unacast.com/2016/12/07/how-datasplash-improved-our-dataflow/) and I'll refer to that as `pipeline.jar` in the code examples later on. Since I already was in Clojure mode with the pipeline code I decided to try writing the Cloud Function in Clojurescript instead of vanilla Javascript. My colleague Martin had already proven that you can write such functions in several [different](https://github.com/MartinSahlen/go-cloud-fn) [languages](https://github.com/MartinSahlen/fsharp-gcloud-functions) that compiles to Javascript, including [Clojurescript](https://github.com/MartinSahlen/cloud-fn-test).

## Generating `index.js` and `package.json`

Since Clojurescript is a language that compiles to Javascript we'll have to start with setting up the tools
to do the code generation. Here's a simplification of how my [Leiningen](https://leiningen.org/) `project.clj` file looks.
<script src="https://gist.github.com/torbjornvatn/9923ef733c5e400b16a72aaba9de92fd.js?file=project.clj"></script>

Now I can run `lein do npm install, cljsbuild once` to install my npm dependencies, generate a `package.json` and compile the `index.js` file.

What ends up in the `index.js` file is defined in some Clojurescript that looks like this.
<script src="https://gist.github.com/torbjornvatn/9923ef733c5e400b16a72aaba9de92fd.js?file=core.cljs"></script>

It's a bit of a mouthful, but the main takeaways are:

- The `pipeline-example-trigger` function has to be exported to act as the entry point used by GCF.
- The incoming `raw-event` that the function receives when a something happens in the bucket gets parsed and the `name` and the `bucket` fields are extracted.
- The `execute-jar-file` function uses `node-jre` to spawn a java process that starts the `pipeline-standalone.jar` executable with the necessary arguments.
- The `-> proc` parts are there to handle logging and events from the child process and making sure the
Cloud Function callback gets called when the java process is done submitting the Dataflow pipeline.

## Deploying the function to GCF
Now we're ready to deploy the function to see it in action. I use the [Google Cloud CLI](https://cloud.google.com/sdk/) to deploy and start the function on GCF, like this:
<pre class="highlight">gcloud beta functions deploy pipeline-example-trigger \
    --local-path target/pipeline-example \
    --stage-bucket [STAGE BUCKET] \
    --trigger-bucket [BUCKET TO WATCH]
</pre>

The `--local-path and --stage-bucket` arguments are the locations the source of the functions should be copied from and to. `--trigger-bucket` is the GCS bucket this function should be watching for changes.

## The proof is in the pudding

![Running function]({{ site.url }}/images/cloudfunctions/pipeline-example-trigger.png)

The function is up and running, and as you can see on the right of the graph there it received an event when I used the CLI to simulate a file change in the bucket it is watching.
<pre class="highlight">gcloud beta functions call pipeline-example-trigger \
--data '{"name": "file-name", "bucket": "bucket-name"}'
</pre>

And the logging works as expected.
<p> </p>
![Log]({{ site.url }}/images/cloudfunctions/log.png)

## Closing thoughts

Google Cloud Functions had just entered beta state when this post was written, so understandably it has some rough edges and some missing features. E.g. I'd like a way of providing my own zip file to deploy instead of having to point to a directory with sources because it'd make using a CI/CD service like CircleCI a lot easier. Being able to write functions in a JVM language instead of just Javascript would also make the exercise I've done here, albeit fun and interesting, unnecessary.

The turnaround for deploying a function to test it is a bit long, especially when you include a quite large jar file like here. Luckily Google has created an [emulator](https://github.com/GoogleCloudPlatform/cloud-functions-emulator) that allows us to test the functions locally before deploying them to the cloud. The fact that I developed this in Clojurescript, that has a great REPL for interactive development, also limited the need for actually deploying the code to test it.

My prediction is that we here at Unacast are going to use Google Cloud Functions to simplify and get rid of a lot of complex code in the months to come. Exciting times ahead!
