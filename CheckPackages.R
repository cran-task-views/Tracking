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
pkg_utilities <- c("renv", "devtools", "remotes", "desc", "dplyr", "coin")
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
readLines("LAST_RUN")
## Packages that did check then, by alphabetical order
sort(pkg_check_prev$package_name[pkg_check_prev$cran_check])

## Import packages table, and create columns if they do not exist
pkg_tbl <- read.csv("Tracking_tbl.csv")
pkg_tbl$source <- tolower(pkg_tbl$source)
pkg_tbl$skip <- ifelse(is.na(pkg_tbl$skip), FALSE, pkg_tbl$skip)
pkg_tbl$archived <- NA
pkg_tbl$recent_commit <- NA
pkg_tbl$dep_errors <- NA_character_
pkg_tbl$cran_check <- NA
pkg_tbl$warnings <- NA
pkg_tbl$errors <- NA
pkg_tbl$vignette_error <- NA
pkg_tbl$imports <- NA_character_
pkg_tbl$suggests <- NA_character_
pkg_tbl$recent_publish_track <- NA
pkg_tbl$version <- NA
## Packages to check now, by alphabetical order:
sort(pkg_tbl$package_name)


## Check all packages (loooong process):
pkg_check <- check_packages(pkg_tbl)
## pkg_check <- check_packages(pkg_tbl, c("adehabitatLT", "adehabitatHR", "drtracker"))


## Check output (check that only packages with 'skip = TRUE' have NA for
## 'cran_check', must be TRUE):
sum(!is.na(pkg_check$cran_check)) == nrow(pkg_check[!pkg_check$skip, ])


## Some stats:
ctv_stats(pkg_check)
subset(pkg_check, core)

## CTV NEWS (differences from previous release):
ctv_news(pkg_check, pkg_check_prev)



## Save previous state, current state, and last run
write.csv(pkg_check_prev, "checks/Checked_packages_previous.csv", row.names = FALSE)
write.csv(pkg_check, "checks/Checked_packages.csv", row.names = FALSE)
writeLines(paste0(Sys.Date()), "checks/LAST_RUN")
