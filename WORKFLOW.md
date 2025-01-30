# Workflow for the Tracking CTV


## Rolling release

* Rolling release essentially accounts for quick-and-easy fixes in between
  heavier checked releases : Only CRAN and Bioconductor packages are added (as
  they are already checked), or removed (when archived).
* Rolling releases live in the `main` branch, and are automatically published
  from the `Tracking.md` file.
* The version is the ISO date of the automatic publication.
* **The trigger event of a new rolling release is typically a new package
  submission or a package being archived.**

### New package submission

To-do list:

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
- [ ] Remove the `add-pkg`
- [ ] Close the GitHub issue.

## Packages that have been archived on CRAN

**Open issues for packages that have been archived on CRAN can be found
[here](https://github.com/cran-task-views/Tracking/issues?q=is%3Aissue+label%3Acran-archived+is%3Aopen).**

When a package gets archived on CRAN, it is flagged as "Archived" in the CTVs,
and does not get installed automatically with the task view anymore.  When the
package has been archived on CRAN for 60 days, this automatically opens an issue
here with a message indicating which package is problematic.

The aim here is twofold: 1) remind the developers that their package is somehow
broken, and will thus be removed also from the Tracking CTV if there is no fix;
2) document the situation here.

To-do list:

- [ ] Contact the package maintainer, from the email address documented in the
      package, with a simple message explaining the situation (see below), and a
      link to the issue here. If we get a bounce-back email (ie email not
      working anymore), we run a quick web search to find another email address
      for the maintainer.
- [ ] If there is a public repository (e.g. GitHub), also open an issue there
      with the same message.
- [ ] Remove the package and document the removal using the dedicated [issue
      template](https://github.com/cran-task-views/Tracking/issues/new?assignees=&labels=removed&template=package-removed.yml&title=Name+of+the+package%3A+description+of+the+package+%28change+this+title%29),
      and add in the additional information the date at which the maintainer was
      contacted, the open issue on the package repo (if it exists) and the link
      to the initial thread here. 
- [ ] If the package gets reinstated in CRAN, we can always add it back and add
      it in a rolling release.

Template for the message:

> **Subject: Package <`pkg`> archived on CRAN and will be removed from the Tracking CTV**
> 
> Dear <`name`>,
> 
> The package <`pkg`> has been archived on CRAN for more than 60 days, and you are listed as the maintainer. This message is to let you know that your package is currently listed in the Tracking CRAN Task View (https://cran.r-project.org/view=Tracking), but is flagged as "Archived", which means it will not get installed automatically with the CTV.
> 
> We are now also removing <`pkg`> from the Tracking CTV. If the package gets reinstated on CRAN, please let us know as we will also add it back to the Tracking CTV. Details of the situation can be found here: https://github.com/cran-task-views/Tracking/issues/<`XX`>
> 
> <`If possible: add details about the issue from CRAN, and how to fix it if it seems easy enough.`>
> 
> In the meanwhile, please feel free to respond to this message or, better, to comment on the issue above.
> 
> Best,
> For the Tracking CTV maintainers,
> <`name of CTV maintainer`>


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

- [ ] Open a new issue to track the process (see [this
      example](https://github.com/cran-task-views/Tracking/issues/76)).
- [ ] Publish a rolling release (see above).
- [ ] Branch out from `main` into `dev`.
- [ ] Check all [open issues for package
      submissions](https://github.com/cran-task-views/Tracking/issues?q=is%3Aissue+is%3Aopen+label%3Aadd-pkg),
      and make sure submitted packages are sorted out and included in
      [`Tracking_tbl.csv`](https://github.com/cran-task-views/Tracking/blob/main/checks/Tracking_tbl.csv)
- [ ] Run the [full
      tests](https://github.com/cran-task-views/Tracking/blob/main/CheckPackages.R)
- [ ] Complete the
      [`NEWS.md`](https://github.com/cran-task-views/Tracking/blob/main/NEWS.md)
      file fully (see template below)
- [ ] Complete and close all open issues.
- [ ] Fully update
      [`Tracking.md`](https://github.com/cran-task-views/Tracking/blob/main/Tracking.md)
      with new and removed packages.
- [ ] Merge `dev` back into `main` and delete the `dev` branch.


## NEWS.md template

For rolling releases, drop the summary paragraph on top, and only fill in the
relevant sections (packages added from CRAN/BioConductor, packages declined,
packages removed because they were archived).

For checked releases, use the help of `ctv_stats()` and `ctv_news()` functions. 

> # Tracking CTV 2025-02-01 // or Tracking CTV rolling release
> 
> X packages were submitted this round. The Tracking CTV now lists Y tracking packages,
> including Z core packages: [`pkg`](CRAN URL), …
> 
> ## Packages added to the tracking CTV
> 
> J newly submitted packages:
> 
> - [`pkg`](package URL): Description ([documentation](doc URL))
> 
> K packages previously submitted and now passing CRAN checks: 
> 
> - [`pkg`](package URL): Description ([documentation](doc URL))
> 
> ## Packages submitted but not added to the tracking CTV
> 
> L packages that did not fit the definition of a tracking package for the CTV:
> 
> - [`pkg`](CTV issue): Short explanation why
> 
> M packages that did not pass CRAN checks:
> 
> - [`pkg`](CTV issue): Short explanation why
>
> Check the links to the submission threads to find details for each package.
> 
> ## Packages removed from the tracking CTV
> 
> N packages removed because they were archived or did not pass CRAN checks
> anymore:
> 
> - [`pkg`](CTV issue): Short explanation why
> 
> Check the links to the submission threads to find details for each package.
