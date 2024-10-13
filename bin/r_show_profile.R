#!/usr/bin/env Rscript

#### Description: Show profile and libPaths
#### Written by: Guillermo de Ignacio - gdeignacio on 12-2022

# https://www.r-project.org/
# https://cloud.r-project.org/

######################################
###        ###
######################################


rpath <- Sys.getenv("R_PATH")

setwd(rpath)

getwd()

libdir <- "../packages"

if (!file.exists(libdir)) {
  stop(paste(libdir, "does not exist in", rpath))
}

.libPaths()