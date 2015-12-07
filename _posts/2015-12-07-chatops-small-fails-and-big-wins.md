---
layout: post
title: "ChatOps: Small fails and big wins"
ghavatar: 53291
ghname: heim
jobtitle: Lead Platform Engineer
---


<div class="message">
  The story of when I made a typo and fixed it while drinking beer.  
</div>


## Background story

Last monday I was experimenting with some new log metrics on our platform. I wanted to make sure that all our alerting rules for errors in the log was correctly reported and sent to our ops-channel in Slack. 

Specifically I wanted to make sure that if the queue that connects our outward API with our processing engine was inaccessible the bells would start to ring. 

Our API is designed to use a local backup-store if our queue experiences problems, and there is a batch job that regularly checks the backup-store and tries to re-send the data to the queue for further processing. This introduces a significant delay in our processing time, and is of course something we prefer to avoid, hence the aggressive alerting when this happens.

To test that the alerts really got triggered I did the simplest thing that I could think of, and introduced a deliberate error in the API so that it would try to push data to a non-existing queue.  
I then deployed this to our staging environment, and made sure that the propert alerts showed up when I tried to post something to the API.

By now it was getting kind of late, and I had planned to go to the local [DevOps meetup](http://www.meetup.com/devops-norway/) to listen to amongst others Kelsey Hightower from Google speak about [Kubernetes](http://kubernetes.io/).

Feeling confident, I deployed the branch to production and left the offices, intentionally leaving my mac behind.

## Kubernetes, beers and errors in production

This evening we expected to receive a lot of new data from a partner that had recently integrated with us, so while enjoying both the Kubernetes talk and a beer, I decided to log into our admin console from my phone and check how much data we had received.

To my surprise we had not received any new data the last few hours, and I felt a bit uneased, and tried to think of possible explanations. I checked the production logs, and was blown away with a mountain of errors.

I started cold-sweating and pinged the other engineers, but none responded. Seemed like I was on my own. I desperately searched the room to see if there was anyone I knew who had a computer with them. No luck. I downed the remaining glass of beer in pure panic. It did not help. 

I could not understand why these errors had not been posted to our dedicated Slack channel, our API had been pumping out errors for several hours, and nothing had reached our data-store. This was starting to become pretty serious. 

Upon inspecting the logs (from my phone) in more detail I managed to find the culprit. Seemed like our queue was not responding. I thought that was strange, I had just worked on that earlier, remember?
Then it hit me, like a ton of bricks, the API was trying to push to a queue that did not exist. 
I had screwed up when I tested our alerts. I had screwed up badly.

## Everything to the rescue

I logged in to GitHub and looked at the last commits, after a whole lot of scrolling and pinching I found the violating line of code. It certainly was my fault, we do not have any queues ending with "foobar".

One of the great things about GitHub is that you can actually edit your source code from a browser. It's pretty practical for editing README's and such, but for editing java-code it is not exactly a direct competitor to IntelliJ or Eclipse.
Anyway, after a bit of struggeling I managed to correct the violating line of code and commit it to a new pull request through the web-ui.

I opened the Slack app, and waited for CircleCI to report a green build. It did so after a few minutes, and I typed `unabot deploy api/fix-stupid-error to production`. 
After a few moments of waiting for [Heaven](https://github.com/atmos/heaven) to do its work I checked the logs again, and was no longer met with errors. The bug had been squashed! Victory!

## The aftermath

For me this incident and how we were able to resolve it proves the importance of automation in general, and ChatOps in particular. Being able to correct an error from my phone while on the move justifies the up-front cost of making it possible. It also makes it easier for us to experiment and try new stuff, when we know that the consequence of fail is mitigated by our tooling.
With a solid deployment and monitoring solution we are able to roll forward or backward at the whim of a few keystrokes in Slack.

This incident also taught us something very important: Nothing is validated, unless it is validated in production. All stages up to production is only increasing our confidence by a small percentage. The full confidence only comes when the code is running with real data in the only environment that matters; production.

The real mistake that I did was not to commit some faulty code with a non-existing queue-name. My sin was that I did not test the alerting policy in production as well. As you might have understood by now, the alerting policy did not do what it was supposed to do. It was actually a very small mistake. The alerting policy was set up correctly, but a small (and very important) thing was missing. The actual integration with Slack, which resulted in a proper alert, but it was propagated to no-one.

## Parting words

To conclude my learnings with this incidents, a couple of things stands out.

1. Investing in automation will pay off. The cost can be high, but in time it *will* pay off.
2. Everything must be validated in production. 

If you are interested in learning more about ChatOps, have a look at our previous blog post [ChatOps @ Unacast](http://labs.unacast.com/2015/10/26/chatops-at-unacast/).










