# final commodity flag designation

# go to commodity scoring output file for the scoring




#############
###Import again for the final designation
#############
getwd()
ls()


final.desig=read.csv("kvi_Threshold_20161116.csv")
dim(final.desig)
names(final.desig)
library(plyr)
final.desig.threshold=ddply(final.desig, .(div_nm), function(x) cbind(quantile(x$score,.97),quantile(x$score,.975),quantile(x$score,.98)))
colnames(final.desig.threshold)=c("div_nm","97%","97.5%","98%")
write.csv(final.desig.threshold,"sum.threshold2.csv",row.names = F)


new.data=merge(x = final.desig, y = final.desig.threshold, by = "div_nm", all.x = TRUE)
dim(new.data)
str(new.data)
#new.data$`98%`>new.data$score

remove(final_data)
final_data=cbind(new.data,com_flg=ifelse(new.data$`97%`<new.data$score,"Y","N"))
dim(final_data)
write.csv(final_data,"C:/Users/e026026/Documents/Analysis 2016/Crawl KVI/kvi_crawl/KVICrawl_RyanInput_2016115/com_flg_reco20161116.csv",row.names = F)


table(final_data$com_flg,final_data$cmdty_ind)


crossing=read.csv("final_list_for_crossing.csv")
names(crossing)
table(current=crossing$cmdty_ind,suggetsed=crossing$com_flag_Suggested)
prop.table(crossing$cmdty_ind,crossing$com_flag_Suggested)


#####################################################
#####################################################
# no volume score by market
#####################################################
#####################################################
noVolumeScore=read.csv("NoVolThreshold.csv")
names(noVolumeScore)
library(plyr)
noVolumeScore.threshold=ddply(noVolumeScore, .(div_nm), function(x) cbind(quantile(x$No.volume.score,.97),quantile(x$No.volume.score,.975),quantile(x$No.volume.score,.98)))
colnames(noVolumeScore.threshold)=c("div_nm","97%","97.5%","98%")
write.csv(noVolumeScore.threshold,"no.volume.threshold.csv",row.names = F)