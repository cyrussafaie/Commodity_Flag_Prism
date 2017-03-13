
# The script is intended to find market elvel threshold for the variables related to Commodity Flag assignment

getwd()
dir()

# data from sql output
threshold=read.csv("data_for_Threshold_calc_excl_filtered_catergories_20160126.csv")
dim(threshold)
summary(threshold)
names(threshold)
summary(threshold[,23:34])
boxplot(threshold[,23], ylim=c(0,1000))
plot(density(threshold[,23]),xlim=c(0,5000))
dev.off()
memory.size()
memory.limit()


##################################################################
##################################################################
#qty threshold
##################################################################
##################################################################
require ("lattice")
# densityplot(~ ttl_qty_cs | pim_brnd_typ_desc, threshold, pch= 20, plot.points=FALSE)

densityplot(~ ttl_qty_cs, threshold, pch= 20, plot.points=T)

#qty plots
quantile(threshold$ttl_qty_cs, .98)
qty.less.98=subset(threshold,threshold$ttl_qty_cs<773)

par(mfrow=c(1,2))
hist(threshold$ttl_qty_cs,prob=1,breaks=200, main = "qty impacted, all")
lines(density(threshold$ttl_qty_cs,kernel="gaussian"),col=2)

hist(qty.less.98$ttl_qty_cs,prob=1,breaks=100, main = "qty impacted, 98% low volume")
lines(density(qty.less.98$ttl_qty_cs,kernel="gaussian"),col=2)

# bottom 98% sumamry
summary(qty.less.98$ttl_qty_cs)
length(summary(qty.less.98$ttl_qty_cs))
densityplot(~ ttl_qty_cs | div_nm, qty.less.98, pch= 20, plot.points=FALSE)

#qty threshold:max of 98 percentile mean and division Q3
library(plyr)
qty.threshold=ddply(qty.less.98, .(div_nm), function(x) round(max(quantile(x$ttl_qty_cs,.75),summary(qty.less.98$ttl_qty_cs)[4]),0))
colnames(qty.threshold)=c("div_nm","qty_threshold")
# ddply(qty.less.98, .(div_nm), function(x) max(mean(x$ttl_qty_cs),153))

##################################################################
##################################################################
#cust_cnt
##################################################################
##################################################################
densityplot(~ cust_cnt, threshold, pch= 20, plot.points=T)

quantile(threshold$cust_cnt, .98)
cust.cnt.less.98=subset(threshold,threshold$cust_cnt<104)

par(mfrow=c(1,2))
hist(threshold$cust_cnt,prob=1,breaks=200, main = "cust count impacted, all")
lines(density(threshold$cust_cnt,kernel="gaussian"),col=2)

hist(cust.cnt.less.98$cust_cnt,prob=1,breaks=100, main = "cust count impacted, 98% low volume")
lines(density(cust.cnt.less.98$cust_cnt,kernel="gaussian"),col=2)


summary(cust.cnt.less.98$cust_cnt)

densityplot(~ cust_cnt | div_nm, cust.cnt.less.98, pch= 20, plot.points=FALSE)

cust.cnt.threshold=ddply(cust.cnt.less.98, .(div_nm), function(x) round(max(quantile(x$cust_cnt,.75),summary(cust.cnt.less.98$cust_cnt)[3]),0))
colnames(cust.cnt.threshold)=c("div_nm","cust_cnt_threshold")


##################################################################
##################################################################
#ttl sales
##################################################################
##################################################################
densityplot(~ ttl_sales, threshold, pch= 20, plot.points=T)

a=quantile(threshold$ttl_sales, .95)
ttl_sales.less.98=subset(threshold,threshold$ttl_sales<a)

par(mfrow=c(1,2))
hist(threshold$ttl_sales,prob=1,breaks=200, main = "cust count impacted, all")
lines(density(threshold$ttl_sales,kernel="gaussian"),col=2)

hist(ttl_sales.less.98$ttl_sales,prob=1,breaks=100, main = "cust count impacted, 95% low volume")
lines(density(ttl_sales.less.98$ttl_sales,kernel="gaussian"),col=2)


