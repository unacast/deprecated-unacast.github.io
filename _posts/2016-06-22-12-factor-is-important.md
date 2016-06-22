---
layout: post
title: "12 factor apps are important"
ghavatar: 831318
ghname: frodebjerke
jobtitle: Platform Engineer
tags: [developer experience, 12 factor]
---

[The 12 factor app](http://12factor.net/) is a methodology that unify the composition and interface of web applications. Additionally, this methodology addresses other factors of web applications such as scalability and continuous deployment.

> **The 12 factors**
>
> 1. *Codebase*
> 2. *Dependencies*
> 3. *Config*
> 4. *Backing services*
> 5. *Build, release, run*
> 6. *Processes*
> 7. *Port binding*
> 8. *Concurrency*
> 9. *Disposability*
> 10. *Dev/prod parity*
> 11. *Logs*
> 12. *Admin processes*
>
> *Source: [12factor.net](http://12factor.net/)*

## A building block for microservices and container orchestration

There is a wide range of reasons for why adoption of the microservices pattern is common today &mdash; continuous integration, independent service scalability and organizational scalability are some. Moreover, the 12 factor app is crucial to creating microservices as it ensures ability to perform continuous integration and independent service scalability.

Microservices require an infrastructure that offers simple service orchestration and deployment management. Therefore, container and orchestration products like Docker or Kubernetes and friends are absolutely pivotal to making microservices a sensible approach. Container technology creates portable, containers, of an application or data. Whereas orchestration tools manages running clusters of such containers or other portable executables, providing clear interfaces for deployment, resilience and scalability.

To create valuable application containers, 12 factor apps again come in handy by exhibiting traits like the use of [backing services](http://12factor.net/backing-services), relying on [port binding](http://12factor.net/port-binding) and [disposability](http://12factor.net/disposability).

Further, container orchestration products are deeply sunk into the composition and interface of 12 factor apps. Commonly, these products expect, in addition to the container traits, apps to be dealing with [config through the environment](http://12factor.net/config), scale by [stateless processes](http://12factor.net/processes) and handle [logs through *stdout*](http://12factor.net/logs).

Looking at the highest current maturity level of web application platforms AppEngine, Heroku and the similars, they are bound into 12 factor apps in much the same way as most container orchestration products. In fact, the 12 factor app was introduced by Heroku themselves.

## Developer experience in a polyglot world

The state of web application development is evolving at a heartening pace. As a result many aspects are heavily fragmented, most notably the number of programming languages and frameworks. Fortunately, an increasing adoption of applications cohering to the 12 factor methodology helps keeping the eco-system as a whole sane. Without the common ground of the 12 factor app, creating general tools would likely be an excruciating task. Not to mention, the 12 factor common ground ease the mental load for developers moving from one framework to another &mdash; something that is especially huge in a microservices setting.
