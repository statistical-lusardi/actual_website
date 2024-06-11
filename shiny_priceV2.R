
require(shiny)
require(tidyverse)
require(shinyWidgets)
require(plotly)
require(data.table)
require(ggplotlyExtra)
require(shinydashboard)
# Define UI for random distribution app ----
# for the latest version

app_data<-read.csv("static/files/app_data.csv")[,-1]%>%mutate(date=as.Date(date))
kva_sizes<-sort(unique(app_data$kva))
mfg_choices<-sort(unique(app_data$mfg))

body <- dashboardBody(
  
  fluidRow(
    valueBoxOutput("profit"), # average profit return summary over time frame
    valueBoxOutput("SuggestedPrice"),
    box(
      width = 4, background = "black",
      "A box with a solid black background"
    ),
    # box(
    #   title = "Suggested Price", width = 4, background = "light-blue"
    # ),
    # # valueBoxOutput("improveSales"),# Name of unit with least amount of profit  
    # valueBoxOutput("bestSales") # most sold unit
  ),
  fluidRow(
    box(title = "Box title", "Box content",
        plotlyOutput("plot"), width = 9),
    box(status = "warning", "Box content",width = 3)
  ),
  
  
  fluidRow(
    box(
      width = 4, background = "black",
      "A box with a solid black background"
    ),
    box(
      title = "Title 5", width = 4, background = "light-blue",
      "A box with a solid light-blue background"
    ),
    box(
      title = "Title 6",width = 4, background = "maroon",
      "A box with a solid maroon background"
    )
  )
)

