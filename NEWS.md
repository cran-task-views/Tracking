# Tracking CTV 2025-02-12

This is a long due update of the Tracking CTV. 7 packages were submitted this
round. The Tracking CTV now lists 59 tracking packages, including 3 core
packages: [`adehabitatLT`](https://cran.r-project.org/package=adehabitatLT),
[`move`](https://cran.r-project.org/package=move)
([documentation](https://bartk.gitlab.io/move/)), and
[`moveHMM`](https://cran.r-project.org/package=moveHMM).

## Packages added to the tracking CTV

4 newly submitted packages:

- [`eyetrackingR`](https://cran.r-project.org/package=eyetrackingR):
  Eye-Tracking Data Analysis
  ([documentation](https://samforbes.me/eyetrackingR/))
- [`move2`](https://cran.r-project.org/package=move2): Processing and Analysing
  Animal Trajectories ([documentation](https://bartk.gitlab.io/move2/))
- [`tagtools`](https://cran.r-project.org/package=tagtools): Work with Data from
  High-Resolution Biologging Tags
  ([documentation](https://animaltags.github.io/tagtools_r/))
- [`triact`](https://cran.r-project.org/package=triact): Analyzing the Lying
  Behavior of Cows from Accelerometer Data

2 packages previously submitted and now passing CRAN checks: 

- [`argosTrack`](https://github.com/calbertsen/argosTrack): Fit Movement Models
  to Argos Data for Marine Animals
- [`Rhabit`](https://github.com/papayoun/Rhabit): Estimation of animal habitat
  selection using the Langevin movement model

2 packages previously submitted that were not tested before due to bugs in the
Tracking CTV code:

- [`pathroutr`](https://github.com/jmlondon/pathroutr): Re-routing paths that
  cross land around barrier polygons
  ([documentation](https://jmlondon.github.io/pathroutr/))
- [`RSP`](https://github.com/YuriNiella/RSP): Refined Shortest Paths

## Packages submitted but not added to the tracking CTV

3 packages that did not pass CRAN checks:

- [MoveR](https://github.com/cran-task-views/Tracking/issues/68): Fails examples
  and tests.
- [hmmSSF](https://github.com/cran-task-views/Tracking/issues/66): Various
  warnings and notes.
- [movedesign](https://github.com/cran-task-views/Tracking/issues/65): Various
  warnings and notes.

Check the links to the submission threads to find details for each package.

## Packages removed from the tracking CTV

4 packages removed because they were archived or did not pass CRAN checks
anymore:

- [`gazepath`](https://github.com/cran-task-views/Tracking/issues/78): Archived
  on 2023-08-19 as email to the maintainer is undeliverable.
- [`migflow`](https://github.com/cran-task-views/Tracking/issues/38): Package
  required but not available: `maptools`.
- [`moveVis`](https://github.com/cran-task-views/Tracking/issues/79): Archived
  on CRAN on 2023-07-11 as issues were not corrected in time.
- [`TrajDataMining`](https://github.com/cran-task-views/Tracking/issues/77):
  Archived on CRAN on 2023-10-16 as requires archived package 'rgdal'.

Check the links to the submission threads to find details for each package.


# Tracking CTV 2023-06-19

Here is an update of the Tracking CTV! We had 16
submissions this round. The Tracking CTV now lists 55 tracking packages,
including 4 core packages:
[`adehabitatLT`](https://cran.r-project.org/package=adehabitatLT),
[`move`](https://cran.r-project.org/package=move)
([documentation](https://bartk.gitlab.io/move/)),
[`adehabitatHR`](https://cran.r-project.org/package=adehabitatHR), and
[`moveHMM`](https://cran.r-project.org/package=moveHMM).

## New packages

6 submitted packages were added successfully to the list this round:

  * [`actel`](https://cran.r-project.org/package=actel): Acoustic Telemetry Data
    Analysis
    ([documentation](https://cran.r-project.org/web/packages/actel/vignettes/))
  * [`eyelinker`](https://cran.r-project.org/package=eyelinker): Import ASC
    Files from EyeLink Eye Trackers
    ([documentation](https://cran.r-project.org/web/packages/eyelinker/vignettes/))
  * [`gazepath`](https://cran.r-project.org/package=gazepath): Parse
    Eye-Tracking Data into Fixations
    ([documentation](https://cran.r-project.org/web/packages/gazepath/gazepath.pdf))
  * [`migflow`](https://github.com/KiranLDA/migflow): Calculates the maximum
    flow through a network
    ([documentation](https://github.com/KiranLDA/migflow))
  * [`mousetrap`](https://cran.r-project.org/package=mousetrap): Process and
    Analyze Mouse-Tracking Data
    ([documentation](https://pascalkieslich.github.io/mousetrap/))
  * [`track2KBA`](https://cran.r-project.org/web/package=track2KBA): Identifying
    Important Areas from Animal Tracking Data
    ([documentation](https://cran.r-project.org/web/packages/track2KBA/vignettes/track2kba_workflow.html))

## Declined submissions

1 submitted package was declined because it was archived on CRAN at the request
of the maintainer

* [`saccades`](https://github.com/cran-task-views/Tracking/issues/15): Saccade
  and Fixation Detection in R

8 submitted packages did not pass the tests

  * [`BaBA`](https://github.com/cran-task-views/Tracking/issues/40): Barrier
    Behavior Analysis (BaBA)
  * [`aniMotum`](https://github.com/cran-task-views/Tracking/issues/59): Fit
    Continuous-Time State-Space and Latent Variable Models for Quality Control
    of Argos Satellite (and Other) Telemetry Data and for Estimating Changes in
    Animal Movement
  * [`mousetrack`](https://github.com/cran-task-views/Tracking/issues/14):
    Mouse-Tracking Measures from Trajectory Data
  * [`nestR`](https://github.com/cran-task-views/Tracking/issues/42): Estimation
    of Bird Nesting from Tracking Data
  * [`palmr`](https://github.com/cran-task-views/Tracking/issues/39): Suite Of
    Functions For Manipulating Pressure, Activity, Magnetism, Temperature And
    Light Data In R
  * [`smoove`](https://github.com/cran-task-views/Tracking/issues/41):
    Simulation and Estimation of Correlated Velocity Movement (CVM) Models
  * [`vmsbase`](https://github.com/cran-task-views/Tracking/issues/43): GUI
    Tools to Process, Analyze and Plot Fisheries Data

You can check the links to the submission threads to find explanations and logs for
each package.

## Packages removed

4 packages have been removed from the list:

  * [`Rhabit`](https://github.com/cran-task-views/Tracking/issues/20): does not
    pass checks anymore
  * [`animalTrack`](https://github.com/rociojoo/CranTaskView-Track/issues/17):
    no longer on CRAN (archived on 2023-02-02).
  * [`argosTrack`](https://github.com/cran-task-views/Tracking/issues/60): does
    not pass checks anymore
  * [`BayesianAnimalTracker`](https://github.com/cran-task-views/Tracking/issues/48):
    no longer on CRAN (archived on 2022-06-08)
  * [`BBMM`](https://github.com/cran-task-views/Tracking/issues/46): no longer
    on CRAN (archived on 2022-05-23)
  * [`foieGras`](https://github.com/rociojoo/CranTaskView-Track/issues/57): no
    longer on CRAN (archived on 2022-12-12)
  * [`mkde`](https://github.com/cran-task-views/Tracking/issues/47): no longer
    on CRAN (archived on 2022-04-25).

You can check the links to the removal threads to find explanations and logs for
each package.

## Packages back in the CTV

1 package has been added back to the CTV as it now passes CRAN checks:

  * [`FLightR`](https://github.com/cran-task-views/Tracking/issues/26)

# Tracking CTV 22.01 (2022-01-27)

Here is finally a long due overdue update of the Tracking CTV! We had 4
submissions this round. The Tracking CTV now lists 54 tracking packages,
including 4 core packages:
[`adehabitatLT`](https://cran.r-project.org/package=adehabitatLT),
[`move`](https://cran.r-project.org/package=move)
([documentation](https://bartk.gitlab.io/move/)),
[`adehabitatHR`](https://cran.r-project.org/package=adehabitatHR), and
[`moveHMM`](https://cran.r-project.org/package=moveHMM).

## New packages

3 submitted packages were added successfully to the list this round:

  * [`bayesmove`](https://cran.r-project.org/package=bayesmove): Non-Parametric
    Bayesian Analyses of Animal Movement
    ([documentation](https://joshcullen.github.io/bayesmove/))
  * [`gtfs2gps`](https://cran.r-project.org/package=gtfs2gps): Converting
    Transport Data from GTFS Format to GPS-Like Records
    ([documentation](https://ipeagit.github.io/gtfs2gps/))
  * [`sftrack`](https://cran.r-project.org/package=sftrack): Modern Classes for
    Tracking and Movement Data ([documentation](https://mablab.org/sftrack/))

## Declined submissions

1 submitted package was deemed to not fit the current definition of a tracking
package:

  * [`RNCEP`](https://github.com/rociojoo/CranTaskView-Track/issues/10): Obtain,
    Organize, and Visualize NCEP Weather Data

You can check the links to the submission threads to find explanations for each
package.

## Packages removed

5 packages have been removed from the list:

  * [`FLightR`](https://github.com/rociojoo/CranTaskView-Track/issues/16): no
    longer on CRAN (archived on 2021-11-14).
  * [`GeoLight`](https://github.com/rociojoo/CranTaskView-Track/issues/17): no
    longer on CRAN (archived on 2021-11-14).
  * [`rpostgisLT`](https://github.com/rociojoo/CranTaskView-Track/issues/18): no
    longer on CRAN (archived on 2020-08-31).
  * [`SwimR`](https://github.com/rociojoo/CranTaskView-Track/issues/19): no
    longer on Bioconductor (deprecated).
  * [`VTrack`](https://github.com/rociojoo/CranTaskView-Track/issues/20): no
    longer on CRAN (archived on 2021-09-13).

You can check the links to the removal threads to find explanations and logs for
each package.

# Tracking CTV 20.07 (2020-07-15)

We have completed our very first update! We had 8 submissions this round. The
Tracking CTV now lists 56 tracking packages.

## New packages

2 submitted packages were added successfully to the list this round:

  * [`Rhabit`](https://github.com/papayoun/Rhabit/)
  * [`rerddapXtracto`](https://cran.r-project.org/package=rerddapXtracto)

## Declined submissions

3 submitted packages did not successfully pass CRAN checks (but will
nevertheless be evaluated in future updates):

  * [`ctmmweb`](https://github.com/rociojoo/CranTaskView-Track/issues/4)
  * [`stmove`](https://github.com/rociojoo/CranTaskView-Track/issues/5)
  * [`VMStools`](https://github.com/rociojoo/CranTaskView-Track/issues/9)
  
2 submitted packages were deemed to not fit the current definition of a tracking
package:
  
  * [`geoviz`](https://github.com/rociojoo/CranTaskView-Track/issues/3)
  * [`overlap`](https://github.com/rociojoo/CranTaskView-Track/issues/7)

You can check the links to the submission threads to find explanations for each
package.

## Packages removed

1 package has been removed from the CTV:

  * [`rsMove`](https://github.com/rociojoo/CranTaskView-Track/issues/21): no
    longer on CRAN (archived on 2020-07-14).

# Tracking CTV 20.01 (2020-01-27)

Initial version online, with 55 tracking packages. Check it out at:

https://cran.r-project.org/view=Tracking
