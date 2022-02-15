# kubty ts harmony
# get the historic eps ratio
eps_kubty <- openmi.om.timeSeriesInput$new()
eps_data <- read.table("/home/git/mopetf/data/kubty.eps.annual.txt")
eps_kubty$tsvalues <- xts(
  eps_data$V2,
  order.by = as.POSIXct(as.character(eps_data$V1), format="%Y", tz="")
)
names(eps_kubty$tsvalues) <- c('tsvalue')

beg<- as.POSIXct( format(min(index(eps_kubty$tsvalues)), "%Y-%m-%d %H:%M", tz=""))
bend<- as.POSIXct( format(max(index(eps_kubty$tsvalues)), "%Y-%m-%d %H:%M", tz=""))
dat_eps_kubty <- as.data.frame(eps_kubty$tsvalues)
dat_eps_kubty$timestamp <-as.integer(index(eps_kubty$tsvalues))
ts = 24*60*60
tseq <- seq(as.integer(beg), as.integer(bend), by=ts)

tbase <-  as.data.frame(tseq)
names(tbase) <- c('timestamp')

# get exact data matches,
# stash in column names "first_inner" and "last_inner"
tsmatrix1 <- fn$sqldf(
  "
  select a.timestamp as t_start, a.timestamp + $ts as t_end,
    min(b.timestamp) as first_inner,
    max(b.timestamp) as last_inner
  from tbase as a
  left outer join dat_eps_kubty as b
  on (
    b.timestamp >= a.timestamp
    and b.timestamp < (a.timestamp + $ts)
  )
  group by a.timestamp
  "
)

# now get previous outer
# so, the last ts found that is NOT
# contained by the timestamp
# will be in col named previous_outer
tsmatrix2 <- fn$sqldf(
  "
  select a.t_start, a.t_end,
    a.first_inner,
    a.last_inner,
    max(c.timestamp) as previous_outer
  from tsmatrix1 as a
  left outer join dat_eps_kubty as c
  on (
    c.timestamp < a.t_start
  )
  group by a.t_start
  "
)

# now get next outer
tsmatrix3 <- fn$sqldf(
  "
  select a.t_start, a.t_end,
    a.first_inner,
    a.last_inner,
    a.previous_outer,
    min(d.timestamp) as next_outer
  from tsmatrix2 as a
  left outer join dat_eps_kubty as d
  on (
    d.timestamp > a.t_start
  )
  group by a.t_start
  "
)


tsvalues_in <- sqldf(
  "select a.t_start, a.t_end,
      a.first_inner, a.last_inner,
      a.previous_outer, a.next_outer,
      avg(b.tsvalue) as inner_mean,
    count(b.tsvalue) as inner_count
    from tsmatrix3 as a
    left outer join dat_eps_kubty as b
    on (
      a.first_inner <= b.timestamp
      and a.last_inner >= b.timestamp
    )
    group by a.t_start, a.t_end, a.first_inner, a.last_inner,
      a.previous_outer, a.next_outer
  "
)

tsvalues_out <- sqldf(
  "select a.t_start, a.t_end,
      a.previous_outer, a.next_outer,
      avg(b.tsvalue) as outer_mean,
    count(b.tsvalue) as outer_count
    from tsvalues_in as a
    left outer join dat_eps_kubty as b
    on (
      a.previous_outer = b.timestamp
      OR a.next_outer = b.timestamp
    )
    where a.inner_count = 0
    group by a.t_start, a.t_end, a.first_inner, a.last_inner,
      a.previous_outer, a.next_outer
  "
)

tsvalues <- sqldf(
  "select a.t_start as timestamp,
     CASE
       WHEN a.inner_count = 0 THEN b.outer_mean
       ELSE a.inner_mean
     END as tsvalue
   from tsvalues_in as a
   left outer join tsvalues_out as b
   on (
     a.t_start = b.t_start
   )
  "
)
