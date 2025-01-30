ctv_check_packages <- function(pkg_table, pkg_name) {
    if (!requireNamespace("tools", quietly = TRUE)) {
        stop("Package 'tools' must be installed to use this function.",
            call. = FALSE)
    }
    ## Check input
    if (!inherits(pkg_table, "data.frame"))
        stop("'pkg_table' should be a data.frame.")
    if (!all(c(c("package_name", "source", "download_link", "owner",
        "repository", "branch", "sub", "date_added_to_list", "force_check",
        "skip", "comments")) %in% names(pkg_table)))
        stop("Required columns: 'package_name', 'source', 'download_link', 'owner', 'repository', 'branch', 'sub', 'date_added_to_list', 'force_check', 'skip', and 'comments'.")

    ## If 'pkg_name' supplied, we subset the whole table
    if(!missing(pkg_name)) {
        if (!inherits(pkg_name, "character"))
            stop("'pkg_name' should be a character vector.")
        pkg_table <- subset(pkg_table, package_name %in% pkg_name)
    }

    ## Create columns that do not exist
    pkg_table$source <- tolower(pkg_table$source)
    pkg_table$skip <- ifelse(is.na(pkg_table$skip), FALSE, pkg_table$skip)
    pkg_table$archived <- NA
    pkg_table$recent_commit <- NA
    pkg_table$dep_errors <- NA_character_
    pkg_table$cran_check <- NA
    pkg_table$warnings <- NA
    pkg_table$errors <- NA
    pkg_table$vignette_error <- NA
    pkg_table$imports <- NA_character_
    pkg_table$suggests <- NA_character_
    pkg_table$recent_publish_track <- NA
    pkg_table$version <- NA

    ## Prepare list of current CRAN packages
    cran_pkg_db <- tools::CRAN_package_db()

    ## Directories to download and run checks in
    download_local <- "checks/downloads"
    unlink(download_local, recursive = TRUE)
    dir.create(download_local)
    check_logs <- "checks/check_logs"
    unlink(check_logs, recursive = TRUE)
    dir.create(check_logs)

    ## Run the check function on each package and return the updated table
    pkg_table <- do.call("rbind", lapply(1:nrow(pkg_table), \(row) {
        ## Announcement
        message(paste0("\n################################################\n\nNow processing package '",
            pkg_table$package_name[row], "' (", row, "/", nrow(pkg_table), ").\n"))
        ## Work on individual package
        ctv_check_package(pkg_table[row, ], cran_pkg_db = cran_pkg_db,
            download_local = download_local, check_logs =  check_logs)
    }))
    class(pkg_table) <- c("ctv_pkg_check", class(pkg_tbl))

    ## Check output (check that there is no NA in '$cran_check' for non-skipped
    ## packages):
    if (sum(is.na(pkg_table$cran_check[!pkg_table$skip])) != 0) {
        warning("\n\n/!\ NAs exist in `$cran_check` for tested packages /!\\n\n")
    }

    ## Check and test the network
    message("\n################################################\n\nChecking and testing the package network.\n")
    pkg_table <- ctv_network(pkg_table)
    if (!is.null(attr(pkg_table, "ctv_network_test"))) {
        print(attr(pkg_table, "ctv_network_test"))
    }

    return(pkg_table)
}

