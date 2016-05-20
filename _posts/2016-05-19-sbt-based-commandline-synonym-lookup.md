---
layout: post
title: "Sbt based command-line synonym lookup using parser combinators"
ghavatar: 4453
ghname: torbjornvatn
name: Torbjørn Vatn
jobtitle: Senior Platform Engineer
tags: [scala, sbt, command-line, client]
---

> I need to add some synonyms for these tags.

> How about a simple command-line tool?

### What do we need synonym lookup for?

We here at Unacast have explored different solutions to how we can find synonyms
for the tags registered with the different resources in our system, so that we can suggest
tag improvements for our partners.
These tags are mostly nouns and our initial exploration into how this could be
done included downloading, massaging and interfacing a large dump of raw [Wiktionary](en.wiktionary.org) data. We found this solution a bit clunky and inelegant, and
it didn't always give us as good results as we had hoped. So when I came across [Big Huge Thesaurus](https://words.bighugelabs.com) and
discovered that they have an [API](https://words.bighugelabs.com/api.php), I decided
it was time for a new experiment to see if we could improve the quality of our tag suggestions.

For this test, I wanted to get suggestions for the actual tags in our database and I wanted to store the suggestions so we could display them in our admin UI. So I had to write something capable of accessing our API and the Big Huge Thesaurus API in a manageable way, but at the same time, I didn't want to build a full blown-app with a web UI and all the complexity that introduces.

### How to quickly create a client to explore data from an API you consider using?

The solution I came up with was inspired by a talk from Josh Suereth about a simple twitter command-line client called [snark](https://github.com/jsuereth/snark), that he had made using a rather original technique. It's based on the internal features powering the excellent interactive mode of the [interactive Scala Build Tool, sbt](http://www.scala-sbt.org/).
It enables me to build a rather advanced command-line tool with autocompletion, ANSI colors and dynamic content only using my favorite language, Scala. I can also package it into any kind of executable using a plugin for sbt called [sbt-native-packager](https://github.com/sbt/sbt-native-packager). That beats wrestling around with a bash script trying to make API calls, parse JSON and at the same time present the results as suggestions using bash-completion.

**This is how it looks in action:**

<script type="text/javascript" src="https://asciinema.org/a/et55aud3fc4yd2kypqvjprlwe.js?"
id="asciicast-et55aud3fc4yd2kypqvjprlwe"
data-speed="2" data-theme="solarized-light" data-t="5" async></script>

As you can see I get tab completion suggestions for the different parts of the command I'm trying to use.
The sbt console also has support for ANSI colors out of the box.

### So how does this marvel work?

As I mentioned earlier it's powered by the command-line client engine in sbt, which in turn uses [JLine](http://jline.sourceforge.net/) to read input from the console and it's own implementation of the [Parser Combinator](https://en.wikipedia.org/wiki/Parser_combinator) pattern for making sense of that input.

>In functional programming, a parser combinator is a higher-order function that accepts several parsers as input and returns a new parser as its output. In this context, a parser is a function accepting strings as input and returning some structure as output, typically a parse tree or a set of indices representing locations in the string where parsing stopped successfully. Parser combinators enable a recursive descent parsing strategy that facilitates modular piecewise construction and testing. This parsing technique is called combinatory parsing.

This allows me to implement the commands I want the CLI to handle as separate parsers that can be combined in the order I want the autocompletion to present them. The resulting parsers from the different combinations encapsulate the actual command that gets executed to perform the task we want to be done.

### Show me the code!

I've created a small sample implementation that shows the main components needed to make a command-line tool like this. Take a look at this [Github project](https://github.com/unacast/sbt-cli-example) for a runnable example or see the gist below for code examples.

<script src="https://gist.github.com/torbjornvatn/88a77b7d5486c76611a10ee95bb837be.js?file=main.scala"></script>

<script src="https://gist.github.com/torbjornvatn/88a77b7d5486c76611a10ee95bb837be.js?file=commands.scala"></script>

### Wrapping up

Using sbt and it's parser combinator abilities it's a breeze to create simple to use CLI tools with full tab completion backed by the full force of Scala to implement the program logic. Combined with the `sbt-native-packager` plugin we can also make them run natively on the major platforms, as runnable jars or even as Docker images. Clone my [example project](https://github.com/unacast/sbt-cli-example) and try for yourself!
