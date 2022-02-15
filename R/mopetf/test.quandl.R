# official release
library("sqldf")
#install.packages("Quandl")
# or github  version
# library("devtools")
# install_github("quandl/quandl-r")
# quandl
library("Quandl")
source("/var/www/R/auth.private")

Quandl.api_key(quandl_api_key) #Need API key to access quandl
stocks <- Quandl.datatable("SHARADAR/SF1", paginate = TRUE)
kubty_all <- sqldf("select * from stocks where dimension like 'KU%'")
