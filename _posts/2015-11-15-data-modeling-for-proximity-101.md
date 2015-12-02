---
layout: post
title: "Data modeling for proximity 101"
ghavatar: 4218596
ghname: martinsahlen
name: Martin Sahlen
jobtitle: Lead API and Integration Engineer
---

## Building a simple demo tool
So, it is yet again time for a new blogpost. This time, I will focus on a tool that I have built to showcase the power of beacons and how they can work with advertising to give users relevant communication as they go along.

I give you, the **Unacast demo tool**. The goal was really to build a flexible tool to showcase the essence of what Unacast is doing, in a user-friendly way that can be handled by our commercial team and also partners of Unacast that bundle our services. 

This was a project that was mainly handled by the engineering team, after experiencing in sales meetings that having a demo or visual presentation would be valuable. There were very few strict requirements, as it is always difficult to convey an idea that you need something, but you are not sure exactly what.

## Carving out initial requirements
However, I chiseled out some of the requirements to fulfill, based on my own experiences in sales meetings as well as feedback from “the suits”:

* Flexible setup and configuration to handle different showcases and pitches
* Adding / removing beacons
* Adding / removing categories (i.e. Food&Beverage, etc) and attaching these to beacons
* Adding / removing ads and attaching these to categories
* An application that is installed on the user device that "picks up" beacons
* Creating and populating user profiles based on device id
* Displaying an ad on the user device and changing it in real time, based on beacon interactions
* Realtime view of user profile as the device interacts with beacons
* A pleasant UI to visualize the data and provide easy setup

## Creating a data model
Based on this, I started iterating on an MVP. The data model and flow was roughly like this:

* An **app** is the domain, or the bucket to which data belongs
* A **user** is identified by the IDFA of his / her device
* A **user** interacts with **beacons** and the **app** sends info about this to the backend, which saves a new **interaction** with info about the **app**, the **user** and the **beacon** encountered
* A **beacon** has one or more **tags** (Sports, Food, Travel, etc)
* When the **user** interacts with a **beacon**, this **interaction** is saved (as stated above). Also, an **advertisement** is shown in the **app**. This **advertisement** has a **tag** of the same type as the beacon. So you guessed right, a “sports” **beacon** will make a “sports” **advertisement** appear in the **user**'s **app**.
* Lastly, when a user opens the app out of range of a beacon, the app shows an ad that matches the tag of the beacon type the user has the most interactions with. If no previous data is available on the **user**, a random **advertisement** is served

## Getting the hands dirty / Taking a first stab
Much can said about this stage, but the fact is that pictures are much more telling than words,
so I will just say that it ended up something like this:

### Prerequisites
![beacons](/images/demo-tool/beacons.JPG)

First, a couple of beacons are needed. These are pretty cool. Stick a couple of USB-beacons in a couple of emergency chargers, and you have a nice setup for testing beacons in a controlled environment.

### The overview
![overview](/images/demo-tool/overview.png)

This screen lets the user edit basic information about the demo, such as name, description, beacon UUIDs to use, as well as the page that the app should embed (the app is very simple, just displaying the contents of a user-specified URL with an ad on top)

### User profile
![realtime](/images/demo-tool/realtime.png)

The user profile gives us a real-time updating view of an end user as he or she journeys trough a world of beacons.
The box labeled "computed user profile" shows us the the user's preferences in a visual manner that updates automatically.


### Managing content
![tags](/images/demo-tool/tags.png)

Here, the user can create their own tags to use.

![entities](/images/demo-tool/entities.png)

Here, the user can add entities (we just used that name insted of beacons to have a generic model for all kinds of proximity tech, such as NFC).
and assign tags to them.

![ads](/images/demo-tool/lol.png)

Lastly, this section enables the user to create advertisements that are connected to the tags, completing the circle and also fulfilling the
requirements that we outlined above.

### The app
![app](/images/demo-tool/app.jpeg)

This is a screenshot from the iOS application that was developed, and shows the wikipedia frontpage (as stated, you can embed any type of web content, even create your own custom page) and a Coke app on top.

## Wrapping it up
Obviously, this is a very crude example, and some of our partners have advanced capabilities that go beyond this example. We do however, encourage Proximity Solution Providers and partners to think about this. It is a small price to pay to implement and it will increase the value of the data in the future. It is also important to keep in mind that it is possible to just store this data and apply analytics and scientific methods at a later stage. As Unacast is a data first company we cannot stress enough the importance of this.

**PS**: This also highlights an important part of our commercial and engineering culture and how they play together. Rather than placing an “order” from the tech team, the tech team was given great room to navigate and explore. This obviously only works if there is a high level of trust and transparancy - essential components as Unacast scales up the organization in all professional disciplines.

**PS#2**: If you are wondering about the technology we used for this project, please leave a comment. If you think this was extremely interesting, we are also <a href="http://thetwenty.jobs/" target="_blank">hiring</a>, so feel free to reach out.
