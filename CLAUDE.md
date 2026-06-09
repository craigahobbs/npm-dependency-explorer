# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

The npm Dependency Explorer is a client-rendered web application that computes and visualizes the
total dependency tree for any npm package. It is written entirely in **BareScript** and runs as a
**MarkdownUp** application — there is no build step or server; the browser loads `index.html`, which
runs `npmDependencyExplorer.md`, which includes and executes the `.bare` source. All npm registry
data is fetched client-side from `https://registry.npmjs.org/` via `systemFetch`.

When writing or modifying `.bare` files, invoke the `bare-script` skill — it covers BareScript syntax,
the built-in library, the MarkdownUp/`markdown-script` model, and unit-test conventions.

## Commands

- `make test` — run the unit tests (coverage-enforced; see `test/runTests.bare`)
- `make test TEST=<name>` — run a single test by name (e.g. `make test TEST=testSemverParse`)
- `make lint` — static-check all `.bare` source and tests
- `make commit` — runs `test` and `lint` (use before committing)
- `make clean` / `make superclean` — remove `build/` and downloaded tooling

The build system is bootstrapped: the `Makefile` downloads `Makefile.tool` from the `python-build`
project, which creates a Python venv under `build/env/` and installs the `bare-script` package
(providing the `bare` CLI). `Makefile.tool` and `build/` are gitignored and regenerated.

To run the app locally, serve the repo root over HTTP and open `index.html` (it loads MarkdownUp and
its dependencies from `craigahobbs.github.io`). Open `test/index.html` to run the test suite in-browser.

## Architecture

Three source modules, layered bottom-up:

- **`semver.bare`** — standalone semantic-versioning library: parse/stringify/compare semver, and
  `semverMatch` which resolves an npm version range against a set of available versions. No
  dependencies on the other modules. This is the most heavily unit-tested module (`test/testSemver.bare`).

- **`npm.bare`** — npm registry layer. Builds package-data URLs, fetches package metadata, and
  maintains an in-memory **cache** (`npmCacheNew`) keyed by `packages`, `versions`, and `ranges`.
  The core work is recursive dependency resolution: `npmCacheLoadPackage*` fetch and walk the tree
  (resolving each dependency's range to a concrete version via `semver.bare`), and
  `npmPackageStats` / `npmCacheGetPackageDependencies` compute the flattened totals, version
  conflicts, and warnings. Batched `systemFetch` of multiple URLs is used to parallelize loads.

- **`npmDependencyExplorer.bare`** — the UI. `ndeMain()` is the entry point. It parses URL hash
  arguments via `argsParse(ndeArguments)` (the `argsValidate` schema near the bottom of the file
  defines every query param: `name`, `version`, `dev`, `direct`, `latest`, `sort`, `warn`,
  `versionSelect`, `versionChart`), loads data through the cache, and renders Markdown + tables +
  line charts. The app is entirely URL-driven: navigation links are built with `argsLink`, so app
  state lives in the location hash, not in mutable variables.

## Testing notes

`test/runTests.bare` is the single test harness. It starts coverage, `include`s the production
modules (the `npmDependencyExplorer.bare` and `npm.bare` includes count as coverage in lieu of
direct tests), then includes test files like `testSemver.bare`. Coverage is enforced via
`coverageMin` in the `unittestReport` call — if you add substantial code, expect to add tests or the
coverage gate will fail.