ctv_check_package <- function(pkg_info, cran_pkg_db, download_local, check_logs) {
    if (!requireNamespace("gh", quietly = TRUE)) {
        stop("Package 'gh' must be installed to use this function.",
            call. = FALSE)
    }
    if (!requireNamespace("remotes", quietly = TRUE)) {
        stop("Package 'remotes' must be installed to use this function.",
            call. = FALSE)
    }
    if (!requireNamespace("devtools", quietly = TRUE)) {
        stop("Package 'devtools' must be installed to use this function.",
            call. = FALSE)
    }
    if (!requireNamespace("desc", quietly = TRUE)) {
        stop("Package 'desc' must be installed to use this function.",
            call. = FALSE)
    }

    ## If 'skip' is 'T'
    if (isTRUE(pkg_info$skip)) {
        message("  * Instructed to do so, skipping…")
        return(pkg_info)
    }

    ## Check that source is properly filled out
    if (!pkg_info$source %in% c("cran", "github", "bioc", "rforge", "other")) {
        message("  * Source is not valid, skipping…")
        return(pkg_info)
    }

    ## Check if package has been published on CRAN (and edit it if it's the case)
    if (pkg_info$source != "cran") {
        if (nrow(cran_pkg_db[cran_pkg_db$Package == pkg_info$package_name, ]) == 1) {
            if (pkg_info$source == "force_check") {
                message("  * A package with the same name is on CRAN. Checking source anyway.")
            } else {
                pkg_info$source <- "cran"
                message("  * Is on CRAN.")
            }
        }
    }

    ## Specific CRAN
    if (pkg_info$source == "cran") {
        cran_pkg <- cran_pkg_db[cran_pkg_db$Package == pkg_info$package_name, ]
        if (nrow(cran_pkg) == 0) {
            message("  * Is now archived on CRAN.")
            pkg_info$cran_check <- FALSE
            pkg_info$errors <- TRUE
            pkg_info$archived <- TRUE
            return(pkg_info)
        } else message("  * Is on CRAN.")
        ## Extract dependencies
        dep_string <- paste(na.omit(c(cran_pkg$Depends, cran_pkg$Imports,
            cran_pkg$LinkingTo)), collapse = ", ")
        dep_string <- gsub("\\s*\\(.*\\)|,$", "" , dep_string)
        dep_string <- gsub("^R$|^R,", "" , dep_string)
        dep_string <- trimws(gsub("\n" , " ", dep_string), "both")
        pkg_info$imports <- as.character(dep_string)
        dep_string <- ifelse(is.na(cran_pkg$Suggests), "", cran_pkg$Suggests)
        dep_string <- gsub("\\(.*\\)|,$", "" , dep_string)
        dep_string <- trimws(gsub("\n" , " ", dep_string), "both")
        pkg_info$suggests <- as.character(dep_string)
        ## Recent track
        pkg_info$recent_publish_track <- cran_pkg$Published
        pkg_info$cran_check <- TRUE
        pkg_info$version <- cran_pkg$Version
        return(pkg_info)
    }

    ## Specific Bioconductor: we trawl the website for the correct link, as
    ## versions may change rapidly
    if (pkg_info$source == "bioc") {
        ## Bioconductor actually uses a "https://bioconductor.org/packages/name"
        ## short URL scheme
        pkg_url <- paste0("https://bioconductor.org/packages/", pkg_info$package_name)
        pkg_page <- readLines(as.character(pkg_url))
        grep("<h3 id=\"archives\">Package Archives</h3>", pkg_page, value = TRUE)
        phrase <- pkg_page[grep("Source Package", pkg_page) + 1]
        phrase
        ## '\" href=\"../src/contrib/SwimR_1.26.0.tar.gz\"'
        match <- regexec("(?:href=\\\"\\.\\./)(.*)(?:\\\">)", phrase)
        ## If the link goes to the removed packages page, adding some lines for it
        if (length(phrase) == 0) {
            message("  * No source available; probably archived on Bioconductor.")
            pkg_info$cran_check <- FALSE
            pkg_info$errors <- TRUE
            pkg_info$archived <- TRUE
            return(pkg_info)
        } else if (regmatches(phrase, match)[[1]][2] == "") {
        ## Second check needs to happen after first
            message("  * No source available; probably archived on Bioconductor.")
            pkg_info$cran_check <- FALSE
            pkg_info$errors <- TRUE
            pkg_info$archived <- TRUE
            return(pkg_info)
        }
        ## Actual repository can be found in 'release/' (one fewer things to
        ## check)
        download_file <- paste0("https://bioconductor.org/packages/release/bioc/",
            regmatches(phrase, match)[[1]][2])
        working_folder <- paste0(download_local, "/", pkg_info$package_name)
        download_folder <- paste0(download_local, "/",
            pkg_info$package_name, ".tar.gz")
        ## Download and unzip folder so we can install dependencies
        download_retry(url = download_file, destfile = download_folder,
            method = "libcurl", quiet = TRUE)
        untar(tarfile = download_folder, exdir = download_local)
        message("  * Is on Bioconductor.")
    }

    ## Specific R-Forge (includes download + untar)
    if (pkg_info$source == "rforge") {
        out <- download.packages(pkg_info$package_name,
            destdir = download_local, repos = "http://download.R-Forge.R-project.org",
            quiet = TRUE)
        download_folder <- out[2]
        working_folder <- paste0(download_local, "/", pkg_info$package_name)
        untar(tarfile = download_folder, exdir = download_local)
        message("  * Is on R-Forge.")
    }

    ## Specific GitHub
    if (pkg_info$source == "github") {
        owner <- pkg_info$owner
        repo <- pkg_info$repository
        branch <- pkg_info$branch
        branch <- ifelse(branch == "", "master", branch)
        sub <- pkg_info$sub
        ## See https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives
        download_file <-
            paste0("https://github.com/",
                owner,
                "/",
                repo,
                "/archive/master.zip")
        working_folder <- paste0(download_local, "/", repo, "-", branch, "/", sub)
        ## if (sub == "") {
        ##     working_folder <- paste0(download_local, "/", repo, "-master")
        ## } else {
        ##     working_folder <- paste0(download_local, "/", repo,
        ##         "-master/", sub)
        ## }
        download_folder <- paste0(download_local, "/",
            pkg_info$repository, ".zip")
        ## Download and unzip folder so we can install dependencies
        download_retry(url = download_file, destfile = download_folder,
            method = "libcurl", quiet = TRUE)
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
        pkg_info$recent_commit <- commit
        message("  * Is on GitHub.")
    }

    ## Specific Other: we assume that we provide the download URL to the .tar.gz
    ## file.
    if (pkg_info$source == "other") {
        ## Check if package even has a repository
        if (nchar(as.character(pkg_info$download_link)) == 0) {
            message("  * Does not have a selected repository, skipping…")
            return(pkg_info)
        }
        download_file <- as.character(pkg_info$download_link)
        working_folder <- paste0(download_local, "/", pkg_info$package_name)
        download_folder <- paste0(download_local, "/",
            pkg_info$package_name, ".tar.gz")
        ## Download and unzip folder so we can install dependencies
        download_retry(url = download_file, destfile = download_folder,
            method = "libcurl", quiet = TRUE)
        if (grepl("\\.zip", download_folder)) {
            if (unzip(zipfile = download_folder, list = TRUE)[1] ==
                paste0(pkg_info$package_name, "/")) {
                unzip(zipfile = download_folder, exdir = download_local)
            } else {
                unzip(zipfile = download_folder, exdir = working_folder)
            }
        }
        if (grepl("\\.tar\\.gz", download_folder)) {
            if (untar(tarfile = download_folder, list = TRUE)[1] ==
                paste0(pkg_info$package_name, "/")) {
                untar(tarfile = download_folder, exdir = download_local)
            } else {
                untar(tarfile = download_folder, exdir = working_folder)
            }
        }
        message("  * Is on a selected repository.")
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
            pkg = working_folder,
            dependencies = TRUE,
            upgrade = "never",
            quiet = TRUE
        ),
        error = function(e) as.character(e)
    )
    ## These are errors that keep the remainder of steps from completing so we
    ## have to exit
    if (!is.null(here)) {
        pkg_info$dep_errors <- here
        return(pkg_info)
    }
    ## We now build the file from scratch so we can guarantee all the correct
    ## folders are in the correct spot.
    there <- tryCatch(
        build_file <- devtools::build(pkg = working_folder, quiet = TRUE),
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
            devtools::check_built(path = build_file, quiet = TRUE),
            error = function(e) data.frame(errors = as.character(e))
        )
        ## Results of CRAN check
        checks <- (length(ll$errors)  + length(ll$warnings)) == 0
        warnings <- length(ll$warnings) > 0
        errors <- length(ll$errors) > 0
        vignette <- FALSE
    }
    pkg_info$cran_check <- checks
    pkg_info$warnings <- warnings
    pkg_info$errors <- errors
    pkg_info$vignette_error <- vignette

    ## Create dependency tree
    if (exists("build_file")) {
        desc_folder <- paste0(download_local, "/DESCRIPTION")
        untar(tarfile = build_file, file = paste0(pkg_info$package_name,
            "/DESCRIPTION"), exdir = desc_folder)
        pkg_desc <- desc::desc(file =  paste0(desc_folder, "/",
            pkg_info$package_name, "/DESCRIPTION"))
        pkg_dep <- pkg_desc$get_deps()
        pkg_dep <- pkg_dep[pkg_dep$package != "R", ]
        string <- paste(unique(pkg_dep$package[pkg_dep$type %in%
            c("Depends", "Imports", "LinkingTo")]), collapse = ", ")
        pkg_info$imports <- as.character(string)
        string <- paste(pkg_dep$package[pkg_dep$type == "Suggests"],
            collapse = ", ")
        pkg_info$suggests <- as.character(string)
        pkg_info$version <- gsub("‘", "", pkg_desc$get_version())
    } else {
        tryCatch({
            pkg_desc <- desc::desc(file =  paste0(working_folder, "/",
                "/DESCRIPTION"))
            pkg_dep <- pkg_desc$get_deps()
            pkg_dep <- pkg_dep[pkg_dep$package != "R", ]
            string <- paste(unique(pkg_dep$package[pkg_dep$type %in%
                c("Depends", "Imports", "LinkingTo")]), collapse = ", ")
            pkg_info$imports <- as.character(string)
            string <- paste(pkg_dep$package[pkg_dep$type == "Suggests"],
                collapse = ", ")
            pkg_info$suggests <- as.character(string)
            pkg_info$version <- gsub("‘", "", pkg_desc$get_version())
        },
        error = function(e) "  * Cannot retrieve DESCRIPTION."
        )
    }

    ## Look for check log
    temp_files <- list.files(paste0(tempdir(), "/", pkg_info$package_name, ".Rcheck"),
        "check.log", full.names = TRUE)
    file.copy(temp_files, paste0(check_logs, "/", pkg_info$package_name, "_check.log"),
        overwrite = TRUE)

    return(pkg_info)
}

