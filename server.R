source("preproc.r")

shinyServer(
	function(input, output {
table_wide <- reactive({
	re_tab <- subset(obesity, YEAR == input$year & SEX %in% input$sex & AGEGROUPS %in% input$agegroup & IMPRACE %in% input$race)
	re_tab <- droplevels(re_tab)
	obesity[, OPREV := sum(ASTDFQ, na.rm = TRUE), by = STATE] 
	group_by(OUTCOME, STATE) %>% summarize(STDFQ = sum(value))	 
})
}
)

