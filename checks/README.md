---
title: "CRAN Checks"
date: "2021-09-28"
output: html_document
---

*This README describes the protocols for checking packages to be included on the
Tracking CRAN Task View (CTV). It's written for the Tracking CTV Maintainers as
well as developers who would like to understand our checking process.*

In order to be added to the Tracking CTV packages must pass `R CMD check`. This
process is required by default for packages on CRAN, but may not be required for
other repositories (like GitHub). Therefore we check every potential package for
its ability to pass `R CMD check`. As each repository has its own standards for
package storage and format, and in order to automate this process, we treat each
repository slightly different in how we run a check.

_**Please note: At the date of writing, all checks are being run on Ubuntu 21.04
using RStudio or Emacs**_


## Folder contents

  * `check_logs/`: All check logs from the last run.
  * `Changes.csv`: A summary of changes (new packages and modifications) from
    the last run.
  * `CheckPackages.R`: R code used to run checks on packages.
  * `Checked_packages.csv`: Output table from `CheckPackages.R`.
  * `LAST_RUN`: Gives the date of the last run of `CheckPackages.R`.
  * `README.md`: This document.
  * `Tracking_tbl.csv`: Table for candidate packages and their info.


## Table requirements and column explanations

All packages to be checked regularly are in the `Tracking_tbl.csv` table
(hereafter refered to as the "Packages Table". This table is a continuous list
of packages to be considered and info for each package. This table is editable
by the Tracking CTV Maintainers and has different pieces of information required
depending on the source of the package. These packages are run using
`CheckPackages.R` and the output of the checks is in `Checked_packages.csv`
(hereafter refered to as the "Checked Packages Table"). This table soley exist
as an output for updating the Tracking CTV and should not be edited as it gets
overwritten during every run.

Because packages on version-controlled repositories like GitHub can change
quickly and CRAN packages occasionally become archived if maintainers are
unresponsive, we run checks on **ALL** packages everytime. This means packages
may occasionally be taken off the list during one period and then placed back on
the list later if the new version passes checks again.

The following is the required information for filling out the *Packages Table*
and is only intended for the Tracking CTV Maintainers:

  * **package_name**: The correctly cased official package name as you would
    find on in the "Package:" section of the `DESCRIPTION` page.
  * **source**: The repository where the package is actively maintained and
    updated. We default to CRAN if available. The current options are : `cran`,
    `github`, `bioc` (bioconductor), `rforge`, and `other`. The use of `other`
    is a catch all with general requirements.
  * **download_link** (if `source == "other"`): The URL for the most up to date
    `tar.gz`. Please only use if the package does not exist on the 4 other
    repositories. (note that the download links normally are refered to be the
    packages version name; because of this the link will need to be periodically
    checked to make sure its referencing the current version of the package)
  * **owner** (if `source == "github"`): The owner (GitHub username) of the
    repository.
  * **repository** (if `source == "github"`): The repository name on GitHub.
  * **sub** (if `source == "github"`; optional): The sub folder name of the
    package. Some developers will insert their package into a subfolder of the
    repository with the same name as the repository (ex `migrateR` package is at
    GitHub address `dbspitz/migrateR/migrateR`). Or the repository is not just
    for the package but instead the package exists within a sub folder of the
    repository. (ex. packages `trackit` and `ukfsst` are in separate sub folders
    at GitHub address `positioning/kalmanfilter`). We do not currently have any
    protocols in place for where packages exist on non-master branches. If this
    is the case, please provide a detailed response for why it is not on master
    and we'll consider its addition.
  * **date_added_to_list**: The `yyyy-mm-dd` date of when the entry was added to
    the table.
  * **skip** (T/F/NA): Whether to skip checks on the package. This is for
    packages which are still being debated whether they fill the requirements as
    a tracking package, and may be added to later. Checks are skipped and rows
    are filled with NA in the *Checked Packages Table*.
  * **comments**: Any comments on the package, mainly related to why its being
    skipped or being reconsidered.
  * All remaining columns describe which category the package belongs to (see
    the description ). 


## Describing the checks required for each repository type. 

For each package we wanted to make sure that the CRAN checks were performed in
the same way regardless of the source. The CRAN checks we run require a tarball
despite not all repositories requiring a built tarball of the package. Some of
the required checks include details about how the tarball is built, so if one
does not exist we must create it. From there we use various functions from the
`devtools` package to help run checks.

The general flow of checks is as follows:

1. Download package from source.
2. Make tarball if does not exist.
3. Unpack tarball.
4. Install dependencies including suggests using `devtools::install_deps()`.
5. Build package and vignettes using `devtools::build(vignettes = TRUE)`.
6. Run CRAN checks on package using `devtools::check_built()`.

The workflow is necessary in this order because for CRAN checks the package must
be buildable and in the correct form, vignettes must be able to be built
otherwise `check_built` fails, and vignettes often fail if the suggests are
incorrect or can not be installed.

While the process is relatively straightforward, each source has slightly
different methods for checks. Below are specific details for checking packages
from each source.


### CRAN

As CRAN checks are required to pass to be allowed on CRAN, we do not run checks on CRAN packages. We do check if the package is still active. To do this we cross reference the package name with the `tools::cran_package_DB()` table.


### GitHub

We wanted to make a concentrated effort to allow GitHub packages on the Tracking
CTV. However, GitHub is generally not the endpoint for packages at the end of
their project life cycle. Instead GitHub is used as a collaborative tool for the
ongoing creating and sharing of software as it develops. This means that build
quality and reliability of packages on GitHub can not be gauranteed at any
particular moment.

We understand that attempting to run CRAN checks on packages in which the
developer never expected it to pass stringent CRAN checks nor be included on
this list is a bit unfair.  However, we hope that their continual existance on
the *Packages Table* and growing list of packages on the Tracking CTV will push
developers to take their packages to the final development stages. These steps
towards quality can only benefit the community.

If you're a developer/maintainer for one of the packages that has failed CRAN
tests and are interested in making the necessary changes to be included on the
package, you can head down to the [Check logs and
troubleshooting](#check-log-and-troubleshooting) section.


#### GitHub specific steps
 
GitHub packages generally exist in an unzipped layout with usually no official
tarball. Because it is never requires to run `devtools::build()` to install a
GitHub package, most GitHub packages may unknowingly not have folders and files
in correct places.

For GitHub packages, we first download the GitHub repository as a .zip and unzip
files. GitHub packages will often have a couple of files and folders which would
not strictly be in a standard tarball and must be deleted. This include deleting
the `inst/doc` folder as well as the `vignette.rds` file if created. These files
will lead to checks failing. We do not believe these files/folders should lead
to a failed CRAN check status, as they would be deleted if a proper tarball was
created, and the majority of users install GitHub packages via
`remotes::install_github()` or `remotes::install_local()`.

After the tarball is created the package is run through steps 3–6 as normal.


### Bioconductor 

Packages included in the [Bioconductor suite](https://www.bioconductor.org/) are
generally of high build quality, however, they require the use of the
Bioconductor package manager to install from the repository. This is bulky and
unnecessary for the purpose of running CRAN checks. Luckily, every Bioconductor
package posts a link to the tarball on the packages webpage. These packages may
change versions rapidly, making it unreliable to keep copying the new tarball
link. To get around this we trawl the Bioconductor web page for the specific
package and grab the tarball link, then download it automatically. After this
the tarball is run through steps 3–6 same as normal. In the future, we expect to
find a more elegant solution around this.


### R-Forge

As R-Forge has a dedicated repository, we use `download.packages(., repos =
"http://download.R-Forge.R-project.org")` function. We then run through steps 3–6 as
normal.


### Other

The other category is a catch-all for packages that either do not exist in a
repository or protocols have not yet been written to handle the specific
repository. All we require is a download link to the built tarball. _**Note that
the download links normally are refered to by the {package name} + {version};
because of this the link will need to be periodically checked to make sure it's
referencing the current version of the package.**_

After downloading the tarball we run through steps 3–6 as normal.


## Check logs and troubleshooting

We want to be as inclusive as possible in what packages are showcased on the
Tracking CTV. We understand that in many cases developers who have not submitted
to CRAN were not creating their packages specifically to pass these checks. Nor
did most packages on the table get submitted by the developers
themselves. Because of this we have attempted to be transparent about what tests
need to be worked on to allow inclusion on the Tracking CTV list.


### Checked Packages Table

The first step in troubleshooting what went wrong with a package is to check the
*Checked Packages Table*. This table has columns relative to the type of error
that lead to the failed check:

  * **cran_check**: `TRUE`/`FALSE` describes whether the package passed CRAN
    tests (CRAN packages are set `TRUE` by default). This is the final
    determining column if a package is included on the Tracking CTV. All `TRUE`
    packages are sent to the CTV, and all `FALSES` are saved and run at the next
    date.
  * **warnings**: `TRUE`/`FALSE` describes whether the package received warnings
    on the CRAN tests. A build must pass with 0 warnings.
  * **error**: `TRUE`/`FALSE` describes whether the package received errors on
    the CRAN tests. A build must pass with 0 errors. If a vignette did not build
    this is set automatically to TRUE as checks can not pass unless the vignette
    can also be built.
  * **vignette_error**: `TRUE`/`FALSE` describes whether there was an error
    while building the vignette. As this comes first in the process CRAN checks
    are not run on the package if there is a vignette error. In this scenario no
    `check.log` will be created either. If you would like to see these errors
    the best way is to run `devtools::build_vignette()` and check the error
    there.

We understand that this may be problematic as `devtools::install_github()` by
default does not build vignettes. It can also be common practice to place a
knitted pdf in the vignettes folder, however, a buildable vignette is still
required for a CRAN check and any PDFs are deleted in the vignette folder during
building. You may want to put these files elsewhere, as in `extdoc`.


### Check logs

As long as the package has built correctly (step 5), then a check log was
created for the package. All check logs from the previous run are stored in the
`checks/check_logs` folder. These are standard outputs written during
`check_package()` and we do not alter these in any way.

Should you have any question on these logs and what errors may mean you can
generally refer to the much maligned [Writing R Extensions
Manual](https://cran.r-project.org/doc/manuals/r-release/R-exts.html) as well as
[Hadley Wickham's book on R packages](https://r-pkgs.org/).

If something just isn't adding up, and you believe the code is incorrectly
kicking out your package (entirely possible), please let us know in an issue
with some extra details so we can look into it.
