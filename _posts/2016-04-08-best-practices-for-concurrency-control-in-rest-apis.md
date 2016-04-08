---
layout: post
title: "Best practices for concurrency control in REST APIs"
ghavatar: 831318
ghname: frodebjerke
jobtitle: Platform Engineer
tags: [rest, api, distributed systems, concurrency, developer experience]
---

When designing REST API interfaces, the methods that modifies existing resources seem to bring forth significant design challenges. The two most prominent challenges are idempotency and concurrency control. [Ken Grønnbeck](https://twitter.com/gronnbeck) earlier wrote about [idempotency in REST APIs](http://labs.unacast.com/2016/02/25/on-idempotency-in-distributed-rest-apis/) on the Unacast Labs Blog. As a follow up, this post will discuss different approaches to concurrency control in REST APIs.


<div class="message">
  TL;DR. Keep the end-to-end flow in mind, minimize change sets and do as little concurrency control as your problem requires.
</div>

To ease the flow of the examples that follow we will begin with establishing the interested parties when working with a REST API. The three interested parties we will keep focus on are the *api-creator*, the *integrator* and the *end-user*. The api-creator are the ones building and designing the API, in some cases this might be "the backend team", for more public facing APIs it might be the core business unit. The integrators are the consumers of the API, they could be another unit in your organization like the frontend team, a business partner or a lone developer using your API in a hobby project. End-users could be anything from your mobile app users to your partner's users, in fact one *end-user* could be the user of several of your integrators. Yet, common for *end-users* is that they are likely oblivous to the fact that the API the *api-creator* provides exists &mdash; and does not want to know a thing about it.

The intended type of concurrency conflict for this post is when a user tries to update a resource which has been modified after the last time this user last saw that resource. The consequence of which is that the user writes over someone else's change to resource, unknowingly.

 As the nature of design challenges are discussions with no definite answers and a myriad of different solutions around &mdash; any feedback or correction are most welcome.

## Minimize consequences

 Reducing the possible consequences of concurrency conflicts is desirable from a API design standpoint. In practice this mean only modifying the fields which the *end-user* intends to modify. This can be achieved with either more granular endpoints for altering different properties or using [PATCH semantics instead of PUT](http://restful-api-design.readthedocs.org/en/latest/methods.html#patch-vs-put). The endgame here is to in a conflict only let the last request write the field(s) it actually intends to modify.

 On another note, if modifying existing resources can be avoided so that you can have immutable resources &mdash; you have in all practicality removed concurrency conflicts from your API.

## Optimistic locking

 If you choose to implement a concurrency control strategy, optimistic locking is likely to be the best bet. Optimistic locking works like the following: try to do an operation, then fail if the resource has changed since last seen. Optimistic locking is opposed to pessimistic locking where a resource is locked from alteration before any changes are done, then released. As pessimistic locking schemes require state to be kept at the server it does not play well in RESTful APIs where it is [idiomatic to keep the server stateless](https://en.wikipedia.org/wiki/Representational_state_transfer#Stateless).

 The general approach for optimistic locking is to along with your payload send a value that identifies which version of the resource you are modifying. If the version to modify from is stale, the request should fail. The version identifier could be a explicit version number or hash of the unmodified resource. Last modified timestamps could also be used, but with caution as clocks might be skewed in a distributed environment.

 Identifying the version in a HTTP request one can either put the version identificator as part of the request model in the payload or utilize the `if-match` request-header from the [HTTP/1.1 specification](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.24). Note that the HTTP/1.1 specification requires 412 (Precondition failed) to be returned upon conflict.

 As a mechanism of concurrency control optimistic locking is a simple yet powerful approach. Implementing it for the *api-creator* is relatively straightforward. This approach does however impose the risk of *end-user's* suffering. A stricter concurrency control strategy requires that the entire end-to-end flow adhere to it. The *integrator* would be forced to implement graceful resolving of conflicts due to the concurrency control &mdash; likely a non-trivial task, definitely so if a GUI is involved.

## Last request wins

Skip concurrency control altogether. What does not doing concurrency control in a REST API lead to? It lets the last request win.

There are in fact several upsides to implementing such a simple strategy &mdash; or the lack of implementing any. First of all, it is a really clean interface for your *integrators*, no extraneous HTTP headers or semantics to comprehend. Stronger, is it is a cleaner interface for the *end-user* as no clutter is added to the interface for handling concurrency conflicts.

Absolutely there are good reasons to use a stricter concurrency control strategy. Most markedly is loss of data. In a last request wins scheme, data from the second last request can be lost. Secondly, having a stricter scheme forces your *integrators* to think about concurrency control. When omitting a strategy as with last request wins it is more likely that issues with concurrency are not considered. Both of these issues are however approachable by other means than a stricter concurrency control scheme. For instance by implementing versioning of resources, data will never be truly be lost &mdash; conflicts can therefore be mended, by manual intervention that is.

Not only is the last request wins approach desirable for the *api creator* as it entails no work at all beyond clearly communicating it through the API documentation. It is also the simplest possible model for the *integrator*. As a matter of fact even the *end-user*'s interfaces would be simpler and more clean.

## Opt-in concurrency control

By qualitatively analyzing some well known public APIs like [Github](https://developer.github.com/v3/), [Spotify](https://developer.spotify.com/web-api/) and [etcd](https://coreos.com/etcd/docs/latest/api.html#changing-the-value-of-a-key) we see everything from strict concurrency control to none at all (the last request wins strategy). The most common solution nonetheless seem to be opt-in concurrency control, as in [Spotify's case](https://developer.spotify.com/web-api/reorder-playlists-tracks/) where you can pass an optional `snapshot_id` on your update request.

An opt-in approach like Spotify's clearly reminds your *integrators* to think about concurrency control and make up their minds whether it makes sense for their *end-users*.

On the contrary this is not a sound strategy if different the same resource can be modified from more than one *integrator*.An *end-user* might then overwrite changes made via a opted-in integration from a opted-out integration.

## Know your requirements

 As shown in this post using concurrency control does impose challenges to your *integrators* and even their end users. Different applications definitely have different requirements to concurrency control. Some applications are even of such a nature that pessimistic locking best meet the requirements.

 The essence here is to know your requirements and how they affect the *api-creator*, *integrators* and *end-users*. Then with this in mind use the first minimize the consequences before applying least concurrency control to fulfill the requirements while keeping all interested parties happy.