summary(ttl_sales.less.98$ttl_sales)

densityplot(~ ttl_sales | div_nm, ttl_sales.less.98, pch= 20, plot.points=FALSE)

#ttl_sales.threshold=ddply(ttl_sales.less.98, .(div_nm), function(x) quantile(x$ttl_sales))

ttl_sales.threshold=ddply(ttl_sales.less.98, .(div_nm), function(x) round(max(quantile(x$ttl_sales,.75),summary(ttl_sales.less.98$ttl_sales)[4]),0))
colnames(ttl_sales.threshold)=c("div_nm","ttl_sales_threshold")


##################################################################
##################################################################
#qty_penetration
##################################################################
##################################################################

densityplot(~ qty_penetration, threshold, pch= 20, plot.points=T)
summary(threshold$qty_penetration)
a.qty_penetration=quantile(threshold$qty_penetration, .98)


qty_penetration.less.98=subset(threshold,threshold$qty_penetration<a.qty_penetration)

densityplot(~ qty_penetration, qty_penetration.less.98, pch= 20, plot.points=T)

par(mfrow=c(1,2))
hist(threshold$qty_penetration,prob=1,breaks=200, main = "qty_penetration impacted, all")
lines(density(threshold$qty_penetration,kernel="gaussian"),col=2)

hist(qty_penetration.less.98$qty_penetration,prob=1,breaks=100, main = "qty_penetration impacted, 98% low volume")
lines(density(qty_penetration.less.98$qty_penetration,kernel="gaussian"),col=2)


summary(qty_penetration.less.98$qty_penetration)

densityplot(~ qty_penetration | div_nm, qty_penetration.less.98, pch= 20, plot.points=FALSE)

#qty_penetration.threshold=ddply(qty_penetration.less.98, .(div_nm), function(x) quantile(x$qty_penetration))
#changed to median for qty penetration
qty_penetration.threshold=ddply(qty_penetration.less.98, .(div_nm), function(x) round(max(quantile(x$qty_penetration,.75),summary(qty_penetration.less.98$qty_penetration)[4]),5))
colnames(qty_penetration.threshold)=c("div_nm","qty_penetration_threshold")


##################################################################
##################################################################
#cust_penetration
##################################################################
##################################################################

densityplot(~ cust_penetration, threshold, pch= 20, plot.points=T)
summary(threshold$cust_penetration)
a.cust_penetration=quantile(threshold$cust_penetration, .98)


cust_penetration.less.98=subset(threshold,threshold$cust_penetration<a.cust_penetration)

densityplot(~ cust_penetration, cust_penetration.less.98, pch= 20, plot.points=T)

par(mfrow=c(1,2))
hist(threshold$cust_penetration,prob=1,breaks=200, main = "cust_penetration impacted, all")
lines(density(threshold$cust_penetration,kernel="gaussian"),col=2)

hist(cust_penetration.less.98$cust_penetration,prob=1,breaks=100, main = "cust_penetration impacted, 98% low volume")
lines(density(cust_penetration.less.98$cust_penetration,kernel="gaussian"),col=2)


summary(cust_penetration.less.98$cust_penetration)

densityplot(~ cust_penetration | div_nm, cust_penetration.less.98, pch= 20, plot.points=FALSE)

#cust_penetration.threshold=ddply(cust_penetration.less.98, .(div_nm), function(x) quantile(x$cust_penetration))
#changed to median for qty penetration
cust_penetration.threshold=ddply(cust_penetration.less.98, .(div_nm), function(x) round(max(quantile(x$cust_penetration,.75),summary(cust_penetration.less.98$cust_penetration)[3]),5))
colnames(cust_penetration.threshold)=c("div_nm","cust_penetration_threshold")



##################################################################
##################################################################
#weighted_elasticity
##################################################################
##################################################################
densityplot(~ weighted_elasticity| div_nm, threshold, pch= 20, plot.points=T)



