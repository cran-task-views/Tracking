## Packages

- [ ] **Add individual issues for each package of the list**, so we have one
      place for all discussion points related to a package. We could certainly
      have templates for basic messages (for instance those that are on CRAN or
      checks CRAN tests). That would be particularly important for packages that
      do not pass CRAN checks (see next point).
- [ ] **Consider contacting maintainers of each package** to let them know about
      the CTV and their individual issue for relevant discussion. Start by
      packages that do not pass CRAN checks, so they can work on fixing them.

## Tracking.md

- [ ] **Rewrite the _Path reconstruction_ section** by being more explicit, and
      check other sections that need clarification (it's OK to have several aims
      for 1 package, 1 aim for several packages, but not several aims for
      several packages).

## Dev

- [ ] **Print informative messages** on different steps, and success or not
      of CRAN checks.
- [ ] **Handle errors** so that the check function does not stop.
- [ ] **Update the function documentation** (the mini-package).
- [ ] **Create a proper package** from the mini-package.
- [ ] **Account for the new Git convention for the primary branch?** Previously
      the primary branch was called 'master' and for newer repository that
      defaults to 'main'. For now, 'master' is used if left empty — 'main' (or
      other) needs to be specified.
- [ ] Use **GitHub Actions to validate the CTV**:
      https://github.com/cran-task-views/ctv/tree/main/validate-ctv
- [ ] Use **GitHub Actions for continuous integration** of the CTV (just like a
      R package). That would allow to automatically test current packages. New
      packages would only be tested when formally added. See
      [here](https://github.com/r-lib/actions) for relevant examples.
- [ ] **Implement automatic CRAN package search** in our workflow, for instance
      with `pkgsearch::pkg_search()`, fixing some search terms (#33), or with
      `CTVsuggest::CTVsuggest()`.
