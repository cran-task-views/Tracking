## -------------------------------------------------------- ##
##                                                          ##
## /!\ Make sure to start with a fully updated system with: ##
##                                                          ##
##   update.packages()                                      ##
##                                                          ##
## -------------------------------------------------------- ##

## Load functions
source("functions/ctv_check_packages.R")

## Install necessary utility packages for this script (devtools, remotes,
## desc, dplyr, coin)
pkg_utilities <- c("renv", "tools", "gh", "remotes", "devtools", "desc", "coin", "dplyr")
install.packages(pkg_utilities[!(pkg_utilities %in% installed.packages()[,"Package"])])

## To initialize renv the first time you use it, run the following line (it runs
## automatically after that):
## renv::init()
## To record a change in the packages used in this script, run:
## renv::snapshot()
## To update said packages, use:
## renv::update()


## Previous state
pkg_check_prev <- read.csv("checks/Checked_packages.csv")
## Date of last run
readLines("checks/LAST_RUN")
## Packages that did check then, by alphabetical order
sort(pkg_check_prev$package_name[pkg_check_prev$cran_check])

## Import packages table
pkg_tbl <- read.csv("Tracking_tbl.csv")
## Packages to check now, by alphabetical order:
sort(pkg_tbl$package_name)


## Check all packages (loooong process):
pkg_check <- ctv_check_packages(pkg_tbl)
## pkg_check <- ctv_check_packages(pkg_tbl, c("adehabitatLT", "adehabitatHR", "drtracker", clean = FALSE))


## Some stats and core packages:
ctv_stats(pkg_check)
subset(pkg_check, core, select = c("package_name", "source"))

## CTV NEWS (differences from previous release):
ctv_news(pkg_check, pkg_check_prev)


## Save previous state, current state, and last run
write.csv(pkg_check_prev, "checks/Checked_packages_previous.csv", row.names = FALSE)
write.csv(pkg_check, "checks/Checked_packages.csv", row.names = FALSE)
writeLines(paste0(Sys.Date()), "checks/LAST_RUN")


## To test the CTV:
ctv::read.ctv("Tracking.md", cran = TRUE)
ctv::check_ctv_packages("Tracking.md")
ctv::ctv2html("Tracking.md")
browseURL("Tracking.html")
