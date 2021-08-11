library("hydrotools")
site = 'http://deq2.bse.vt.edu/d.dh'
ds <- RomDataSource$new(site, 'restws_admin')
ds$get_token()

well1 <- ds$get(
  'dh_feature', 'hydroid', 
  list(hydroid = 147)
)

well2 <- ds$get(
  'dh_feature', 'hydroid', 
  list(hydroid = 1092)
)

well3 <- ds$get(
  'dh_feature', 'hydroid', 
  list(hydroid = 1096)
)

tsvals2 <- ds$get_ts(list(featureid=well2$hydroid, entity_type='dh_feature'))

tsvals3 <- ds$get_ts(list(featureid=well3$hydroid, entity_type='dh_feature'))

