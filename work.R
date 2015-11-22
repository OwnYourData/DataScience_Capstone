# documentation
# http://www.yelp.com/dataset_challenge

library(jsonlite)
library(dplyr)
library(zoo)
library(ggplot2)

# read data
load("~/Documents/coursera/dataScience/Capstone/DataScience_Capstone/yelp_data.RData")
#setwd("~/Documents/coursera/dataScience/Capstone/yelp_dataset_challenge_academic_dataset")
#biz_file <- "yelp_academic_dataset_business.json"
#dat_biz <- stream_in(file(biz_file))
#usr_file <- "yelp_academic_dataset_user.json"
#dat_usr <- stream_in(file(usr_file))
#rvw_file <- "yelp_academic_dataset_review.json"
#dat_rvw <- stream_in(file(rvw_file))
#tip_file <- "yelp_academic_dataset_tip.json"
#dat_tip <- stream_in(file(tip_file))

# subset
#condition <- c("2e2e7WgqU1BnpxmQL5jbfw", "4bEjOyTaDG24SY5TxsaUNQ", "aGbjLWzcrnEx2ZmMCFm3EA", "sIyHTizqAiGu12XMLX3N3g", "zt1TpTuJ6y9n551sw9TaEg")
#dat_biz_sub <- dat_biz[dat_biz$business_id %in% condition,]
#dat_rvw_sub <- dat_rvw[dat_rvw$business_id %in% condition,]

# merge data
dat_biz20 <- dat_biz[dat_biz$review_count > 50, ]

biz <- merge(dat_rvw, dat_biz20, by="business_id")
biz[,"quarter"] <- factor(as.yearqtr(biz$date, format="%Y-%m-%d"))
#biz[,"month"] <- factor(as.yearmon(biz$date, format="%Y-%m-%d"))

# subset by country
biz_de <- biz[biz$longitude > 1,]
biz_uk <- biz[biz$longitude >= -5 & biz$longitude <= 1,]
biz_ca <- biz[biz$longitude < -5 & biz$latitude > 43.1,]
biz_us <- biz[biz$longitude < -5 & biz$latitude <= 43.1,]

# aggregate data
agg_de <- biz_de %>% group_by(quarter) %>% summarise(rating=mean(stars.x)) %>% mutate(country="Germany")
agg_uk <- biz_uk %>% group_by(quarter) %>% summarise(rating=mean(stars.x)) %>% mutate(country="UK")
agg_ca <- biz_ca %>% group_by(quarter) %>% summarise(rating=mean(stars.x)) %>% mutate(country="Canada")
agg_us <- biz_us %>% group_by(quarter) %>% summarise(rating=mean(stars.x)) %>% mutate(country="US")
agg_countries <- rbind(agg_de, agg_uk, agg_ca, agg_us)

ggplot(data=agg_countries, aes(x=quarter, y=rating, group=country, color=country)) + 
        geom_line() + geom_point() + 
        theme(axis.text.x = element_text(angle = 90, hjust = 1))


# subset by category
biz_restaurant    <- biz[grep("restaurant", biz$categories, ignore.case=TRUE),]
biz_food          <- biz[grep("food", biz$categories, ignore.case=TRUE),]
biz_nightlife     <- biz[grep("nightlife", biz$categories, ignore.case=TRUE),]
biz_entertainment <- biz[grep("entertainment", biz$categories, ignore.case=TRUE),]
biz_active_life   <- biz[grep("active life", biz$categories, ignore.case=TRUE),]
biz_beauty        <- biz[grep("beauty", biz$categories, ignore.case=TRUE),]
# aggregate data
agg_restaurant    <- biz_restaurant    %>% group_by(quarter) %>% summarise(rating=mean(stars.x)) %>% mutate(category="Restaurant")
agg_food          <- biz_food          %>% group_by(quarter) %>% summarise(rating=mean(stars.x)) %>% mutate(category="Food")
agg_nightlife     <- biz_nightlife     %>% group_by(quarter) %>% summarise(rating=mean(stars.x)) %>% mutate(category="Nightlife")
agg_entertainment <- biz_entertainment %>% group_by(quarter) %>% summarise(rating=mean(stars.x)) %>% mutate(category="Entertainment")
agg_active_life   <- biz_active_life   %>% group_by(quarter) %>% summarise(rating=mean(stars.x)) %>% mutate(category="Active Life")
agg_beauty        <- biz_beauty        %>% group_by(quarter) %>% summarise(rating=mean(stars.x)) %>% mutate(category="Beauty")
agg_categories <- rbind(agg_restaurant, agg_food, agg_nightlife, agg_entertainment, agg_active_life, agg_beauty)
#plot
ggplot(data=agg_categories, aes(x=quarter, y=rating, group=category, color=category)) + 
        geom_line() + geom_point() + 
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) 

# group data
#biz_summary <- biz %>% group_by(business_id, quarter) %>% summarise(rating=mean(stars.x))
#ggplot(biz_summary,aes(x=factor(quarter), y=rating, group=factor(business_id), color=factor(business_id))) + geom_line() + geom_point()


# list of all categories
cats<-unique(unlist(unique(biz$categories)))
sport_cats <- c("Active Life", "Gyms", "Fitness & Instruction", "Pilates", "Yoga", "Climbing", "Hiking", "Sports Clubs", "Weight Loss Centers", "Skating Rinks", "Rafting/Kayaking", "Outdoor Gear")
