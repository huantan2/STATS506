
library(data.table)
library(tidyverse)
nyc14 = fread('https://github.com/arunsrinivasan/flights/wiki/NYCflights14/flights14.csv')
class(nyc14)
nyc14

print(object.size(nyc14), units='Mb')

nyc14[,list(mean(cancelled)),month]

dim(nyc14[origin=='JFK' & dest=='LAX'])

nyc14[origin=='JFK' & dest=='LAX', .(time=mean(hour+min/60)), ]


nyc14[origin=='JFK' & dest=='LAX', .(time=mean(hour+min/60)), 
      list(carrier, month)] %>%
  ggplot(aes(y=time, x=month, group=carrier)) + 
  geom_line(aes(col=carrier))

nyc14[origin=='JFK' & dest=='LAX', .(time=mean(hour+min/60)), list(carrier, month)]

## Chaining - Average flight times with standard errors
nyc14[origin=='JFK' & dest=='LAX', .(time=hour+min/60,carrier, month)
    ][,.(time=mean(time), se_time=sd(time)/.N), .(carrier, month)
    ][,.(time=time, upr=time+2*se_time, lwr=time-2*se_time),.(carrier, month)
    ] %>%
  ggplot(aes(y=time, x=month, group=carrier)) + 
  geom_line(aes(col=carrier)) +
  geom_ribbon(aes(ymin=lwr, ymax=upr, fill=carrier), alpha=.5)


nyc14[dest=='DTW', .(time=hour+min/60,carrier, month)
      ][,.(time=mean(time), se_time=sd(time)/.N), .(carrier, month)
        ][,.(time=time, upr=time+2*se_time, lwr=time-2*se_time),.(carrier, month)
          ] %>%
  ggplot(aes(y=time, x=month, group=carrier)) + 
  geom_line(aes(col=carrier)) +
  geom_ribbon(aes(ymin=lwr, ymax=upr, fill=carrier), alpha=.5)

## Do something more ambitious here
nyc14[order(dest, origin), .(time=mean(hour+min/60), distance=distance[1]), 
      .(origin, dest, carrier)]

nyc14[,.(dep_time)]

compute_time = function(dep, arr){
  d = arr - dep
  floor(d / 100)*60 + d %/% 60
}

  nyc14[,.( dep_time, arr_time,
          minutes = compute_time(dep_time, arr_time)+dep_delay+arr_delay, 
          air_time, dep_delay, arr_delay
        )
    ][,.(dep_time, arr_time,  minutes, delta={air_time - minutes}/60 )
    ]
