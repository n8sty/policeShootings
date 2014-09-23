require(shiny)
require(rCharts)
require(rMaps)
require(ggvis)
require(devtools)

shinyUI(fluidPage(

  titlePanel("Occurances of police shooting civilians in the United States of America",
             windowTitle = 'Police Shootings Dashboard'),

  sidebarLayout(
    sidebarPanel(width = 3,
                 
                 selectInput(inputId = 'data',
                             label = 'Choose the police shootings data set to use',
                             choices = c(
                               #'Fatal Encounters',
                               'Deadspin'
                               #'Both'
                               ),
                             selected = 'Deadspin',
                             multiple = FALSE),
                 
                 dateRangeInput(inputId = 'date',
                                label = 'Date range to look at:',
                                start = '2011-01-01',
                                end = NULL,
                                min = NULL,
                                max = as.Date(Sys.time()),
                                format = "yyyy-mm-dd",
                                startview = 'year',
                                weekstart = 0,
                                language = "en",
                                separator = " to "),
                 
                 textInput(inputId = 'state',
                           label = 'Zoom to city (eg: Brooklyn, NY)',
                           value = '')
                 ),
    
    mainPanel(
      #textOutput("text1"),
      showOutput('myChart2', 'leaflet'),
      p('Consider this a pre-alpha.'),
      p('The above is a geographic mapping of police shootings of civilians in the United States over the period defined at left. When viewing the data, note that placement of geo tags on the map are not precise because exact location information is not available in the data set. Furthermore, the location data (particularly discrepencies between county and city) have not been cleaned so some points are misplaced. To avoid overplotting of points, the latitude and longitude are jiggered randomly, which may sometimes result in a geo tag being placed in a location that makes little sense, like a pond. Click on a point for more information about a given shooting, and follow the links provided. To adjust the number of points displayed use the date range input provided to the left. Data for the police shootings comes from this Google Sheet: '),
      a('http://goo.gl/zUdwkg'),
      p('which is managed by Deadspin\'s Kyle Wagner. Geographic (latitude and longitude) information comes from Sujee Maniyam\'s blog:'),
      a('http://sujee.net/tech/articles/geocoded/')
    )
  )
))
