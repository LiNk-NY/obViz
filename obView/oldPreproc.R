## Preproc Version 2 (SLOW)
setwd("~/Documents/GitHub/obViz/obView/")
library(maps)
library(dplyr)
library(foreign)
library(survey)
library(data.table)
data(state.fips)

mapsdf <- data.table(REGION = factor(state.fips$region, levels = 1:4, 
                    labels = c("North East", "MidWest", "South", "West")), 
                     STATE = as.character(state.fips$polyname) %>% gsub(pattern = ":.*", "", .) %>%
                       strsplit(" ") %>% sapply(function(x) { paste(toupper(substr(x, 1,1)), substring(x, 2), sep = "", collapse = " ")}),
                     ABB = as.character(state.fips$abb), 
                     FIPS = state.fips$fips)
setkey(mapsdf, STATE)

brfss1 <- read.xport("data/LLCP2011.XPT")
brfss1 <- rename(brfss1, IMPRACE = X_IMPRACE, AGEGROUP = X_AGE_G, AGE65YR = X_AGE65YR, FIPS = X_STATE, PSU = X_PSU, STSTR = X_STSTR, LLCPWT = X_LLCPWT, BMI5CAT = X_BMI5CAT)
brfss1 <- select(brfss1, IMPRACE, SEX, AGEGROUP, AGE65YR, FIPS, PSU, STSTR, LLCPWT, BMI5CAT)
brfss1$IMPRACE <- with(brfss1, factor(IMPRACE, levels = seq(6), labels=c("NH White", "NH Black", "NH Asian", "NH NA/AN", "Hispanic","NH Other")))
brfss1$GENDER <- with(brfss1, factor(SEX, levels = c(1,2), labels = c("Male", "Female")))
brfss1$AGEGROUP <- with(brfss1, factor(AGEGROUP, levels = seq(6), labels=c("18-24", "25-34", "35-44", "45-54", "55-64", ">65")))
brfss1$BMI5CAT <- with(brfss1, factor(BMI5CAT, levels = seq(4), labels = c("Underweight", "Normal", "Overweight", "Obese")))
brfss1$OBESE <- with(brfss1, ifelseBRFSS[, AGEPR := props$Percent[match(AGEGROUP, props$Age.Group)]] (BMI5CAT == "Obese", 1, 0))
brfss1$ADLT <- with(brfss1, ifelse(AGE65YR == 1 | AGE65YR == 2, 1, 0))
brfss1$YEAR <- rep(2011, nrow(brfss1))
brfss1 <- filter(brfss1, brfss1$ADLT == 1)
brfss1 <- merge(brfss1, mapsdf, by = "FIPS")


brfss2 <- read.xport("data/LLCP2012.XPT")
brfss2 <- rename(brfss2, IMPRACE = X_IMPRACE, AGEGROUP = X_AGE_G, AGE65YR = X_AGE65YR, FIPS = X_STATE, PSU = X_PSU, STSTR = X_STSTR, LLCPWT = X_LLCPWT, BMI5CAT = X_BMI5CAT)
brfss2 <- select(brfss2, IMPRACE, SEX, AGEGROUP, AGE65YR, FIPS, PSU, STSTR, LLCPWT, BMI5CAT)
brfss2$IMPRACE <- with(brfss2, factor(IMPRACE, levels = seq(6), labels=c("NH White", "NH Black", "NH Asian", "NH NA/AN", "Hispanic","NH Other")))
brfss2$GENDER <- with(brfss2, factor(SEX, levels = c(1,2), labels = c("Male", "Female")))
brfss2$AGEGROUP <- with(brfss2, factor(AGEGROUP, levels = seq(6), labels=c("18-24", "25-34", "35-44", "45-54", "55-64", ">65")))
brfss2$BMI5CAT <- with(brfss2, factor(BMI5CAT, levels = seq(4), labels = c("Underweight", "Normal", "Overweight", "Obese")))
brfss2$OBESE <- with(brfss2, ifelse(BMI5CAT == "Obese", 1, 0))
brfss2$ADLT <- with(brfss2, ifelse(AGE65YR == 1 | AGE65YR == 2, 1, 0))
brfss2$YEAR <- rep(2012, nrow(brfss2))
brfss2 <- filter(brfss2, brfss2$ADLT == 1)
brfss2 <- merge(brfss2, mapsdf, by = "FIPS")

