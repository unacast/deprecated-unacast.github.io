---
layout: post
title: "Visualize your BigQuery data with re:dash"
ghavatar: 4453
ghname: torbjornvatn
name: Torbjørn Vatn
jobtitle: Senior Platform Engineer
tags: [BigQuery, re_dash, visualization]
---

<div class="message">
  How do you make sense of all those terabytes of data stuck in your BigQuery database?
</div>

## Here's what we tested

We here at Unacast sit on loads of data in several [BigQuery](https://cloud.google.com/bigquery/?utm_source=google&utm_medium=cpc&utm_campaign=2015-q1-cloud-emea-bigdata-bkws-freetrial-en&gclid=CLeD4dyo8c0CFYL4cgodLGMG1A) databases and have tried several ways of visualizing that data to better understand them. These efforts has been mostly custom Javascript code as a part of our admin UI, but when we read about [Re:dash](https://redash.io/) we were eager to test how advanced visualizations we could do with an "off the shelf" solution like that. We wanted both charts showing all kinds of numerical statistics retreived from that data and maps showing us geographical patterns. Re:dash supports this right out of the box, so what were we waiting for?

### Getting up and running

Since we run all our systems on Google Cloud we where really happy to discover that Re:dash offers a [pre-built image](http://docs.redash.io/en/latest/setup.html#google-compute-engine) for Google Compute Engine, and they even have one with BigQuery capabilities preconfigured. This means that when we fire up Re:dash in one of our Google Cloud projects, the BigQuery databases in the same project are automatically available as a data sources ready to be queried. Awsomeness!!

Apart from booting the GCE image it self we had to open some firewall ports (80/443) using the `gcloud compute firewall-rules create` command, add a [certificate](http://docs.redash.io/en/latest/misc/ssl.html) to the `nginx` running inside the Re:dash image to enable `https` and lastly add a `dns` record for easy access.

The final touch was to add [authentication using Google Apps](http://docs.redash.io/en/latest/setup.html#users-google-authentication-setup) so we could log in using or Unacast Google accounts. This also makes access and user control a breeze.
