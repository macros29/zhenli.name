## Created by: Zhen Li
## Created on: 11/29/2018
## Purpose: This script is used to organize table from .xlsx file into html format for datatable. 
## Specify which sheet on .xlsx file with the sheet option

library(openxlsx)

setwd("~/zhen/scripts/zhenli.name/content/")
sheet = 3
dt <- read.xlsx("./single_cell_RNA-seq.xlsx",sheet = sheet,rowNames = F,colNames = F)
temp <- as.character(sapply(dt[1,], function(xx){paste("<th>", xx, "</th>", sep="")}))
temp <- c("<thead>", "<tr>", temp, "</tr>", "</thead>")

temp2 <- apply(dt[-1,], 1, function(xx){
  temp <- as.character(sapply(xx, function(yy){paste("<td>", yy, "</td>", sep="")}))
  c("<tr>", temp, "</tr>")
})
temp2 <- c('<table id="example" class="display" style="width:100%">"', temp, "<tbody>", temp2, "</tbody>", "</table")
write.table(temp2, paste("d", sheet, ".html", sep=""), eol = "\n",row.names = F,col.names = F,quote = F)

## After saving the formatted data, remember to insert the rest of the html text into the document, otherwise it won't work.