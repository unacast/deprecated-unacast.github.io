---
layout: post
title: "SEO for dummies"
ghavatar: 4218596
ghname: martinsahlen
jobtitle: Lead API and Integration Engineer
---

<div class="message">
  Disclaimer: The title is ironic. Search Engine Optimization is in fact a huge task, and this post is just a small summary of my experiences of working hands on with it.
  Most self-proclaimed "SEO experts" will just tell you that SEO is important and that you should use keywords and some tags. That is not wrong, but it will only take you
  part of the way of increasing traffic to your site, which is what SEO is really about. Especially, the term SEO misses out on
  an equally important channel, social media.
</div>

## Motivation
This Summer, we decided to build Proxbook - a crowdsourced directory of proximity solution providers, use cases,
white papers and in depth resources about the industry itself.
It has worked pretty well, in fact so well that we recently decided to take things to the next level.

So far so good. Proxbook is implemented as a <a target="_blank" href="https://en.wikipedia.org/wiki/Single-page_application">Single Page Application</a>
using an underlying API for populating the frontend with
data. SPA architecture gives developers flexibility, and end users gets more responsive web applications with a lot
less overhead of unnecessary page loads.

“The next level” in these terms meant that we certainly could see that the site got more traffic and usage - especially
in terms of how long time users spend on the page. Consider it a funnel - users enters the page, some leave (bounce)
and some stay, or move to other sub-pages, creating a flow chart of a user journey. In order to boost these numbers, we realized that we had to look at SEO.
Proxbook had pretty low scores on all parameters (using Google Pagespeed / Google webmaster tools and similar). So, what is SEO, and what are the important parameters
for getting your site high up the search engine indices?

## SEO is a beast with many heads
Most technologists want to focus on building kickass stuff on bleeding edge technology,
but this often mixes bad with SEO (not by definition, but optimization is usually not the first that comes to mind when learning new stuff).
I myself thought SEO was mainly about adding some keywords in the page header,
but my initial research revealed that SEO has actually become quite comprehensive. The list below describes what
I’ve found, it is probably not exhaustive - but it definitely shows that SEO is something that must be grounded in
all aspects of a website, from copywriters and authors to designers and developers:

* Semantic HTML
    * use section, article, nav, h1, h2, don't use background images that are relevant for the content, use image alt text etc
    * The elements themselves convey their importance and relationships.
    * One page should only have one h1 tag.
    * Use section tags to divide the different sections of the page instead of div
    * Use a nav tag to contain all the links for navigation your site
* Microdata
    * https://schema.org/docs/gs.html
    * Using special markup to display products, locations, companies etc. nicely in the Google search.
* Page loading time
    * Caching of assets - images, fonts etc (yes, Pagespeed will tell you this - essentially means that you should set long expiration times)
    * Gzip Compression, image sizes, file sizes, minifying html / js / css.
* Content itself
    * Meta keywords, description and page title
    * Content use of keywords etc in the text itself
    * using editing tools that allow to set / override specific meta tags for subpages, sections, blogposts in an easy manner
* SSL
* Links in out / PageRank. Number of inbound links vs outbound links. Inbound links from other sites (preferably high ranking sites)
* Generating a sitemap.
* Social sharing of content
    * This is not SEO per se, but if we consider SEO (to simplify) to also include all factors that drive traffic to a site, this is extremely important.
    Many sites hardly have traffic through their main portals. Not knowing the exact ratio, I would assume sites like TNW, techcrunch and their likes
    (this also includes all viral sites with stupid links like “you would not believe what she did when…”)
    generate 80-90% of their traffic through facebook, twitter and linkedin.
    That means having good shareability of all subpages of the site will greatly increase the probability of inbound traffic.
    Which is the end goal no matter where users are coming from. The image below shows the facebook link when sharing the last Proxbook report:
<div style="text-align:center;">
<img src="/images/seo-for-dummies/proxbook-social.png">
</div>

So, where to begin? This is simple, right? Well, both yes and no. Proxbook was conceived and created extremely fast,
so some shortcuts were made. Adding semantic HTML / Microdata for instance, was to say the least a lot of boilerplate work.
At the same time it provided good motivation for restructuring the page and getting code redundancy down to an acceptable level.
The next section will not necessarily deal with all these points, but use the ones we worked the most on.

## Loading time - Assets / compression
According to Google, user experience is very important and also something they factor in when ranking pages. This is also why
SSL has recently been added as a bonus (or rather a penalty for not having it) in their ranking algorithms. The focus on loading time makes
sense as more and more users are on mobile devices with limited battery capacity as well as limited data plans. Thus, having optimized pages
using caching, compression and other strategies for minimizing bandwith as well as not running heavy scripts is increasingly important.

