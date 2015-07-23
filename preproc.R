## Marcel Ramos - obViz Project Pre-processing R Code (R version 3.2.1)
## To load processed data, use load("filename.rda") ## make sure RDA file is in the working directory

library(maps)
library(dplyr)
library(foreign)
library(survey)
library(data.table)

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
	OBESE = ifelse(BMI5CAT == 4, 1, 0), 
	ADLT = ifelse(AGE65YR == 1 | AGE65YR == 2, 1, 0),
	YEAR = c(2011:2013)[i])
 }, mydat = .) -> BRFSS 

mapsdf <- data.frame(REGION = factor(state.fips$region, levels = 1:4, 
	labels = c("North East", "MidWest", "South", "West")), 
	STATE = as.character(state.fips$polyname) %>% gsub(pattern = ":.*", "", .) %>%
	strsplit(" ") %>% 
	sapply(function(x) { paste(toupper(substr(x, 1,1)), substring(x, 2), sep = "", collapse = " ")}),
	ABB = state.fips$abb, 
	FIPS = state.fips$fips, stringsAsFactors = FALSE)

BRFSS <- lapply(BRFSS, FUN = function(mydat) {mydat <- right_join(mydat, mapsdf, by= "FIPS")
						 mydat}) 
options(survey.lonely.psu="remove")

DSGS <- lapply(seq_along(BRFSS), function(mysurvey, i) {svydesign(id = ~PSU, strata = ~STSTR, weights = ~LLCPWT, data = mysurvey[[i]], nest = TRUE)}, mysurvey = BRFSS)

lapply(seq_along(DSGS), FUN = function(svyobj, i) { data.frame(svytable(~AGEGROUP+STATE+GENDER+IMPRACE+OBESE, svyobj[[i]], 
Ntotal = sum(weights(svyobj[[i]], "sampling"))), YEAR = c(2011:2013)[i], stringsAsFactors = FALSE)}, svyobj = DSGS) %>% 
	rbindlist -> obesity 

#Loading Census Population Proportions Data
ASprops <- read.csv("data/Census2010prop.csv", header=TRUE, colClasses=c("factor", "integer", "numeric"))

#Loading farmers market / fast food data
fmf <- read.csv("data/percap_fst_fm.csv")

setkey(obesity, AGEGROUP)
obesity <- obesity[ASprops[, c("Age.Group","Percent")]]
setnames(obesity, "Percent", "AGEPR")
obesity[, ASTDFQ:= Freq*AGEPR]

save(obesity, file = "data/obesity.rda")


