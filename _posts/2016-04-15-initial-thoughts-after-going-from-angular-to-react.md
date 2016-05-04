---
layout: post
title: "From the trenches: What we learned building a production React Redux application"
ghavatar: 4218596
ghname: martinsahlen
jobtitle: Lead API and Integration Engineer
tags: [js, react, redux]
---

<div class="message">
Hot tip: Want to learn react-redux? check out this guide by mr redux himself:
<a href="https://egghead.io/series/getting-started-with-redux" target="blank">
  https://egghead.io/series/getting-started-with-redux
</a>
</div>

## Summary
This post cointains some thoughts around migrating an existing app from angular 1.x / ES5 to react-redux and ES6-7 and some patterns that have appeared, as well as how it has affected our workflow. I will not get too technical on how i.e. react-redux bindings and react context works. This post gives some empirical arguments why react-redux with ES6-7 is something you definitely should consider for your next project.

This post might be best served to people that are experienced in front-end development on single page applications and are familiar with frameworks and libraries such as react, ember and angular. But I may be wrong.

## Background

### Motivation
The main motivation going from angular 1.x to react-redux may be many, but some are that

* Angular 2 is coming,  Angular 1 is in maintenance mode and approaching end of life
* Migration from Angular 1 to 2 is at best cumbersome
* Angular is a large and complex framework with batteries included, rather than a lightweight library that can be used with other focused libs
* Going from two-way bindings to unidirectional data flow (Flux) - a need to reason more explicitly about app state and how it relates to the UI
* Using the new and exiting features of ES6-7
* Learning new and fun stuff (the most important)

So, it seemed to be a good time to jump on the boat and learn something new. Just to make it clear, i don't believe there are any silver bullets. Let’s consider this more of a story of where react-redux shines and makes life a as a developer a little easier. I say this a developer who have been doing large angular projects for the last three years - there are definitely many things to love about angular.

### Disclaimer
We rely on react-redux-bindings, but there are obviously some features of i.e. the redux store and ES6/7 that is equally valid and useful in angular or in vanilla javascript for that matter. Also, react / redux are completely stand alone libraries that does not require or depend on each other to work. It might be difficult to always separate react from redux in this writing as we are using them very tightly coupled.

### The old stack
To summarize, this was the situation:
ES5, Angular 1.5, Bootstrap, angular-ui-bootstrap, angular-ui-router, restangular, bower, npm, gulp and less + much more

The build system consisted of a ~300 lines custom gulpfile with pretty advanced features that was hard to grasp for everybody, even myself sometimes. It did a lot of magic stuff in very “creative” ways and it was difficult to get into the code after not having touched it for some time.

### The new stack
ES6/7, React-redux / router, redux-dev-tools, material-ui, superagent, webpack, pure npm and no bower.

