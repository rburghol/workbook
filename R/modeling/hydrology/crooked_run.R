library("hydrotools")

runid = 401
omsite = "http://deq1.bse.vt.edu:81"

rodat <- om_get_rundata(352117, 401, omsite, FALSE)
  
datcr <- om_get_rundata(352115, runid, omsite, FALSE)
datcr_4 <- om_get_rundata(352115, 401, omsite, FALSE)
datcr_6 <- om_get_rundata(352115, 601, omsite, FALSE)

datbs_6 <- om_get_rundata(351628, 601, omsite, FALSE)
datbs_4 <- om_get_rundata(351628, 400, omsite, FALSE)
datbs_2 <- om_get_rundata(351628, 2, omsite, FALSE)

datbs <- om_get_rundata(351628, runid, omsite, FALSE)

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


