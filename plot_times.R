rm(list=ls())

# Explore lichess game times (run lichess_time.py first)

library(tidyverse)
library(ggplot2)

li <- read.csv("game_times.csv") %>% filter(total_time > 0)

agg <- li %>% group_by(time_control) %>% summarise(mean_time = mean(total_time),
                                                   median_time = median(total_time),
                                                   top_90=quantile(total_time,0.9),
                                                   N = n()) %>%
  arrange(mean_time)

# Control plot ordering
agg$time_control <- factor(agg$time_control, levels=agg$time_control)
li$time_control <- factor(li$time_control, levels=agg$time_control)

qplot(data=agg %>% filter(N>10000 & mean_time>300), x=time_control, y=mean_time, size=10)

classical <- (agg %>% filter(N>10000,mean_time>540 & mean_time<1200))$time_control
qplot(data=li %>% filter(time_control %in% classical), x=time_control, y=total_time/60, geom="boxplot") +
  ylab("duration (m)") + coord_cartesian(ylim=c(0,30))

blitz <- (agg %>% filter(N>10000,mean_time>150 & mean_time < 540))$time_control
qplot(data=li %>% filter(time_control %in% blitz), x=time_control, y=total_time/60, geom="boxplot") +
  ylab("duration (m)") + coord_cartesian(ylim=c(0,15))

bullet <- (agg %>% filter(N>10000,mean_time<150))$time_control
qplot(data=li %>% filter(time_control %in% bullet), x=time_control, y=total_time/60, geom="boxplot") +
  ylab("duration (m)") + coord_cartesian(ylim=c(0,5))

qplot(data=li%>%filter(time_control == "60+0"), x=total_time, geom="histogram")
qplot(data=li%>%filter(time_control == "300+0"), x=total_time, geom="histogram")
qplot(data=li%>%filter(time_control == "300+8"), x=total_time, geom="histogram")
qplot(data=li%>%filter(time_control == "600+0"), x=total_time, geom="histogram")
qplot(data=li%>%filter(time_control == "600+5"), x=total_time, geom="histogram")
qplot(data=li%>%filter(time_control == "600+10"), x=total_time, geom="histogram")
qplot(data=li%>%filter(time_control == "900+0"), x=total_time, geom="histogram")
qplot(data=li%>%filter(time_control == "900+5"), x=total_time, geom="histogram")
qplot(data=li%>%filter(time_control == "900+15"), x=total_time, geom="histogram")

m <- lm(total_time ~ main + increment , li)
m
summary(m)

(300*0.8+25*8)/60

# qplot(data=li, x=total_time,y=m$fitted.values) + stat_smooth(method=lm) + xlim(0,1200) + ylim(0,1200) +
  # geom_abline()

