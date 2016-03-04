---
layout: post
title: "Building microservices with Scala and akka-http"
ghavatar: 4218596
ghname: martinsahlen
jobtitle: Lead API and Integration Engineer
tags: [rest, api, akka, akka-http, microservices]
---

<div class="message">
  This post is probably best served with some previous knowledge of Scala, Futures
  and akka-http, but I've tried to skip the most nitty gritty stuff and jump to
  the fun part.
</div>

### Motivation
Learning new programming languages and frameworks is one of
the most important things you can do as an engineer to stay updated and keep
the fun. Recently, I have been looking at scala and akka, with special focus
on akka-http. I will not go into basics here, there are many great tutorials on
akka and scala that you can find on google.

This post will be an not be an introduction to microservices either, but it will
look at how the basic building blocks in akka-http and scala that you can use to build a
microservice that uses HTTP as the interface to other services. Which, in my opinion
is a good choice of protocol, being implementation-agnostic and battle-proven.
The general motivation for making microservices is starting to become well known, but
for us, it boils down to a couple of things:

* We can easily change, update and kill services that do a specific task
* The interfaces between services are well defined and does not require knowledge
of inner workings and implementations
* As stated in the first line, it enables us to continually experiment with new stuff,
have fun, learn things and always choose the best tools to achieve a specific task rather than
to make boring tradeoffs.

### Some background
So, what makes a framework or language good for writing a microservice?
I would argue light weight, speed and security features. By light weight I mean
a light core lib that can be extended by adding additional libs that do a specific task well.

The language or framework also needs to have support calling other microservices in parallel and
merge / compose the results and return it. In our case, akka-http is completely async and
Scala Futures and Future composition is very powerful, yet simple to use and reason about.
Akka-http is somewhat different than than existing web frameworks such as Django
and ruby on rails where the main focus is on the request-response cycle.
The goal of akka-http is essentially to connect akka to the web, so it is a really light weight
library that can co-exist with an an existing akka application.
In fact, my experience with akka-http started when we wanted to expose our batch processing tool
(written in akka) to the web in order to trigger jobs on demand.

### Getting started
I have always been a fan of just getting my hands dirty right away, rather than reading
up forever. I also have good experience with having a clear scope and goal when learning
new stuff. So let's create some code that can handle authenticating and authorizing incoming
requests and call appropriate methods.

### Domain models, validation and JSON mapping
First, let's create a model for containing a login request. This could obviously have
been done with a regular form post request, but doing it like this let's me show off the
elegant spray JSON serializers, as well as WIX's accord library for validating object
properties (If you need more fine-grained control, let's say omit some fields or rename
them, you can also create a custom object mapper):
<script src="https://gist.github.com/MartinSahlen/2b4b7f93f68630382f77.js"></script>

### Routing and mapping requests
Then, let's show off the elegant __routing directives__ in akka-http, which I really like.
There are actually quite a few built in directives for handling all HTTP methods, as well
as conditional GZIP and more. The gist below shows the route for logging in, which will return
a token that will be used as the ``Authorization`` header in following requests. It also
uses the validation provided by WIX and returns an error object that explains what went wrong if so.
<script src="https://gist.github.com/MartinSahlen/0dea83af180957b34993.js"></script>

This shows some really cool features in akka-http. A route is essentially built by composing
directives such as ``post, complete, pathEndOrSingleSlash``. The important part in this case is
the ``entity`` directive, which enables mapping a request body to a domain object, in our case
the ``LoginRequest``. Then, we let WIX do the validation.

### Show me the rest of the code
To complete this example and for clarity's sake,
let's look at the ``generateLoginToken`` method that provides a token upon a successful login (I apologize
  to all scala savants for the possibly messy code):
<script src="https://gist.github.com/MartinSahlen/f13c2fceb3bf810cf376.js"></script>

### Creating your own directives
As previously mentioned, there are quite a few built in directives, for instance you
can do Basic Auth. However, in our case, we have made our own authentication mechanism,
consisting of using tokens (obviously, this example is bit artificial, as basic auth
probably is a better choice when building microservices).

When looking at the routing example above, we see that some directives, such as ``post``
does not do anything more than wrap the inner directives. The ``entity`` directive, on
the other hand, returns the ``LoginRequest`` object and makes it available to the inner
directives.

So, knowing this, let's create a directive that parses the ``Authorization`` header
(with the token obtained when logging in) from the request and provides us with the
User object that issued the request. Then, the user can be passed on to domain / business
logic methods to i.e. determine permissions if we want to do that.

Essentially, we are now creating middleware, as most of you probably are familiar
with from Django, Express.js and similar web frameworks - where the goal is either
to reject a request before it reaches the domain methods or to augment the
request context with i.e. information about the user that issues the request before calling
domain methods. Let's look at the code:
<script src="https://gist.github.com/MartinSahlen/65116df412e32cf24409.js"></script>

First, we created a directive that just gets the user from looking up the login tokens. The
next directive, ``authenticateWithRoles``, does filtering based on a list of roles, which some of you probably are
familiar with from Java / Jersey and the ``@RolesAllowed`` annotation.

To round off, let's create a route that uses the ``authenticateWithRoles`` directive to only let users with
the ``admin`` role create new users:
<script src="https://gist.github.com/MartinSahlen/863853e232d577edd7f5.js"></script>

The really cool thing about this kind of middleware is that it's quite explicit and that you can wrap one route,
or you can compose many routes (using the ``~`` operator) and wrap them. No configuration files, it's all just code.

Lastly, let's spin up the server and serve some http:
<script src="https://gist.github.com/MartinSahlen/f9039a8b314724e38b42.js"></script>
