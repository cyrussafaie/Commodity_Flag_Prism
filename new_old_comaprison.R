ls()
remove(old.data)

# old_data <- read.csv("com_flag_20161121.csv")
# dim(old_data)
new_data=read.csv("final_dataJan31_1745.csv")
dim(new_data)
names(new_data)


library(sqldf)

divs=sqldf('select div_nm, count(*) as proposed 
           from new_data 
           where com_flg_final_final="Y" 
           and div_nm not in ("CHARLOTTE","MILWAUKEE-WAUKESHA") 
           group by div_nm ')

divs[order(divs$proposed),]


current_flag=sqldf('select div_nm, count(*) as proposed 
           from new_data 
           where cmdty_ind="Y" 
           and div_nm not in ("CHARLOTTE","MILWAUKEE-WAUKESHA") 
           group by div_nm ')

current_flag[order(current_flag$proposed),]

table(new_data$cmdty_ind,new_data$com_flg_final_final)

names(new_data)
dim(new_data)

# New_old_merge =merge(new_data,old_data[,c("prod_nbr","div_nbr","com_flg")],by = c("prod_nbr","div_nbr"), all.x = TRUE )
# 
# dim(New_old_merge)
# names(New_old_merge)
# table(New=New_old_merge$com_flg_final_final,old=New_old_merge$com_flg.y)
# 

# mismatches=subset(New_old_merge, New_old_merge$com_flg_final_final=="Y" & New_old_merge$com_flg.y=="N")
# dim(mismatches)
# write.csv(mismatches,"mismatches.csv",row.names = F)


names(new_data)
unique(new_data$div_nm)
head(new_data)
this=c("X","a96.","a97.","com_flg","com_flg_adj","prposd_com_flg","current_com_ind","proposed_share","current_share","com_flg_final")

new_data_summarized=new_data[,!names(new_data) %in% this]

dim(new_data_summarized)
names(new_data_summarized)

colnames(new_data_summarized)[68]<- "Proposed_Commodity_Flag"
colnames(new_data_summarized)[15]<- "Current_Commodity_Flag"
colnames(new_data_summarized)[65]<- "div_Threshold_98perc"
names(new_data_summarized)

new_data_summarized_reordered= new_data_summarized[,c(1:67,15,68)]
dim(new_data_summarized_reordered)
names(new_data_summarized_reordered)

#blanks removed
#write.csv(new_data_summarized_reordered,"new_data_summarized_reordered20170202_1531.csv",row.names = F)
new_data_summarized_reordered=read.csv("new_data_summarized_reordered20170202_1531.csv")
unique(new_data_summarized_reordered$Proposed_Commodity_Flag)

#replace(new_data_summarized_reordered$Current_Commodity_Flag.1, new_data_summarized_reordered$Current_Commodity_Flag.1 == " ", NA)
#Flag_Change= ifelse(as.factor(new_data_summarized_reordered$Current_Commodity_Flag.1)[1:10]!=as.factor(new_data_summarized_reordered$Proposed_Commodity_Flag)[1:10],TRUE,FALSE)
#length(levels(new_data_summarized_reordered$Current_Commodity_Flag.1)) == length(levels(factor2))

#levels(new_data_summarized_reordered$Current_Commodity_Flag.1)
#library(plyr)
#new_data_summarized_reordered$Current_Commodity_Flag.1=revalue(new_data_summarized_reordered$Current_Commodity_Flag.1, c("  "="N"))

### removing the blank cells
#new_data_summarized_reordered=subset(new_data_summarized_reordered, new_data_summarized_reordered$Current_Commodity_Flag.1=="N" | new_data_summarized_reordered$Proposed_Commodity_Flag=="Y")
table(new_data_summarized_reordered$Current_Commodity_Flag.1,new_data_summarized_reordered$Proposed_Commodity_Flag)

#write.csv(new_data_summarized_reordered,"new_data_summarized_reordered.csv",row.names = F)

#new_data_summarized_reordered2=read.csv("new_data_summarized_reordered.csv")


#remove(new_data_summarized_reordered2)
Flag_Change= ifelse(new_data_summarized_reordered$Current_Commodity_Flag.1!=new_data_summarized_reordered$Proposed_Commodity_Flag,TRUE,FALSE)
head(Flag_Change)

new_data_summarized_reordered_final=cbind(new_data_summarized_reordered,Flag_Change)
dim(new_data_summarized_reordered_final)
#head(new_data_summarized_reordered_final[,68:70],300)


table(new_data_summarized_reordered_final$Current_Commodity_Flag.1,new_data_summarized_reordered_final$Proposed_Commodity_Flag)

dim(new_data_summarized_reordered_final)



###########subset of data with mimatch
slsl=subset(new_data_summarized_reordered_final,new_data_summarized_reordered_final$Flag_Change==TRUE)
dim(slsl)

write.csv(slsl,"flag_differnces_allMarkets.csv", row.names = F)
# this is the final data
head(slsl)

paste("Today is", date())

# now let's get the VPP list in 
vpp=read.csv("Vendor_VPP_Upload_20170126.csv", header = F)

dim(vpp)
colnames(vpp)=c("prod_nbr","VPP_available?")
head(vpp)
dim(slsl)


new_slsl=merge(slsl,vpp,by="prod_nbr",all.x = TRUE)
table(new_slsl$`VPP_available?`,new_slsl$Proposed_Commodity_Flag)
names(new_slsl)
#new_slsl=new_slsl[,-71]
#colnames(new_slsl)[71]<- "VPP_available?"
head(new_slsl)
dim(new_slsl)

#fill list of missmatches
write.csv(new_slsl,"fullMismatches_20170202_1700.csv",row.names = F)

#Boston data
boston_data_20170201=subset(new_data_summarized,new_data_summarized$div_nm=="BOSTON")
dim(boston_data_20170201)


unique(boston_data_20170201$Current_Commodity_Flag)
unique(boston_data_20170201$Proposed_Commodity_Flag)

write.csv(boston_data_20170201,"boston_data_20170201.csv",row.names = F)

# metro NY data:
metroNY_data_20170201=subset(new_data_summarized,new_data_summarized$div_nm=="METRO NEW YORK")
dim(metroNY_data_20170201)

write.csv(metroNY_data_20170201,"metroNY_data_20170201.csv",row.names = F)

