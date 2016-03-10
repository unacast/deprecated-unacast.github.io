---
layout: post
title: "ChatOps @ Unacast"
ghavatar: 53291
ghname: heim
jobtitle: Lead Platform Engineer
---


<div class="message">
  The Unacast tech team has invested heavily in ChatOps, this post gives an overview over our deployment system and the advantages it gives us both in a short, and longer term.
</div>

![Hubot](/images/chatops/hubot.jpg)

### ChatOps?!?
ChatOps is a term often credited to <a href="https://www.youtube.com/watch?v=NST3u-GjjFw">GitHub</a>, and it is all about putting the tools in the middle of the conversations. At Unacast most of our conversations go through Slack, and when we integrated ChatOps into our workflow we got the tools closer to the conversation.

So, what is ChatOps? For us it is the the action of triggering stuff from Slack instead of pressing buttons on a dashboard or runing shell scripts from the command-line. It is your monitoring tool posting alerts to chat instead of sending you an email. It is about deployment, monitoring and operation in the context of a conversation. It also democratises the deployment process, so the Product Owners can do the actual deployment to production.

![Kjartan deploys](/images/chatops/kjartan_deploys.png) 


### Why are we doing ChatOps, and why should you?
You all know the case when something critical breaks. The “go-to” guy fires up the SSH-console and enters a selection of different commands to fix the issue. Unless you actually go and SSH into the box and hit the arrow keys to replay the sequence of commands, this critical knowledge will be lost until next time the excrements hit the air-moving device. Which in this case, probably will be the next time the application is deployed. 

If we were to place ourself in this situation it would be a huge liability for us as a young tech company. We just cannot afford that the knowledge about our systems resides in the brain of only one developer. 

This is why ChatOps is huge for us. By showing everyone else what you are doing, through the chat, you are at the same time spreading the knowledge on how to deploy and run the different applications. 

This is especially important to us, who are now hiring our next 10 developers. This means that from the day they log in to our Slack will see what everyone else is doing, and most importantly: How they are doing it. 

![heim deploys](/images/chatops/heim_deploys.png)

From deploying an app to production, to splitting traffic between versions and to cancel processing jobs, everything is documented in real-time as it happens.

### Our development process

We are using a version of GitHub Flow for our development process. That means all new features goes in a branch, a pull request is opened and we merge continuously from master into the feature branch. When we have something that is ready to deploy to a server we trigger a deploy of the branch to a test environment. When the new feature is verified it is deployed to production, verified again, and then merged back into master. This enables us to maintain a clean master branch so we can roll back in case something fails.

Our deployment mechanism consists of a few discrete parts: <a href="https://hubot.gitub.com/">Hubot</a>, <a href="https://developer.github.com/v3/repos/deployments/">GitHub Deployments API</a>, <a href="https://github.com/atmos/heaven">Heaven</a>, and <a href="https://circleci.com/">CircleCI</a>.

This is how it works:

* Someone tells our Hubot to deploy something to some environment
* Hubot creates a new deployment in the GitHub Deployments API
* The affected repo triggers a webhook with the deployment-information and sends it to Heaven
* Heaven triggers a parameterized build on CircleCI
* CircleCI handles the actual deployment

This setup is very powerful and we can use it to deploy any type of application on any cloud provider. It also enables us to limit deployment to our system from individual accounts to prevent someone from deploying something by mistake.

### How do I start?

It may be daunting to try to chew over too much at once, so our general advice is to start small and build from there. The thing that brought us immediate value was bringing in deployments and health checks, and we are currently working on bringing creation of ephemeral environments into our flow. 

There is literally hundreds of plugins to Hubot, so you should be able to find something that will suit your needs. If not, it offers flexible scripting through CoffeScript so to integrate with an existing API you only need some time and elbow grease.