# We'll save it in a variable `ui` so that we can preview it in the console
ui <- dashboardPage(
  dashboardHeader(title = "Pricing Tool"),
  dashboardSidebar(
    checkboxGroupInput("mfg_toggle", "Manufacturer Type:",
                       c("Vendor 1" = "hps",
                         "Vendor 2" = "mgm",
                         "Vendor 3" = "jeff",
                         "Vendor 4" = "egr"), selected = c(unique(app_data$mfg))
    )
    ,checkboxGroupInput("conductor", "Conductor Type:",
                        c("Aluminum" = "AL",
                          "Copper" = "CU"), selected = c(unique(app_data$conductor))
    ),
    
    dateRangeInput('date',
                   label = 'Date Sold input: yyyy-mm',
                   start = sort.POSIXlt(app_data$date)[1],
                   end = sort.POSIXlt(app_data$date,TRUE)[1]
    ),
    #,br() element to introduce extra vertical spacing ----
    br(),
    
    # Input: Slider for the number of observations to generate ----
    sliderTextInput(
      inputId = "kva", label = h4(tags$b("KVA size:")),
      choices = kva_sizes, selected = range(unique(app_data$kva)),
      grid = TRUE
    ),
    selectInput("p_volt", "Primary Voltage",
                c("All",unique(app_data$p_volt))
    ),
    selectInput("s_volt", "Secondary Voltage",
                c("All",unique(app_data$s_volt))
    ),
    selectInput("phase", "Phase Type",
                c("All",unique(app_data$phase))
    )
    
  ),
  body
)
server <- function(input, output) {
  
  # Filter the products, returning a data frame _f is to distinguish it is a filter
  filtered_data <- reactive({
    # Due to dplyr issue #318, we need temp variables for input values
    mfg_f <- input$mfg_toggle
    conductor_f <- input$conductor
    
    mindate_f <- input$date[1]
    maxdate_f <- input$date[2]
    
    minkva_f <- input$kva[1]
    maxkva_f <- input$kva[2]
    
    
    
    # Apply filters
    m <- app_data %>%
      filter(
        mfg  %in% mfg_f,
        conductor %in% conductor_f,
        date %between% as.Date(c(mindate_f,maxdate_f)),
        kva %between% as.numeric(c(minkva_f,maxkva_f)),
      ) 
    
    # Optional: filter by p_volt
    if (input$p_volt != "All") {
      p_volt_f <- input$p_volt
      m <- m %>% filter(p_volt %like% p_volt_f)
    }
    # Optional: filter by p_volt
    if (input$s_volt != "All") {
      s_volt_f <- input$s_volt
      m <- m %>% filter(s_volt %like% s_volt_f)
    }
    # Optional: filter by phase
    if (input$phase != "All") {
      phase_f <- input$phase
      m <- m %>% filter(phase %like% phase_f)
    }
    
    
    m <- as.data.frame(m)
    
    m
  })
  
  
  #full_log<-lm(log(cost)~as.factor(kva)+s_volt+conductor+mfg,data=train)
  
  # Reactive expression to generate the requested distribution ----
  # This is called whenever the inputs change. The output functions
  # defined below then use the value computed from this expression
  output$plot<-renderPlotly({
    fig <-filtered_data()%>%plot_ly(alpha = 0.6)
    fig <- fig %>% add_histogram(x~cost,name=c(filtered_data()$mfg))
    
    fig<-fig %>% layout(title = paste("Price Distribution"),
                        barmode="overlay",
                        xaxis = list(title = "Unit Cost in USD"))
    fig
    
    
  })
  
  # Generate a plot of the data ----
  # Also uses the inputs to build the plot label. Note that the
  # dependencies on the inputs and the data reactive expression are
  # both tracked, and all expressions are called in the sequence
  # implied by the dependency graph.
  output$profit <- renderValueBox({
    box1_data <- filtered_data()%>%
      summarise(Avg_Profit=mean(unit_sale)) 
    if(box1_data$Avg_Profit < quantile(app_data$unit_sale,0.5)){
      valueBox("Profit", "For this selection is less than 50th percentile of total sales", HTML(paste0(round(box1_data$Avg_Profit), sep="<br>")), icon = icon("exclamation-triangle"), color = "red")
    } else {
      valueBox("Profit"," For this selection is more than 50% of total sales", HTML(paste0(round(box1_data$Avg_Profit), sep="<br>")), icon = icon("exclamation-triangle"), color = "green")
    }
  })
  ?valueBox
  
  output$SuggestedPrice <- renderValueBox({
    valueBox("Price",HTML(paste0(c("For KVA sizes within the range of ",input$kva[1], "and",input$kva[2],
                           "it has historically cost around $",
                           filtered_data() %>%
                             na.omit()%>%
                             summarise(`Mean Cost`=round(mean(cost))),
                           " <br><br> To gain a 10% price increase you should sell it for $",
                           filtered_data()%>% 
                             na.omit()%>%
                             summarise(`Price Set`=round(1.10*mean(cost))))
                         ,  sep=" ")), icon = icon("bar-chart-o"), color = "light-blue")
    
  })
   
  # Generate a summary of the data ----
  output$summary <- renderText({
    paste("For KVA sizes within the range of ",input$kva[1], "and",input$kva[2],
          "it has historically cost \n",
          filtered_data() %>%
            na.omit()%>%
            summarise(`Mean Cost`=round(mean(cost)),2),
          ". \n To gain a 10% price increase you should sell it for",
          filtered_data()%>% 
            na.omit()%>%
            summarise(`Price Set`=round(1.10*mean(cost)),2)
    )
  })
  
  # Generate an HTML table view of the data ----
  output$table <- DT::renderDataTable({
    DT::datatable(filtered_data()%>%
                    na.omit()
                  ,extensions = 'Buttons', options = list(
                    dom = 'Bfrtip',
                    buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
                    columnDefs = list(list(targets = c(1, 2),visible=FALSE))# hides X column
                  )
    )
  })
  output$factors <- renderPlotly({
    ggplotly(ggplot(data=filtered_data()%>%
                      na.omit(),aes(x=kva,y=cost,color=mfg))+
               geom_point()+
               theme_classic()+
               facet_wrap(~mfg,nrow=4))
    
  })
  output$mfg_hist <- renderPlotly({ggplotly(
    app_data%>%
      select(date,mfg)%>%
      mutate(mfg_change=str_replace_all(mfg,c(hps="Vendor 1",
                                              jeff="Vendor 2", 
                                              mgm="Vendor 3",
                                              egr="Vendor 4")))%>%
      #select(-date)%>%
      group_by(date,mfg_change)%>%
      summarise(counts=n())%>%
      data.frame()%>%
      ggplot(aes(x=date,y=counts,color=mfg_change))+
      geom_line()+
      ggtitle("Number of Total Orders Over Time by Manufacturer") +
      xlab("Date") +
      ylab("Number of Orders")+
      theme_classic()+
      facet_wrap(~mfg_change,nrow=4)
  )
    
    
  })
}

# Preview the UI in the console
shinyApp(ui = ui, server = server)