Webpack is more about configuring the different plugins rather than writing code that works directly on the source files, such as the gulp streaming system. We chose webpack because it seemed to be widely adopted in all examples and tutorials we found, especially on react-redux, both official and non-official sources. Webpack also sports built-in hot reloading that plays really well with what we want to achieve from our development / build-pipeline. To be honest, other options like [browserify](http://browserify.org/) was not considered or investigated in much depth.

## What is Redux
Redux is a very simple and powerful pattern where the entire app state is stored in a single immutable object, and in conjunction with react it can be used to implement the Flux pattern, which basically is about unidirectional data flow in the application, no two-way bindings as in angular.

That’s the redux store / state. The next piece of the puzzle is the reducers. Reducers are simply pure functions that take two inputs - the current state and an action. Based on these two, the new state is computed and returned. The state is immutable, so the reducer will never change the current state.

Let’s look at how this works in pseudo code when a user clicks a button:

* (User clicks button)
* → dispatch(action(USER_CLICK))
* → reduce(currentState, action)
* → return newState
* → subscribing react components are notified and calls .render() on themselves.

Reducers will usually work on small and specific parts of the application state, such as the UI state of a subpage and then all reducers are composed to a bigger reducer, or the store - sometimes referred to as the state tree. This is very powerful, because the application can grow arbitrarily large, and you just add more reducers for the different parts and components with a single responsibility that are small, easily testable (pure) functions.

In the example above, the button click could be used to open a modal dialog. Then, the newState object would have a key called isDialogOpen set to true. Then as the view component renders, it will show the modal given that the prop isDialogOpen is true. Declarative and easy to reason about!

### React-redux bindings
React-redux bindings and “smart components” enables you to extract just the piece of state you want to render, for instance the logged in user’s name to display in a top bar component, using the connect() method from react-redux bindings. When an action is dispatched - the store will propagate this to subscribers, which are the smart react components that will rerender.

What the connect method essentially does is to map the app state to component props as your are familiar with from react, by slicing off the piece of state you want. It also adds the dispatch method as prop on the component so you can use it to dispatch actions based on i.e. mouse clicks, button clicks, input field focus / blur, routing / url updates, map zooming, panning etc.

### Why is react-redux a powerful pattern
React-redux  is a powerful pattern for creating and reasoning about UI. It forces you to consider all possible events that can happen in the app and give them a semantic meaning. Lastly, you decide how these events should affect the app state through dispatching actions.  All reducers receive actions and can respond with a new state however they see fit. The UI can be seen as just a pure function of the state object, easing overall testability and general reasoning about the UI. For debugging, it’s also great because you can easily reproduce state given a series of actions.

Further, using react-redux with hot reloading is supported, meaning that the source code can be changed in real time (while the state is kept in store). Remember, the UI is a function of the state so we just render what is there at any time. Super simple and powerful when developing on complex navigation and interactions such as modal dialogs, forms, wizards with steps and similar. How many times have you (using live-reload) not done a small change to form, just to reset all form fields when you do a small css change? The great part is that is not really a feature, it is more consequence of the fact that all app state is the store and not scattered around in code that can be hot reloaded.

The [redux-devtools](https://github.com/gaearon/redux-devtools) are also awesome, giving you an instant overview of the app state and actions dispatched.

This together gives a very developer friendly and fun environment to work in. In Angular, data is scattered around in different controllers, maybe in services, but it the overall app state is arguably more implicit. From my experience, react-redux yields some more code and verbosity, but explicitness trumps implicitness all the time. There are for instance a lot of sugar contained in the react-redux bindings, but we have opted to not use too many of them, as they can be hard to understand and are really very simple convenience functions, such as the connect() function explained above.

### Our approach and learnings
Getting started with a npm / js project nowadays is a truly daunting task, and there are enough memes, tweets and rants about this, so I will not add to that. I do believe that it’s best to start simple and learn, so I’m not a huge fan of all these “starter kits”, because they just take your breath away in their complexity and fancy approaches to handle all use cases and corner cases. I think it’s the best way to lose motivation when learning new stuff. Start simple! At a later stage it’s obviously great to borrow ideas from other’s work but it’s not a good idea to solve all types of problems before you have them.

We decided to clone the [react-redux counter example](https://github.com/reactjs/redux/tree/master/examples/counter) and build it out, adding additional tooling as we went along. This was a sweet spot in terms of being easy to understand, yet having some wiring done already.

What we saw was in many ways that we approached the [real-world-example](https://github.com/reactjs/redux/tree/master/examples/real-world), in terms of structure and features added. For instance, we quickly discovered that using [normalizr](https://github.com/gaearon/normalizr) is a must for storing API data in the store, as reducers don’t deal well with arrays. I think this plays well with my previous argument about not adding a lot of stuff before you know what it is for and why it is useful. It also made us understand better why normalizr is a good pattern for dealing with API data in reducers. Further, using among other the features in ES7 and lodash, you can slice and dice objects in an immutable manner. You can quote me on this; when developing in react-redux, you become very familiar with lodash you will probably use most of the functions at least once.

As the app grew, we saw that Webpack started taking close to 30s on build, and 4-5s on hot-reload, which was getting painful. Using [happypack](https://github.com/amireh/happypack) and some modifications to how webpack deals with sourcemaps, we got times down to 6-8s on build and <1 s on hot-reload.

## Closing notes
Our experiences with react-redux so far are very good. It’s far from a silver bullet, and the batteries-not-included approach requires you to reason about your app’s structure and libraries to use for different functionality. We have opted for a module approach, which has its advantages and disadvantages, and the app is continuously being refactored as we learn and discuss along the way. Yet, we are very happy about our decision. If that’s the right choice for you and your team is another question, but I hope the above has given you some more insight - maybe not on the super technical level, but on why the philosophy behind react-redux is a great one.

Look out for code in later posts, we will probably go into more detail as things are getting  polished!
