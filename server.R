# define required libraries
require(shiny)
#require(mosaic) # devtools::install_github("rpruim/mosaic")
require(RCurl)
require(plyr)


# define a function to load data from google sheets
# the following is an expansion of the fetchGoogle function from the dev version of the mosaic package
# see http://goo.gl/hNUsdc
loadGoogSheet <- function(URL, key = NULL,
                          stringsAsFactors = default.stringsAsFactors(), na.strings = "NA",
                          colClasses = NA, blank.lines.skip = TRUE
                          ) 
{
  
  #.try_require("RCurl")
  if (missing(URL) & !is.null(key)) 
    URL = paste("https://docs.google.com/spreadsheet/pub?key=", 
                key, "&single=TRUE&gid=0", "&output=csv", sep = "")
  s = RCurl::getURLContent(URL)
  foo = textConnection(s)
  b = read.csv(foo,
               stringsAsFactors = stringsAsFactors,
               na.strings = na.strings,
               colClasses = colClasses,
               blank.lines.skip = blank.lines.skip
  )
  close(foo)
  return(b)
  
}

# define the capWords function used to capitalize the worlds in a string
capWords <- function(s, strict = FALSE) 
  {
  cap <- function(s) paste(toupper(substring(s, 1, 1)),
                           {s <- substring(s, 2); if(strict) tolower(s) else s},
                           sep = "", collapse = " " )
  sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
}

# ensure proper certs for loading a google doc
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))

# load the police shootings data which is sourced from this google document http://goo.gl/zUdwkg
# the google doc referenced in the line above comes from http://regressing.deadspin.com/were-compiling-every-police-involved-shooting-in-americ-1624180387
# note that this function will grow to include multiple data sources, next: http://www.fatalencounters.org/spreadsheets/
# eventually, I hope to include all forms of gun violence, not just those that are police generated, to do this I hope to incorporate data from http://gunviolencearchive.org/
url <- 'https://docs.google.com/spreadsheets/d/1cEGQ3eAFKpFBVq1k2mZIy5mBPxC6nBTJHzuSWtZQSVw/export?usp=sharing&format=csv'
shootings <- loadGoogSheet(url, stringsAsFactors = FALSE,
                           na.strings = c('', 'Unknown', 'unknown'),
                           colClasses = c('character', # timestampe
                                          'character', # date searched
                                          'factor', # state
                                          'character', # county
                                          'character', # city
                                          'character', # agency name
                                          'character', # victim's name
                                          'numeric', # victim's age
                                          'factor', # victim's gender
                                          'factor', # race
                                          'factor', # hispanic
                                          'numeric', # shots fired
                                          'factor', # hit or killed
                                          'factor', # armed or unarmed
                                          'character', # weapon
                                          'character', # summary
                                          'character', # source link
                                          'character', # name of officer
                                          'character', # shootings
                                          'numeric', # was the shooting justified
                                          'NULL', # receive updates
                                          'NULL', # name of submitter
                                          'NULL', # email address
                                          'NULL', # twitter
                                          'character', # date of incident
                                          'NULL', # results page number
                                          'factor' # x - (changed below) date completion
                                          ),
                           blank.lines.skip = TRUE
                           )
names(shootings) <- tolower(gsub('[.]', '', names(shootings)))
names(shootings) <- gsub('x', 'datecompletion', names(shootings), fixed = TRUE)
# convert dates to correct class
shootings$datesearched <- as.Date(shootings$datesearched, format = '%m/%d/%Y')
shootings$dateofincident <- as.Date(shootings$dateofincident, format = '%m/%d/%Y')
shootings$timestamp <- as.POSIXct(shootings$timestamp, format = '%m/%d/%Y %H:%M:%S')
# remove entries with dates that are greater than today's date
shootings <- shootings[!shootings$datesearched > Sys.Date(), ]
# remove shootings with NA in the datesearched column
shootings <- shootings[!is.na(shootings$datesearched), ]

# download geo code data from http://sujee.net/tech/articles/geocoded/
temp <- tempfile()
download.file("http://sujee.net/tech/articles/geocoded/cities.csv.zip", temp, mode = 'wb')
unzip(temp, "cities.csv")
cities <- read.table("cities.csv", sep = ',', header = FALSE)
names(cities) <- c('city', 'state', 'latitude', 'longitude')
cities$city <- tolower(cities$city)
cities$state <- factor(cities$state)

# integrate geo code data with shootings data set
shootings <- shootings[shootings$city != '', ]
shootings <- shootings[shootings$state != '', ]
shootings$state2 <- factor(substring(shootings$state, 1, 2))
shootings$city <- tolower(shootings$city)

shootings <- merge(shootings,
                   cities,
                   by.x = c('state2', 'city'),
                   by.y = c('state', 'city'),
                   all.x = TRUE
                   )

shinyServer(function(input, output) {

  # define a reactive subset of the shootings data based on dates input by user
  shootings_subset <- reactive({
    shootings[shootings$datesearched >= input$date[1] & shootings$datesearched <= input$date[2], ]
    })

  # define a reactive location based on user input of a city and state in the form of <city, state>
  location <- reactive({
    if(input$state != '') {
      state <- unlist(strsplit(input$state, c(', ', ',')))[2]
      city <- unlist(strsplit(input$state, c(', ', ',')))[1]
      latitude <- cities[tolower(cities$state) == tolower(state) & tolower(cities$city) == tolower(city),][['latitude']]
      longitude <- cities[tolower(cities$state) == tolower(state) & tolower(cities$city) == tolower(city),][['longitude']]
      zoom <- 10
      } else {
      latitude <- 33.65711
      longitude <- -85.81558
      zoom <- 3
    }
    list(latitude, longitude, zoom)
  })
  
  # create the geo map of shootings
  output$myChart2 <- renderMap({
    x <- subset(shootings_subset(), longitude != 'NA' & latitude != 'NA')
    lat <- location()[1]
    lon <- location()[2]
    z <- location()[3]
    map <- Leaflet$new()
    map$setView(c(lat, lon), zoom = z)
    for (i in (1:nrow(x))) {
      map$marker(
        c(jitter(x$latitude[i], factor = .01), jitter(x$longitude[i], factor = .01)),
        bindPopup = paste0('Victim: ',
                           x$victimname[i],
                           '<br>',
                           'Date: ',
                           x$datesearched[i],
                           '<br>',
                           'Location: ',
                           capWords(x$city[i]),
                           ', ',
                           substring(x$state[i], 1, 2),
                           '<br>',
                           'Officer(s): ',
                           x$nameofofficerorofficers[i],
                           '<br>',
                           'Source: ',
                           paste0('<a href="',
                                  x$sourcelink[i],
                                  '">',
                                  x$sourcelink[i],
                                  '</a>'
                                  )
        )
      )
    }
    map
  })
  
})
