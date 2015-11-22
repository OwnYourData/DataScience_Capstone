# documentation
# http://www.yelp.com/dataset_challenge

library(jsonlite)
library(dplyr)
library(zoo)
library(ggplot2)
library(knitr)

# read data
#biz_file <- "yelp_academic_dataset_business.json"
#dat_biz <- stream_in(file(biz_file))
#rvw_file <- "yelp_academic_dataset_review.json"
#dat_rvw <- stream_in(file(rvw_file))
load("~/Documents/coursera/dataScience/Capstone/DataScience_Capstone/yelp_data.RData")
sport_cats <- c("Active Life", "Gyms", "Fitness & Instruction", "Pilates", 
                "Yoga", "Weight Loss Centers")
biz_sport <- dat_biz[grep(paste(sport_cats, collapse="|"), dat_biz$categories, 
                          ignore.case=TRUE), ]
sport_rvw <- merge(dat_rvw, biz_sport, by="business_id")
sport_rvw <- sport_rvw[as.POSIXct(sport_rvw$date) < as.POSIXct("2015-01-01") & 
                       as.POSIXct(sport_rvw$date) >= as.POSIXct("2006-01-01") ,]
sport_rvw[,"quarter"] <- factor(as.yearqtr(sport_rvw$date, format="%Y-%m-%d"))
agg_sport <- sport_rvw %>% group_by(quarter) %>% 
                summarise(rating=mean(stars.x), count=n())

biz_restaurant <- dat_biz[grep("restaurant", dat_biz$categories, 
                               ignore.case=TRUE),]
restaurant_rvw <- merge(dat_rvw, biz_restaurant, by="business_id")
restaurant_rvw <- restaurant_rvw[as.POSIXct(restaurant_rvw$date) < as.POSIXct("2015-01-01") & 
                                 as.POSIXct(restaurant_rvw$date) >= as.POSIXct("2006-01-01") ,]
restaurant_rvw[,"quarter"] <- factor(as.yearqtr(restaurant_rvw$date, format="%Y-%m-%d"))
agg_restaurant <- restaurant_rvw %>% group_by(quarter) %>% 
                        summarise(rating=mean(stars.x), count=n())

ggplot(data=agg_sport, aes(x=quarter, y=rating, group=1)) + 
        geom_line() + geom_point() + 
        theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggplot(data=agg_sport, aes(x=quarter, y=count, group=1)) + 
        geom_line() + geom_point() + 
        theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggplot(data=agg_restaurant, aes(x=quarter, y=rating, group=1)) + 
        geom_line() + geom_point() + 
        theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggplot(data=agg_restaurant, aes(x=quarter, y=count, group=1)) + 
        geom_line() + geom_point() + 
        theme(axis.text.x = element_text(angle = 90, hjust = 1))

t <- t.test(agg_sport$rating, agg_restaurant$rating, 
            paired = FALSE, var.equal = FALSE)
result <- data.frame("p-value" = t$p.value, 
                     "CI.low" = t$conf[1], "CI.high" = t$conf[2])
kable(result, format = 'pandoc')


t <- t.test(agg_sport$count, agg_restaurant$count, 
            paired = FALSE, var.equal = FALSE)
result <- data.frame("p-value" = t$p.value, 
                     "CI.low" = t$conf[1], "CI.high" = t$conf[2])
kable(result, format = 'pandoc')


