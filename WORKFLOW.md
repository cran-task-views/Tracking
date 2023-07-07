There are two types of releases, the rolling release and checked releases.

## Rolling release

* Rolling release essentially accounts for quick-and-easy fixes in between
  heavier checked releases : Only CRAN and Bioconductor packages are added, as
  they are already checked.
* Rolling releases live in the `main` branch, and are automatically published
  from the `Tracking.md` file.
* The version is the ISO date of the automatic publication.
* **The trigger event of a new rolling release is typically a new package
  submission.**

To-do list for rolling releases, upon each new package submission:

- [ ] Evaluate the submitted package against the scope criteria.
- [ ] Add the package to
      [`Tracking_tbl.csv`](https://github.com/cran-task-views/Tracking/blob/main/checks/Tracking_tbl.csv)
- [ ] For new CRAN/Bioconductor packages, add a description in the relevant
      section of
      [`Tracking.md`](https://github.com/cran-task-views/Tracking/blob/main/Tracking.md)
- [ ] For new CRAN/Bioconductor packages, add a line to the
      [`NEWS.md`](https://github.com/cran-task-views/Tracking/blob/main/NEWS.md)
      file in `New packages` section for the next checked release (see template
      below).
- [ ] For packages declined due to scope criteria, add a line to the
      [`NEWS.md`](https://github.com/cran-task-views/Tracking/blob/main/NEWS.md)
      file in `Declined submissions` section for the next checked release (see
      template below).
- [ ] For non-CRAN/non-Bioconductor packages that fall within the scope, reply
      in the submission issue that the package is considered for the next
      checked version.
- [ ] Close the GitHub issue for the submission.

> # Tracking CTV next checked release
> 
> ## New packages
> 
> * [`Blip`](CRAN URL): Does This And That As A Tracking Package.
> 
> ## Declined submissions
> 
> * [`Blop`](Submission URL): Does Many Things Out Of Scope.


## Checked releases

* Checked releases are thoroughly tested and complete updates, including new
  non-CRAN/non-Bioconductor packages, removal of packages,
* Checked releases live in the `dev` branch, and are only published when merged
  back to `main`.
* The version is the ISO date of the automatic publication, but the Tracking CTV
  (automatically) indicates the date of the last checked release.
* **The trigger event of a new checked release is the manual initiation of the
  process by one of the maintainers, ideally twice a year.**

To-do list for checked releases, when full tests are to be run:

- [ ] Branch out from `main` into `dev`
- [ ] Check all [open issues for package
      submissions](https://github.com/cran-task-views/Tracking/issues?q=is%3Aissue+is%3Aopen+label%3Aadd-pkg),
      and make sure submitted packages are sorted out and included in
      [`Tracking_tbl.csv`](https://github.com/cran-task-views/Tracking/blob/main/checks/Tracking_tbl.csv)
- [ ] Run the [full
      tests](https://github.com/cran-task-views/Tracking/blob/main/CheckPackages.R)
      (note: Make sure to check the packages that have `skip = TRUE` in the
      table).
- [ ] Check [archived
      packages](https://github.com/cran-task-views/Tracking/issues/49).
- [ ] Complete the
      [`NEWS.md`](https://github.com/cran-task-views/Tracking/blob/main/NEWS.md)
      file fully (see template below), including:
    - [ ] Overview
    - [ ] Newly included non-CRAN/non-Bioconductor packages
    - [ ] Packages removed (including archived packages)
- [ ] Fully update
      [`Tracking.md`](https://github.com/cran-task-views/Tracking/blob/main/Tracking.md)
      with new and removed packages.
- [ ] Complete and close all open issues.
- [ ] Merge `dev` back into `main` and delete the `dev` branch.

> # Tracking CTV : Checked version 2023-05-20
> 
> We had X submissions this round. The Tracking CTV now lists Y tracking
> packages, including Z core packages: [`pkg`](CRAN URL), …
> 
> ## New packages
> 
> K submitted packages were added successfully to the list this round:
> 
>   * [`pkg`](package URL): Description ([documentation](doc URL))
> 
> ## Declined submissions
> 
> J submitted packages were deemed to not fit the current definition of a
> tracking package:
> 
>   * [`pkg`](package URL): Description
> 
> You can check the links to the submission threads to find explanations for
> each package.
> 
> ## Packages removed
> 
> M packages have been removed from the list:
> 
>   * [`pkg`](GitHub issue URL): quick explanation.
> 
> You can check the links to the removal threads to find explanations and logs
> for each package.
