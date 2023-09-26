# -*- coding: utf-8 -*-
"""
Created on Mon Jul  6 10:28:33 2015

@author: nate
"""

import pandas as pd

db_name = 'police_shootings.sqlite'
schema_file = 'police_shootings_db_schema.sql'

fe_url = 'https://docs.google.com/spreadsheet/pub?key=0Aul9Ys3cd80fdHNuRG5VeWpfbnU4eVdIWTU3Q0xwSEE&single=TRUE&gid=0&output=csv'
ds_url = 'https://docs.google.com/spreadsheets/d/1cEGQ3eAFKpFBVq1k2mZIy5mBPxC6nBTJHzuSWtZQSVw/export?format=csv'

fe_cols = 23
ds_cols = 27

fe = pd.read_csv(fe_url)
ds = pd.read_csv(ds_url)

def shape_check(df, cols):
    return df.shape[1] == cols
    
if shape_check(fe, 23) == False:
    print('data frame has incorrect number of columns')
if shape_check(ds, 27) == False:
    print('data frame has incorrect number of columns')

def name_processor(df, col_name):

    names = df[col_name]
    names = names.str.lower()
    names = names.str.replace('\d', '')  # remove numeric characters
    names = names.str.replace(',', '')
    names = names.str.replace('[.]', '')

    suffixes = []
    cnt = 0

    for name in names:
        w = str(name).rsplit(' ')[-1]
        if w in ['jr', 'sr', 'ii', 'iii', 'iv']:
            suffixes.append(w)
            names[cnt] = str(names[cnt]).replace(' ' + w, '')
            continue
        else:
            suffixes.append('')
            cnt += 1

    def try_pop(lst, index = -1):
        try:
            return(lst.pop(index))
        except:
            return('')

    names = names.map(lambda x: str(x).rsplit(' '))
    last_name = names.map(lambda x: try_pop(x, index = -1))
    first_name = names.map(lambda x: try_pop(x, index = 0))
    middle_name = names.map(lambda x: ' '.join(x))

    return(last_name, first_name, middle_name, suffixes)
    

col_mapping = \
    {'fe': {'name': 'Subject\'s name', \
            'age': 'Subject\'s age', \
            'gender': 'Subject\'s gender', \
            'race': 'Subject\'s race', \
            'hispanic_latin': None, \
            'mental_illness': 'Symptoms of mental illness?', \
            'date': 'Date of injury resulting in death (month/day/year)', \
            'address': 'Location of injury (address)', \
            'city': 'Location of death (city)', \
            'state': 'Location of death (state)', \
            'zip_code': 'Location of death (zip code)', \
            'county': 'Location of death (county)', \
            'agency': 'Agency responsible for death', \
            'source': 'Link to news article or photo of official document', \
            'justified': 'Official disposition of death (justified or other)', \
            'description': 'A brief description of the circumstances surrounding the death' \
           }, \
     'ds': {'name': 'Victim Name', \
            'age': 'Victim\'s Age', \
            'gender': 'Victim\'s Gender', \
            'race': 'Race', \
            'hispanic_latin': 'Hispanic or Latino Origin', \
            'mental_illness': None, \
            'date': 'Date of Incident', \
            'address': None, \
            'city': 'City', \
            'state': 'State', \
            'zip_code': None, \
            'county': 'County', \
            'agency': 'Agency Name', \
            'source': 'Source Link', \
            'justified': 'Was the Shooting Justified?', \
            'description': 'Summary' \
           }
    }
    

def shootings_df_process(df_name, col_mappings):
    df = eval(df_name)
    length = df.shape[0]

    cols_names = list(col_mappings[df_name].keys())
    cols_select = list(col_mappings[df_name].values())
    # create an empty dataframe as a destination for data
    df_output = pd.DataFrame(columns = col_mapping[df_name].keys())

    for cnt, col in enumerate(cols_select):
        col_values = [None] * length if col is None else df[col]
        df_output[cols_names[cnt]] = col_values
    return(df_output)


from os import path
from sqlite3 import connect

db_exists = path.exists(db_name)

con.close()

with connect(db_name) as con:
    if not db_exists:
        with open(schema_file, 'rt') as f:
            schema = f.read()
        con.executescript(schema)

con = connect(db_name)


ds.to_sql(con = con, if_exists = 'replace', name = 'raw_deadspin')
fe.to_sql(con = con, if_exists = 'replace', name = 'raw_fatal_encounters')

con.close()

ds_processed = shootings_df_process('ds', col_mapping)
ds_processed['source'] = 'deadspin'
fe_processed = shootings_df_process('fe', col_mapping)
fe_processed['source'] = 'fatal_encounters'

shootings = pd.concat([ds_processed, fe_processed]).reset_index()
last, first, middle, suffix = name_processor(shootings, 'name')
shootings['name_last'] = last
shootings['name_first'] = first
shootings['name_middle'] = middle
shootings['name_suffix'] = suffix
shootings = shootings.drop('name', 1)
shootings['race_black'] = shootings['race'].str.contains('african|black', case = False, na = False)
shootings['race_white'] = shootings['race'].str.contains('white|caucasian', case = False, na = False)
shootings['race_hispanic'] = shootings['race'].str.contains('latin|hispanic', case = False, na = False)
shootings['race_asian'] = shootings['race'].str.match('asian', case = False, na = False)
shootings['race_nativeamer'] = shootings['race'].str.contains('native', case = False, na = False)
shootings = shootings.drop('race', 1)
shootings['state'] = shootings['state'].map(lambda x: str(x).split(' ')[0])
shootings['mental_illness'] = shootings['mental_illness'].map(lambda x: str(x).lower() == 'yes')
shootings['gender_male'] = shootings['gender'].map(lambda x: str(x).lower() == 'male')


con = connect(db_name)

# fix here: https://goo.gl/8nVjn3
shootings.to_sql(name = 'shootings', con = con, if_exists = 'replace')

con.close()

