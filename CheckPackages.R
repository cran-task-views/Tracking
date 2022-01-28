## ------------------------------------------------------ ##
##                                                        ##
## /!\ Make sure to start with a fully updated system /!\ ##
##                                                        ##
## ------------------------------------------------------ ##

## Install packrat if not available
if (!require("packrat")) install.packages("packrat")

## Set up private library (delete it first)
unlink("packrat", recursive = TRUE)
packrat::init(infer.dependencies = FALSE)

## Install necessary utility packages for this script (devtools, remotes, desc,
## dplyr, coin)
install.packages(c("devtools", "remotes", "desc", "dplyr", "coin"))

## Directories to download and run checks in
download_local <- "checks/downloads"
unlink(download_local, recursive = TRUE)
dir.create(download_local)
check_logs <- "checks/check_logs"
unlink(check_logs, recursive = TRUE)
dir.create(check_logs)


## List of CRAN packages
pkg_db <- tools::CRAN_package_db()

## Previous state
track_old <- read.csv("checks/Checked_packages.csv")
## Date of last run
readLines("LAST_RUN")
## Packages that did check then, by alphabetical order
sort(track_old$package_name[track_old$cran_check])

## Import packages list, and create columns if not exist
track <- read.csv("checks/Tracking_tbl.csv")
track$source <- tolower(track$source)
track$skip <- ifelse(is.na(track$skip), FALSE, track$skip)
track$recent_commit <- NA
track$cran_check <- NA
track$warnings <- NA
track$errors <- NA
track$vignette_error <- NA
track$imports <- NA_character_
track$suggests <- NA_character_
track$recent_publish_track <- NA
track$version <- NA
## set up an error list to check later if installs failed because of
## dependencies the computer doesn't have
error_list <- list()


