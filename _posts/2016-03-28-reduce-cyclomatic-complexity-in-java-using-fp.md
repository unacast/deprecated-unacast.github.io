---
layout: post
title: "Battling Cyclomatic Complexity in Java using Javaslang"
ghavatar: 4453
ghname: torbjornvatn
name: Torbjørn Vatn
jobtitle: Senior Platform Engineer
tags: [java, scala, javaslang]
---

<div class="message">
  What does that deeply nested if statement do exactly?
</div>

The last couple of weeks I've been doing some java programming for the first time in 5 years, and something
that my Scala tuned brain has had a hard time readjust to, is **nested if statements with returns in them**.

In my view this way of doing control flow is quite hard to follow and leads to high 
[Cyclomatic Complexity](https://en.wikipedia.org/wiki/Cyclomatic_complexity).

Lets look at an example that I encountered recently (the code has been somewhat altered to protect the innocent):

<script src="https://gist.github.com/torbjornvatn/99325d5985ac0c43f3e8.js?file=the_old_ways.java"></script>

As we can see the nesting goes deep, and there are seveal places where the code can "escape" via a return.
It's not obvious what the result will be in any given situation, at least not to me.

I started to think about how I would have solved this particular problem in Scala and I recalled that a former
colleague of mine had given me a tip about a functional library for Java called [Javaslang](http://www.javaslang.io/).
I desided to see if I could solve this problem in a Scala'ish style using that library.

My first attempt looked like this:

<script src="https://gist.github.com/torbjornvatn/99325d5985ac0c43f3e8.js?file=the_slightly_better_way.java"></script>

It was slightly better than the original as the different operations where separated out into functions that was called
from one quite compact return statement at the end. However I thought it had some shortcommings:

- There where still some **nested if statements with returns in them**. 
- The `map()` on line `11` actually discards it's argument and performs a side effect using the `user` argument from the encapsualting
function instead.

This code could also have been accompished using the methods available on `java.util.Optional`, so there wheren't really any good
reason to introduce Javaslang just to do it this way. Javaslang had another trick up it's sleeve however, one that it has 
borrowed from languages like Scala and Haskell, namely [Pattern matching](https://en.wikipedia.org/wiki/Pattern_matching).

Using that as an approach, I landed on this solution:

<script src="https://gist.github.com/torbjornvatn/99325d5985ac0c43f3e8.js?file=the_javaslang_way.java"></script>

So what did we gain from this?

- If we count the `Cases` of the `Match` as one Cyclomatic Complexity point, non of the three code blocks gets above 4.
- The extraction syntax of Pattern Matching gives us the power to check both that the `Option` is non empty and it's 
value fulfils a predicate in one swoop.
- The alignment of the the `Case` lines makes for great readability (in my view).
- If you get used to the style of looking at the last line/block of a method for it's return statement, you'll usually find
a compact and concise definition composed of functions doing one separate thing.

Last, but not least, I've also included a Scala version of the same solution for comparison.

<script src="https://gist.github.com/torbjornvatn/99325d5985ac0c43f3e8.js?file=the_scala_way.scala"></script>