densityplot(~ weighted_elasticity, threshold, pch= 23, plot.points=T, col=ifelse(threshold$div_nbr==2350,"red","light grey"))
abline(h=-3.44)
summary(threshold$weighted_elasticity)

a.weighted_elasticity=quantile(threshold$weighted_elasticity, .05,na.rm =T)


weighted_elasticity.less.98=subset(threshold,threshold$weighted_elasticity>a.weighted_elasticity)

densityplot(~ weighted_elasticity, weighted_elasticity.less.98, pch= 20, plot.points=T)

par(mfrow=c(1,2))
hist(threshold$weighted_elasticity,prob=1,breaks=200, main = "weighted_elasticity impacted, all")
lines(density(threshold$weighted_elasticity,kernel="gaussian"),col=2)

hist(weighted_elasticity.less.98$weighted_elasticity,prob=1,breaks=100, main = "weighted_elasticity impacted, 98% low volume")
lines(density(weighted_elasticity.less.98$weighted_elasticity,kernel="gaussian"),col=2)


summary(weighted_elasticity.less.98$weighted_elasticity)

densityplot(~ weighted_elasticity | div_nm, weighted_elasticity.less.98, pch= 20, plot.points=FALSE)

#weighted_elasticity.threshold=ddply(weighted_elasticity.less.98, .(div_nm), function(x) quantile(x$weighted_elasticity))
#elasticity -1 or division 25 percentile (75 fr absolute elasticity)
weighted_elasticity.threshold=ddply(weighted_elasticity.less.98, .(div_nm), function(x) round(min(quantile(x$weighted_elasticity,.25),-1.5),2))
colnames(weighted_elasticity.threshold)=c("div_nm","weighted_elasticity_threshold")



##################################################################
##################################################################
#psi_cnt
##################################################################
##################################################################

densityplot(~ psi_cnt, threshold, pch= 20, plot.points=T)
summary(threshold$psi_cnt)

a.psi_cnt=quantile(threshold$psi_cnt, .98,na.rm =T)


psi_cnt.less.98=subset(threshold,threshold$psi_cnt<10)

densityplot(~ psi_cnt, psi_cnt.less.98, pch= 20, plot.points=T)

par(mfrow=c(1,2))
hist(threshold$psi_cnt,prob=1,breaks=200, main = "psi_cnt impacted, all")
lines(density(threshold$psi_cnt,kernel="gaussian"),col=2)

hist(psi_cnt.less.98$psi_cnt,prob=1,breaks=100, main = "psi_cnt impacted, 98% low volume")
lines(density(psi_cnt.less.98$psi_cnt,kernel="gaussian"),col=2)


summary(psi_cnt.less.98$psi_cnt)

densityplot(~ psi_cnt | div_nm, psi_cnt.less.98, pch= 20, plot.points=FALSE)

psi_cnt.threshold=ddply(psi_cnt.less.98, .(div_nm), function(x) quantile(x$psi_cnt,.98))
#

colnames(psi_cnt.threshold)=c("div_nm","psi_cnt_threshold")



##################################################################
##################################################################
#psi_share_of_item_in_div
##################################################################
##################################################################

densityplot(~ psi_share_of_item_in_div, threshold, pch= 20, plot.points=T)
summary(threshold$psi_share_of_item_in_div)
a.psi_share_of_item_in_div=quantile(threshold$psi_share_of_item_in_div, .98,na.rm = T)


psi_share_of_item_in_div.less.98=subset(threshold,threshold$psi_share_of_item_in_div<a.psi_share_of_item_in_div)

densityplot(~ psi_share_of_item_in_div, psi_share_of_item_in_div.less.98, pch= 20, plot.points=T)

par(mfrow=c(1,2))
hist(threshold$psi_share_of_item_in_div,prob=1,breaks=200, main = "psi_share_of_item_in_div impacted, all")
lines(density(threshold$psi_share_of_item_in_div,kernel="gaussian"),col=2)

