# Sandy River REservoir
facid = 351166
rsegid = 352139

dat <- om_get_rundata(352139, 401, omsite)
fdat <- om_get_rundata(351166, 401, omsite)

seg.hydroid <- 476998
fac.hydroid = 71977
runid.list = c("runid_400", "runid_600")
intake_stats_runid = 2

runid.list <- c("runid_401", "runid_601" )
fac.metric.list <- c("wd_mgd","ps_mgd","unmet30_mgd" )
rseg.metric.list <- c( "Qout","Qbaseline","remaining_days_p0","l30_Qout",
                    "l90_Qout","consumptive_use_frac","wd_cumulative_mgd","ps_cumulative_mgd" )
intake_stats_runid <- 11
