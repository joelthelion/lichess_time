rm(list=ls())

# Explore lichess game times (run lichess_time.py first)

library(tidyverse)
library(ggplot2)

li <- read.csv("game_times.csv")

agg <- li %>% group_by(time_control) %>% summarise(mean_time = mean(total_time), N = n()) %>%
  arrange(mean_time)

# Control plot ordering
agg$time_control <- factor(agg$time_control, levels=agg$time_control)
li$time_control <- factor(li$time_control, levels=agg$time_control)

qplot(data=agg %>% filter(N>300 & mean_time>300), x=time_control, y=mean_time, size=10)

classical <- c("300+3","600+0","900+15","300+8","900+0","900+10")
classical <- (agg %>% filter(N>100,mean_time>400 & mean_time<1200))$time_control
qplot(data=li %>% filter(time_control %in% agg$time_control), x=time_control, y=total_time, geom="boxplot")
qplot(data=li %>% filter(time_control %in% classical), x=time_control, y=total_time/60, geom="boxplot") +
  ylab("duration (m)") + coord_cartesian(ylim=c(0,25))

blitz <- (agg %>% filter(N>100,mean_time>150 & mean_time < 8*60))$time_control
qplot(data=li %>% filter(time_control %in% blitz), x=time_control, y=total_time/60, geom="boxplot") +
  ylab("duration (m)") + coord_cartesian(ylim=c(0,10))

bullet <- (agg %>% filter(N>100,mean_time<150))$time_control
qplot(data=li %>% filter(time_control %in% bullet), x=time_control, y=total_time/60, geom="boxplot") +
  ylab("duration (m)") + coord_cartesian(ylim=c(0,5))

qplot(data=li%>%filter(time_control == "300+0"), x=total_time, geom="density")
qplot(data=li%>%filter(time_control == "60+0"), x=total_time, geom="density")
qplot(data=li%>%filter(time_control == "600+0"), x=total_time, geom="density")
qplot(data=li%>%filter(time_control == "900+15"), x=total_time, geom="density")

m <- lm(total_time ~ main + increment + 0 , li)
m
summary(m)

(300*0.8+25*8)/60

qplot(data=li, x=total_time,y=m$fitted.values) + stat_smooth() + xlim(0,1200) + ylim(0,1200) +
  geom_abline()
