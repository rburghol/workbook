library("hydrotools")

runid = 11
rselid = 352006
omsite = "http://deq1.bse.vt.edu:81"

datmr <- as.data.frame(om_get_rundata(352006, runid, omsite, FALSE))

dat_summer <- sqldf("select * from datmr where month in (7,8,9)")
quantile(datmr$impoundment_Qin)
quantile(datmr$impoundment_Qout)

quantile(dat_summer$impoundment_Qin)
quantile(dat_summer$impoundment_Qout)

runid = 13
rselid = 352006
omsite = "http://deq1.bse.vt.edu:81"

datmr <- as.data.frame(om_get_rundata(352006, runid, omsite, FALSE))

dat_summer <- sqldf("select * from datmr where month in (7,8,9)")

dat_fall <- sqldf("select * from datmr where month in (10,11,12)")

rbind(
  quantile(dat_fall$impoundment_Qin),
  quantile(dat_fall$impoundment_Qout)
)
sf <- rbind(
  quantile(dat_summer$impoundment_Qin),
  quantile(dat_summer$impoundment_Qout)
)
rbind(
  quantile(dat_summer$impoundment_Qin),
  quantile(dat_summer$impoundment_Qout)
)

quantile(dat_summer$impoundment_Qin)
quantile(dat_summer$impoundment_Qout)
hydroTSM::fdc(
  cbind(dat_summer$impoundment_Qin, dat_summer$impoundment_Qout),
  ylab="Q (cfs)",
  ylim=c(0,1500),
  main="Inflow vs.Outflow (summer)"
)
hydroTSM::fdc(
  cbind(datmr$impoundment_Qin, datmr$impoundment_Qout),
  ylab="Q (cfs)",
  ylim=c(0,1500),
  main="Inflow vs.Outflow (all year)"
)
