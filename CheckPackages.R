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
track_old <- read.csv("checks/Checked_packages.csv")
## Date of last run
readLines("LAST_RUN")
## Packages that did check then, by alphabetical order
sort(track_old$package_name[track_old$cran_check])

## Import packages list, and create columns if not exist
track <- read.csv("Tracking_tbl.csv")
track$source <- tolower(track$source)
track$skip <- ifelse(is.na(track$skip), FALSE, track$skip)
track$archived <- NA
track$recent_commit <- NA
track$dep_errors <- NA_character_
track$cran_check <- NA
track$warnings <- NA
track$errors <- NA
track$vignette_error <- NA
track$imports <- NA_character_
track$suggests <- NA_character_
track$recent_publish_track <- NA
track$version <- NA
## Packages to check now, by alphabetical order
sort(track$package_name)


## Check all packages
track <- check_packages(track)

track <- check_packages(track, c("adehabitatLT", "adehabitatHR", "drtracker"))


## Check output
sum(!is.na(track$cran_check)) == nrow(track[!track$skip, ]) # Must be TRUE
## Number of packages in the CTV
sum(track$cran_check, na.rm = TRUE)
subset(track, is.na(cran_check))



ctv_network(track)
debug(ctv_network)


############################################################################

## Imports/suggests network and core packages

## We work on packages that check
pkg_check <- subset(track, cran_check)

## Remove spaces, separate imported packages by commas
pkg_import <- strsplit(gsub("\\s*", "", pkg_check$imports), split = ",")
## Remove duplicates
pkg_import <- lapply(pkg_import, FUN = unique)
## Number of dependencies
pkg_import_length <- sapply(pkg_import, FUN = length)
## Create empty data.frame with that number of elements
pkg_import_gather <- data.frame(
    package = rep.int(pkg_check$package_name, times = pkg_import_length),
    network = unlist(pkg_import), role = rep("import", sum(pkg_import_length)))

## Now same thing for suggest
pkg_suggest <- strsplit(gsub("\\s*", "", pkg_check$suggests), split = ",")
pkg_suggest <- lapply(pkg_suggest, FUN = unique)
pkg_suggest_length <- sapply(pkg_suggest, FUN = length)
pkg_suggest_gather <- data.frame(
    package = rep.int(pkg_check$package_name, times = pkg_suggest_length),
    network = unlist(pkg_suggest), role = rep("suggest", sum(pkg_suggest_length)))

## One data frame to rule them all
pkg_net <- rbind.data.frame(pkg_import_gather, pkg_suggest_gather)
# Filtering out non movement packages
pkg_net <- subset(pkg_net, network %in% pkg_check$package_name)

## Counting how much a package is needed or suggested
pkg_net_tb <- data.frame(table(pkg_net$network))
names(pkg_net_tb) <- c("package_name", "mention")
pkg_net_tb <- pkg_net_tb[order(pkg_net_tb$mention, decreasing = TRUE), ]
pkg_net_tb$t <- 1:nrow(pkg_net_tb)

## Actual test
library("coin")
(cointest <- maxstat_test(mention ~ t, dist = "approx", data = pkg_net_tb))

## Add 'core' variable
pkg_net_tb$core <- (pkg_net_tb$mention > cointest@estimates$estimate$cutpoint)
pkg_net_tb

## Merge to global table
track <- left_join(track, pkg_net_tb[, -3], by = "package_name")
track$mention <- ifelse(is.na(track$mention), 0, track$mention)
track$core <- ifelse(is.na(track$core), FALSE, track$core)

#####################################################################



## Save previous state, current state, and last run
write.csv(track_old, "checks/Checked_packages_previous.csv", row.names = FALSE)
write.csv(track, "checks/Checked_packages.csv", row.names = FALSE)
writeLines(paste0(Sys.Date()), "checks/LAST_RUN")


## Differences with previous state
## 1) new packages
track %>%
    filter(!skip) %>%
    filter(!(package_name %in% track_old$package_name)) %>%
    mutate(news = "new") %>%
    select(news, package_name, version, source, date_added_to_list,
        cran_check, warnings, errors, vignette_error, comments) -> track_new
## 2) CRAN check difference
left_join(track, track_old, by = "package_name", suffix = c("", "_old")) %>%
    ## filter(!skip) %>%
    filter(cran_check != cran_check_old) %>%
    mutate(news = "mod") %>%
    select(news, package_name, version, source, date_added_to_list,
        cran_check, warnings, errors, vignette_error, comments) -> track_mod
## 3) New skipped packages
track %>%
    filter(skip) %>%
    filter(!(package_name %in% track_old$package_name)) %>%
    mutate(news = "skipped") %>%
    select(news, package_name, version, source, date_added_to_list,
        cran_check, warnings, errors, vignette_error, comments) -> track_skipped
## 4) Together and export
(changes <- bind_rows(track_new, track_skipped, track_mod))
write.csv(changes, file = "checks/CHANGES.csv", row.names = FALSE)

anti_join(track, track_old, by = join_by(package_name, skip, cran_check, warnings, errors, vignette_error)) |>
    select(package_name, version, source, date_added_to_list,
        cran_check, warnings, errors, vignette_error, comments)
