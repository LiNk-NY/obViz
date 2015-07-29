library(maps)
data(state.fips)

shinyServer(
 function(input, output {

table_wide <- reactive({
	re_tab <- subset(obesity, YEAR == input$year & GENDER %in% input$sex & AGEGROUP %in% input$agegroup & IMPRACE %in% input$race)
	re_tab <- droplevels(re_tab)
	re_tab[, OPREV := sum(ASTDFQ, na.rm = TRUE), 
	       ABB := state.fips$abb[match(tolower(re_tab$State), state.fips$polyname)], 
	       
	       by = STATE] 
	group_by(re_tab, OBESE + STATE) %>% summarize(STDFQ = sum(value))	 
})
}
)
        )