brfss3 <- read.xport("data/LLCP2013.XPT")
brfss3 <- rename(brfss3, IMPRACE = X_IMPRACE, AGEGROUP = X_AGE_G, AGE65YR = X_AGE65YR, FIPS = X_STATE, PSU = X_PSU, STSTR = X_STSTR, LLCPWT = X_LLCPWT, BMI5CAT = X_BMI5CAT)
brfss3 <- select(brfss3, IMPRACE, SEX, AGEGROUP, AGE65YR, FIPS, PSU, STSTR, LLCPWT, BMI5CAT)
brfss3$IMPRACE <- with(brfss3, factor(IMPRACE, levels = seq(6), labels=c("NH White", "NH Black", "NH Asian", "NH NA/AN", "Hispanic","NH Other")))
brfss3$GENDER <- with(brfss3, factor(SEX, levels = c(1,2), labels = c("Male", "Female")))
brfss3$AGEGROUP <- with(brfss3, factor(AGEGROUP, levels = seq(6), labels=c("18-24", "25-34", "35-44", "45-54", "55-64", ">65")))
brfss3$BMI5CAT <- with(brfss3, factor(BMI5CAT, levels = seq(4), labels = c("Underweight", "Normal", "Overweight", "Obese")))
brfss3$OBESE <- with(brfss3, ifelse(BMI5CAT == "Obese", 1, 0))
brfss3$ADLT <- with(brfss3, ifelse(AGE65YR == 1 | AGE65YR == 2, 1, 0))
brfss3$YEAR <- rep(2013, nrow(brfss3))
brfss3 <- filter(brfss3, brfss3$ADLT == 1)
brfss3 <- merge(brfss3, mapsdf, by = "FIPS")

svd1 <- svydesign(id = ~PSU, strata = ~STSTR, weights = ~LLCPWT, data = brfss1, nest = TRUE)
sub1 <- subset(svd1, brfss1$FIPS < 57)
svd2 <- svydesign(id = ~PSU, strata = ~STSTR, weights = ~LLCPWT, data = brfss2, nest = TRUE)
sub2 <- subset(svd2, brfss2$FIPS < 57)
svd3 <- svydesign(id = ~PSU, strata = ~STSTR, weights = ~LLCPWT, data = brfss3, nest = TRUE)
sub3 <- subset(svd3, brfss3$FIPS < 57)

df1 <- as.data.frame(svytable(~AGEGROUP+STATE+GENDER+IMPRACE+OBESE, sub1, Ntotal=sum(weights(sub1, "sampling"))))
df1$YEAR <- rep(2011, nrow(df1))
df2 <- as.data.frame(svytable(~AGEGROUP+STATE+GENDER+IMPRACE+OBESE, sub2, Ntotal=sum(weights(sub2, "sampling"))))
df2$YEAR <- rep(2012, nrow(df2))
df3 <- as.data.frame(svytable(~AGEGROUP+STATE+GENDER+IMPRACE+OBESE, sub3, Ntotal=sum(weights(sub2, "sampling"))))
df3$YEAR <- rep(2013, nrow(df3))


BRFSS <- rbindlist(list(df1, df2, df3))
BRFSS[, AGEGROUP := as.character(AGEGROUP)]

props <- read.csv("data/Census2010prop.csv", header=TRUE, colClasses=c("character", "integer", "numeric"))

# fmf <- read.csv("data/percap_fst_fm.csv")

BRFSS[, AGEPR := props$Percent[match(AGEGROUP, props$Age.Group)]] 

setkey(BRFSS, STATE)

BRFSS <- BRFSS[ mapsdf, allow.cartesian = TRUE]

BRFSS[, ASTDFQ:= Freq*AGEPR]
BRFSS[, STATE := as.character(STATE)]

levels(BRFSS$REGION)[2] <- "Midwest"
BRFSS$AGEGROUP <- factor(BRFSS$AGEGROUP, levels = c("18-24", "25-34", "35-44", "45-54", "55-64", ">65"), ordered = TRUE)

save(BRFSS, file = "data/fullsurvey.Rda")
