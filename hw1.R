library(tidyverse)
library(mosaic)
library(ggplot2)

#setup
abia = read.csv('abia.csv')
abia = mutate(abia, category = ifelse(Origin == "AUS", "Departure", "Arrival"))
abia$CRSTWindow_D = floor(abia$CRSDepTime/100)
abia$CRSTWindow_A = floor(abia$CRSArrTime/100)

airports = read.csv('airports.csv')
airports = subset(airports,!(airports$iata_code == ""))
airports = airports[-c(1:4,7:13,15:18)]

#cleaning the data: get rid of cancelled or diverted flights
abia_conf <- subset(abia,(abia$Cancelled == "0"))
abia_conf <- subset(abia_conf,!(abia_conf$Diverted == 1)) #should we keep?
abia_cancel <- subset(abia,(abia$Cancelled == "1"))

departures_fly <- subset(abia_conf, abia_conf$category == "Departure")
delay_summ = departures_fly %>%
  group_by(Dest)  %>%  # group the data points by model nae
  summarize(dly.mean = mean(DepDelay[(DepDelay>=0)], na.rm=TRUE))
delay_summ = left_join(delay_summ, airports, by = c("Dest" = "iata_code"))
delay_summ = mutate(delay_summ,AUSLat = 30.194500)
delay_summ = mutate(delay_summ,AUSLong = -97.66990)

p1= ggplot(delay_summ, aes(x=reorder(Dest, dly.mean), y=dly.mean)) +  labs(title = "Avrage departure delay per destination")+
  theme(plot.title = element_text(hjust = 0.5))+ geom_bar(stat='identity') + 
  coord_flip()+labs(x="Average departure delay(minutes)", y="Airline company")
p1

# Should I do the same graph for departures?
# ggplot(arrdel_summ, aes(x=reorder(Origin, dly.mean), y=dly.mean)) + 
#  geom_bar(stat='identity') + 
#  coord_flip()

# plot the summ for all the airline companies 
abia_CRSsumm_D_total <- abia_conf %>%
  group_by(CRSTWindow_D,category) %>%
  summarise(DepDelay_mean = mean(DepDelay))

abia_CRSsumm_A_total <- abia_conf %>%
  group_by(CRSTWindow_A,category) %>%
  summarise(ArrDelay_mean = mean(ArrDelay))

p2 = ggplot(data = subset(abia_CRSsumm_D_total,(abia_CRSsumm_D_total$category == "Departure")))+
  geom_bar(aes(x = CRSTWindow_D, y = DepDelay_mean),stat='identity',position='dodge')+
  labs(title = "Scheduled Time vs Average Departure Delay", x = "Scheduled Time", y = "Departure Delay")+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))
p2
p3 = ggplot(data = subset(abia_CRSsumm_A_total,(abia_CRSsumm_A_total$category == "Arrival")))+
  geom_bar(aes(x = CRSTWindow_A, y = ArrDelay_mean),stat='identity',position='dodge')+
  labs(title = "Scheduled Time vs Average Arrival Delay", x = "Scheduled Time", y = "Arrival Delay")+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))
p3

# Q2: When is the best month to fly to minimize delays?
# plot the summ for all the airline companies 
abia_summ_Month <- abia_conf %>%
  group_by(Month,category) %>%
  summarise(DepDelay_mean = mean(DepDelay),ArrDelay_mean = mean(ArrDelay))

p4 = ggplot(data = subset(abia_summ_Month,(abia_summ_Month$category == "Departure")))+
  geom_bar(aes(x = Month, y = DepDelay_mean),stat='identity',position='dodge')+
  labs(title = "Month vs Average Departure Delay", x = "Month", y = "Departure Delay")+
  theme_bw()+
  scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8,9,10,11,12),labels = c("1" = "Jan", "2" = "Feb", "3" = "Mar", "4" = "Apr", "5" = "May", "6" = "Jun", "7" = "Jul", "8" = "Aug", "9" = "Sep", "10" = "Oct", "11" = "Nov", "12" = "Dec"))+
  theme(plot.title = element_text(hjust = 0.5))
p4
p5 = ggplot(data = subset(abia_summ_Month,(abia_summ_Month$category == "Arrival")))+
  geom_bar(aes(x = Month, y = ArrDelay_mean),stat='identity',position='dodge')+
  labs(title = "Month vs Average Arrival Delay", x = "Month", y = "Arrival Delay")+
  scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8,9,10,11,12),labels = c("1" = "Jan", "2" = "Feb", "3" = "Mar", "4" = "Apr", "5" = "May", "6" = "Jun", "7" = "Jul", "8" = "Aug", "9" = "Sep", "10" = "Oct", "11" = "Nov", "12" = "Dec"))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))
p5



#Q4. Which airplane company makes delays most often?
#Delays by Airline company 
bwplot(DepDelay~UniqueCarrier, data=abia_conf)
p6= bwplot(DepDelay~UniqueCarrier, data=abia_conf, ylim=c(-20,60))
p6
# seems like EV is the worst
AvgDepDelay_Unique=abia_conf%>% group_by(UniqueCarrier) %>% summarize(AvgDepDelay= mean(DepDelay) )

mean.abia_conf<-as.data.frame(tapply(abia_conf$DepDelay, abia_conf$UniqueCarrier, mean))
mean.abia_conf$UniqueCarrier<-rownames(mean.abia_conf)
names(mean.abia_conf)<-c("DepDelay","UniqueCarrier")
mean.abia_conf
p7= ggplot(mean.abia_conf, aes(reorder(UniqueCarrier, -DepDelay, sum), DepDelay))+geom_bar(stat="identity")
p7

p8= bwplot(ArrDelay~UniqueCarrier, data=abia_conf, ylim=c(-20,60))
p8

mean.abia_conf<-as.data.frame(tapply(abia_conf$ArrDelay, abia_conf$UniqueCarrier, mean))
mean.abia_conf$UniqueCarrier<-rownames(mean.abia_conf)
names(mean.abia_conf)<-c("ArrDelay","UniqueCarrier")
mean.abia_conf
p9= ggplot(mean.abia_conf, aes(reorder(UniqueCarrier, -ArrDelay, sum), ArrDelay))+geom_bar(stat="identity")
p9
# seems like OH is the worst


# delay_summ$dly.mean[is.nan(delay_summ$dly.mean)]<-0.01
# delay_summ = subset(delay_summ,(delay_summ$dly.mean >= 1))
# delay_summ = arrange(delay_summ, dly.mean)

us_states <- map_data("state")
ggplot() +
  geom_polygon(data = us_states,  aes(long, lat, group = group), fill = "grey", col = "black") +
  geom_curve(data=delay_summ, aes(x = AUSLong, y = AUSLat, xend = longitude_deg, yend = latitude_deg, colour = dly.mean), size = 1, curvature = 0.1) + 
  geom_point(data=delay_summ, aes(x=longitude_deg, y=latitude_deg),color="red",size=3)
#  transition_states(
#    dly.mean,
#    transition_length = 0,
#    state_length = 1
#  )
