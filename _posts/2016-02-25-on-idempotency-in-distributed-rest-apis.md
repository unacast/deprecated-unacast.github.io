---
layout: post
title: "Idempotency in REST APIs"
ghavatar: 310118
ghname: gronnbeck
jobtitle: Platform Engineer
tags: [rest, api, distributed systems]
---

A few weeks back our team had a discussion about API design. The discussion was
mostly about what we could do to design pragmatic and user friendly RESTful APIs for our clients.
At some point in the discussion we discussed what idempotency is and what it
actually guarantees. That sparked a curiosity in me, and I wanted to explore deeper
into that.

Idempotency is defined as: ([wikipedia](https://en.wikipedia.org/wiki/Idempotence)):

> Idempotence is the property of certain operations in mathematics and computer
> science, that can be applied multiple times without changing the result beyond
> the initial application.

In the context of HTTP APIs, a HTTP method is idempotent if it guarantees that
repeating a request multiple of times has the same effect as issuing
the request once. This is especially important in the case of network failures. In
such cases clients can repeat the same request multiple times without worrying
about any unintended effects.

## Safe vs Idempotent
[Idempotent methods](https://tools.ietf.org/html/rfc7231#section-4.2.2)
should not be confused with
[Safe methods](https://tools.ietf.org/html/rfc7231#section-4.2.1).
In HTTP, method is safe if they are not expected to cause side effects.
Meaning clients can send request to safe methods without worrying about
causing any side effects or changes to the resource.

The table below gives an overview of the different properties for the most
popular HTTP methods used when implementing RESTful APIs,
``GET``, ``PUT``, ``POST`` and ``DELETE``.

| Method | Safe | Idempotent |
|:-------|:----:|:----------:|
| GET    | Yes  | Yes        |
| PUT    | No   | Yes        |
| POST   | No   | No         |
| DELETE | No   | Yes        |


## Pragmatic vs Idempotency

Being idempotent is important. However, it does not mean that you
have to guarantee that a request one point in time should always return
the same result. One examples of this is when we apply ``DELETE`` on
an existing resource multiple times it should return ``HTTP Status: OK (200)``
the first time and ``HTTP Status: Not Found (404)`` the subsequent times.

A strict implementation of ``DELETE`` would expect ``HTTP Status: OK (200)``.
I believe that approach to be unnecessary cumbersome and pragmatism should
trump idempotency in such cases.

Being pragmatic about ``PUT``'s idempotence is common, either by purpose or by
carelessness. In the next part we will dive deeper in to the ramifications of
relying too much on idempotency of ``PUT`` in a concurrent setting.

## Concurrency vs Idempotency

A typical semantic used to ensure idempotency for a ``PUT`` request is to
require the client to send all the values, including the ones
that does not change, when updating an object. This approach for ``PUT`` that is idempotent but prone to race conditions, both in case of
network failure and in highly concurrent environments.

Say ``Alice`` tries to update the ``secret`` to ``"A"`` and because the network
is not reliable she loses the connection right before the request was supposed
to respond. Now she does not know if the the update got through or not. However,
since the ``PUT`` is idempotent she can retry the request without worrying of
causing other side effects.

This line of thought is correct, if we assume that ``Alice`` was the only only one
trying to update the secret. Let us assume that an another user Bob
was simultaneously trying to update the same ``secret`` as Alice to ``"B"``,
and successfully did so in between ``Alice``'s two requests.  Then ``Alice``'s
request will implicitly overwrite ``Bob``s ``secret`` and it will be lost forever.

Even thought the example is fairly trivial example it illustrates pretty clear
that idempotency does not ensure safe updates in a concurrent environment.
Also, consider how such API semantics in a large distributed environment can
cause a a lot of data loss and race conditions if not properly implemented.

### Avoiding race conditions
One approach to avoid such race conditions is to implement the API with
[Optimistic Locking](http://stackoverflow.com/questions/129329/optimistic-vs-pessimistic-locking)
semantics. We can do that by introducing a version number or an hash, to the data model. I prefer using version numbers because
they are easy to understand and update.

Assuming that we are using ``version`` numbers to implement Optimistic Locking.
Each update of a resource must include a strictly monotonically increasing
version number of the previous resources. That is if we have a resources

```js
{
  secret: "A",
  version: 1
}
```

then the update request for the resource at hand must include ``version: 2``, or
it will be rejected,

```js
{
  secret: "B",
  version: 2
}
```

Now, let us reconsider the case with ``Alice`` and ``Bob``. Let us assume that
``Alice``s first request was persisted and that ``Bob`` has persisted his secret
``"B"``. If Alice retries her request with ``version: 1`` from earlier, her request
will fail since the version number ``1`` of her request is less ``2``.
The only way for Alice to update the secret is to explicitly set the version
number to ``3``. Solving the race condition problem illustrated earlier.

Implementing optimistic locking is a trade-off between complexity
and reliability, and should only be included if necessary.

## Closing Notes

Remember that every API is different and has different requirements.
There is no golden rule for API design and you will have to make
lot of trade-offs along the way.

For further reading on API designs and principles I highly recommended
[apigee's ebooks](http://apigee.com/about/resources/ebooks) and [3scales reports](http://www.3scale.net/resources/reports/).
