#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
use this function to download a google sheet as a csv
the url or path input variable must be the correct csv file path
google drive paths are not always similar and depend on the owner of the file
'''

url_fe = 'https://docs.google.com/spreadsheet/pub?key=0Aul9Ys3cd80fdHNuRG5VeWpfbnU4eVdIWTU3Q0xwSEE&single=TRUE&gid=0&output=csv'
url_ds = 'https://docs.google.com/spreadsheets/d/1cEGQ3eAFKpFBVq1k2mZIy5mBPxC6nBTJHzuSWtZQSVw/export?format=csv'

log_file = '/media/sf_general_assembly/final_project/activity.log'

#con = None  # sqlite database connection name
# clear initially - to be set later

def log_activity(log_input, log_file):
    # http://goo.gl/jvE7Fm
    # http://goo.gl/IIee2
    import logging
    from time import strftime            

    timestamp = strftime("%Y-%m-%d-%H:%M:%S")

    # will create or add to the log file
    logging.basicConfig(filename = log_file, level = logging.DEBUG)

    logging.info(f'{timestamp} {log_input}')


def load_google_shootings_csv(url, log_str, log_file, num_cols_check):
    from pandas import read_csv

    df = read_csv(url)

    if (df.shape[0] >= 0 and df.shape[1] == num_cols_check):
        outcome = f'{log_str} success'
    else:
        outcome = f'{log_str} failure'

    log_activity(outcome, log_file)

    return(df)

# def action_success_failure(logical_test):
'''
replace the error checking within functions with a function that performs error checking
don't use eval!
'''

df_fe = load_google_shootings_csv(url_fe, 'load fatal encounters into pandas df', log_file, 23)
df_ds = load_google_shootings_csv(url_ds, 'load deadspin into pandas df', log_file, 27)

# create a database or connect to existing database
def create_connect_db(db_name, db_schema, log_file):
    from os import path
    from sqlite3 import connect
    
    db_exists = path.exists(db_name)
    
    with connect(db_name) as con:
        if not db_exists:
            log_activity('database does not exist, creating database', log_file)
            with open(db_schema, 'rt') as f:
                schema = f.read()
            con.executescript(schema)
            
        else:
            log_activity('database already exists', log_file)
            
    con.close()
    

create_connect_db('police_shootings_db.sqlite', 'police_shootings_db_schema.sql', 'activity.log')


tbl_to_update = df_fe
from sqlite3 import connect
con = connect('police_shootings_db.sqlite')
tbl_to_update.to_sql(con = con, if_exists='replace', name = 'raw_fatal_encountersYAY')


def update_db(db_name, tbl_to_update, df, if_exists = 'replace', log_file):
    from sqlite3 import connect
    from pandas import to_sql    

    con = lite.connect(db_name)
    tbl_to_update.to_sql(name = tbl_to_update, con = con, flavor = 'sqlite',  if_exists = if_exists, chunksize = 50)
    log_activity(f'{tbl_to_update} updated using method {if_exists}', log_file)

    con.close()
    
update_db('police_shootings.sqlite', 'raw_fatal_encounters', df_fe, 'replace', 'activity.log')

import pandas as pd
import sqlite3

con = sqlite3.connect('police_shootings.sqlite')

fe = pd.read_sql('SELECT * FROM raw_fatal_encounters', con = con)
ds = pd.read_sql('SELECT * FROM raw_deadspin', con = con)


names = fe['Subject\'s name'].append(ds['Victim Name'])
ages = fe['Subject\'s age'].append(ds['Victim\'s Age'])
races = fe['Subject\'s race'].append(ds['Race'])
genders = fe['Subject\'s gender'].append(ds['Victim\'s Gender'])
sources = fe['Link to news article or photo of official document'].append(ds['Source Link'])

combo = pd.DataFrame({'victim_name': names, 'victim_age': ages, 'victim_race': races, 'victim_gender': genders,
                      'source_url': sources
                     })


#### todo ####
'''
1. combo table with comparison/merge of data
2. are data sources the same
3. rf of shooting justification
4. test on same data
5. apply to different
'''