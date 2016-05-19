---
layout: post
title: "Sbt based command-line synonym lookup"
ghavatar: 4453
ghname: torbjornvatn
name: Torbjørn Vatn
jobtitle: Senior Platform Engineer
tags: [scala, sbt, command-line, client]
---

> I need to add some synonyms for these tags.

> How about a simple command-line tool?

### How to quickly create a client to explore data from a API you consider using?

We here at Unacast have explored different solutions to how we can find synonyms
for the tags registered on different resources in our platform so we can suggest
tag improvements to our users.
These tags are mostly nouns and our initial exploration into how this could be
done included downloading, massaging and interfacing a large dump of raw [Wiktionary](en.wiktionary.org) data. We found this solution a bit clunky and inelegant, and
it didn't always give us as good results as we had hoped.

So when I came across [Big Huge Thesaurus](https://words.bighugelabs.com) and
discovered that they have an [API](https://words.bighugelabs.com/api.php) I decided
it was time for a new experiment to see if we could get better synonyms for our tags.
