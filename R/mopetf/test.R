#install.packages("quantmod")
library("quantmod")
library("devtools")
#install_github("HARPgroup/openmi-om")
library("openmi.om")
library("stringr")

options("getSymbols.warning4.0"=FALSE)
options("getSymbols.yahoo.warning"=FALSE)
# Downloading Kubota price using quantmod
getSymbols("KUBTY", from = '2000-01-01',
           to = "2022-02-01",warnings = FALSE,
           auto.assign = TRUE)

# set up the nmodel container
m <- openmi.om.runtimeController$new();

# get the historic eps ratio
eps_kubty <- openmi.om.timeSeriesInput$new()
eps_data <- read.table("/home/git/workbook/R/mopetf/data/kubty.eps.annual.txt")
eps_kubty$tsvalues <- xts(
  eps_data$V2,
  order.by = as.POSIXct(as.character(eps_data$V1), format="%Y", tz="")
)
names(eps_kubty$tsvalues) <- c('eps')
m$addComponent(eps_kubty)

# get the ticker data
ts_kubty <- openmi.om.timeSeriesInput$new()
ts_kubty$tsvalues <- xts(
  KUBTY,
  order.by = as.POSIXct(as.character(index(KUBTY)), format="%Y-%m-%d", tz="")
)
m$timer$thistime
m$addComponent(ts_kubty)
#################################
# Add debugging equation
#################################
j <- openmi.om.equation$new();
j$addInput('kval', ts_kubty, 'KUBTY.Close', 'numeric')
j$addInput('keps', eps_kubty, 'eps', 'numeric')
j$equation = paste(
  "kval / keps",
  sep=";"
)
#j$equation <- "kval"
#vahydro_prop_matrix

m$addComponent(j)

#****************************
# Set up run timer
#****************************
m$timer$starttime = as.POSIXct('2005-03-01',tz="")
m$timer$endtime = as.POSIXct('2020-01-06',tz="")
m$timer$thistime = m$timer$starttime
m$timer$dt <- 86400
#****************************
# Call initialize for model and all children
#****************************
m$init()
m$step()
m$timer$thistime
#****************************
# Run Model
#****************************
m$run()
j$value
ts_kubty$data
ts_kubty$timer$thistime
ts_kubty$tsvalues[ts_kubty$timer$thistime]

# does not work
ts_kubty$tsvalues["2000-01-14 EST"]
# DOES work
ts_kubty$tsvalues["2000-01-14"]
# but output of this *seems* to match
index(ts_kubty$tsvalues[5])
#[1] "2000-01-14 EST"
# should be the same as thisL
ts_kubty$tsvalues[10]
# this works!
ts_kubty$tsvalues[index(ts_kubty$tsvalues[10])]
# this this appears the same as above strings
index(ts_kubty$tsvalues[10])
as.character(index(ts_kubty$tsvalues[10]))
ts_kubty$tsvalues[as.character(index(ts_kubty$tsvalues[10]))]
ts_kubty$tsvalues[ts_kubty$timer$thistime]
ts_kubty$timer$thistime
ts_kubty$getInputs()
ts_kubty$data
m$timer$thistime
m$step()
