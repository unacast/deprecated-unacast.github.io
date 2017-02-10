---
layout: post
title: "Simplified database migrations in go"
ghavatar: 501424
ghname: mastoj
jobtitle: Platform Engineer
tags: [go, golang]
---

## Introduction

There are two main criteria that one should look for when choosing a database migration framework; it should be simple and it should always roll forward. When we began looking for a migration framework to use in one of our Go applications we could not find one that was simple in the sense that it could read from file as well as from pre-compiled assets, which we tend to use at Unacast, and only rolls forward. As a result of that we ended up implementing our own simple [migration framework](https://github.com/unacast/migrations) for Go applications, which I will guide you through in this post.

*TLDR; Grab the code on [github](https://github.com/unacast/migrations)*

## Why you should not roll back a database

For some it might sound a little bit odd to say that you should never roll back a database, but let us think about what a rollback is for a moment. While you think about that I will define what I mean rollback and rollforward are.

* Rollforward: an action in which you take your database from one state to another
* Rollback: an action in which you take your database from one state to another

The observant reader will notice that the definition for both actions are quite similar, or wait, they are the same. This means that instead of having a rollback you can just write a new rollforward if you are in a situation where a database update has gone wrong. 

Another reason is that database roll backs are complicated and there are a lot of things that you need to consider, which you most likely will not, when you are writing a rollback. Let me show an example of something that most people would do when writing a new migration adding a new column:

1. Write migrate up that adds column X
2. Write migrate down that removes column X
3. Runs migration

So far so good. If step 3 fails you can just rollback right away, no stress, but this could also be solved by using a transaction when you run the migration. A more complicated scenario, and probably more realistic one as well, is that migration went well but a couple of hours later the database starts to act weird. What do you do? Should you run the rollback? Probably not. At this point in time you have already gotten some data in the new column X which you most likely want to keep, so the solution for rolling back is not just to remove what you just added. Instead you should write a new migration where you define what you should do to not lose any data. If you would have run the rollback at this point in time, when you have data in column X, you would lose that data. This means that rollbacks are only good during the migration process inside a transaction, but at that point you could as well just use the transaction as rollback mechanism.

Not everyone agrees with always rolling forward, and that is ok, but this is the way we at Unacast think of migrations.

## Why could not we just use an existing migration framework

In regard of the roll back issue we could most likely have used an existing framework but not use the roll back feature. The main reason to why we wrote our own framework was that none of the frameworks we could find supported reading migration scripts from assets. In most of our Go applications we compile everything to one file, using [go-bindata](https://github.com/jteeuwen/go-bindata), meaning that sql files will have a pre-compile step where we generate Go files from the content in the sql scripts. This together with our opinionated view of migrations made us write a new migration framework.

## Implementing a migration framework

Before implementing something, it is always good to think about what you want to achieve. The minimum list of features for this project was:

* Run migrations from assets
* Run migrations from files
* Run all migrations, that has not been run before, in one transaction
* It should use the existing `sql.DB` package
* Only roll forward

That does not sound too hard, and it is not as we will see. The last point actually makes things a little bit easier since we are leaving out one feature, rolling back, compared to most other migrations framework. When we know the set of features we need to define the main flow and it turns out it is quite simple:

1. Verify a migrations table exist, this is needed to keep track of which migrations that has been executed
2. Get all migrations that has been executed
3. Get all migrations
4. Start transaction
5. Loop over and execute all migrations, ignore those that are already executed
6. Commit transaction if everything is ok, otherwise roll back transaction (note that this is not roll back of the migration, just a roll back of the transaction)

Now we know everything we need to know to implement the migrations framework. I will not cover all the code, which you can find on [github](https://github.com/unacast/migrations/blob/master/migrations.go), but there is one thing that I would like to cover. If you look at the signature of the `Migrate` function it looks like this:

    func (migrator *Migrator) Migrate(getFiles GetFiles, getContent GetContent) 

where `GetFiles` and `GetContent` has the following signature:

    type GetFiles func() []string
    type GetContent func(string) string

The rationale behind this approach, instead of giving a folder path where all the files are, is that we can take any function as parameter to the `Migrate` function that returns a list of strings pointing to where the actual content is and then use the second function to get that content. It also makes it very flexible since the migrations framework is agnostic to where and how the actual content is stored. 

When writing your migrations, you will implement a function that has the signature of `GetFiles` and it will most likely do one of these two things:

* Return a list of files in a folder or folder tree
* Return a list of keys that you can use against some map to get content

What your function that implements `GetContent` should do depends on how you decide you want to use the framework. If reading directly from files the input to `GetContent` should be file paths, that you get from your `GetFiles` function, and then your `GetContent` function just returns the content of those files. If you are using assets your `GetContent` function should read from the asset framework instead of from disk.

## Using the framework

We are still missing a little bit of documentation, but it should be enough to get you started in the [readme](https://github.com/unacast/migrations). Running the migration from inside your application is as simple as: 

```
func runMigrations() {
    db, _ := connectToDb() // should return *sql.DB
    getFiles := func() []string {
        files, _ := assets.AssetDir("migrations/sql")
        return files
    }
    getContent := func(file string) string {
        bytes, _ := assets.Asset(fmt.Sprintf("migrations/sql/%s", file))
        return string(bytes)
    }
    migrator := migrations.New(db)

    migrator.Migrate(getFiles, getContent)
    db.Close()
}
```

In the example above we are using assets, which have been generated from sql files. The `getFiles` function returns a list of "file names" in the asset folder `migrations/sql`. The `getContent` function will get the output from `getFiles` as input and will just read the actual asset on each request. With those two defined we can now call `Migrate`.

Please try it out and let us know what you think. If you have any problems just register a github issue or (even better) send us a PR.