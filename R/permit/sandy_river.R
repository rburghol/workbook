# Sandy River REservoir
facid = 351166
rsegid = 352139

runid = 401
# watershed container
dat <- om_get_rundata(352139, 401, omsite)
# facility
fdat <- om_get_rundata(351166, 401, omsite)
# runoff agregator
roadat <- om_get_rundata(352141, 401, omsite)
# cbp6 agregator
cbp6dat <- om_get_rundata(352143, 401, omsite)
# runoff 


quantile(dat$impoundment_Qin)
quantile(dat$local_channel_Qout)
quantile(dat$Runit_mode)
quantile(roadat$Runit)
quantile(cbp6dat$Qunit)
quantile(fdat$wd_mgd)

hydroTSM::fdc(cbind(dat$impoundment_Qin, dat$impoundment_Qout))
quantile(dat$impoundment_use_remain_mg)

seg.hydroid <- 476998
fac.hydroid = 71977
runid.list = c("runid_400", "runid_600")
intake_stats_runid = 2

runid.list <- c("runid_401", "runid_601" )
fac.metric.list <- c("wd_mgd","ps_mgd","unmet30_mgd" )
rseg.metric.list <- c( "Qout","Qbaseline","remaining_days_p0","l30_Qout",
                    "l90_Qout","consumptive_use_frac","wd_cumulative_mgd","ps_cumulative_mgd" )
intake_stats_runid <- 11
