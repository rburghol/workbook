#install.packages("quantmod")
library("quantmod")
# qmao has earnings and other things
#install_github("gsee/qmao")
library("devtools")
#install_github("HARPgroup/openmi-om")
library("openmi.om")
library("stringr")
library("sqldf")

options("getSymbols.warning4.0"=FALSE)
options("getSymbols.yahoo.warning"=FALSE)
# get the data in Yen
kubyen <- getSymbols("6326.T", from = '2000-01-01',
                        to = "2022-02-15",warnings = FALSE,
                        auto.assign = FALSE
)

# Downloading Kubota price using quantmod getSymbols function
kub <- getSymbols(
  "KUBTY", from = '2000-01-01',
  to = "2022-02-15",warnings = FALSE,
  auto.assign = FALSE
)
kub$close <- kub$KUBTY.Close
kub$tstime <- as.numeric(as.POSIXct(as.character(index(kub)), format="%Y-%m-%d", tz=""))
kub <- as.data.frame(kub)

nikkei <- getSymbols(
  "^N225", from = '2000-01-01',
  to = "2022-02-15",warnings = FALSE,
  auto.assign = FALSE
)
nikkei$close <- nikkei$N225.Close
nikkei$tstime <- as.numeric(as.POSIXct(as.character(index(nikkei)), format="%Y-%m-%d", tz=""))
nikkei <- as.data.frame(nikkei)

dji <- getSymbols(
  "^DJI", from = '2000-01-01',
  to = "2022-02-15",warnings = FALSE,
  auto.assign = FALSE
)
dji$close <- dji$DJI.Close
dji$tstime <- as.numeric(as.POSIXct(as.character(index(dji)), format="%Y-%m-%d", tz=""))
dji <- as.data.frame(dji)

kn <- sqldf(
  "select kub.tstime, kub.close as kclose,
     dji.close as djclose,
     nikkei.close as nkclose 
  from kub left outer join nikkei
  on (kub.tstime = nikkei.tstime)
  left outer join dji
  on (kub.tstime = dji.tstime)
  order by kub.tstime"
)
kulm <- lm(kclose ~ nkclose, data = kn)
summary(kulm)
kudlm <- lm(kclose ~ djclose, data = kn)
summary(kudlm)
kundlm <- lm(kclose ~ djclose + nkclose, data = kn)
summary(kundlm)

# set up the nmodel container
m <- openmi.om.runtimeController$new();

# get the historic eps ratio
eps_kubty <- openmi.om.timeSeriesInput$new()
# gert earnings data from hand spun time series
# source: https://www.macrotrends.net/stocks/charts/KUBTY/kubota/eps-earnings-per-share-diluted
#    other winfohttps://www.macrotrends.net/stocks/charts/KUBTY/kubota/revenue
# alt source in Yen: https://in.investing.com/equities/kubota-corp.-historical-data-earnings
# other earnings info for Janpanese stocks: https://tradingeconomics.com/6326:jp:eps
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
  kub,
  order.by = as.POSIXct(as.character(index(kub)), format="%Y-%m-%d", tz="")
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
