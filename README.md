# The npm Dependency Explorer

The [npm Dependency Explorer] is a web application that allows you to compute and explore the total
dependencies for any [Node Package Manager (npm)][npm] JavaScript package. It provides various
features to sort, filter, and visualize package dependencies.


## Links

- [npm Dependency Explorer]

- [Source Code][source]


## Features

- Compute a package's total dependencies

- Compute a package's total development dependencies

- Sort dependencies by the number of sub-dependencies

- Filter to display only outdated dependencies

- Identify dependencies with multiple versions

- Visualize a package's dependencies over time


## Managing Dependencies

Before adding a package as a dependency, it's crucial to carefully consider the potential impact on
your project's velocity and maintenance costs. While dependencies can provide valuable functionality
not available in your language's standard library, they also introduce challenges that can slow down
development and increase the risk of bugs and compatibility issues.


### The Dependency Rules

Follow *The Dependency Rules* to reduce the risks of dependencies:

- The dependency should provide unique functionality not available in your language's standard
  library, ensuring that it is genuinely necessary and adds value to your project.

- The dependency should be well-maintained, with extensive unit test coverage, backward
  compatibility, and respect for The Dependency Rules, ensuring that it remains reliable over time.

Following these rules is the best way to ensure that your project's dependencies are necessary,
reliable, and well-maintained.


### Reducing Dependencies

By minimizing the number of external dependencies, developers can decrease their project's
complexity, making it easier to understand and maintain. They can also reduce the time spent
managing dependencies and waiting for builds and deployments to complete, which can improve
development velocity and minimize the risk of errors and conflicts.

Managing dependencies is essential to developing reliable, maintainable software. Following The
Dependency Rules and reducing a project's dependencies can help enhance productivity, decrease
maintenance costs, and reduce the risk of errors and compatibility issues. The [npm Dependency
Explorer] can be a valuable tool for exploring dependencies and identifying opportunities to
simplify and streamline your project.


[npm Dependency Explorer]: https://craigahobbs.github.io/npm-dependency-explorer/
[source]: https://github.com/craigahobbs/npm-dependency-explorer
[issues]: https://github.com/craigahobbs/npm-dependency-explorer/issues
[npm]: https://www.npmjs.com/
