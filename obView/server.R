load("data/fullsurvey.Rda")
load("data/states.Rda")

perc <- function(col2, col3){
proportion <- round(col3/(col2 + col3), 3)
proportion*100
}

fmf <- fread("data/percap_fst_fm.csv")
fmf <- data.table(fmf)
setkey(fmf, fips)

us <- map('state', fill = TRUE, plot = FALSE)

mypal <- colorQuantile("Reds", NULL, n = 9)


shinyServer(
 function(input, output) {

table_wide <- reactive({
	re_tab <- subset(BRFSS, YEAR == input$year & GENDER %in% input$sex & AGEGROUP %in% input$agegroup & IMPRACE %in% input$race)
	re_tab <- droplevels(re_tab)
	re_tab <- group_by(re_tab, OBESE, STATE) %>% summarize(Prevalence = sum(ASTDFQ)) %>% spread(OBESE, Prevalence) %>% dplyr::rename(NO = `0`, YES = `1`)
	re_tab <- cbind(re_tab, Prevalence = perc(re_tab[[2]], re_tab[[3]]))
	setkey(re_tab, STATE)  
	re_tab <- re_tab[mapsdf, allow.cartesian = TRUE]
	us$data <- re_tab
	return(us)
	})

state_popup <- reactive({ 
  mydaat <- table_wide()
	stooltip <- paste0("<strong> Year: </strong>", input$year,
	"<br><strong> State: </strong>", mydaat$data$STATE, 
	"<br><strong> Prevalence proportion: </strong>", mydaat$data$Prevalence)
})   

    output$obemap <- renderLeaflet({
	mydaat <- table_wide()
	pops <- state_popup()
	UMap <- leaflet(data = mydaat) %>% 
		addTiles() %>% addPolygons(fillColor = ~mypal(mydaat$data$Prevalence), 
			fillOpacity = 0.5, 
			color = "#BDBDC3", 
			weight = 1, 
			popup = pops)
	return(UMap)
    })
    
    output$farmers <- renderGvis({
      mydaat <- table_wide() 
      mydaat <- mydaat$data
      setkey(mydaat, FIPS)
      cast1 <- mydaat[fmf, allow.cartesian = TRUE]
      # cast1 <- merge(mydaat$data, fmf, by.x = "FIPS", by.y = "fips")
      # colnames(cast1)[grep("capfarmkt", colnames(cast1))] <- "MarketsPerPop"
      setnames(cast1, "percapfarmkt", "MarketPerPop")
      cast1[, MarketPerPop := round(MarketPerPop, 2)]
      # cast1$MarketsPerPop <- round(cast1$MarketsPerPop, 2)
      cast1 <- cbind(cast1, Population.Proportion=round((cast1$popfm/sum(cast1$popfm))*100,2))
      
      return(gvisBubbleChart(cast1, idvar="ABB", xvar="Prevalence", yvar="MarketPerPop", 
                             sizevar="Population.Proportion",colorvar="REGION",
                             options=list(width=800,
                                          height=400,
                                          chartArea="{left:35,top:35,width:'75%',height:'80%'}",
                                          title="Farmers' Markets*", 
                                          titleTextStyle="{fontSize:18}",
                                          vAxis ="{title:'Farmers\\' Markets per 100,000 population', 
                                                                viewWindowMode:'explicit', viewWindow:{min:0}}",
                                          hAxis="{title:'Proportion of State Residents with Met. Synd.',
                                                                viewWindowMode:'explicit', viewWindow:{min:0}}"   )))
    })
    
    output$fastfood <- renderGvis({
      mydaat <- table_wide() 
      mydaat <- mydaat$data
      setkey(mydaat, FIPS)
      cast1 <- mydaat[fmf, allow.cartesian = TRUE]
      # cast1 <- merge(mydaat$data, fmf, by.x = "FIPS", by.y = "fips")
      # colnames(cast1)[grep("capfstfd", colnames(cast1))] <- "FastFoodPerPop"
      setnames(cast1, "percapfstfd", "FastFoodPerPop")
      cast1[, FastFoodPerPop := round(FastFoodPerPop, 2)]
      # cast1$FastFoodPerPop <- round(cast1$FastFoodPerPop, 2)
      cast1 <- cbind(cast1, Population.Proportion=round((cast1$popff/sum(cast1$popff))*100,2))
      
      return(gvisBubbleChart(cast1, idvar="ABB", xvar="Prevalence", yvar="FastFoodPerPop", 
                             sizevar="Population.Proportion",colorvar="REGION",
                             options=list(width=800,
                                          height=400,
                                          chartArea="{left:35,top:35,width:'75%',height:'80%'}",
                                          title="Fast Food Restaurants*",
                                          titleTextStyle="{fontSize:18}",
                                          vAxis ="{title:'Fast Food Restaurants per 100,000 population', 
                                                                viewWindowMode:'explicit', viewWindow:{min:0}}",
                                          hAxis="{title:'Proportion of State Residents with Met. Synd.',
                                                                viewWindowMode:'explicit', viewWindow:{min:0}}"   )))
    })
   
    side_tab <-  reactive({
      side <- base::subset(BRFSS, YEAR == input$year & STATE == input$state)
      side <- dcast(aggregate(ASTDFQ~OBESE+AGEGROUP+IMPRACE, side, sum), AGEGROUP+IMPRACE~OBESE, value.var="ASTDFQ", na.action=na.omit)
      grptot <- aggregate(`1`+`0`~AGEGROUP, side, sum)
      colnames(grptot)[2] <- "TotFQ"
      side$GTOT <- grptot$TotFQ[match(side$AGEGROUP, grptot$AGEGROUP)]
      side$Prop <- side$`1`/side$GTOT
      return(side)
    })
    
    side_tab2 <-  reactive({
      side <- base::subset(BRFSS, YEAR == input$year & STATE == input$state)
      side <- dcast(aggregate(ASTDFQ~OBESE+AGEGROUP+GENDER, side, sum), AGEGROUP+GENDER~OBESE, value.var="ASTDFQ", na.action=na.omit)
      grptot <- aggregate(`1`+`0`~AGEGROUP, side, sum)
      colnames(grptot)[2] <- "TotFQ"
      side$GTOT <- grptot$TotFQ[match(side$AGEGROUP, grptot$AGEGROUP)]
      side$Prop <- side$`1`/side$GTOT
      return(side)
    })
    
    output$stateview <- renderPlot({
      
      a <- ggplot(side_tab(), aes(x=AGEGROUP, y=Prop, fill=IMPRACE)) + geom_bar(stat="Identity") + 
        scale_fill_brewer(type="qual", palette="Accent", guide=guide_legend(nrow=1, title=NULL))
      k <- a + ylab("Prevalence Proportion (%)") + xlab("Age Group") + labs(fill="Racial/Ethnic \n Group") + 
        theme(legend.position="bottom", text=element_text(size=11, family="sans"))
      
      b <- ggplot(side_tab2(), aes(x=AGEGROUP, y=Prop, fill=GENDER)) + geom_bar(stat="identity") + 
        scale_fill_manual(values=c("#B3CDE3","#FBB4AE"), guide=guide_legend(title=NULL))
      j <- b + ylab("Prevalence Proportion (%)") + xlab("Age Group") + labs(fill="Gender") + 
        theme(legend.position="bottom", text=element_text(size=11,family="sans"))
      grid.arrange(k,j, ncol=2)
      
    }) 
     
 }
)