ctv_network <- function(pkg_check) {
    if (!requireNamespace("coin", quietly = TRUE)) {
        stop("Package 'coin' must be installed to use this function.",
            call. = FALSE)
    }

    if (sum(pkg_check$cran_check, na.rm = TRUE) == 0) {
        message("No package that passes CRAN checks.")
        return(pkg_check)
    } else {
        pkg_check_ok <- subset(pkg_check, cran_check)
    }

    ## Remove spaces, separate imported packages by commas
    pkg_import <- strsplit(gsub("\\s*", "", pkg_check_ok$imports), split = ",")
    ## Remove duplicates
    pkg_import <- lapply(pkg_import, FUN = unique)
    ## Number of dependencies
    pkg_import_length <- sapply(pkg_import, FUN = length)
    ## Create empty data.frame with that number of elements
    pkg_import_gather <- data.frame(
        package = rep.int(pkg_check_ok$package_name, times = pkg_import_length),
        network = unlist(pkg_import), role = rep("import", sum(pkg_import_length)))

    ## Now same thing for suggest
    pkg_suggest <- strsplit(gsub("\\s*", "", pkg_check_ok$suggests), split = ",")
    pkg_suggest <- lapply(pkg_suggest, FUN = unique)
    pkg_suggest_length <- sapply(pkg_suggest, FUN = length)
    pkg_suggest_gather <- data.frame(
        package = rep.int(pkg_check_ok$package_name, times = pkg_suggest_length),
        network = unlist(pkg_suggest), role = rep("suggest", sum(pkg_suggest_length)))

    ## One data frame to rule them all
    pkg_net <- rbind.data.frame(pkg_import_gather, pkg_suggest_gather)
    ## Filtering out non movement packages
    if (sum(pkg_net$network %in% pkg_check_ok$package_name, na.rm = TRUE) == 0) {
        message("There is no network in the movement packages.\n")
        return(pkg_check)
    } else {
        pkg_net <- subset(pkg_net, network %in% pkg_check_ok$package_name)
    }

    ## Counting how much a package is needed or suggested
    pkg_net_tb <- data.frame(table(pkg_net$network))
    names(pkg_net_tb) <- c("package_name", "mention")
    pkg_net_tb <- pkg_net_tb[order(pkg_net_tb$mention, decreasing = TRUE), ]
    row.names(pkg_net_tb) <- t <- 1:nrow(pkg_net_tb)

    ## Actual test
    network_test <- coin::maxstat_test(mention ~ t, dist = "approx", data = pkg_net_tb)

    ## Add 'core' variable
    pkg_net_tb$core <- (pkg_net_tb$mention > network_test@estimates$estimate$cutpoint)

    ## Add 'core' and 'mention' to global table
    mm <- match(pkg_check$package_name, as.character(pkg_net_tb$package_name))
    pkg_check$mention <- ifelse(is.na(mm), 0, pkg_net_tb$mention[mm])
    pkg_check$core <- ifelse(is.na(mm), FALSE, pkg_net_tb$core[mm])
    ## Add the test as attribute
    attr(pkg_check, "ctv_network_test") <- network_test

    return(pkg_check)
}

