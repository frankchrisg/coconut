library(lubridate)
library(ggplot2)
library(plotly)
library(reshape2)
library(scales)
library(grid)
require(gridExtra)
library(tidyverse)
library(stringr)
library(hash)
library(dplyr)
library(tibble)
library(xtable)

prepareFiles <- function(fileName) {
  fNameFullAll <- fileName
  fileToUseFullAll <-
    read.csv(gsub(" ", "", paste(fNameFullAll)), dec = ".")
  
  fileToUseFullAll <-
    filter(
      fileToUseFullAll,
      !grepl(
        "4000000-sawtoothConfiguration-.*-.*-40-flalv-rn-1-hetzner-repid-.*-sawtooth-rl-.*-notpbpc-.*-nobpc-1-maxbtperbl-.*-notppc-[[:digit:]]+$",
        run_id,
        ignore.case = FALSE
      )
    )
  
  fileToUseFullAll <-
    filter(
      fileToUseFullAll,
            grepl("4000000-sawtoothConfiguration-.*", run_id, ignore.case = FALSE)
    )
  
  fileToUseFullAll$run_id <-
    sub("repid-.*?-", "repid-0-", fileToUseFullAll$run_id)
  
  return (fileToUseFullAll)
}

fNameFullAll <-
    "C:/Users/parallels/Downloads/testwr-cpbftbpd"

allData <- prepareFiles(fNameFullAll)

allData$rl = str_split_fixed(allData$run_id, "-", Inf)[, 14]
allData$cutCriteria <-
  str_split_fixed(allData$run_id, "-", Inf)[, 24]
allData$notpbpc <- str_split_fixed(allData$run_id, "-", Inf)[, 16]
allData$fullBenchmarkName <- paste(allData$bm, allData$bmf)

allData$avglatency <-
  replace(allData$avglatency, allData$avglatency == 0, NA)
allData$tps <- replace(allData$tps, allData$tps == 0, NA)

generalGroup <-
  allData %>% group_by(fullBenchmarkName, rl, notpbpc, cutCriteria)

summariseByMeanTpsAndLatency <- generalGroup %>% summarise(
  meantps = mean(tps, na.rm = TRUE),
  meanlatency = mean(avglatency, na.rm = TRUE),
  .groups = "keep"
) %>% arrange(
  match(notpbpc, c("1", "50", "100")),
  match(rl, c("50", "100", "200", "400")),
  match(cutCriteria, c("1", "2", "5", "10")),
  fullBenchmarkName,
  rl,
  notpbpc,
  cutCriteria
)#, desc(rl), desc(tps))

#summariseByMeanTpsAndLatency <- summariseByMeanTpsAndLatency %>% filter(notpbpc == 1)

summariseByMeanTpsAndLatency$meantps <-
  replace(
    summariseByMeanTpsAndLatency$meantps,
    is.nan(summariseByMeanTpsAndLatency$meantps) |
      is.na(summariseByMeanTpsAndLatency$meantps),
    0
  )
summariseByMeanTpsAndLatency$meanlatency <-
  replace(
    summariseByMeanTpsAndLatency$meanlatency,
    is.nan(summariseByMeanTpsAndLatency$meanlatency) |
      is.na(summariseByMeanTpsAndLatency$meanlatency),
    0
  )

ifelse (
  summariseByMeanTpsAndLatency$meanlatency == 0,
  summariseByMeanTpsAndLatency$meantps,
  0
)
ifelse (
  summariseByMeanTpsAndLatency$meantps == 0,
  summariseByMeanTpsAndLatency$meanlatency,
  0
)

benchmarkNameGroup <-
  summariseByMeanTpsAndLatency %>% group_by(fullBenchmarkName)
summariseByMaxTps <- benchmarkNameGroup %>%
  #filter(meanlatency > 0) %>%
  summarise(maxtps = max(meantps, na.rm = TRUE), .groups = "keep")

optimalList <-
  summariseByMeanTpsAndLatency[which(unlist(
    summariseByMeanTpsAndLatency$meantps == summariseByMaxTps$maxtps
  )),]

summariseByMeanTpsAndLatency$highlight <- "normal"
for (i in 1:nrow(summariseByMeanTpsAndLatency)) {
  for (j in 1:nrow(optimalList)) {
    if (summariseByMeanTpsAndLatency[i, ]$fullBenchmarkName == optimalList[j, ]$fullBenchmarkName &&
        summariseByMeanTpsAndLatency[i, ]$meantps == optimalList[j, ]$meantps) {
      summariseByMeanTpsAndLatency[i, ]$highlight <- "highlight"
    }
  }
}

