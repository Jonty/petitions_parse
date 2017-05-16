setwd('/pathto/petitions')

root = 'https://petition.parliament.uk/petitions.json?page='
tail = '&state=open'
fn = substr(as.character(Sys.time()), 1, 10)

i = 1
loop = TRUE

while(loop & i < 300){
  url = paste0(root, i, tail)
  destfn = paste0('json/', fn, '_', formatC(i, width = 3, flag = '0'), '.json')
  download.file(url, destfile = destfn, quiet=T)
  file.size(destfn)
  i = i + 1
  if(file.size(destfn) < 1000) loop = FALSE
}

# Example crontab line for weekly scraping:
# 0 0 * * sun Rscript /pathto/petitions/get_petitions.R > /pathto/petitions/log 2>&1
