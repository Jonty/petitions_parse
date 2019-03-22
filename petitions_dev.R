require(tidyverse)
require(jsonlite)

setwd('/Users/robinedwards/Documents/github/petitions_parse')

pt = fromJSON('petition_timelines.json') %>% 
  map_df(~ data_frame(date = .x$date, signature_count = .x$signature_count), .id='id') %>% 
  map_df(parse_guess)

pa = fromJSON('petition_attributes.json') %>% map_df(parse_guess)
















