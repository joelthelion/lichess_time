rm(list=ls())

library(dplyr)
library(ggplot2)
# library(xgboost)

games <- read.csv("./game_times.csv") %>% filter(!is.na(white_cpwn) & total_time>0) %>%
  mutate(estimated_time = main + 30*increment, ln_est_time = log(estimated_time+1),
         ln_main=log(main+1), ln_inc=log(increment+1), ln_tot_time=log(total_time+1),
         elo_diff=white_elo-black_elo)



df <- games %>% filter()

#df <- sample_n(df,5000)

# df$white_level <- cut(df$white_elo,5)
# #df$time_cat <- cut(df$ln_est_time,5)
df$time_cat <- cut(df$estimated_time, c(0,3*60,8*60,25*60,+Inf),labels=c("Bullet","Blitz","Rapid","Classical"))
# 
# m <- lm(white_cpwn~white_elo*ln_est_time*ln_tot_time, data=games)
# #m <- lm(white_cpwn~white_elo, data=games)
# #m <- lm(white_cpwn~white_elo*estimated_time*total_time, data=games)
# m <- lm(white_cpwn~white_elo*black_elo*ln_est_time*ln_tot_time, data=games)
# m
# summary(m)
# 
# qplot(data=df, x=estimated_time, color=white_elo, y=white_cpwn) + scale_x_log10() +stat_smooth()

# the plot
ggplot(data=df, aes(x=white_elo, y=white_cpwn)) + geom_point(alpha=0.1) + stat_smooth(aes(color=time_cat), method="lm") +
  ggtitle("Average centipawn loss as a function of Elo and time (for white)") + ylab("Average centipawn loss") + xlab("Elo rating") +
  scale_color_discrete(name="Time category")


# 
# 
# qplot(data=df, color=ln_tot_time, x=black_elo, y=black_cpwn) + stat_smooth(aes(fill=time_cat))
# qplot(data=df, x=white_level, fill=time_cat, y=white_cpwn, geom="boxplot")
# 
# 
# qplot(data=df, color=ln_tot_time, x=white_cpwn, y=black_cpwn) + stat_smooth()
# 
# #features <- c("white_elo","main","increment","estimated_time","ln_est_time", "total_time","ln_main","ln_inc")
# features <- c("white_elo","main","increment","total_time","black_elo","elo_diff")
# input <- as.matrix(subset(df,select=features))
# m <- xgboost(data=input,label=df$white_cpwn, nrounds=100)
# imp <- xgb.importance(features, m)
# xgb.plot.importance(imp)
# cut
# 
