library("rgl")
library("hydrotools")
basepath =
source("/var/www/R/config.R")
# Difficult Run
pid = 6569128
elid = 352131
runid = 201
dt = 86400

dat <- om_get_rundata(elid, runid, site = omsite)

# NOte: if using exponents, enclose term in I(), like so:
# dat$Qout ~ dat$local_channel_Qin + I(dat$local_channel_last_S^2)
quadratic_model2 <- lm(
  dat$Qout ~ dat$local_channel_Qin + I(dat$local_channel_last_S^2)
)
summary(quadratic_model2)

plot3d(
  x=dat$local_channel_last_S, y=dat$local_channel_Qout, z=dat$local_channel_Qin,
  type = 's',
  xlab="S(t-1)", ylab="Qout", zlab="Qin"
)

