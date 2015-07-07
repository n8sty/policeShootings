#!/bin/sh
####################################
#
# download google spreadsheets with police shootings data
#
####################################

wget --no-check-certificate --content-disposition "https://docs.google.com/spreadsheets/d/1cEGQ3eAFKpFBVq1k2mZIy5mBPxC6nBTJHzuSWtZQSVw/export?format=csv" -O '/media/sf_general_assembly/final_project/ds.csv'
echo 'download of deadspin data finished'

wget --no-check-certificate --content-disposition "https://docs.google.com/spreadsheet/pub?key=0Aul9Ys3cd80fdHNuRG5VeWpfbnU4eVdIWTU3Q0xwSEE&single=TRUE&gid=0&output=csv" -O '/media/sf_general_assembly/final_project/fe.csv'
echo 'download of fatal encounters data finished'