hist(psi_share_of_item_in_div.less.98$psi_share_of_item_in_div,prob=1,breaks=100, main = "psi_share_of_item_in_div impacted, 98% low volume")
lines(density(psi_share_of_item_in_div.less.98$psi_share_of_item_in_div,kernel="gaussian"),col=2)


summary(psi_share_of_item_in_div.less.98$psi_share_of_item_in_div)

densityplot(~ psi_share_of_item_in_div | div_nm, psi_share_of_item_in_div.less.98, pch= 20, plot.points=FALSE)

#psi_share_of_item_in_div.threshold=ddply(psi_share_of_item_in_div.less.98, .(div_nm), function(x) quantile(x$psi_share_of_item_in_div))
#changed to median for qty penetration
psi_share_of_item_in_div.threshold=ddply(psi_share_of_item_in_div.less.98, .(div_nm), function(x) round(max(quantile(x$psi_share_of_item_in_div,.75),summary(psi_share_of_item_in_div.less.98$psi_share_of_item_in_div)[4]),5))
colnames(psi_share_of_item_in_div.threshold)=c("div_nm","psi_share_of_item_in_div_threshold")



##################################################################
##################################################################
#lpc_chng_frequency
##################################################################
##################################################################

densityplot(~ lpc_chng_frequency, threshold, pch= 20, plot.points=T)
summary(threshold$lpc_chng_frequency)
a.lpc_chng_frequency=quantile(threshold$lpc_chng_frequency, .90,na.rm = T)


lpc_chng_frequency.less.98=subset(threshold,threshold$lpc_chng_frequency<a.lpc_chng_frequency+1)

densityplot(~ lpc_chng_frequency, lpc_chng_frequency.less.98, pch= 20, plot.points=T)

par(mfrow=c(1,2))
hist(threshold$lpc_chng_frequency,prob=1,breaks=200, main = "lpc_chng_frequency impacted, all")
lines(density(threshold$lpc_chng_frequency,kernel="gaussian"),col=2)

hist(lpc_chng_frequency.less.98$lpc_chng_frequency,prob=1,breaks=100, main = "lpc_chng_frequency impacted, 98% low volume")
lines(density(lpc_chng_frequency.less.98$lpc_chng_frequency,kernel="gaussian"),col=2)


summary(lpc_chng_frequency.less.98$lpc_chng_frequency)

densityplot(~ lpc_chng_frequency | div_nm, lpc_chng_frequency.less.98, pch= 20, plot.points=FALSE)

#lpc_chng_frequency.threshold=ddply(threshold, .(div_nm), function(x) quantile(x$lpc_chng_frequency,.75))
#changed to median for qty penetration
lpc_chng_frequency.threshold=ddply(threshold, .(div_nm), function(x) round(min(max(quantile(x$lpc_chng_frequency,.93),5),9),0))
colnames(lpc_chng_frequency.threshold)=c("div_nm","lpc_chng_frequency_threshold")



thresholds.by.market=cbind(qty.threshold,cust.cnt.threshold[,2],ttl_sales.threshold[,2],qty_penetration.threshold[,2],cust_penetration.threshold[,2])
colnames(thresholds.by.market)=c("div_nm","qty.threshold","cust.cnt.threshold","ttl_sales.threshold","qty_penetration.threshold","cust_penetration.threshold")
thresholds.by.market <- join( as.data.frame(thresholds.by.market),as.data.frame(weighted_elasticity.threshold), by = "div_nm")
thresholds.by.market <- join( as.data.frame(thresholds.by.market),as.data.frame(psi_cnt.threshold), by = "div_nm")
thresholds.by.market <- join( as.data.frame(thresholds.by.market),as.data.frame(psi_share_of_item_in_div.threshold), by = "div_nm")
thresholds.by.market=cbind(thresholds.by.market,lpc_chng_frequency_threshold=lpc_chng_frequency.threshold[,2])
dim(thresholds.by.market)
ls()
# imputation, replacing the NAs with 

write.csv(thresholds.by.market,"threshold_v3_20170127.csv",row.names = F)







