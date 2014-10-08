police shootings
===============

Violence committed by American police officers against civilians, justified or not, has recently been in the news. Different groups have begun or have been trying to compile data sets that attempt to understand these acts of violence. This work is an extension of those individuals' much needed efforts.

*You can view the current pre-alpha version of the police shootings dashboard here:*   https://n8sty.shinyapps.io/policeShootingsDashboard/

*The tools currently in use are:*  
R, otherwise known as GNU S: http://www.r-project.org/  
Shiny Server by the RStudio team: http://www.rstudio.com/products/shiny/shiny-server/

*The data sets currently in use or identified to be integrated are:*  
Deadspin's Kyle Wagner (http://regressing.deadspin.com/were-compiling-every-police-involved-shooting-in-americ-1624180387) is crowdsourcing police shooting information from 2011-2013 here: http://goo.gl/23Xy4O  
Fatal Encounters has been maintaining their own crowdsourced police shooting data here: http://www.fatalencounters.org/spreadsheets/  
The Gun Violence Archive is attempting to track all instances of gun violence in the United States: www.gunviolencearchive.org  

*Some future ideas for enhancements:*  

1. Incorporating the Fatal Encounters data set.
2. Changing the leaflet points to something less intrusive than the current design, possibly a simple dot.
3. Making the links workable inside the leaflet pop-ups. **DONE 10/6/2014**
4. Shifting the data source to a cloud hosted system that I set up on AWS that scrapes the Deadspin and Fatal Encounters data, attempts to merge them, and then provides single data set to source data from.
5. Identifying the days that have been completed. Meaning, some days in the Deadspin data set have been exhausted in terms of researching the police shootings that occured on those days. I want to understand the amount of unknown unknowns, ie: how many days in our time frame still exist where there could be more police shootings.
6. Add in some sort of dashboard that provides a quick synthesis of statistics I deem important to police shootings.
Please suggest more, or make your own and submit them.
7. Make the shiny app a single file per the 0.10.2 release of shiny: http://blog.rstudio.org/2014/10/02/shiny-0-10-2/
8. Account for duplicates in entries to the Deadspin and Fatal Encounters data sets.
