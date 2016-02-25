---
layout: post
title: "Idempotency in REST APIs and distributed systems"
ghavatar: 310118
ghname: gronnbeck
jobtitle: Platform Engineer
tags: [rest, api, distributed systems]
---

A few weeks back we have had a good discussion about how to design pragmatic
and user friendly RESTful APIs. At some point in the discussion we discussed
what idempotency is and what it actually guarantees.
That triggered my curiosity and I wanted to explore deeper into idempotency and
how to create APIs design that could guarantee that updates are safe even in a
largely distributed and concurrent environment.

This post is a result of that exploration and includes two lessons I learned
about idempotency that I want to share with you.

## The HTTP Spec: Safe vs Idempotent
First, let us take a step back and take a look at two important properties of
HTTP methods: Safe and Idempotent.

The table below gives an overview of the different properties for the most
popular HTTP methods used when implementing RESTful APIs,
``GET``, ``PUT``, ``POST`` and ``DELETE``.

| Method | Safe | Idempotent |
|--------|:----:|:----------:|
| GET    | Yes  | Yes        |
| PUT    | No   | Yes        |
| POST   | No   | No         |
| DELETE | No   | Yes        |

So what the heck does it mean that a method is ``Safe`` or ``Idempotent`` ?

#### Safe methods

A HTTP method is safe if they are not expected to cause side effects.
Meaning clients can send request to safe methods without worrying about
causing any side effects or changes to the resource.

#### Idempotent methods

The definition of idempotence ([Wikipedia](https://en.wikipedia.org/wiki/Idempotence)):

> Idempotence is the property of certain operations in mathematics and computer
> science, that can be applied multiple times without changing the result beyond
> the initial application.

That is, a HTTP method is idempotent if it guarantees that a repeating a
request multiple of times has the same effect as issuing the request once.

## Lessons Learned


### Lesson 1: Pragmatic vs Idempotency

Being idempotent is important. However, it does not mean that you
have to guarantee that a request one point
in time should always return the same result. E.g. applying ``DELETE`` on
a existing resource multiple times should return ``HTTP Status: OK (200)``
the first time and ``HTTP Status: Not Found (404)`` the subsequent times.

A strict implementation of ``DELETE`` would expect ``HTTP Status: OK (200)``.
I believe that approach to be unnecessary cumbersome and pragmatism should
trump idempotency in such cases.


### Lesson 2: Idempotency does not avoid race conditions

A typical semantics to ensure idempotency for a ``PUT`` request is to
require the client to send all the values, including the ones
that does not change, when updating an object. This approach results in an
``PUT`` that is idempotent but prone to race conditions both in case of
network failure and in highly concurrent environments.

Say ``Alice`` tries to update the ``secret`` to ``"A"`` and because the network
is not reliable she loses the connection right before the request was supposed
to respond. Now she does not know if the the update got through or not. However,
since the API is idempotent she can retry the request without worrying of
causing other side effects.

This line of thought is correct, if we assume that ``Alice`` was the only only one
trying to update the secret. Let us assume that an another user Bob
was simultaneously trying to update the same ``secret`` as Alice to ``"B"``,
and successfully did so in between ``Alice``'s two requests.  Then Alice's request
will implicitly overwrite ``Bob``s ``secret`` and it will be lost forever.

Even thought the example is fairly trivial example it illustrates pretty clear
that idempotency does not ensure safe updates in case of concurrent environment.
Also, consider how such API semantics in a large distributed environment can
cause a a lot of data loss and race conditions if not properly implemented.

#### Avoiding race conditions
To avoid race conditions we introduce a version number to the data model:

```js
{
  secret: "A", // or "B" for Bob
  version: 1
}
```

and only allowing updates if ``version`` is monotonically increasing (a similar approach is implemented in distributed systems such as [etcd](https://coreos.com/etcd/)). If the
version number is not correct then the API should respond with an error.
By doing so we are strictly speaking sacrificing a bit idempotency
for safe updates.

Now, let us reconsider the case with ``Alice`` and ``Bob``. Using these semantics,
``Alice`` cannot overwrite ``Bobs`` secret implicitly as before. ``Alice`` has
to increment the ``version`` counter.

Of course implementing such semantics is a trade-off in complexity and should
only be included if necessary.
