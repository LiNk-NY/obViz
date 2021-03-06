## Marcel Ramos - obViz Project Pre-processing R Code (R version 3.2.1)
## To load processed data, use load("filename.rda") ## make sure RDA file is in the working directory

library(maps)
library(dplyr)
library(foreign)
library(survey)
library(data.table)
data(state.fips)

list(brfss1 = read.xport("data/LLCP2011.XPT"), 
	brfss2 = read.xport("data/LLCP2012.XPT"), 
	brfss3 = read.xport("data/LLCP2013.XPT")) %>% 
lapply(seq_along(.), FUN = function(mydat, i) { 
	rename(mydat[[i]], IMPRACE = X_IMPRACE, AGEGROUP = X_AGE_G, AGE65YR = X_AGE65YR, 
		FIPS = X_STATE, PSU = X_PSU, STSTR = X_STSTR, LLCPWT = X_LLCPWT, BMI5CAT = X_BMI5CAT) %>%  
	mutate(IMPRACE = factor(IMPRACE, levels = seq(6), 
	labels=c("NH White", "NH Black", "NH Asian", "NH NA/AN", "Hispanic","NH Other")), 
	GENDER = factor(SEX, levels = c(1,2), labels = c("Male", "Female")), 
	AGEGROUP = factor(AGEGROUP, levels = seq(6), labels=c("18-24", "25-34", 
						"35-44", "45-54", "55-64", ">65")),
	BMI5CAT = factor(BMI5CAT, levels = seq(4), labels = c("Underweight", "Normal", "Overweight", "Obese")),
	OBESE = ifelse(BMI5CAT == "Obese", 1, 0), 
	ADLT = ifelse(AGE65YR == 1 | AGE65YR == 2, 1, 0),
	YEAR = c(2011:2013)[i])
 }, mydat = .) %>% lapply(., function(mysurv) { subset(mysurv, mysurv$ADLT == 1) } ) -> BRFSS 

mapsdf <- data.table(REGION = as.character(factor(state.fips$region, levels = 1:4, 
	labels = c("North East", "MidWest", "South", "West"))), 
	STATE = as.character(state.fips$polyname) %>% gsub(pattern = ":.*", "", .) %>%
	strsplit(" ") %>% 
	sapply(function(x) { paste(toupper(substr(x, 1,1)), substring(x, 2), sep = "", collapse = " ")}),
	ABB = as.character(state.fips$abb), 
	FIPS = state.fips$fips)
setkey(mapsdf, STATE)

# save(mapsdf, file = "data/states.Rda")

BRFSS <- lapply(BRFSS, FUN = function(mydat) {mydat <- right_join(mydat, mapsdf, by= "FIPS")
						 mydat}) 

# save(BRFSS, file = "data/surveydata.Rda")

options(survey.lonely.psu="remove")

DSGS <- lapply(BRFSS, function(mysurvey) {svydesign(id = ~PSU, strata = ~STSTR, weights = ~LLCPWT, data = mysurvey, nest = TRUE)} )
# save(DSGS, file = "data/svydesign.Rda")

DSUBS <- lapply(seq_along(DSGS), function(mysurv, mydseg, indx) { subset(mydseg[[indx]], mysurv[[indx]]$ADLT == 1 & mysurv[[indx]]$FIPS < 57)
						}, mysurv = BRFSS, mydseg = DSGS)

obesity <- lapply(DSUBS, FUN = function(svyobj, indx) { data.frame(svytable(~AGEGROUP+STATE+GENDER+IMPRACE+OBESE, svyobj,
        Ntotal = sum(weights(svyobj, "sampling"))), YEAR = c(2011:2013)[indx], stringsAsFactors = FALSE)}, indx = c(1:3)) %>% 
        rbindlist 

#Loading Census Population Proportions Data
props <- read.csv("data/Census2010prop.csv", header=TRUE, colClasses=c("character", "integer", "numeric"))

#Loading farmers market / fast food data
fmf <- read.csv("data/percap_fst_fm.csv")

# load("data/obesity.Rda")

obesity[, AGEPR := props$Percent[match(AGEGROUP, props$Age.Group)]] 
obesity[, STATE := as.character(STATE)] 
obesity[, AGEGROUP := as.character(AGEGROUP)]

setkey(obesity, STATE)
obesity <- obesity[mapsdf, allow.cartesian = TRUE]

obesity[, ASTDFQ:= Freq*AGEPR]


# save(obesity, file = "data/obesity.Rda")


