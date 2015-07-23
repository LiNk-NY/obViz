shinyServer(
	function(input, output {
table_wide <- reactive({
	select(obdata, YEAR == input$year & SEX %in% input$sex & AGEG %in% input$race) %>% 
	group_by(OUTCOME, STATE) %>% summarize(STDFQ = sum(value))	 
})
}
)