ctv_stats <- function(pkg_check) {
    pkg_check <- subset(pkg_check, !skip)
    ctv_stats <- table(pkg_check$cran_check, factor(pkg_check$source,
        levels = c("bioc", "cran", "github", "other", "rforge")))
    ctv_stats <- cbind(ctv_stats, apply(ctv_stats, 1, sum))
    ctv_stats <- rbind(ctv_stats, apply(ctv_stats, 2, sum))
    rownames(ctv_stats) <- c("fails", "checks", "total")
    colnames(ctv_stats) <- c("bioc", "cran", "github", "other", "rforge", "total")
    return(ctv_stats[c(2, 1, 3), c(2, 3, 1, 5, 4, 6)])
}

ctv_news <- function(pkg_check, pkg_check_prev) {
    if (!requireNamespace("dplyr", quietly = TRUE)) {
        stop("Package 'dplyr' must be installed to use this function.",
            call. = FALSE)
    }
    ## Differences with previous state
    ## 1) submitted packages that pass/fail CRAN checks
    pkg_check |>
        dplyr::filter(!skip) |>
        dplyr::filter(!(package_name %in% pkg_check_prev$package_name)) |>
        dplyr::mutate(news = ifelse(cran_check, "new-pass", "new-fail")) |>
        dplyr::arrange(desc(cran_check), tolower(package_name)) |>
        dplyr::select(news, package_name, version, source, date_added_to_list,
            cran_check, warnings, errors, vignette_error, comments) -> pkg_check_new
    ## 2) previous packages that now pass or now fail CRAN checks
    dplyr::left_join(pkg_check, pkg_check_prev, by = "package_name", suffix = c("", "_old")) |>
        dplyr::filter(cran_check != cran_check_old) |>
        dplyr::mutate(news = ifelse(cran_check, "mod-pass", "mod-fail")) |>
        dplyr::arrange(desc(cran_check), tolower(package_name)) |>
        dplyr::select(news, package_name, version, source, date_added_to_list,
            cran_check, warnings, errors, vignette_error, comments) -> pkg_check_mod
    ## 3) submitted but skipped packages
    pkg_check |>
        dplyr::filter(skip) |>
        dplyr::filter(!(package_name %in% pkg_check_prev$package_name)) |>
        dplyr::mutate(news = "skipped") |>
        dplyr::select(news, package_name, version, source, date_added_to_list,
            cran_check, warnings, errors, vignette_error, comments) -> pkg_check_skipped
    ## 4) bind all 3
    dplyr::bind_rows(pkg_check_new, pkg_check_mod, pkg_check_skipped)
}

download_retry <- function(
        url, destfile = basename(url), mode = "wb",
        N.TRIES = 10L, ...) {
    ## From 'recount::download_retry'

    N.TRIES <- as.integer(N.TRIES)
    stopifnot(length(N.TRIES) == 1L, !is.na(N.TRIES))
    stopifnot(N.TRIES > 0L)

    while (N.TRIES > 0L) {
        result <- tryCatch(download.file(
            url = url, destfile = destfile, mode = mode, ...
        ), error = identity)
        if (!inherits(result, "error")) {
            break
        }
        ## Wait between 2 and 5 seconds between retries
        Sys.sleep(runif(n = 1, min = 2, max = 5))
        N.TRIES <- N.TRIES - 1L
    }

    if (N.TRIES == 0L) {
        stop(
            "'download_retry()' failed:",
            "\n  URL: ", url,
            "\n  error: ", conditionMessage(result)
        )
    }

    invisible(result)
}
