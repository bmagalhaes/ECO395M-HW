library(tidyverse)
library(mosaic)
library(ggplot2)

abia = read.csv('abia.csv')

# Surpplus?
#ABIA2 = abia
#USairports <- subset(airports,(airports$iso_country =="US"))
#ABIA2$TWindow = floor(ABIA2$DepTime/100)



# Q1: What is the best time of day to fly to minimize delays?
# Calculate delaying departure time:
abia = mutate(abia, category = ifelse(Origin == "AUS", "Departure", "Arrival"))
abia$CRSTWindow_D = floor(abia$CRSDepTime/100)
abia$CRSTWindow_A = floor(abia$CRSArrTime/100)
abia_conf <- subset(abia,(abia$Cancelled == "0"))
abia_conf <- subset(abia_conf,!(abia_conf$Diverted == 1)) #should we keep?
abia_cancel <- subset(abia,(abia$Cancelled == "1"))

# plot the summ for all the airline companies 
abia_CRSsumm_D_total <- abia_conf %>%
  group_by(CRSTWindow_D,category) %>%
  summarise(DepDelay_mean = mean(DepDelay))

abia_CRSsumm_A_total <- abia_conf %>%
  group_by(CRSTWindow_A,category) %>%
  summarise(ArrDelay_mean = mean(ArrDelay))

p1 = ggplot(data = subset(abia_CRSsumm_D_total,(abia_CRSsumm_D_total$category == "Departure")))+
  geom_bar(aes(x = CRSTWindow_D, y = DepDelay_mean),stat='identity',position='dodge')+
  labs(title = "Scheduled Time vs Average Departure Delay", x = "Scheduled Time", y = "Departure Delay")+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))
p1
p2 = ggplot(data = subset(abia_CRSsumm_A_total,(abia_CRSsumm_A_total$category == "Arrival")))+
  geom_bar(aes(x = CRSTWindow_A, y = ArrDelay_mean),stat='identity',position='dodge')+
  labs(title = "Scheduled Time vs Average Arrival Delay", x = "Scheduled Time", y = "Arrival Delay")+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))
p2

# Q2: When is the best month to fly to minimize delays?
# plot the summ for all the airline companies 
abia_summ_Month <- abia_conf %>%
  group_by(Month,category) %>%
  summarise(DepDelay_mean = mean(DepDelay),ArrDelay_mean = mean(ArrDelay))

p3 = ggplot(data = subset(abia_summ_Month,(abia_summ_Month$category == "Departure")))+
  geom_bar(aes(x = Month, y = DepDelay_mean),stat='identity',position='dodge')+
  labs(title = "Month vs Average Departure Delay", x = "Month", y = "Departure Delay")+
  theme_bw()+
  scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8,9,10,11,12),labels = c("1" = "Jan", "2" = "Feb", "3" = "Mar", "4" = "Apr", "5" = "May", "6" = "Jun", "7" = "Jul", "8" = "Aug", "9" = "Sep", "10" = "Oct", "11" = "Nov", "12" = "Dec"))+
  theme(plot.title = element_text(hjust = 0.5))
p3
p4 = ggplot(data = subset(abia_summ_Month,(abia_summ_Month$category == "Arrival")))+
  geom_bar(aes(x = Month, y = ArrDelay_mean),stat='identity',position='dodge')+
  labs(title = "Month vs Average Arrival Delay", x = "Month", y = "Arrival Delay")+
  scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8,9,10,11,12),labels = c("1" = "Jan", "2" = "Feb", "3" = "Mar", "4" = "Apr", "5" = "May", "6" = "Jun", "7" = "Jul", "8" = "Aug", "9" = "Sep", "10" = "Oct", "11" = "Nov", "12" = "Dec"))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))
p4
mean(DepDelay~Month, data=abia_conf)
#Q3. We can check it by days(Mon~Sun)


p5 = ggplot(abia, aes(Month))+geom_bar()
p5
count(abia$Month==12)
# How can I split it into Arrival vs Departure? Why are there errors whenever I try to put in JAN to DEC?
# Why are there so many delays in December although there are not much traffic?


#Q4. Which airplane company makes delays most often?
#Delays by Aircraft companies 
favstats(DepDelay~UniqueCarrier, data=abia_conf)
bwplot(DepDelay~UniqueCarrier, data=abia_conf)
p6= bwplot(DepDelay~UniqueCarrier, data=abia_conf, ylim=c(-20,30))
p6
# seems like EV is the worst
AvgDepDelay_Unique=abia_conf%>% group_by(UniqueCarrier) %>% summarize(AvgDepDelay= mean(DepDelay) )

mean.abia_conf<-as.data.frame(tapply(abia_conf$DepDelay, abia_conf$UniqueCarrier, mean))
mean.abia_conf$UniqueCarrier<-rownames(mean.abia_conf)
names(mean.abia_conf)<-c("DepDelay","UniqueCarrier")
mean.abia_conf
ggplot(mean.abia_conf, aes(UniqueCarrier, DepDelay))+geom_bar(stat="identity")
ggplot(mean.abia_conf, aes(reorder(UniqueCarrier, -DepDelay, sum), DepDelay))+geom_bar(stat="identity")


favstats(ArrDelay~UniqueCarrier, data=abia_conf)
p7= bwplot(ArrDelay~UniqueCarrier, data=abia_conf, ylim=c(-20,30))
p7

# seems like OH is the worst

# Do they stay longer at the airport when they arrive earlier than scheduled time?
plot(TaxiIn~ArrDelay, data=abia, xlim=c(-100,0))

EarlyArrival= subset(abia, abia$ArrDelay<0)
EarlyArrival
lm(TaxiIn~EarlyArrival, data=abia)
# How can I show it? Anyway my assumption was wrong!

arrivals <- subset(abia_conf, abia_conf$category == "Arrival")
departures <- subset(abia_conf, abia_conf$category == "Departure")

arrdel_summ = arrivals %>%
  group_by(Origin)  %>%  # group the data points by model nae
  summarize(dly.mean = mean(ArrDelay[ArrDelay>=0], na.rm=TRUE))  # calculate a mean for each model

# reorder the x labels
ggplot(arrdel_summ, aes(x=reorder(Origin, dly.mean), y=dly.mean)) + 
  geom_bar(stat='identity') + 
  coord_flip()

dep_summ = departures %>%
  group_by(Dest)  %>%  # group the data points by model nae
  summarize(dly.mean = mean(DepDelay, na.rm=TRUE))  # calculate a mean for each model

# reorder the x labels
ggplot(dep_summ, aes(x=reorder(Dest, dly.mean), y=dly.mean)) + 
  geom_bar(stat='identity') + 
  coord_flip()

delay_summ$dly.mean[is.nan(delay_summ$dly.mean)]<-0.01


us_states <- map_data("state")
delay_summ = subset(delay_summ,(delay_summ$dly.mean >= 1))
delay_summ = arrange(delay_summ, dly.mean)
delay_summ <- mutate(delay_summ, n = rownames(delay_summ))

ggplot() +
  geom_polygon(data = us_states,  aes(long, lat, group = group), fill = "grey", col = "black") +
  geom_curve(data=delay_summ, aes(x = AUSLong, y = AUSLat, xend = longitude_deg, yend = latitude_deg), col = n, size = 1, curvature = 0.1) + 
  geom_point(data=delay_summ, aes(x=longitude_deg, y=latitude_deg),color="red",size=3)