For managing assets, I decided to use GZIP compression  (<a target="_blank" href="https://github.com/jstuckey/gulp-gzip">gulp-gzip</a>) , long cache expiration as well as hosting on Amazon S3.
The app itself is built on Angular.js and a gulp build pipeline, so I just added a step that uploads all assets to an
S3 bucket after a successful run. This step also runs through all HTML / CSS and swaps references to assets with the S3 url.
The S3 part was done using <a target="_blank" href="https://www.npmjs.com/package/gulp-cdnizer">gulp-cdnizer</a>
and <a target="_blank" href="https://www.npmjs.com/package/gulp-s3-upload">gulp-s3-upload</a>.
To bust the cache, all generated assets are versioned using <a target="_blank" href="https://www.npmjs.com/package/gulp-rev">gulp-rev</a> .

We also had another issue. As all user media such as company logos were uploaded to S3 without compression or resizing,
we had a lot of images on the site that was unnecessarily large and caused Pagespeed
to complain. To deal with that, I created a script in the backend that looped through all the
companies and used <a target="_blank" href="https://pypi.python.org/pypi/requests">requests</a>
to get the image, then <a target="_blank" href=" https://pypi.python.org/pypi/Pillow/3.1.0">Pillow</a> to downsize all images to
an acceptable size and save them back to S3. The last part is already handled by Django / boto using S3 as primary file storage.

This script did most of the heavy lifting for updating the logos:
<pre>
size = 600, 600
    if PRODUCTION_MODE:
        for company in Company.objects.all():
            if company.logo:
                try:
                    logo = Image.open(StringIO(urllib.urlopen(
                        company.logo.url).read()))
                except IOError:
                    print company.name
                    continue
                logo.thumbnail(size, Image.ANTIALIAS)
                logo_io = StringIO()
                try:
                    logo.save(logo_io, 'PNG')
                except IOError:
                    logo.convert('RGB').save(logo_io, 'PNG')
                logo_image_file = InMemoryUploadedFile(
                    logo_io, None, uuid.uuid4().hex + '.png', 'image/png',
                    logo_io.len, None)
                company.logo = logo_image_file
                company.save()
                print 'Successfully converted logo for ' + company.name
</pre>
Lastly, a manual inspection of background images, css and similar etc was done to optimize / resize and remove duplicate css.

These steps combined got The pagespeed index from about 2% to 79%, a very decent increase considering the amount of time
spent. From my experience, and also from trying sites like facebook on pagespeed, 79% is a very good score. Getting the last 20% seems
to involve a lot of obscure hacks and a lot of sweat. having it around 80% is far better than most sites and conforms well
with the 80-20 principle.

## So, you got a single page app? And you want SEO? And you want social media to understand the content of your links?
Seamless indexing of single page apps has for a long time been a holy grail for frontend developers. Angular 2.0 will also support it server side rendering,
and this is also supported in react. However, it does not seem to completely straightforward, and will either way involve a case-specific server setup.
Proxbook is built on Angular 1.x, so there was no help here, meaning we had to "roll our own".

Some well known articles on these topics are

* <a target="_blank" href=" http://www.yearofmoo.com/2012/11/angularjs-and-seo.html">http://www.yearofmoo.com/2012/11/angularjs-and-seo.html</a>
* <a target="_blank" href=" https://developers.google.com/webmasters/ajax-crawling/docs/specification?hl=en.">https://developers.google.com/webmasters/ajax-crawling/docs/specification?hl=en.</a>

These describes the mechanics of getting crawlers to 1) understand that your page is a SPA and 2) serve an HTML snapshot of a requested page.
It was a bit difficult to understand whether it applied to sites using hashbang-navigation or pushstate-based navigation as proxbook does to
get more visually appealing URLs. To some degree, they also seem to be a bit outdated.

To my surprise, the Google bot seemed to pick up all links and crawl the page, as well as displaying these links in the search
out of the box, even before we started diving into the SEO. The articles mentioned indicate that you must do special stuff for achieving this, but Google is notoriously secretive about these things actually work and from
my experience they will often put things in production and test it long before they add official documentation.