######################################################################
## START LOOP
## Loop over all packages (looooong process)
for (i in 1:nrow(track)) {
    if (isTRUE(track$skip[i])) { next }

    ## Check that source is properly filled out
    if (!track$source[i] %in% c("cran", "github", "bioc", "rforge", "other")) {
        message(paste0(
            track$package_name[i],
            " source is not valid, skipping..."
        ))
        next
    }

    ## Check if package has been published to CRAN
    if (track$source[i] != "cran") {
        track_pkg <- pkg_db[pkg_db$Package == track$package_name[i], ]
        if (nrow(track_pkg) == 1) {
            track$source[i] <- "cran"
            message(paste0(track$package_name[i], " is now on CRAN"))
        }
    }

    ## Specific CRAN
    if (track$source[i] == "cran") {
        track_pkg <- pkg_db[pkg_db$Package == track$package_name[i], ]
        if (nrow(track_pkg) == 0) {
            warning(paste0(track$package_name[i], " is not on CRAN"))
            track$source[i] <- "cran-archived"
            track$errors[i] <- TRUE
            track$cran_check[i] <- FALSE
            next
        }
        string <- paste(na.omit(c(track_pkg$Depends, track_pkg$Imports,
            track_pkg$LinkingTo)), collapse = ", ")
        string <- gsub("\\s*\\(.*\\)|,$", "" , string)
        string <- gsub("^R$|^R,", "" , string)
        string <- trimws(gsub("\n" , " ", string), "both")
        track$imports[i] <- as.character(string)
        string <- ifelse(is.na(track_pkg$Suggests), "", track_pkg$Suggests)
        string <- gsub("\\(.*\\)|,$", "" , string)
        string <- trimws(gsub("\n" , " ", string), "both")
        track$suggests[i] <- as.character(string)
        ## Recent track
        track$recent_publish_track[i] <- track_pkg$Published
        track$cran_check[i] <- TRUE
        track$version[i] <- track_pkg$Version
        ## House cleaning
        suppressWarnings(rm(string, track_pkg))
        next
    }

    ## Specific Bioconductor: we trawl the website for the correct link, as
    ## versions may change rapidly
    if (track$source[i] == "bioc") {
        ## Bioconductor actually uses a "https://bioconductor.org/packages/name"
        ## short URL scheme
        track_url <- paste0("https://bioconductor.org/packages/", track$package_name[i])
        track_page <- readLines(as.character(track_url))
        grep("<h3 id=\"archives\">Package Archives</h3>", track_page, value = TRUE)
        phrase <- track_page[grep("Source Package", track_page) + 1]
        phrase
        ## '\" href=\"../src/contrib/SwimR_1.26.0.tar.gz\"'
        match <- regexec("(?:href=\\\"\\.\\./)(.*)(?:\\\">)", phrase)
        if (regmatches(phrase, match)[[1]][2] == "") {
            message("No source available. Package probably removed from Bioconductor.")
            track$source[i] <- "bioc-deprecated"
            track$errors[i] <- TRUE
            track$cran_check[i] <- FALSE
            next
        }
        ## Actual repository can be found in 'release/' (one fewer things to
        ## check)
        download_file <- paste0("https://bioconductor.org/packages/release/bioc/",
            regmatches(phrase, match)[[1]][2])
        working_folder <- paste0(download_local, "/", track$package_name[i])
        download_folder <- paste0(download_local, "/",
            track$package_name[i], ".tar.gz")
        ## download and unzip folder so we can install dependencies
        download.file(url = download_file, destfile = download_folder,
            method = "libcurl")
        untar(tarfile = download_folder, exdir = download_local)
    }

    ## Specific R-Forge (includes download + untar)
    if (track$source[i] == "rforge") {
        out <- download.packages(track$package_name[i],
            destdir = download_local, repos = "http://download.R-Forge.R-project.org")
        download_folder <- out[2]
        working_folder <- paste0(download_local, "/", track$package_name[i])
        untar(tarfile = download_folder, exdir = download_local)
    }

    ## Specific GitHub
    if (track$source[i] == "github") {
        branch <- track$sub[i]
        owner <- track$owner[i]
        repo <- track$repository[i]
        download_file <-
            paste0("https://github.com/",
                owner,
                "/",
                repo,
                "/archive/master.zip")
        if (branch == "") {
            working_folder <- paste0(download_local, "/", repo, "-master")
        } else {
            working_folder <- paste0(download_local, "/", repo,
                "-master/", branch)
        }
        download_folder <- paste0(download_local, "/",
            track$repository[i], ".zip")
        ## Download and unzip folder so we can install dependencies
        download.file(url = download_file, destfile = download_folder,
            method = "libcurl")
        unzip(zipfile = download_folder, exdir = download_local)
        ## For now we'll query the GitHub API for last commit, though this isn't
        ## being used currently
        commit_list <-
            gh::gh(
                "/repos/:owner/:repo/commits",
                owner = owner,
                repo = repo,
                state = "all",
                .limit = 1
            )
        commit <- (Sys.time() - as.POSIXct(strptime(commit_list[[1]]$commit$author$date,
            format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))) < 365
        track$recent_commit[i] <- commit
    }

    # Specific Other: we assume that we provide the download URL to the .tar.gz
    # file.
    if (track$source[i] == "other") {
        ## Check if package even has a repository
        if (nchar(as.character(track$download_link[i])) == 0) {
            message(paste0(
                track$package_name[i],
                " does not have a selected repository, skipping..."
            ))
            next
        }
        download_file <- as.character(track$download_link[i])
        working_folder <- paste0(download_local, "/", track$package_name[i])
        download_folder <- paste0(download_local, "/",
            track$package_name[i], ".tar.gz")
        ## Download and unzip folder so we can install dependencies
        download.file(url = download_file, destfile = download_folder,
            method = "libcurl")
        if (grepl("\\.zip", download_folder)) {
            if (unzip(zipfile = download_folder, list = TRUE)[1] ==
                paste0(track$package_name[i], "/")) {
                unzip(zipfile = download_folder, exdir = download_local)
            } else {
                unzip(zipfile = download_folder, exdir = working_folder)
            }
        }
        if (grepl("\\.tar\\.gz", download_folder)) {
            if (untar(tarfile = download_folder, list = TRUE)[1] ==
                paste0(track$package_name[i], "/")) {
                untar(tarfile = download_folder, exdir = download_local)
            } else {
                untar(tarfile = download_folder, exdir = working_folder)
            }
        }
    }

    ## Delete some folders that may exist that may interfere with building
    ## process. For now these are not strictly 'wrong' but bad form. In some
    ## cases the packages pass CRAN after these are installed.
    unlink(paste0(working_folder, "/inst/doc"), recursive = TRUE)
    unlink(paste0(working_folder, "/build/vignette.rds"), recursive = TRUE)

    ## CRAN checks and dependencies. We have to install suggestions as well, as
    ## one of the CRAN checks is that suggested packages are installable. Also
    ## sometimes these packages are used in the vignette
    here <- tryCatch(
        remotes::install_deps(
            pkgdir = working_folder,
            dependencies = TRUE,
            upgrade = "never"
        ),
        error = function(e) as.character(e)
    )
    ## These are errors that keep the remainder of steps from completing so we
    ## have to exit
    if (!is.null(here)) {
        error_list[[paste0(i)]] <- here
        next
    }
    ## We now build the file from scratch so we can guarantee all the correct
    ## folders are in the correct spot.
    there <- tryCatch(
        build_file <- devtools::build(working_folder),
        error = function(e) "vignette_error"
    )
    ## In the build stage vignette errors can halt building, and this implies a
    ## failure of CRAN check.
    if (there == "vignette_error") {
        checks <- FALSE
        warnings <- FALSE
        errors <- TRUE
        vignette <- TRUE
    }
    if (there != "vignette_error") {
        ## Actual CRAN check
        ll <- tryCatch(
            devtools::check_built(build_file),
            error = function(e) data.frame(errors = as.character(e))
        )
        ## Results of CRAN check
        checks <- (length(ll$errors)  + length(ll$warnings)) == 0
        warnings <- length(ll$warnings) > 0
        errors <- length(ll$errors) > 0
        vignette <- FALSE
    }
    track$cran_check[i] <- checks
    track$warnings[i] <- warnings
    track$errors[i] <- errors
    track$vignette_error[i] <- vignette

    ## Create dependency tree
    if (exists("build_file")) {
        desc_folder <- paste0(download_local, "/DESCRIPTION")
        untar(tarfile = build_file, file = paste0(track$package_name[i],
            "/DESCRIPTION"), exdir = desc_folder)
        track_desc <- desc::desc(file =  paste0(desc_folder, "/",
            track$package_name[i], "/DESCRIPTION"))
        track_dep <- track_desc$get_deps()
        track_dep <- track_dep[track_dep$package != "R", ]
        string <- paste(unique(track_dep$package[track_dep$type %in%
            c("Depends", "Imports", "LinkingTo")]), collapse = ", ")
        track$imports[i] <- as.character(string)
        string <- paste(track_dep$package[track_dep$type == "Suggests"],
            collapse = ", ")
        track$suggests[i] <- as.character(string)
        track$version[i] <- gsub("‘", "", track_desc$get_version())
    } else {
        tryCatch(
        {
            track_desc <- desc::desc(file =  paste0(working_folder, "/",
                "/DESCRIPTION"))
            track_dep <- track_desc$get_deps()
            track_dep <- track_dep[track_dep$package != "R", ]
            string <- paste(unique(track_dep$package[track_dep$type %in%
                c("Depends", "Imports", "LinkingTo")]), collapse = ", ")
            track$imports[i] <- as.character(string)
            string <- paste(track_dep$package[track_dep$type == "Suggests"],
                collapse = ", ")
            track$suggests[i] <- as.character(string)
            track$version[i] <- gsub("‘", "", track_desc$get_version())
        },
        error = function(e) "cannot retrieve DESCRIPTION"
        )
    }

    ## Look for check log
    temp_files <- list.files(paste0(tempdir(), "/", track$package_name[i], ".Rcheck"),
        "check.log", full.names = TRUE)
    file.copy(temp_files, paste0(check_logs, "/", track$package_name[i], "_check.log"),
        overwrite = TRUE)

    ## House cleaning
    suppressWarnings(rm(branch, build_file, checks, commit, commit_list,
        download_file, download_folder, errors, here, ll, match, out,
        owner, phrase, repo, string, temp_files, desc_folder, there,
        track_dep, track_desc, track_page, track_pkg, track_url, vignette,
        warnings, working_folder))

}
## END LOOP
######################################################################



## Final file for export to `Checked_packages.csv`
library("dplyr")
sum(!is.na(track$cran_check)) == nrow(track[!track$skip, ]) # Must be TRUE
## Number of packages in the CTV
sum(track$cran_check, na.rm = TRUE)
subset(track, is.na(cran_check))
track <- track %>%
    arrange(desc(track$cran_check), track$package_name) %>%
    select(package_name, version, source, date_added_to_list, skip,
        recent_publish_track, recent_commit, cran_check, warnings,
        errors, vignette_error, imports, suggests, comments)



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

## Counting how much is package is needed or suggested
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


## Save previous state, current state, and last run
write.csv(track_old, "checks/Checked_packages_previous.csv", row.names = FALSE)
write.csv(track, "checks/Checked_packages.csv", row.names = FALSE)
writeLines(paste("LAST_RUN:", Sys.Date()), "LAST_RUN")


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
