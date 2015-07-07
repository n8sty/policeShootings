-- Schema for police shootings sqlite database

-- raw_fatal_encounters is the raw data downloaded from the csv here: https://docs.google.com/spreadsheet/pub?key=0Aul9Ys3cd80fdHNuRG5VeWpfbnU4eVdIWTU3Q0xwSEE&single=TRUE&gid=0&output=csv
CREATE TABLE raw_fatal_encounters (
	[index] INTEGER,
	[Timestamp] TEXT,
	[Subject's name] TEXT,
	[Subject's age] TEXT,
	[Subject's gender] TEXT,
	[Subject's race] TEXT,
	[URL of image of deceased] TEXT,
	[Date of injury resulting in death (month/day/year)] TEXT,
	[Location of injury (address)] TEXT,
	[Location of death (city)] TEXT,
	[Location of death (state)] TEXT,
	[Location of death (zip code)] TEXT,
	[Location of death (county)] TEXT,
	[Agency responsible for death] TEXT,
	[Cause of death] TEXT,
	[A brief description of the circumstances surrounding the death] TEXT,
	[Official disposition of death (justified or other)] TEXT,
	[Link to news article or photo of official document] TEXT,
	[Symptoms of mental illness?] TEXT,
	[Source/Submitted by] TEXT,
	[Email address] TEXT,
	[Date&Description] TEXT,
	[Unnamed: 21] REAL,
	[Unique identifier] REAL
);


-- raw_fatal_deadspin is the raw data downloaded from the csv here: https://docs.google.com/spreadsheets/d/1cEGQ3eAFKpFBVq1k2mZIy5mBPxC6nBTJHzuSWtZQSVw/export?format=csv
CREATE TABLE raw_deadspin (
	[index] INTEGER,
	[Timestamp] TEXT,
	[Date Searched] TEXT,
	[State] TEXT,
	[County] TEXT,
	[City] TEXT,
	[Agency Name] TEXT,
	[Victim Name] TEXT,
	[Victim's Age] REAL,
	[Victim's Gender] TEXT,
	[Race] TEXT,
	[Hispanic or Latino Origin] TEXT,
	[Shots Fired] REAL,
	[Hit or Killed?] TEXT,
	[Armed or Unarmed?] TEXT,
	[Weapon] TEXT,
	[Summary] TEXT,
	[Source Link] TEXT,
	[Name of Officer or Officers] TEXT,
	[Shootings] TEXT,
	[Was the Shooting Justified?] REAL,
	[Receive Updates?] TEXT,
	[Name] TEXT,
	[Email Address] TEXT,
	[Twitter] TEXT,
	[Date of Incident] TEXT,
	[Results Page Number] REAL,
	[Unnamed: 26] TEXT
);

CREATE TABLE `shootings` (
	`index`	INTEGER,
	`agency`	TEXT,
	`source`	TEXT,
	`age`	INTEGER,
	`hispanic_latin`	TEXT,
	`address`	TEXT,
	`city`	TEXT,
	`date`	TEXT,
	`state`	TEXT,
	`justified`	TEXT,
	`mental_illness`	TEXT,
	`description`	TEXT,
	`zip_code`	TEXT,
	`county`	TEXT,
	`race`	TEXT,
	`gender`	TEXT,
	`name_last`	TEXT,
	`name_first`	TEXT,
	`name_middle`	TEXT,
	`name_suffix`	TEXT
);

