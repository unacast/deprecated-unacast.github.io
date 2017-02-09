---
layout: post
title: "Simplified database migrations in go"
ghavatar: 501424
ghname: mastoj
jobtitle: Platform Engineer
tags: [go, golang]
---

## Introduction

There are two main criteria that one should look for when choosing a database migration framework; it should be simple and it should always roll forward. When we began looking for a migration framework to use in one of our applications we couldn't find one that was simple in the sense that it could read from file as well as from pre-compiled assets, which we tend to use at Unacast, and only rolls forward. As a result of that we ended up implementing our own simple migration framework for go applications, https://github.com/unacast/migrations, which I will guide you through in this post.

*TLDR; Grab the code here: https://github.com/unacast/migrations*

## Why you shouldn't roll back a database

For some it might sound a little bit odd to say that you should never rollback a database, but let's think about what a rollback is for a moment. While you think about I'll define what I mean rollback and rollforward are.

* Rollforward: an action in which you take your database from one state to another
* Rollback: an action in which you take your database form one state to another

The observant reader will notice that the definition for both actions are quite similar, or wait, they are the same. This basically means that instead of having a rollback you can just write a new rollforward if you are in a situation where a database update has gone wrong. 

Another reason is that database roll backs are complicated and there are a lot of things that you need to consider, which you most likely won't, when you're writing a rollback. Let me show an example of something that most people would do when writing a new migration adding a new column:

1. Write migrate up that adds column X
2. Write migrate down that removes column X
3. Runs migration

So far so good. If step 3 fails you can just rollback right away, no stress, but this could also be solved by using a transaction when you run the migration. A more complicated scenario, and probably more realistic one as well, is that migration went well but a couple of hours later the database starts to act weird. What do you do? Should you run the rollback? Probably not. At this point in time you have already gotten some data in the new column X which you most likely want to keep, so the solution for rolling back isn't just to remove what you just added. Instead you should write a new migration where you define what you should do to not lose any data.

Not everyone agrees with always rolling forward, and that is ok, but this is the way we at Unacast think of migrations.

## Why couldn't we just use an existing migration framework

In regard of the rollback issue we could most likely have used an existing framework but not used the rollback feature. The main issue to why we wrote our own framework was that none of the framework I could find supported reading migration scripts from assets. In basically all our go application we compile everything to one file, meaning that sql files will have a pre-compile step where we generate go files from the content in the sql scripts. At the same time, it would be nice to use a file backed approach if we would like that in the future. This together with our opinionated view of migrations made us write a new migration framework.

## Implementing a migration framework

Before implementing something, it is always good to think about what you want to achieve. The minimum list of features for this project was:

* Run migrations from assets
* Run migrations from files
* Run all migrations, that hasn't been run before, in one transaction
* It should use the existing `sql.DB`
* Only roll forward

That doesn't sound so hard, and it isn't as we will see. The last point actually makes things easier since it is a cut in scope compared to most migrations framework. When we now the set of features we need to think about the main flow through the code, and it turns out it is quite simple for migrations:

1. Verify a migrations table exist, this is needed to keep track of which migrations we have run
2. Get all migrations that has been executed
3. Get all migrations
4. Start transaction
5. Loop over and execute all migration, ignore those that are in the list of executed migrations since before
6. Commit transaction if everything went ok, otherwise rollback transaction (note that this is not a migration rollback, just a transaction rollback)

Now we know everything we need to know to implement the migrations framework. I won't cover all the code, which you can find here https://github.com/unacast/migrations/blob/master/migrations.go, but there is one thing that I would like to cover. If you look at the signature of the `Migrate` function it looks like this:

    func (migrator *Migrator) Migrate(getFiles GetFiles, getContent GetContent) 

where `GetFiles` and `GetContent` has the following signature:

    type GetFiles func() []string
    type GetContent func(string) string

The rationale behind this approach, instead of giving a folder path where all the files are, is that we can take any function as parameter to the `Migrate` function that returns a list of strings pointing to where the actual content is and then use the second function to get that content. `GetFiles` should do is one of two things most likely:

1. Return a list of files in a folder or folder tree
2. Return a list of keys that you can use against some map to get content

What the function `GetContent` should do depends on how you decide you want to use the framework. If reading directly from files the input to `GetConent` should be file paths, that you get from `GetFiles`, and then `GetContent` just returns the content of those files. If you are using assets `GetContent` should read from the asset framework instead of from disk.

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