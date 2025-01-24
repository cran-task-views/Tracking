## Check and add packages

- RSP: check issue with synonymous on CRAN
  https://github.com/cran-task-views/Tracking/issues/37

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

- [ ] Silence all output (notably package installation stuff) except for
      explicit messages and errors. Complete output should go to the log file. 
- [ ] Create a mini package: one function to work on a single line of the table,
      one function to make it a loop and produce the final table, another one
      for network stuff, and another one for differences.
- [ ] Sometimes download from GitHub fails with:

        trying URL 'https://github.com/SESman/rbl/archive/master.zip'
        downloaded 55.5 MB
        
        Error in `httr2::resp_body_json()`:
        ! Unexpected content type "text/html".
        • Expecting type "application/json" or suffix "json".
        Run `rlang::last_trace()` to see where the error occurred.

- [ ] Use **GitHub Actions for continuous integration** of the CTV (just like a
      R package). That would allow to automatically test current packages. New
      packages would only be tested when formally added. See
      [here](https://github.com/r-lib/actions) for relevant examples.
      * See also https://github.com/cran-task-views/ctv/tree/main/validate-ctv
        and particularly https://github.com/cran-task-views/ctv/blob/main/validate-ctv/action.yml
- [ ] **Implement automatic CRAN package search** in our workflow, for instance
      with `pkgsearch::pkg_search()`, fixing some search terms (#33), or with
      `CTVsuggest::CTVsuggest()`.