summariseByMeanTpsAndLatency <-
  summariseByMeanTpsAndLatency %>% arrange(match(
    fullBenchmarkName,
    c(
      "DoNothing DoNothing",
      "KeyValue Set",
      "KeyValue Get",
      "BankingApp CreateAccount",
      "BankingApp SendPayment",
      "BankingApp Balance"
    )
  ))

summariseByMeanTpsAndLatency$meantps <-
  format(round(summariseByMeanTpsAndLatency$meantps, digits = 2), nsmall = 2)
#round(summariseByMeanTpsAndLatency$meantps, digits = 2)
summariseByMeanTpsAndLatency$meanlatency <-
  format(round(summariseByMeanTpsAndLatency$meanlatency, digits = 2), nsmall = 2)
#round(summariseByMeanTpsAndLatency$meanlatency, digits = 2)

summariseByMeanTpsAndLatency$meantps <-
  ifelse(
    summariseByMeanTpsAndLatency$highlight == "highlight",
    paste("\\textbf{", summariseByMeanTpsAndLatency$meantps, "}", sep =
            ""),
    summariseByMeanTpsAndLatency$meantps
  )

summariseByMeanTpsAndLatency$meanlatency <-
  ifelse(
    summariseByMeanTpsAndLatency$highlight == "highlight",
    paste(
      "\\textbf{",
      summariseByMeanTpsAndLatency$meanlatency,
      "}",
      sep = ""
    ),
    summariseByMeanTpsAndLatency$meanlatency
  )

summariseByMeanTpsAndLatency$fullBenchmarkName <-
  ifelse(
    summariseByMeanTpsAndLatency$highlight == "highlight",
    paste(
      "\\textbf{",
      summariseByMeanTpsAndLatency$fullBenchmarkName,
      "}",
      sep = ""
    ),
    summariseByMeanTpsAndLatency$fullBenchmarkName
  )

summariseByMeanTpsAndLatency$rl <-
  ifelse(
    summariseByMeanTpsAndLatency$highlight == "highlight",
    paste("\\textbf{", summariseByMeanTpsAndLatency$rl, "}", sep = ""),
    summariseByMeanTpsAndLatency$rl
  )

summariseByMeanTpsAndLatency$notpbpc <-
  ifelse(
    summariseByMeanTpsAndLatency$highlight == "highlight",
    paste("\\textbf{", summariseByMeanTpsAndLatency$notpbpc, "}", sep = ""),
    summariseByMeanTpsAndLatency$notpbpc
  )

summariseByMeanTpsAndLatency$cutCriteria <-
  ifelse(
    summariseByMeanTpsAndLatency$highlight == "highlight",
    paste(
      "\\textbf{",
      summariseByMeanTpsAndLatency$cutCriteria,
      "}",
      sep = ""
    ),
    summariseByMeanTpsAndLatency$cutCriteria
  )

summariseByMeanTpsAndLatency <-
  select(summariseByMeanTpsAndLatency, -highlight)


# fullTable ---------------------------------------------------------------

xt <-
  xtable(
    summariseByMeanTpsAndLatency,
    digits = 2,
    align = "l|cccccc",
    caption = "Hyperledger Sawtooth",
    sanitize.text.function = identity
  )

#digits(xt) <- 4
align(xt) <- xalign(xt)
#digits(xt) <- xdigits(xt)
display(xt) <- xdisplay(xt)

print(
  xtable(xt, align = "l|cccccc", caption = "Hyperledger Sawtooth"),
  include.rownames = FALSE,
  sanitize.text.function = identity
)


# optimalTable ------------------------------------------------------------

optimalList <-
  optimalList %>% arrange(match(
    fullBenchmarkName,
    c(
      "DoNothing DoNothing",
      "KeyValue Set",
      "KeyValue Get",
      "BankingApp CreateAccount",
      "BankingApp SendPayment",
      "BankingApp Balance"
    )
  ))

xtOptimal <-
  xtable(
    optimalList,
    digits = 2,
    align = "l|cccccc",
    caption = "Hyperledger Sawtooth",
    sanitize.text.function = identity
  )

#digits(xtOptimal) <- 4
align(xtOptimal) <- xalign(xtOptimal)
#digits(xtOptimal) <- xdigits(xtOptimal)
display(xtOptimal) <- xdisplay(xtOptimal)
print(
  xtable(xtOptimal, align = "l|cccccc", caption = "Hyperledger Sawtooth"),
  include.rownames = FALSE,
  sanitize.text.function = identity
)
