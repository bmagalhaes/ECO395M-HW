library(tidyverse)
library(mosaic)
library(ggplot2)

#setup
abia = read.csv('abia.csv')
abia = mutate(abia, category = ifelse(Origin == "AUS", "Departure", "Arrival"))
abia$CRSTWindow_D = floor(abia$CRSDepTime/100)
abia$CRSTWindow_A = floor(abia$CRSArrTime/100)

us_states <- map_data("state")
airports = read.csv('airports.csv')
airports = subset(airports,!(airports$iata_code == ""))
airports = airports[-c(1:4,7:13,15:18)]

abia_conf <- subset(abia,(abia$Cancelled == "0"))
abia_general <- abia_conf
abia_cancel <- subset(abia,(abia$Cancelled == "1"))

departures_fly <- subset(abia_conf, abia_conf$category == "Departure")
Arrivals_fly <- subset(abia_conf, abia_conf$category == "Arrival")
departures_fly = mutate(departures_fly, delay = ifelse(DepDelay <= 0, 0, DepDelay))
delay_summ = departures_fly %>%
group_by(Dest)  %>% 
summarize(dly.mean = mean(delay), na.rm=TRUE)

delay_summ = left_join(delay_summ, airports, by = c("Dest" = "iata_code"))
delay_summ = mutate(delay_summ,AUSLat = 30.194500)
delay_summ = mutate(delay_summ,AUSLong = -97.66990)

cancel_rate = abia %>%
  group_by(UniqueCarrier)  %>%  # group the data points by model nae
  summarize(cancelrate = length(which(Cancelled == 1)) / (length(which(Cancelled == 1)) + length(which(Cancelled == 0))))
cancel_rate = mutate(cancel_rate,cancelrate = cancelrate*100)

ggplot(cancel_rate, aes(x=reorder(UniqueCarrier, cancelrate), y=cancelrate)) + 
  geom_bar(stat='identity') + 
  coord_flip() +
  labs(title = 'Cancellation Rate per Carrier', x = "Carrier", y = "Cancelation Rate (%)")+
  scale_size_area()+
  theme(plot.title = element_text(hjust = 0.5))

ggplot(delay_summ, aes(x=reorder(Dest, dly.mean), y=dly.mean)) + 
  geom_bar(stat='identity') + 
  coord_flip() +
  labs(title = 'Average Departure Delay per Destination', x = "Airport", y = "Minutes") +
  scale_size_area()+
  theme(plot.title = element_text(hjust = 0.5))

abia_conf = mutate(abia_conf, DepDelay = ifelse(DepDelay <= 0, 0, DepDelay))

abia_CRSsumm_D_total <- departures_fly %>%
  group_by(CRSTWindow_D) %>%
  summarise(DepDelay_mean = mean(delay))

abia_CRSsumm_A_total <- Arrivals_fly %>%
  group_by(CRSTWindow_A) %>%
  summarise(ArrDelay_mean = mean(ArrDelay, na.rm=TRUE))

ggplot(data = abia_CRSsumm_D_total)+
geom_bar(aes(x = CRSTWindow_D, y = DepDelay_mean),stat='identity',position='dodge')+
labs(title = "Scheduled Time vs Average Departure Delay", x = "Scheduled Time", y = "Departure Delay")+
theme_bw()+
theme(plot.title = element_text(hjust = 0.5), panel.grid.major = element_blank())

ggplot(data = abia_CRSsumm_A_total)+
geom_bar(aes(x = CRSTWindow_A, y = ArrDelay_mean),stat='identity',position='dodge')+
labs(title = "Scheduled Time vs Average Arrival Delay", x = "Scheduled Time", y = "Arrival Delay")+
theme_bw()+
theme(plot.title = element_text(hjust = 0.5), panel.grid.major = element_blank())


# Q2: When is the best month to fly to minimize delays?
# plot the summ for all the airline companies 
abia_summ_Month <- abia_conf %>%
  group_by(Month,category) %>%
  summarise(DepDelay_mean = mean(DepDelay),ArrDelay_mean = mean(ArrDelay, na.rm=TRUE))
 
ggplot(data = subset(abia_summ_Month,(abia_summ_Month$category == "Departure")))+
geom_bar(aes(x = Month, y = DepDelay_mean),stat='identity',position='dodge')+
labs(title = "Month vs Average Departure Delay", x = "Month", y = "Departure Delay")+
theme_bw()+
scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8,9,10,11,12),labels = c("1" = "Jan", "2" = "Feb", "3" = "Mar", "4" = "Apr", "5" = "May", "6" = "Jun", "7" = "Jul", "8" = "Aug", "9" = "Sep", "10" = "Oct", "11" = "Nov", "12" = "Dec"))+
theme(plot.title = element_text(hjust = 0.5))

