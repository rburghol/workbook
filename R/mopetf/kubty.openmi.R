#install_github("HARPgroup/openmi-om")
library("openmi.om")
library("stringr")
library("sqldf")
library("xts")
library("quantmod")
# qmao has earnings and other things


source("/home/git/openmi-om/R/utils/oom_ts_dt_table.R")

#****************************
# set up the model container
#****************************
m <- openmi.om.runtimeController$new();
#****************************
# Set up run timer
#****************************
m$timer$starttime = as.POSIXct('2005-03-01',tz="")
m$timer$endtime = as.POSIXct('2020-01-06',tz="")
m$timer$thistime = m$timer$starttime
m$timer$dt <- 86400
tseq <- seq(as.integer(m$timer$starttime), as.integer(m$timer$endtime), by=m$timer$dt)

# get the historic eps ratio
eps_kubty <- openmi.om.timeSeriesInput$new()
# gert earnings data from hand spun time series
# source: https://www.macrotrends.net/stocks/charts/KUBTY/kubota/eps-earnings-per-share-diluted
#    other winfohttps://www.macrotrends.net/stocks/charts/KUBTY/kubota/revenue
# alt source in Yen: https://in.investing.com/equities/kubota-corp.-historical-data-earnings
# other earnings info for Janpanese stocks: https://tradingeconomics.com/6326:jp:eps
eps_data <- read.table("/home/git/workbook/R/mopetf/data/kubty.eps.annual.txt")
eps_tsvalues <- xts(
  eps_data$V2,
  order.by = as.POSIXct(as.character(eps_data$V1), format="%Y", tz="")
)
names(eps_tsvalues) <- c('eps')
eps_tsvalues <- oom_ts_dt_table(eps_tsvalues, 'eps', m$timer$dt, tseq)
eps_kubty$tsvalues <- xts(
  eps_tsvalues$tsvalue,
  order.by = as.POSIXct(as.numeric(eps_tsvalues$timestamp),origin="1970-01-01", tz="")
)
names(eps_kubty$tsvalues) <- c('eps')
m$addComponent(eps_kubty)

# get the ticker data and put in a timeseries 
ts_kubty <- openmi.om.timeSeriesInput$new()
kub <- getSymbols(
  "KUBTY", from = '2000-01-01',
  to = "2022-02-15",warnings = FALSE,
  auto.assign = FALSE
)
kub$close <- kub$KUBTY.Close
kub$tstime <- as.numeric(as.POSIXct(as.character(index(kub)), format="%Y-%m-%d", tz=""))
kub <- xts(
  kub$close,
  order.by = as.POSIXct(as.numeric(kub$tstime),origin="1970-01-01", format="%Y-%m-%d", tz="")
)
kub_tsvalues <- om_ts_dt_table(kub, 'close', m$timer$dt, tseq)

ts_kubty$tsvalues <- xts(
  kub_tsvalues$tsvalue,
  order.by = as.POSIXct(as.numeric(kub_tsvalues$timestamp),origin="1970-01-01", format="%Y-%m-%d", tz="")
)
names(ts_kubty$tsvalues) <- c('close')
m$addComponent(ts_kubty)
#################################
# Add debugging equation
#################################
j <- openmi.om.equation$new();
j$addInput('kval', ts_kubty, 'close', 'numeric')
j$addInput('keps', eps_kubty, 'eps', 'numeric')
j$equation = paste(
  "kval / keps",
  sep=";"
)
#j$equation <- "kval"
#vahydro_prop_matrix

m$addComponent(j)

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
eps_kubty$data

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