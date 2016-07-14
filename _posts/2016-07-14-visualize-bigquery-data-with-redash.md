---
layout: post
title: "Visualize your BigQuery data with re:dash"
ghavatar: 4453
ghname: torbjornvatn
name: Torbjørn Vatn
jobtitle: Senior Platform Engineer
tags: [BigQuery, redash, visualization]
---

<div class="message">
  How do you make sense of all those terabytes of data stuck in your BigQuery database?
</div>

## Here's what we tested

We here at Unacast sit on loads of data in several [BigQuery](https://cloud.google.com/bigquery/?utm_source=google&utm_medium=cpc&utm_campaign=2015-q1-cloud-emea-bigdata-bkws-freetrial-en&gclid=CLeD4dyo8c0CFYL4cgodLGMG1A) databases and have tried several ways of visualizing that data to better understand them. These efforts have been mostly custom Javascript code as a part of our admin UI, but when we read about [Re:dash](https://redash.io/) we were eager to test how advanced visualizations we could do with an "off the shelf" solution like that. We wanted both charts showing all kinds of numerical statistics retrieved from that data and maps showing us geographical patterns. Re:dash supports this right out of the box, so what were we waiting for?

### Getting up and running

Since we run all our systems on Google Cloud we were really happy to discover that Re:dash offers a [pre-built image](http://docs.redash.io/en/latest/setup.html#google-compute-engine) for Google Compute Engine, and they even have one with BigQuery capabilities preconfigured. This means that when we fire up Re:dash in one of our Google Cloud projects, the BigQuery databases in the same project are automatically available as a data sources ready to be queried. Awesomeness!!

Apart from booting the GCE image itself we had to open some firewall ports (80/443) using the `gcloud compute firewall-rules create` command, add a [certificate](http://docs.redash.io/en/latest/misc/ssl.html) to the nginx instance running inside the Re:dash image to enable https and lastly add a dns record for easy access.

The final touch was to add [authentication using Google Apps](http://docs.redash.io/en/latest/setup.html#users-google-authentication-setup) so we could log in using our Unacast Google accounts. This also makes access and user control a breeze.

### The power of queries

As the name implies, the power of BigQuery lies in queries on big datasets. To write these queries we can (luckily) just use our old friend SQL so we don't have to learn some new weird query language. The [documentation](https://cloud.google.com/bigquery/query-reference/) is nothing less than excellent. There's a detailed section on [Query Syntax](https://cloud.google.com/bigquery/query-reference#select-syntax) and then there's a really extensive list of [Functions](https://cloud.google.com/bigquery/query-reference#syntax-aggfunctions) that spans from simple `COUNT()` and `SUM()` via `REGEXP_EXTRACT()` on Strings and all kinds of Date manipulations like `DATE_DIFF()`. There's also [beta support](https://cloud.google.com/bigquery/sql-reference/)
> which is compliant with the SQL 2011 standard and has extensions that support querying nested and repeated data

but that's sadly not supported in re:dash yet (at least not in the version included in the GCE image we use).

In Re:dash you can utilize all of BigQuery's querying power and you can (and should) save those queries with descriptive names to use later for visualizations in dashboards. Here's a screenshot of the query editor and the observant reader will notice that I've used Google's public `nyc-tlc:yellow` dataset in this example. It's a dataset containing lots and lots of data about NYC Yellow Cab trips and I'll use them in my examples because they're kind of similar to our beacon interaction data.

![1000 cab trips](/images/redash/1000 cab trips.png)

It's however worth noting that you don't get any autocomplete functionality in Re:dash, so if you want to explore the different functions of BigQuery using the tab key you should use the "native" query editor instead. Just ⌘-C/⌘-V the finished query into Re:dash and start visualizing.

### Visualize it

Every query view in Re:dash has a section at the bottom where you can create visualizations of the data returned by that specific query. We can choose between these visualization types: `[Boxplot, Chart, Cohort, Counter, Map]` and here's how a 100 cab trips looks in a map

![100 cab trips](/images/redash/visualizations.png) 
