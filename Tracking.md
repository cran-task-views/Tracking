---
name: Tracking
topic: Processing and Analysis of Tracking Data
maintainer: Rocío Joo and Mathieu Basille
email: rocio.joo@globalfishingwatch.org
version: 22.01.1 (2023-02-10)
source: https://github.com/cran-task-views/Tracking
---


**This CRAN Task View (CTV) contains a list of packages useful for the
processing and analysis of tracking data.** If you just want to see what is new
in this version of the CTV, click
[here](https://github.com/cran-task-views/Tracking/blob/main/NEWS.md). See below
[how to cite the Tracking CTV](#citing-and-acknowledgments).

Movement of an object (both living organisms and inanimate objects) is defined
as a change in its geographic location in time, so movement data can be defined
by a space and a time component. Tracking data are composed by at least
2-dimensional spatial coordinates (x,y) and a time index (t), and can be seen as
the geometric representation (the trajectory) of an object's path. The packages
listed here, henceforth called **tracking packages** , are those explicitly
**developed to either create, transform or analyze tracking data (i.e. (x,y,t))**,
allowing a full workflow from raw data from tracking devices to final analytical
outcome. In other words, a tracking package must have one or several functions 
that have tracking data as input or output. 
For instance, a package that would use accelerometer, gyroscope and
magnetometer data to reconstruct an objects's trajectory---most likely an
animal's trajectory---via dead-reckoning, thus transforming those data into an
(x,y,t) format, would fit into the definition. However, a package analyzing
accelerometry series to detect changes in behavior would not fit 
(note that there is a dedicated section at the end of this CTV for packages that
deal with movement but not tracking data per se). See more on
this in [Joo *et al.*  (2020)](https://doi.org/dcnf). 
Regarding (x,y), some
packages may assume 2-D Euclidean (Cartesian) coordinates, and others may assume
geographic (longitude/latitude) coordinates. We encourage the users to verify
how coordinates are processed in the packages, as the consequences can be
important in terms of spatial attributes (e.g.  distance, speed and angles).

The packages included here are mainly tracking packages though we include a
subsection of other movement-related packages. The packages are mainly from CRAN
and a few of them are from other repositories. The ones that are not from CRAN
were only included if they passed the check test ( `R CMD check`; more details
[here](https://github.com/cran-task-views/Tracking/tree/main/checks) ). Core
packages are defined as the group of tracking packages with the highest number
of mentions ( `Depends`, `Imports`, `Suggests`) from other tracking packages;
the cutpoint is estimated using the `maxstat_test` function in the `coin`
package. At the beginning and middle of each calendar year, we will update the
CTV, making an assessment on the non-CRAN packages here and remove the non-CRAN
packages that do not pass the check test. Bioconductor packages are
automatically accepted here as they are required to pass by a similar scrutiny
than CRAN packages. We are also open to include more packages every time we
update the CTV. We welcome and encourage
[contributions](https://github.com/cran-task-views/ctv/blob/main/Contributing.md)
to add packages at any time. To open an issue on the GitHub repository, please
use this [link](https://github.com/cran-task-views/Tracking/issues) .

Besides these packages, many other packages contain functions for data
processing and analysis that could eventually be used for tracking data or
second/third degree variables obtained from tracking data; we encourage users to
check other CRAN Task Views like `r view("SpatioTemporal")`, `r view("Spatial")`
and `r view("TimeSeries")`.

This CTV was inspired on the review of tracking packages by [Joo *et al.*
(2020)](https://doi.org/dcnf) , as an attempt to continuously update the list of
packages already described in the review. Therefore, the CTV takes a similar
structure as the review:

```{r, include = FALSE}
tdir <- tempfile()
dir.create(tdir)
svg <- file.path(tdir, "workflow.svg")
download.file("https://raw.githubusercontent.com/cran-task-views/Tracking/main/img/workflow.svg", svg, quiet = TRUE)
svg <- xfun::base64_uri(svg)
unlink(tdir)
```

![Diagram depicting the workflow for data processing and analysis in movement
ecology. Three steps are identified: 1) Pre-processing, taking raw data as input
and leading to tracking data as output (x, y, t); 2) Post-processing,
manipulating tracking data as both input and output; 3) Analysis, which takes
tracking data as input for visualization, track description, path
reconstruction, behavioral pattern identification, space use, trajectory
simulation, and others.](`r svg`){width="500"}\

## Table of contents

* [Pre-processing](#pre-processing)
* [Post-processing](#post-processing)
* [Analysis](#analysis)
  - [Visualization](#visualization)
  - [Track description](#track-description)
  - [Path reconstruction](#path-reconstruction)
  - [Behavioral pattern identification](#behavioral-pattern-identification)
  - [Space and habitat use characterization](#space-and-habitat-use-characterization)
  - [Trajectory simulation](#trajectory-simulation)
  - [Others analyses of tracking data](#other-analyses-of-tracking-data)
* [Dealing with movement but not tracking data](#dealing-with-movement-but-not-tracking-data)
* [Citing and acknowledgments](#citing-and-acknowledgments)
* [Related links](#related-links)



### Pre-processing

Pre-processing is required when raw data are not in a tracking data format. The
methods used for pre-processing depend heavily on the type of biologging device
used. Among the tracking packages, some of them are focused on GLS (global
location sensor), others on radio telemetry, accelerometry, magnetometry, or
GTFS (General Transit Feed Specification) data.

* **GLS data pre-processing:** Several methodologies have been developed to
  reduce errors in geographic locations generated from the light data, which is
  reflected by the large number of packages for pre-processing GLS data. We
  classified these methods in three categories: threshold, curve-fitting and
  twilight-free (no package currently included):
  - **Threshold methods:** Threshold levels of solar irradiance, which are
    arbitrarily chosen, are used to identify the timing of sunrise and
    sunset. The package that uses threshold methods is 
    `r github("SWotherspoon/SGAT")`.
  - **Curve-fitting methods:** The observed light irradiance levels for each
  twilight are modeled as a function of theoretical light levels (i.e. the
  template). Then, parameters from the model (e.g. a slope in a linear
  regression) are used to estimate the locations. The formulation of the model
  and the parameters used for location estimation vary from method to
  method. The packages that use curve-fitting methods are 
  `r pkg("tripEstimation")` and `r github("SWotherspoon/SGAT")`.
* **Dead-reckoning using accelerometry and magnetometry data:** The combined use
  of magnetometer and accelerometer data, and optionally gyroscopes and speed
  sensors, allows to reconstruct sub-second fine scale movement paths using the
  dead-reckoning (DR) technique.  `r pkg("animalTrack")` and 
  `r pkg("TrackReconstruction")` implement DR to obtain tracks, based on
  different methods.
* **GTFS data pre-processing:** Public transportation data in GTFS format per
  trip and vehicle can be interpolated in space-time to obtain GPS-like records
  with `r pkg("gtfs2gps")`.


### Post-processing

Post-processing of tracking data comprises data cleaning (e.g.  identification
of outliers or errors), compressing (i.e. reducing data resolution which is
sometimes called resampling) and computation of metrics based on tracking data,
which are useful for posterior analyses.

- **Data cleaning:** `r pkg("argosfilter")`, `r pkg("foieGras")` and 
  `r pkg("SDLfilter")` implement functions to filter implausible platform
  terminal transmitter (PTT) locations. `r pkg("SDLfilter")` is also adapted to
  GPS data. Other packages with functions for cleaning tracking data are 
  `r pkg("TrajDataMining")` and `r pkg("trip")`.
- **Data compression:** Rediscretization or getting data to equal step lengths
  can be achieved with `r pkg("adehabitatLT", priority = "core")`, 
  `r pkg("trajectories")` or `r pkg("trajr")`.  Regular time-step interpolation
  can be performed using `r pkg("adehabitatLT")`, `r pkg("amt")` or 
  `r pkg("trajectories")`. Other compression methods include Douglas-Peucker 
  (`r pkg("TrajDataMining")` and `r pkg("trajectories")`), opening window 
  (`r pkg("TrajDataMining")`) or Savitzky-Golay (`r pkg("trajr")`).
- **Computation of metrics:** Some packages automatically derive second or third
  order movement variables (e.g. distance and angles between consecutive fixes)
  when transforming the tracking data into the package's data class. These
  packages are `r pkg("adehabitatLT")`, `r pkg("momentuHMM")`, 
  `r pkg("moveHMM", priority = "core")` and `r pkg("trajectories")`.
  `r pkg("bcpa")` has a function to compute speeds, step lengths, orientations
  and other attributes from a track.  `r pkg("amt")`,
  `r pkg("move", priority = "core")`, `r pkg("segclust2d")`, `r pkg("sftrack")`,
  `r pkg("trajr")` and `r pkg("trip")` also contain functions for computing
  those metrics, but the user needs to specify which ones they need to compute.


### Analysis


#### Visualization

The packages mainly developed for visualization purposes, and more specifically,
animation of tracks, are `r pkg("anipaths")` and `r pkg("moveVis")`.


#### Track description

`r pkg("amt")` and `r pkg("trajr")` compute summary metrics of tracks, such as
total distance covered, straightness index and sinuosity. `r pkg("trackeR")` was
created to analyze running, cycling and swimming data from GPS-tracking devices
for humans.  `r pkg("trackeR")` computes metrics summarizing movement effort
during each track (or workout effort per session).  `r pkg("sftrack")` defines
two classes of objects from tracking data, tracks (`sf` points in a time
sequence) and trajectories (`sf` linestrings in a time sequence) and provides
functions to summarize both showing starting and ending time, number of points,
and total distance covered.


#### Path reconstruction

Whether it is for the purposes of correcting for sampling errors, or obtaining
finer data resolutions or regular time steps, path reconstruction is a common
goal in movement analysis. Packages available for path reconstruction are 
`r github("calbertsen/argosTrack")`, 
`r pkg("bsam")`, `r pkg("crawl")`, `r pkg("ctmm")`, `r pkg("ctmcmove")`, 
`r pkg("foieGras")` and `r pkg("TrackReconstruction")`.


#### Behavioral pattern identification

Another common goal in movement ecology is to get a proxy of the individual's
behavior through the observed movement patterns, based on either the locations
themselves or second/third order variables such as distance, speed or turning
angles. Covariates, mainly related to the environment, are frequently used for
behavioral pattern identification.

We classify the methods in this section as: 1) non-sequential classification or
clustering techniques, 2) segmentation methods and 3) hidden Markov models.

- **Non-sequential classification or clustering techniques:** Here each fix in
  the track is classified as a given type of behavior, independently of the
  classification of the preceding or following fixes (i.e. independently of the
  temporal sequence). The packages implementing these techniques are 
  `r pkg("EMbC")` and `r pkg("m2b")`.
- **Segmentation methods:** They identify change in behavior in time series of
  movement patterns to cut them into several segments. The packages implementing
  these techniques are `r pkg("adehabitatLT")`, `r pkg("bcpa")`, 
  `r pkg("bayesmove")`, `r pkg("segclust2d")` and `r pkg("marcher")`.
- **Hidden Markov models:** They are centered upon a hidden state Markovian
  process (representing the sequence of non-observed behaviors) that conditions
  the observed movement patterns. The packages implementing these methods are 
  `r pkg("bsam")`, `r pkg("moveHMM")` and `r pkg("momentuHMM")`.


#### Space and habitat use characterization

Multiple packages implement functions to help answer questions related to where
individuals spend their time and what role environmental conditions play in
movement or space-use decisions, which are typically split into two categories:
home range calculation and habitat selection.

- **Home ranges:** Several packages allow the estimation of home ranges, such as
  `r pkg("adehabitatHR", priority = "core")`, `r pkg("amt")`, 
  `r pkg("ctmm")`, and `r pkg("move")`. They provide a variety
  of methods, from simple Minimum convex polygons to more complex probabilistic
  Utilization distributions, potentially accounting for the temporal
  autocorrelation in tracking data.
- **Habitat use:** Several packages estimate the role of habitat features on
  animal space use or habitat selection, such `r pkg("amt")` using step
  selection functions, `r pkg("ctmcmove")` using functional movement modeling,
  and `r github("papayoun/Rhabit")` using a classical resource selection
  function fitted with a Langevin model on movement data.
- **Non-conventional approaches for space use:** Other non-conventional
  approaches for investigating space use from tracking data can be found in 
  `r pkg("recurse")`.


#### Trajectory simulation

Tracking packages implementing trajectory simulation are mainly based on Hidden
Markov models, correlated random walks, Brownian motions, Lévy walks or
Ornstein-Uhlenbeck processes: `r pkg("adehabitatLT")`, 
`r github("calbertsen/argosTrack")`, `r pkg("bsam")`, `r pkg("crawl")`, 
`r pkg("ctmm")`, `r pkg("momentuHMM")`, `r pkg("moveHMM")`, `r pkg("smam")`, 
`r pkg("SiMRiv")` and `r pkg("trajr")`.


#### Other analyses of tracking data

- **Interactions:** Interactions between individuals can be assessed using
  metrics from `r pkg("wildlifeDI")` and `r pkg("TrajDataMining")`. 
  `r pkg("spatsoc")` groups relocations within a same time-period or a same
  spatial range, and allows computing distances between individuals in the group
  and identifying nearest neighbors.
- **Movement similarity:** Measures such as the longest common subsequence,
  Fréchet distance, edit distance and dynamic time warping could be computed
  with `r pkg("SimilarityMeasures")` or `r pkg("trajectories")`.
- **Population size:** `r pkg("caribou")` was specifically created to estimate
  population size from Caribou tracking data, but can also be used for wildlife
  populations with similar home-range behavior.
- **Environmental conditions:** `r pkg("moveWindSpeed")` uses tracking data to
  infer wind speed.  `r pkg("rerddapXtracto")` allows extracting environmental
  data served on any ERDDAP server along a given track.


### Dealing with movement but not tracking data

- **Analysis of biologging data:** Packages to analyze time-depth recorder (TDR)
  and accelerometer data from animals is `r pkg("diveMove")`. It allows
  obtaining statistics of dive effort. Several packages focus on the analysis of
  human accelerometry data, mainly to describe periodicity and levels of
  activity: `r pkg("acc")`, `r pkg("accelerometry")`, `r pkg("GGIR")`, 
  `r pkg("nparACT")`, `r pkg("pawacc")` and `r pkg("PhysicalActivity")`.
- **Non-biologging video and images:** When a camera can encompass an area large
  enough for an individual to move in, video and images can be used to record
  movement. A package related to these data is `r pkg("trackdem")` (for
  processing frame-by-frame images).


### Citing and acknowledgments

If you would like to cite this CTV, we suggest mentioning: maintainers, year,
title of the CTV, version, and URL. For instance:

> Joo and Basille (2022) CRAN Task View: Processing and Analysis of Tracking
> Data. Version 22.01 (2022-01-27). URL:
> [https://cran.r-project.org/view=Tracking](https://cran.r-project.org/view=Tracking) 

Besides the maintainers, the following people contributed to the creation of
this task view: **Achim Zeileis**, **Edzer Pebesma**, **Michael Sumner**,
**Matthew E. Boone** (former CTV maintainer).

Early work resulting in the article at the base of this Task View, and thus the
initial list of Tracking packages, was partially funded by a **Human Frontier
Science Program Young Investigator Grant** (SeabirdSound - RGY0072/2017; R. Joo
and M. Basille).


### Related links

- [Article at the base of this Task View](https://doi.org/dcnf)
- [GitHub repository for this Task
  View](https://github.com/cran-task-views/Tracking/)