So, the site would now be crawled and indexed, but we still experienced problems with sharing content on social media (manual testing indicated that it didn't work).
mean-seo, angular-seo had solutions that basically used phantom to render html and send the generated html snapshot to
the requesting entity based on the escaped_fragment semantics described in the articles. This was not a good fit for our
case, so based on those I created a simple express middleware that instead looked at the user-agent that requested the page,
and pre-rendered the page for the user-agents we identify as bots from twitter, facebook and crawlers:

<pre>
var knownBots = [
  'Twitterbot',
  'LinkedInBot/1.0',
  'LinkedInBot/1.0 (compatible; Mozilla/5.0; Jakarta Commons-HttpClient/3.1 +http://www.linkedin.com',
  'Facebot',
  'facebookexternalhit/1.1',
  'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)',
  'Googlebot',
  'Google (+https://developers.google.com/+/web/snippet/)',
  'Google-StructuredDataTestingTool',
  '+http://www.google.com/webmasters/tools/richsnippets',
  'Google-Structured-Data-Testing-Tool',
  '+http://developers.google.com/structured-data/testing-tool',
  'Yahoo',
  'Yahoo! Slurp',
  'bingbot',
  'msnbot',
  'adidxbot',
  'BingPreview'
];

function crawlerMiddleWare(req, res, next) {
  var isCrawler = false;
  for (var i = 0; i < knownBots.length; i++) {
    if (req.headers['user-agent'].indexOf(knownBots[i]) >= 0) {
      isCrawler = true;
      var startedRender, startedPhantom;
      startedPhantom = Date.now();
      phantom.create(function (ph) {
        ph.createPage(function (page) {
          var fullUrl = req.protocol + '://' + req.get('host') + req.originalUrl;
          page.set('settings.loadImages', false);
          page.set('onCallback', function(){
            page.getContent(function (content) {
              console.log('Started phantom and rendered page page in ' + (Date.now() - startedPhantom) + ' ms');
              console.log('finished rendering page in ' + (Date.now() - startedRender) + ' ms');
              res.send(content);
              ph.exit();
            });
          });
          startedRender = Date.now();
          page.open(fullUrl);
        });
      });
      break;
    }
  }
  if (!isCrawler) {
    next();
  }
}
</pre>
A bit hackish, but it seems to work - enabling us to share customized links on social networks and increasing the value
of the content on proxbook. We tested this on facebook, twitter and linkedin, which are the most important platforms for us.

How does it work? If we are dealing with at bot request, Phantom fires up, and loads the original url. When Angular starts up, it fires all API requests as usual. Then, there is a callback
on each http request that checks if there are any pending requests. If there are none, it fires yet another callback to phantom
(the phantom browser exposes a *callPhantom* function to the window object) that
tells it that the rendering is completed, with a safety interval of 500ms:

<pre>
(function() {
  'use strict';

  angular
    .module('proxbook')
    .run(SeoRunConfig);

  SeoRunConfig.$inject = [
    '$rootScope'
  ];

  function SeoRunConfig($rootScope) {
    $rootScope.htmlReady = function() {
      $rootScope.$evalAsync(function() { // fire after $digest
        setTimeout(function() { // fire after DOM rendering
          if (typeof window.callPhantom == 'function') {
            window.callPhantom();
          }
        }, 500);
      });
    };
  }
})();
</pre>

It is not necessary to use a callback to achieve this,
one can also set a timeout for a couple of seconds and just assume that everything is rendered by that time. The best approach would in that case be
to load your site a certain number of times to make it statistically significant, and take the average of the total loading time and add
a safety interval. I tried that as well, and it worked. But since Angular has good support for looking at the number of pending http requests,
the callback approach seemed the more "correct" way of doing it.

In the time ahead, we may turn of this rendering for Googlebot (and / or other), as it already seems to understand
our page without upfront-rendering. Considering the significant performance penalty of rendering pages in this manner, it
is obvious that you only want to use it where and when strictly necessary. You also see that it seems to be some duplication
in the bot list, it was just to safeguard based on reading around the web and stack overflow. The server logs will in time
show which ones are actually used by the crawlers.

We also generated the sitemap server-side by calling the API and populating an XML file with all the content that we wanted in the
sitemap using <a target="_blank" href=" https://github.com/oozcitak/xmlbuilder-js">xmlbuilder-js</a>
  and
<a target="_blank" href=" https://github.com/caolan/async">async</a>
 to speed up the rendering by running all API calls in parallel.

## Wrapping it up
So, the search engines understand our content as well as social networks. Goal achieved.
It was at times a nitty gritty project with some tasks that were pretty boring, and some tasks were challenging and fun to work with. It was
also a humbling and learning experience. At the end of the day, I'm glad i'm not in the SEO business myself, it's really really hard work.

There are probably many of you that have a lot more of experience with this, this just sums up my experiences with working on this for
a short period of time. There are many things that can be done better, for instance using redis, in-memory or disk to cache the html
snapshots for a certain amount of time to increase snappiness and maybe avoid the (if applicable) penalty on the SEO ranking. The image conversion
could also have been done directly on S3 without going through Django and changing their names. But you live and learn, and it works OK so why bother?

There is a lot of material avaiable on this topic online, but I didn't manage to find any material that was really up to date
and that included both SEO and social media optimization for SPAs. I hope this post can be helpful for any of you that are
struggling on this. As we figured out in this post, my solution in itself isn't too many lines of code, but the journey to get there
was long. And it probably never ends as web technology is changing from day to day.