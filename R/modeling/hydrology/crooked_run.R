library("hydrotools")

runid = 401
omsite = "http://deq1.bse.vt.edu:81"

rodat401 <- om_get_rundata(352117, 401, omsite, FALSE)
rodat601 <- om_get_rundata(352117, 601, omsite, FALSE)

datcr <- om_get_rundata(352115, runid, omsite, FALSE)
datcr_4 <- om_get_rundata(352115, 400, omsite, FALSE)
datcr_6 <- om_get_rundata(352115, 601, omsite, FALSE)

datbs_6 <- om_get_rundata(351628, 600, omsite, FALSE)
datbs_6 <- om_get_rundata(351628, 6001, omsite, FALSE)
datbs_4 <- om_get_rundata(351628, 400, omsite, FALSE)
datbs_2 <- om_get_rundata(351628, 2, omsite, FALSE)

datbs <- om_get_rundata(351628, runid, omsite, FALSE)

# cu calcs
datcr_6$Qbaseline <- datcr_6$Qout +
   (datcr_6$wd_cumulative_mgd - datcr_6$ps_cumulative_mgd ) * 1.547
datcr_6$consumptive_use_frac <- 1.0 - (datcr_6$Qout / datcr_6$Qbaseline)


# debug

rodat401 <- om_get_rundata(352117, 401, omsite, FALSE)
rodat601 <- om_get_rundata(352117, 601, omsite, FALSE)

rocbp6_401 <- om_get_rundata(352121, 401, omsite, FALSE)
rocbp6_601 <- om_get_rundata(352121, 601, omsite, FALSE)
rocbp6_401$Runit <- rocbp6_401$Qout / rocbp6_401$area_sqmi
rocbp6_601$Runit <- rocbp6_601$Qout / rocbp6_601$area_sqmi

# om_ts_diff comes from hydro-tools/R/cia_utils.R
# TBD: turn that into hydrotools function
rodiff <- om_ts_diff(rodat401, rodat601, "Runit", "Runit")
rodiff6 <- om_ts_diff(rocbp6_401, rocbp6_601, "Runit", "Runit")

quantile(datcr$local_channel_Qout)
quantile(datbs$Qtest)
quantile(datbs$refill_available_mgd)
quantile(datbs$refill_pump_mgd)
quantile(datbs$local_impoundment_use_remain_mg)
mean(datbs$flowby)
mean(datbs$flowby_current)
mean(datbs$flowby_proposed)

mean(datbs$Qintake)
mean(datbs$refill_available_mgd)
mean(datbs$local_impoundment_refill_full_mgd)

mean(datbs$flowby)

dat <- as.data.frame(datbs_4)
modat <- sqldf(
  "SELECT month, avg(base_demand_mgd) base_demand_mgd
   FROM dat
   GROUP BY month
   ORDER BY month
  "
)

barplot(modat$base_demand_mgd ~ modat$month)


# Stack plots
dat <- om_get_rundata(351628, 400, omsite, FALSE)
dat$impoundment_use_remain_mg <- dat$local_impoundment_use_remain_mg
dat$impoundment_max_usable <- dat$local_impoundment_max_usable
dat$impoundment_Qin <- dat$local_impoundment_Qin
dat$impoundment_Qout <- dat$local_impoundment_Qout
dat$impoundment_demand <- dat$local_impoundment_demand
dat$impoundment <- dat$local_impoundment
dat$storage_pct <- as.numeric(dat$impoundment_use_remain_mg) * 3.07 / as.numeric(dat$impoundment_max_usable)
datpd <- dat

sdate = '1984-10-01'
edate = '2014-09-30'
par(mar = c(1,5,2,5),mfrow = c(2,1))
plot(
   datpd$storage_pct * 100.0,
   ylim=c(0,100),
   ylab="Reservoir Storage (%)",
   xlab="",
   main=paste("Storage and Flows",sdate,"to",edate)
)
ymx <- ceiling(
   pmax(
      max(datpd$Qreach)
   )
)
# if this is a pump store, refill_pump_mgd > 0
# then, plot Qreach first, overlaying impoundment_Qin
plot(
   datpd$Qreach,
   col='blue',
   xlab="",
   ylab='Flow/Demand (cfs)',
   #ylim=c(0,ymx),
   log="y",
   yaxt="n" # supress labeling till we format
)
y_ticks <- axTicks(2)
y_ticks_fmt <- format(y_ticks, scientific = FALSE)
axis(2, at = y_ticks, labels = y_ticks_fmt)
ymx <- ceiling(
   pmax(
      max(datpd$refill_pump_mgd),
      max(datpd$impoundment_demand * 1.547)
   )
)
#par(new = TRUE)
#plot(datpd$refill_pump_mgd * 1.547,col='green',xlab="",ylab="")
lines(datpd$refill_pump_mgd * 1.547,col='red')
lines(datpd$impoundment_demand * 1.547,col='green')
#axis(side = 4)
#mtext(side = 4, line = 3, 'Flow/Demand (cfs)')

