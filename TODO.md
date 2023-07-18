## Check and add packages

- [ ] movedesign: https://ecoisilva.github.io/movedesign/
      * paper: https://twitter.com/ecoisilva/status/1668177982718980097?s=46&t=Z2tKSAWwQu4saaRVEKNTvQ
- [ ] hmmSSF: https://github.com/NJKlappstein/hmmSSF
      * paper: https://twitter.com/njklappstein/status/1665417299963019264?s=46&t=Z2tKSAWwQu4saaRVEKNTvQ
- [ ] MoveFormer: https://github.com/cifkao/moveformer
      * paper: https://twitter.com/chamaillejammes/status/1633197981858947072?s=46&t=Z2tKSAWwQu4saaRVEKNTvQ
- [ ] move2: https://cran.r-project.org/web/packages/move2/index.html
      * doc: https://bartk.gitlab.io/move2/
- [ ] moveR: https://github.com/qpetitjean/MoveR
      * doc: https://qpetitjean.github.io/MoveR/index.html

## Markdown CTV file

- [ ] **Rewrite the _Path reconstruction_ section** by being more explicit, and
      check other sections that need clarification (it's OK to have several aims
      for 1 package, 1 aim for several packages, but not several aims for
      several packages).
- [ ] **Check documentation format** as recommended by the CTV org:
      https://github.com/cran-task-views/ctv/blob/main/Documentation.md 

## Long term organization

- [ ] **Check maintenance guidelines** as recommended by the CTV org:
      https://github.com/cran-task-views/ctv/blob/main/Maintenance.md 
- [ ] **Add individual issues for each package of the list**, so we have one
      place for all discussion points related to a package. We could certainly
      have templates for basic messages (for instance those that are on CRAN or
      checks CRAN tests).
- [ ] **Consider contacting maintainers of each package** to let them know about
      the CTV and their individual issue for relevant discussion.

## Dev features

- [ ] Use **GitHub Actions for continuous integration** of the CTV (just like a
      R package). That would allow to automatically test current packages. New
      packages would only be tested when formally added. See
      [here](https://github.com/r-lib/actions) for relevant examples.
      * See also https://github.com/cran-task-views/ctv/tree/main/validate-ctv
        and particularly https://github.com/cran-task-views/ctv/blob/main/validate-ctv/action.yml
- [ ] **Check [`renv`](https://rstudio.github.io/renv/)** as a replacement to
      `packrat` to deal with the private library of packages. [Migration
      tools](https://rstudio.github.io/renv/articles/renv.html#migrating-from-packrat)
      are provided with `renv`.
- [ ] **Implement automatic CRAN package search** in our workflow, for instance
      with `pkgsearch::pkg_search()`, fixing some search terms (#33), or with
      `CTVsuggest::CTVsuggest()`.
