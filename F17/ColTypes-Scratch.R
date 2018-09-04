We can get additional improvement if we prespecify the column types.  

```{r,echo=TRUE,warning=FALSE}
#install.packages('dplyr')
library(dplyr)
## Read col types in from file
pub_layout = read_csv('./public_layout.csv')
unique(pub_layout$'Variable Type')

# rename and convert to lower to please R and readr
pub_layout = pub_layout %>% rename(type='Variable Type') %>%
  mutate(type = sapply(type, function(x){
    switch(x, Character='c', Numeric='n')
  }))
unique(pub_layout$type)
# Paste individual column types into a single string
col_types = paste(pub_layout$type,collapse='')

# Time it again
system.time({
  suppressMessages({
    recs_tib = read_delim('./recs2009_public.csv', delim=',',
                          col_names=TRUE, 
                          col_types=col_types)
  })
})
```