ggplot(data = subset(abia_summ_Month,(abia_summ_Month$category == "Arrival")))+
geom_bar(aes(x = Month, y = ArrDelay_mean),stat='identity',position='dodge')+
labs(title = "Month vs Average Arrival Delay", x = "Month", y = "Arrival Delay")+
scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8,9,10,11,12),labels = c("1" = "Jan", "2" = "Feb", "3" = "Mar", "4" = "Apr", "5" = "May", "6" = "Jun", "7" = "Jul", "8" = "Aug", "9" = "Sep", "10" = "Oct", "11" = "Nov", "12" = "Dec"))+
theme_bw()+
theme(plot.title = element_text(hjust = 0.5))


bwplot(DepDelay~UniqueCarrier, data=abia_general, ylim=c(-20,30))

# seems like EV is the worst
AvgDepDelay_Unique=abia_conf%>% group_by(UniqueCarrier) %>% summarize(AvgDepDelay= mean(DepDelay) )

mean.abia_conf<-as.data.frame(tapply(abia_conf$DepDelay, abia_conf$UniqueCarrier, mean))
mean.abia_conf$UniqueCarrier<-rownames(mean.abia_conf)
names(mean.abia_conf)<-c("DepDelay","UniqueCarrier")
ggplot(mean.abia_conf, aes(reorder(UniqueCarrier, -DepDelay, sum), DepDelay))+geom_bar(stat="identity") +
labs(title = "Carrier vs Average Departure Delay", x = "Carrier", y = "Minutes")+
theme_bw()+
theme(plot.title = element_text(hjust = 0.5))

bwplot(ArrDelay~UniqueCarrier, data=abia_conf, ylim=c(-60,70), xlab="Airlines", ylab="Arrival delays(min)", main="Arrival delays by Airlines")
AvgDepDelay_Unique=abia_conf%>% group_by(UniqueCarrier) %>% summarize(AvgArrDelay= mean(ArrDelay) )

mean.abia_conf<-as.data.frame(tapply(abia_conf$ArrDelay, abia_conf$UniqueCarrier, mean, na.rm=TRUE))
mean.abia_conf$UniqueCarrier<-rownames(mean.abia_conf)
names(mean.abia_conf)<-c("ArrDelay","UniqueCarrier")
ggplot(mean.abia_conf, aes(reorder(UniqueCarrier, -ArrDelay, sum), ArrDelay))+geom_bar(stat="identity") +
  labs(title = "Carrier vs Average Arrival Delay", x = "Carrier", y = "Minutes")+  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

#####################

dest_traf = departures_fly %>%
  group_by(Dest)  %>% 
  summarize(number = n())
dest_traf = left_join(dest_traf, airports, by = c("Dest" = "iata_code"))
dest_traf = mutate(dest_traf,AUSLat = 30.194500)
dest_traf = mutate(dest_traf,AUSLong = -97.66990)
summary(dest_traf$number)
number_quant = subset(dest_traf,dest_traf$number >= 939)

ggplot() +
theme(plot.title = element_text(hjust = 0.5), panel.grid.major = element_blank(),  panel.grid.minor = element_blank())+
geom_polygon(data = us_states,  aes(long, lat, group = group), fill = "grey", col = "black") +
geom_curve(data=number_quant, aes(x = AUSLong, y = AUSLat, xend = longitude_deg, yend = latitude_deg, colour = number), size = 1, curvature = 0.1) + 
geom_point(data=number_quant, aes(x=longitude_deg, y=latitude_deg),color="red",size=1) +
scale_colour_gradient2(low="blue", high="red")+
labs(title = 'Number of Flights per Destination 3rd Quantile', x = "", y = "")+
theme(plot.title = element_text(hjust = 0.5))+
scale_x_discrete()+
scale_y_discrete()

summary(delay_summ$dly.mean)
delay_quant = subset(delay_summ,delay_summ$dly.mean >= 12.771)
ggplot() +
  theme(plot.title = element_text(hjust = 0.5), panel.grid.major = element_blank(),  panel.grid.minor = element_blank())+
  geom_polygon(data = us_states,  aes(long, lat, group = group), fill = "grey", col = "black") +
  geom_curve(data=delay_quant, aes(x = AUSLong, y = AUSLat, xend = longitude_deg, yend = latitude_deg, colour = dly.mean), size = 1, curvature = 0.1) + 
  geom_point(data=delay_quant, aes(x=longitude_deg, y=latitude_deg),color="red",size=1) +
  scale_colour_gradient2(low="blue", high="red")+
  labs(title = 'Average Departure Delay per Destination - 3rd Quantile', x = "", y = "")+
  theme(plot.title = element_text(hjust = 0.5))+
  scale_x_discrete()+
  scale_y_discrete()
