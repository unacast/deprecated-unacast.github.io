---
layout: post
title: "Seo for dummies"
ghavatar: 4218596
ghname: martinsahlen
jobtitle: Lead API and Integration Engineer
---

## Motivation
This Summer, we decided to build Proxbook - a crowdsourced directory of proximity solution providers, use cases,
white papers and in depth resources about the industry itself.
It has worked pretty well, in fact so well that we recently decided to take things to the next level.

So far so good. Proxbook is implemented as a single page application
(SPA, https://en.wikipedia.org/wiki/Single-page_application) using an underlying API for populating the frontend with
data. SPA architecture gives developers flexibility, and end users gets more responsive web applications with a lot
less overhead of unnecessary page loads.

“The next level” in these terms meant that we certainly could see that the site got more traffic and usage - especially
in terms of how long time users spend on the page. Consider it a funnel - users enters the page, some leave (bounce)
and some stay, or move to other sub-pages, creating a flow chart of a user journey.

In order to boost these numbers, we realized that we had to look at SEO (Search Engine Optimization).
Proxbook had pretty low scores on all parameters. So, what is SEO, and what are the important parameters
for getting your site high up the search engine indices?

## SEO is a beast with many heads
Most technologists want to focus on building kickass stuff on bleeding edge technology,
but this often mixes bad with SEO. I myself thought SEO was mainly about adding some keywords in the page header,
but my initial research revealed that SEO is actually become quite comprehensive. The list below describes what
I’ve found, it is probably not exhaustive - but it definitely shows that SEO is something that must be grounded in
all aspects of a website, from copywriters, to designers and developers.

* Semantic HTML
    * use section, article, nav, h1, h2, don't use background images that are relevent for teh contant, use image alt text etc
    * The elements themselves convey their importance and relationships.
    * One page should only have one h1 tag.
    * Use section tags to divide the different sections of the page instead of div
    * Use a nav tag to contain all the links for navigation your site
* Microdata
    * https://schema.org/docs/gs.html
    * Using special markup to display products, locations, companies etc. nicely in the Google search.
* Page loading time
    * Caching of assets - images, fonts etc (yes, google will tell you this)
    * Gzip Compression, image sizes, file sizes, minifying html / js / css.
* Content itself
    * Meta keywords, description and page title
    * Content use of keywords etc in the text itself
    * using editing tools that allow to set / override specific meta tags for subpages, sections, blogposts in an easy manner
* SSL
* Links in out / PageRank. Number of inbound links vs outbound links. Inbound links from other sites (preferably high ranking sites)
* Generating a sitemap.
* Social sharing of content
    * This is not SEO per se, but if we consider SEO (to simplify) to also include all factors that drive traffic to a site, this is extremely important. Many sites hardly have traffic through their main portals. Not knowing the exact ratio, I would assume sites like TNW, techcrunch and their likes (this also includes all viral sites with stupid links like “you would not believe what she did when…”) generate 80-90% of their traffic through facebook, twitter and linkedin. That means having IMAGE good shareability of all subpages of the site will greatly increase the probability of inbound traffic. Which is the end goal no matter where users are coming from.
Opengraph tags (facebook, google+, linkedin), twitter card tags.

So, where to begin? This is simple, right? Well, both yes and no. Proxbook was conceived and created extremely fast, so some shortcuts were made. Adding semantic HTML for instance, was to say the least a lot of boilerplate work. At the same time it provided good motivation for restructuring the page and getting code redundancy down to an acceptable level.

Assets / compression
For managing assets, I decided to use GZIP compressing, long cache expiration as well as hosting on Amazon S3. The app itself is built on Angular.js and a gulp build pipeline, so I just added a step that uploads all assets to an S3 bucket after a successful run. This step also runs through all HTML / CSS and swaps references to assets with the CDN url. The S3 part was done using https://www.npmjs.com/package/gulp-cdnizer and https://www.npmjs.com/package/gulp-s3-upload.

using versioniong gulp - gulp rev.

We also had another issue. As all user media such as company logos are uploaded to S3 without compression or resizing, we had a lot of media on the site that was unnecessarily large and caused https://developers.google.com/speed/pagespeed/?hl=en to complain. To deal with that, I created a script in the backend (Django of course, my go-to framework) that looped through all the

Got pagespeed from 2% to 79%. pretty decent, facebook has


Using Google



adding sitemap.xml
async parallel. getting all data that is needed. takes about 5 secs


for single page apps

Social sharing
opengraph tags

Fundamental issue:
The application / webpage is rendered in the frontend. No specifig URLs, content, etc etc

Diagram User → webserver. Crawler

Angular. React works with server side rendering. Many frameworks dont. This is a pretty good general solution.
