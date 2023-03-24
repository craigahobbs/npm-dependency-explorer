# The npm Dependency Explorer

The [npm Dependency Explorer] is a web application that allows you to compute and explore the total
dependencies for any [Node Package Manager (npm)][npm] JavaScript package. It provides various
features to sort, filter, and visualize package dependencies.


## Links

- [npm Dependency Explorer]

- [Source Code][source]


## Features

- Compute a package's total dependencies

- Compute a package's total *development* dependencies

- Order dependencies by most sub-dependencies

- Filter to only out-of-date dependencies

- Compute dependencies with multiple versions

- Visualize a package's dependencies over time


## The Dependency Rules

Before taking a package as a dependency, it's important to consider *The Dependency Rules*. The
rules are:

1. The dependency should give you "something good" - it implements something non-trivial that is not
   in your language's standard library.

2. The dependency is well-maintained - it has high unit test coverage, maintains
   backward compatibility, and respects *The Dependency Rules*.

Following these rules is the best way to improve productivity and minimize maintenance headaches.


## Usage

To use the [npm Dependency Explorer], enter the package name you want to explore. The application
will compute the package's dependencies and display them in a table. From there, you can sort and
filter the table to find the necessary information.


## Feedback

I'm always looking for ways to improve the [npm Dependency Explorer]. If you have any feedback or
suggestions, please let me know by [contacting me][issues].


[npm Dependency Explorer]: https://craigahobbs.github.io/npm-dependency-explorer/
[source]: https://github.com/craigahobbs/npm-dependency-explorer
[issues]: https://github.com/craigahobbs/npm-dependency-explorer/issues
[npm]: https://www.npmjs.com/
