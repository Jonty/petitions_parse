require(tidyverse)
require(jsonlite)
require(stringr)

setwd('~/Documents/github/petitions_parse/data')

j = list.files(pattern = '.json')

d0 = lapply(j, function(i) list(date = as.Date(substr(i,1,10)), json = fromJSON(i, flatten = TRUE)))

# extract data.frames and unite with dates
d1 = d0 %>% lapply(function(l){
  k <<- l$date
  n = nrow(l$json$data)
  if(is.null(n)) return(NA)
  l$json$data %>% as.data.frame() %>% mutate(date = rep(l$date,  n))
})
d1 = d1[ !is.na(d1) ] # remove empty items

# merge into single df
d2 = d1 %>% bind_rows() %>% as_data_frame() %>% 
  mutate_if(str_detect(names(.), '_at$'), funs(as.Date(.)))
names(d2) = str_replace(names(d2), 'attributes[.]', '')

# timeline data

timelines = d2 %>% select(id, date, signature_count) %>% as_data_frame() %>% mutate(id = as.character(id)) 

start_point_ids = d2 %>% select(id, created_at) %>% unique() %>% filter(created_at > min(d2$date)) %>% .[['id']] %>% as.character()
start_point_rows = d2 %>% filter(id %in% start_point_ids) %>% group_by(id) %>% filter(date == min(date)) %>% 
  mutate(date = created_at, signature_count = 1) %>% ungroup() %>% select(id, date, signature_count)

timelines = rbind(timelines, start_point_rows) %>% arrange(date) %>% 
  split(.$id) %>% lapply(function(i) i %>% select(-id))

sink('../petition_timelines.json')
cat(toJSON(timelines, 'columns'))
sink()

# attribute data

d3 = d2 %>% group_by(id) %>% filter(date == max(date)) %>% select(-type, -links.self, -state)

sink('../petition_attributes.json')
cat(toJSON(d3, 'rows'))
sink()

# PARSE JSON
# jj = fromJSON('../timelines.json')
# 
# # parse timeline json
# j2 = lapply(seq_len(length(jj)), function(i){ data.frame(id = names(jj)[i], as.data.frame(jj[[i]], stringsAsFactors=F), stringsAsFactors=F) }) %>%
#   bind_rows() %>% mutate(date = as.Date(date)) %>% as_data_frame()


