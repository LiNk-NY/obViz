function(){
        tabPanel("About",
                 HTML('<div style="float: right; margin: 5px 5px 5px 10px;"> 
                     <iframe width="560" height="315" frameborder="0" allowfullscreen></iframe> 
                      </div>'),
                 h4("About Us"),
                 p("This a risk visualization web application developed using the 'shiny' package in R version 3.2.1. It was proudly developed by Dr. Levi Waldron, Jasmine Abdelnabi, Marcel Ramos, Finn Schubert, 
                   Henry Wang, Cody Boppert, Kezhen Fei, Ragheed Al-dulaimi and Dr. Ashish Joshi."),
                 hr(),
                 h4("Methods"),
                 p("Data were obtained from the Behavioral Risk Factor Surveillance System (BRFSS) survey for the years 2011, 2012, and 2013. 
                    All survey analyses were done using R and the 'survey' package by Thomas Lumley. After adjusting for the survey design, participants who were older than 18 years of age and within the 50 states or District of Columbia were considered for the visualization."
                   ),
                 h4("Data Sources"),
                 p("1) Centers for Disease Control and Prevention (CDC). ", a("Behavioral Risk Factor Surveillance System Survey Data.", href="http://www.cdc.gov/brfss/"), 
                "Atlanta, Georgia: U.S. Department of Health and Human Services, Centers for Disease Control and Prevention, [2011, 2012, 2013]"),
                 p("2) U.S. Census Bureau, ", a("2010 Population Census.",  href="http://www.census.gov/2010census/")), 
                 p("3) Ian Spiro, Phil Dhingra. ", a("Fast Food Locations Geographic Distribution Project.", href="http://www.fastfoodmaps.com/"), "[2007]"),
                 p("4) Department of Agriculture, Agricultural Marketing Service. ", a("USDA Farmer Market Geographic Data.", href="http://www.ams.usda.gov/farmersmarkets")),
                    
         value="about"
                 )
}
