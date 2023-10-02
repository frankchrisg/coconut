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
library(viridis)
library(ggtext)
library(ggrepel)
library(data.table)
library(xtable)

library(remotes)
#remotes::install_version("Rttf2pt1", version = "1.3.8")
library(extrafont) 
#font_import(paths = "C:/Users/parallels/Downloads/linux_libertine", prompt=FALSE)
#font_import(pattern = "LMRoman*") 

prepareFilesRep <- function(fileName) {
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
      # Okay here because of rid in query
      grepl("4000000-grapheneConfiguration-.*", run_id, ignore.case = FALSE)
      #      grepl("4000000-sawtoothConfiguration-.*", run_id, ignore.case = FALSE)
    )
  
  fileToUseFullAll <-
    filter(fileToUseFullAll,
           #             grepl(".*-opt-50-.*", run_id, ignore.case = FALSE))
           grepl(".*-donothing-doNothing-.*-opt-100-.*|.*-keyvalue-set-.*-opt-50-.*|.*-keyvalue-get-.*-opt-50-.*|.*-sb-createAccount-.*-opt-50-.*|.*-sb-sendPayment-.*-opt-100-.*|.*-sb-balance-.*-opt-100-.*", run_id, ignore.case = FALSE))
  #           grepl(".*-notpbpc-100-.*", run_id, ignore.case = FALSE))
  
  fileToUseFullAll$run_id <-
    sub("repid-.*?-", "repid-0-", fileToUseFullAll$run_id)
  
  return (fileToUseFullAll)
}

cleanTpl <-
  function (base_size = 9,
            base_family = "Linux Libertine",
            ...) {
    modifyList (
      theme_minimal (base_size = base_size, base_family = base_family),
      list (axis.line = element_line (colour = "black"))
    ) + theme(
      legend.title = element_blank(),
      legend.position = "bottom",
      axis.text.y = element_text(size = 9, color = "black"),
      axis.title.y = element_text(size = 9, color = "black", face="bold"),
      axis.text.x = element_text(
        color = "black",
        size = 9,
        angle = 0,#45,
        vjust = 0.5
      ),
      axis.title.x = element_text(size = 9, color = "black"),
      axis.line.x = element_line(color = "grey", size = 0.5),
      plot.caption = element_markdown(
        hjust = 0.9,
        vjust = -0.5,
        size = 9
      ),
      legend.key.size = unit(0.7, "line"),
      legend.text = element_markdown(
        colour = "black",
        size = 9#,
        #face = "bold"
      ),
      legend.box.margin = margin(-15, -15, -10, -15),
    )
  }

ggplot2::update_geom_defaults("text", list(color = "black", family = "Linux Libertine", size=9*(1/72 * 25.4)))

failureEvalList <- c()

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
      grepl("4000000-grapheneConfiguration-.*fixblockstatshetzner-.*", run_id, ignore.case = FALSE)
      #      grepl("4000000-sawtoothConfiguration-.*", run_id, ignore.case = FALSE)
    )
  
  fileToUseFullAll <-
    filter(fileToUseFullAll,
           #             grepl(".*-opt-50-.*", run_id, ignore.case = FALSE))
           grepl(".*-donothing-doNothing-.*-opt-100-.*|.*-keyvalue-set-.*-opt-50-.*|.*-keyvalue-get-.*-opt-50-.*|.*-sb-createAccount-.*-opt-50-.*|.*-sb-sendPayment-.*-opt-100-.*|.*-sb-balance-.*-opt-100-.*", run_id, ignore.case = FALSE))
  #           grepl(".*-notpbpc-100-.*", run_id, ignore.case = FALSE))
  
  #fileToUseFullAll <-
  #  filter(fileToUseFullAll,
  #         grepl(".*-keyvalue-set-.*-opt-50-.*", run_id, ignore.case = FALSE))
  #fileToUseFullAll <-
  #  filter(fileToUseFullAll,
  #         grepl(".*-keyvalue-get-.*-opt-50-.*", run_id, ignore.case = FALSE))
  #fileToUseFullAll <-
  #  filter(fileToUseFullAll,
  #         grepl(".*-sb-createAccount-.*-opt-50-.*", run_id, ignore.case = FALSE))
  #fileToUseFullAll <-
  #  filter(fileToUseFullAll,
  #         grepl(".*-sb-sendPayment-.*-opt-100-.*", run_id, ignore.case = FALSE))
  #fileToUseFullAll <-
  #  filter(fileToUseFullAll,
  #         grepl(".*-sb-balance-.*-opt-100-.*", run_id, ignore.case = FALSE))
  
  fileToUseFullAllTemp <- fileToUseFullAll[fileToUseFullAll$failed == 1 | fileToUseFullAll$failed == 2,]
  options(width = 1600)
  groupByRidForFailureEval <- fileToUseFullAllTemp %>% group_by(run_id)
  summariseForFailureEval <- groupByRidForFailureEval %>% summarise()
  
  replaceRidEvalList <- sub("repid-.*?-", "repid-0-", summariseForFailureEval$run_id)
  uniqueEvalList <- unique(replaceRidEvalList)
  for(val in uniqueEvalList) {
    if(!(sub("repid-0-", "repid-1-", val) %in% fileToUseFullAllTemp$run_id)) {
      failureEvalList <<- append(failureEvalList,sub("repid-0-", "repid-1-", val))
    }
    if(!(sub("repid-0-", "repid-2-", val) %in% fileToUseFullAllTemp$run_id)) {
      failureEvalList<<-append(failureEvalList,sub("repid-0-", "repid-2-", val))
    } 
    if(!(sub("repid-0-", "repid-3-", val) %in% fileToUseFullAllTemp$run_id)) {
      failureEvalList<<-append(failureEvalList,sub("repid-0-", "repid-3-", val))
    }
  }
  
  fileToUseFullAll$run_id <-
    sub("repid-.*?-", "repid-0-", fileToUseFullAll$run_id)
  
  return (fileToUseFullAll)
}

save <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/final-plots/graphene/",path,"/", titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 40,
    #NA,
    height = 20,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

# Create data by program
fNameFullAll <-
  "C:/Users/frank/Downloads/testwr-graphene"

tpsAndLatencyData <- prepareFiles(fNameFullAll)

fNameFullAllRep <-
  "C:/Users/frank/Downloads/failed1query-rid-data-1657910318868.csv" #fabric
tpsAndLatencyDataRep <- prepareFilesRep(fNameFullAllRep)
tpsAndLatencyDataRep <- tpsAndLatencyDataRep[tpsAndLatencyDataRep$run_id != "4000000-grapheneConfiguration-sb-sendPayment-40-flalv-rn-1-hetzner-repid-0-graphene-rl-400-bi-10-opt-100-notpc-1",]
tpsAndLatencyDataRep <- tpsAndLatencyDataRep[tpsAndLatencyDataRep$run_id != "4000000-grapheneConfiguration-sb-createAccount-40-flalv-rn-1-hetzner-repid-0-graphene-rl-50-bi-5-opt-100-notpc-1",]
tpsAndLatencyDataRep <- tpsAndLatencyDataRep[tpsAndLatencyDataRep$run_id != "4000000-grapheneConfiguration-sb-sendPayment-40-flalv-rn-1-hetzner-repid-0-graphene-rl-400-bi-2-opt-100-notpc-1",]
tpsAndLatencyDataRep <- tpsAndLatencyDataRep[tpsAndLatencyDataRep$run_id != "4000000-grapheneConfiguration-sb-createAccount-40-flalv-rn-1-hetzner-repid-0-graphene-rl-400-bi-2-opt-100-notpc-1",]
tpsAndLatencyDataRep <- tpsAndLatencyDataRep[tpsAndLatencyDataRep$run_id != "4000000-grapheneConfiguration-sb-createAccount-40-flalv-rn-1-hetzner-repid-0-graphene-rl-400-bi-10-opt-100-notpc-1",]
tpsAndLatencyDataRep <- tpsAndLatencyDataRep[tpsAndLatencyDataRep$run_id != "4000000-grapheneConfiguration-sb-sendPayment-40-flalv-rn-1-hetzner-repid-0-graphene-rl-50-bi-5-opt-100-notpc-1",]
tpsAndLatencyDataRep$run_id<-gsub("hetzner","fixblockstatshetzner",tpsAndLatencyDataRep$run_id)
for (i in 1:nrow(tpsAndLatencyData))
{
  for(j in 1:nrow(tpsAndLatencyDataRep)) 
    if(tpsAndLatencyData[i,]$stf=="1970-01-01 00:59:59+01" & tpsAndLatencyData[i,]$run_id ==tpsAndLatencyDataRep[j,]$run_id) {
      print(paste("Replacing: ", tpsAndLatencyData[i, ]$run_id))
      tpsAndLatencyData[i, 1:20] <- tpsAndLatencyDataRep[j, ]
    }
}

tpsAndLatencyData$rl = str_split_fixed(tpsAndLatencyData$run_id, "-", Inf)[, 14]
# Sawtooth: 24, Graphene: 16, Quorum: 16, Fabric: 16, Diem: 16
tpsAndLatencyData$cutCriteria <-
  str_split_fixed(tpsAndLatencyData$run_id, "-", Inf)[, 16] # 16
tpsAndLatencyData$fullBenchmarkName <-
  paste(tpsAndLatencyData$bm, tpsAndLatencyData$bmf)

tpsAndLatencyData$avglatency <-
  replace(tpsAndLatencyData$avglatency,
          tpsAndLatencyData$avglatency == 0,
          NA)

tpsAndLatencyData$tps <-
  replace(tpsAndLatencyData$tps, tpsAndLatencyData$tps == 0, NA)

generalGroup <-
  tpsAndLatencyData %>% group_by(fullBenchmarkName, cutCriteria, rl) # %>% filter(tps == max(tps))

summariseByMeanTpsAndLatency <-
  generalGroup %>% summarise(
    n = n(),  # Count number of samples
    sdtps = sd(tps, na.rm = TRUE),
    sdavglatency = sd(avglatency, na.rm = TRUE),
    tps = mean(tps, na.rm = TRUE),
    avglatency = mean(avglatency, na.rm = TRUE),
    duration = mean(duration, na.rm = TRUE),
    semtps = sdtps / sqrt(n),
    semavglatency = sdavglatency / sqrt(n),
    # Use qt() for the t-distribution quantile function. Use df = n - 1
    CI_low_tps = tps - qt(0.975, df = n-1) * semtps,
    CI_high_tps = tps + qt(0.975, df = n-1) * semtps,
    CI_low_avglatency = avglatency - qt(0.975, df = n-1) * semavglatency,
    CI_high_avglatency = avglatency + qt(0.975, df = n-1) * semavglatency,
    .groups = "keep"
  ) %>% arrange(match(cutCriteria, c("1", "2", "5", "10")), match(rl, c("50", "100", "200", "400")))#, desc(rl), desc(tps))

x1 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "donothing" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==1,]$stf
x2 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "donothing" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==1,]$etf

x3 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "set" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==5,]$stf
x4 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "set" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==5,]$etf

x5 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "get" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==5,]$stf
x6 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "get" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==5,]$etf

x7 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "create" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==2,]$stf
x8 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "create" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==2,]$etf

x9 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "send" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==2,]$stf
x10 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "send" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==2,]$etf

x11 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "balance" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==2,]$stf
x12 <- tpsAndLatencyData[tpsAndLatencyData$run_id %like% "balance" & tpsAndLatencyData$rl==400 & tpsAndLatencyData$cutCriteria==2,]$etf

df <- data.frame()
dfw <- do.call("rbind", list(df, matrix(x1), matrix(x2), matrix(x3), matrix(x4),
                      matrix(x5), matrix(x6), matrix(x7), matrix(x8),
                      matrix(x9), matrix(x10), matrix(x11), matrix(x12)))

write.csv(dfw, "C:/Users/frank/Downloads/grapheneFnh.csv", row.names=FALSE)

summariseByMeanTpsAndLatency$tps <-
  replace(
    summariseByMeanTpsAndLatency$tps,
    is.nan(summariseByMeanTpsAndLatency$tps) |
      is.na(summariseByMeanTpsAndLatency$tps),
    0
  )
summariseByMeanTpsAndLatency$avglatency <-
  replace(
    summariseByMeanTpsAndLatency$avglatency,
    is.nan(summariseByMeanTpsAndLatency$avglatency) |
      is.na(summariseByMeanTpsAndLatency$avglatency),
    0
  )

summariseByMeanTpsAndLatency$duration <-
  replace(
    summariseByMeanTpsAndLatency$duration,
    is.nan(summariseByMeanTpsAndLatency$duration) |
      is.na(summariseByMeanTpsAndLatency$duration),
    0
  )

# Replace NA or NaN with 0 for semtps
summariseByMeanTpsAndLatency$semtps <- replace(
  summariseByMeanTpsAndLatency$semtps,
  is.nan(summariseByMeanTpsAndLatency$semtps) |
    is.na(summariseByMeanTpsAndLatency$semtps),
  0
)

# Replace NA or NaN with 0 for CI_low_tps
summariseByMeanTpsAndLatency$CI_low_tps <- replace(
  summariseByMeanTpsAndLatency$CI_low_tps,
  is.nan(summariseByMeanTpsAndLatency$CI_low_tps) |
    is.na(summariseByMeanTpsAndLatency$CI_low_tps),
  0
)

# Replace NA or NaN with 0 for CI_high_tps
summariseByMeanTpsAndLatency$CI_high_tps <- replace(
  summariseByMeanTpsAndLatency$CI_high_tps,
  is.nan(summariseByMeanTpsAndLatency$CI_high_tps) |
    is.na(summariseByMeanTpsAndLatency$CI_high_tps),
  0
)

# Replace NA or NaN with 0 for semavglatency
summariseByMeanTpsAndLatency$semavglatency <- replace(
  summariseByMeanTpsAndLatency$semavglatency,
  is.nan(summariseByMeanTpsAndLatency$semavglatency) |
    is.na(summariseByMeanTpsAndLatency$semavglatency),
  0
)

# Replace NA or NaN with 0 for CI_low_avglatency
summariseByMeanTpsAndLatency$CI_low_avglatency <- replace(
  summariseByMeanTpsAndLatency$CI_low_avglatency,
  is.nan(summariseByMeanTpsAndLatency$CI_low_avglatency) |
    is.na(summariseByMeanTpsAndLatency$CI_low_avglatency),
  0
)

# Replace NA or NaN with 0 for CI_high_avglatency
summariseByMeanTpsAndLatency$CI_high_avglatency <- replace(
  summariseByMeanTpsAndLatency$CI_high_avglatency,
  is.nan(summariseByMeanTpsAndLatency$CI_high_avglatency) |
    is.na(summariseByMeanTpsAndLatency$CI_high_avglatency),
  0
)

summariseByMeanTpsAndLatency$duration<-ifelse (summariseByMeanTpsAndLatency$avglatency == 0 | summariseByMeanTpsAndLatency$tps == 0,
                                               0,
                                               summariseByMeanTpsAndLatency$duration)

summariseByMeanTpsAndLatency$tps<-ifelse (summariseByMeanTpsAndLatency$avglatency == 0,
                                          0,
                                          summariseByMeanTpsAndLatency$tps)

summariseByMeanTpsAndLatency$avglatency<-ifelse (summariseByMeanTpsAndLatency$tps == 0,
                                                 0,
                                                 summariseByMeanTpsAndLatency$avglatency)

counter <- 0

plot_listTps = list()
datalistTps = list()
plot_listLatency = list()
datalistLatency = list()
plot_listFailures = list()
datalistFailures = list()
datalistSubsetTps = list()
datalistSubsetLatency = list()
datalistSubsetFailures = list()

benchmarkList <-
  c(
    "DoNothing",
    "KeyValue-Set",
    "KeyValue-Get",
    "Banking-Create",
    "Banking-Send",
    "Banking-Balance"
  )
for (benchmark in benchmarkList) {
  counter <- counter + 1
  
  if (benchmark == "DoNothing") {
    tempName <- "DoNothing DoNothing"
  }
  else if (benchmark == "KeyValue-Set") {
    tempName <- "KeyValue Set"
  }
  else if (benchmark == "KeyValue-Get") {
    tempName <- "KeyValue Get"
  }
  else if (benchmark == "Banking-Create") {
    tempName <- "BankingApp CreateAccount"
  }
  else if (benchmark == "Banking-Send") {
    tempName <- "BankingApp SendPayment"
  }
  else if (benchmark == "Banking-Balance") {
    tempName <- "BankingApp Balance"
  }
  
  # dfTps -------------------------------------------------------------------
  
  preparedDataFrameTps <-
    data.frame(
      "RL" = c(rep(
        c("RL=200", "RL=400", "RL=800", "RL=1600"), 4
      )),
      "placeholder_name" = summariseByMeanTpsAndLatency$tps[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                    tempName)],
      "Category" = c(rep("BI=1s", 4), rep("BI=2s", 4), rep("BI=5s", 4), rep("BI=10s", 4)),
      "SDTPS" = summariseByMeanTpsAndLatency$sdtps[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                           tempName)],
      "SEMTPS" = summariseByMeanTpsAndLatency$semtps[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                             tempName)],
      "CI_low_tps" = summariseByMeanTpsAndLatency$CI_low_tps[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                     tempName)],
      "CI_high_tps" = summariseByMeanTpsAndLatency$CI_high_tps[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                       tempName)]
    )
  
  print(preparedDataFrameTps)
  
  preparedDataFrameTps <- subset(preparedDataFrameTps, Category != "BI=2s" & Category != "BI=5s" & Category != "BI=10s")
  preparedDataFrameTps <- subset(preparedDataFrameTps, RL != "RL=200" & RL != "RL=400")
  
  names(preparedDataFrameTps)[names(preparedDataFrameTps) == "placeholder_name"] <-
    benchmark
  
  longFormatTps <-
    melt(
      setDT(preparedDataFrameTps),
      id.vars = c("RL", "Category", "SDTPS", "SEMTPS", "CI_low_tps", "CI_high_tps"),
      variable.name = "BenchmarkName"
    )
  longFormatTps$BenchmarkName <-
    gsub("\\.", "-", longFormatTps$BenchmarkName)
  
  longFormatTps$RL <-
    factor(longFormatTps$RL,
           levels = c("RL=200", "RL=400", "RL=800", "RL=1600"))
  longFormatTps$BenchmarkName <-
    factor(longFormatTps$BenchmarkName, levels = benchmark)
  longFormatTps$Category <-
    factor(longFormatTps$Category,
           levels = c("BI=1s", "BI=2s", "BI=5s", "BI=10s"))
  
  aggDataMaxTps <-
    aggregate(x = value ~ BenchmarkName,
              FUN = max,
              data = longFormatTps)
  
  longFormatTps$highlight <-
    ifelse((
      longFormatTps$value %in% aggDataMaxTps$x &
        longFormatTps$value > 0
    ),
    "highlight",
    "normal"
    )
  
  longFormatTps$highlight <- "normal"
  for (i in 1:nrow(longFormatTps)) {
    for (j in 1:nrow(aggDataMaxTps)) {
      if (longFormatTps[i, ]$BenchmarkName == aggDataMaxTps[j, ]$BenchmarkName &&
          longFormatTps[i, ]$value == aggDataMaxTps[j, ]$value) {
        longFormatTps[i, ]$highlight <- "highlight"
      }
    }
  }
  
  longFormatIsNotMax <-
    longFormatTps[longFormatTps$highlight != "highlight"]
  longFormatIsMax <-
    longFormatTps[longFormatTps$highlight == "highlight"]
  longFormatIsMax <- longFormatIsMax[longFormatIsMax$value > 0]
  
  # dfLatency -------------------------------------------------------------------
  
  preparedDataFrameLatency <-
    data.frame(
      "RL" = c(rep(
        c("RL=200", "RL=400", "RL=800", "RL=1600"), 4
      )),
      "placeholder_name" = summariseByMeanTpsAndLatency$avglatency[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                           tempName)],
      "Category" = c(rep("BI=1s", 4), rep("BI=2s", 4), rep("BI=5s", 4), rep("BI=10s", 4)),
      "SDLATENCY" = summariseByMeanTpsAndLatency$sdavglatency[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                      tempName)],
      "SEMLATENCY" = summariseByMeanTpsAndLatency$semavglatency[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                     tempName)],
      "CI_low_latency" = summariseByMeanTpsAndLatency$CI_low_avglatency[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                         tempName)],
      "CI_high_latency" = summariseByMeanTpsAndLatency$CI_high_avglatency[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                           tempName)]
    )
  
  preparedDataFrameLatency <- subset(preparedDataFrameLatency, Category != "BI=2s" & Category != "BI=5s" & Category != "BI=10s")
  preparedDataFrameLatency <- subset(preparedDataFrameLatency, RL != "RL=200" & RL != "RL=400")
  
  names(preparedDataFrameLatency)[names(preparedDataFrameLatency) == "placeholder_name"] <-
    benchmark
  
  longFormatLatency <-
    melt(
      setDT(preparedDataFrameLatency),
      id.vars = c("RL", "Category", "SDLATENCY", "SEMLATENCY", "CI_low_latency", "CI_high_latency"),
      variable.name = "BenchmarkName"
    )
  longFormatLatency$BenchmarkName <-
    gsub("\\.", "-", longFormatLatency$BenchmarkName)
  
  longFormatLatency$RL <-
    factor(longFormatLatency$RL,
           levels = c("RL=200", "RL=400", "RL=800", "RL=1600"))
  longFormatLatency$BenchmarkName <-
    factor(longFormatLatency$BenchmarkName, levels = benchmark)
  longFormatLatency$Category <-
    factor(longFormatLatency$Category,
           levels = c("BI=1s", "BI=2s", "BI=5s", "BI=10s"))
  
  aggDataMinLatency <-
    aggregate(
      x = value ~ BenchmarkName,
      FUN = min,
      data = longFormatLatency,
      subset = value > 0
    )
  
  longFormatLatency$highlight <-
    ifelse((
      longFormatLatency$value %in% aggDataMinLatency$x &
        longFormatLatency$value > 0
    ),
    "highlight",
    "normal"
    )
  
  longFormatLatency$highlight <- "normal"
  for (i in 1:nrow(longFormatLatency)) {
    for (j in 1:nrow(aggDataMinLatency)) {
      if (longFormatLatency[i, ]$BenchmarkName == aggDataMinLatency[j, ]$BenchmarkName &&
          longFormatLatency[i, ]$value == aggDataMinLatency[j, ]$value) {
        longFormatLatency[i, ]$highlight <- "highlight"
      }
    }
  }
  
  longFormatIsNotMin <-
    longFormatLatency[longFormatLatency$highlight != "highlight"]
  longFormatIsMin <-
    longFormatLatency[longFormatLatency$highlight == "highlight"]
  longFormatIsMin <- longFormatIsMin[longFormatIsMin$value > 0]
  
  longFormatTpsTemp <- longFormatTps
  longFormatTpsTemp$highlight <-
    ifelse((longFormatTps$value == 0),
           "failed",
           longFormatTps$highlight)
  longFormatTps$normaltag <- "normal"
  longFormatIsMax$maxtag <- "max"
  longFormatTpsTemp$failedtag <- "failed"
  
  tpsAndLatencyData$countallrows <-
    replace(tpsAndLatencyData$countallrows,
            tpsAndLatencyData$countallrows == 0,
            NA)
  summariseAllMeanData <-
    generalGroup %>% summarise(#%>% filter( countallrows > 0 ) %>% summarise(
      mrows = mean(countallrows, na.rm = TRUE),
      sdmrows = sd(countallrows, na.rm = TRUE),
      # Calculate number of rows (sample size)
      n = n(),
      # Calculate SEM
      semmrows = sdmrows / sqrt(n),
      # Calculate lower and upper bounds of the confidence interval
      CI_low_mrows = mrows - qt(0.975, df = n-1) * semmrows,
      CI_high_mrows = mrows + qt(0.975, df = n-1) * semmrows,
      .groups = "keep") %>% arrange(match(cutCriteria, c("1", "2", "5", "10")), match(rl, c("50", "100", "200", "400")))
  summariseAllMeanData$mrows <-
    replace(
      summariseAllMeanData$mrows,
      is.nan(summariseAllMeanData$mrows) |
        is.na(summariseAllMeanData$mrows),
      0
    )
  summariseAllMeanData$expected <-
    (as.numeric(summariseAllMeanData$rl) * 300 * 4)
  summariseAllMeanData$failed <-
    summariseAllMeanData$expected - summariseAllMeanData$mrows
  summariseAllMeanData$offset <-
    ((summariseAllMeanData$expected - summariseAllMeanData$mrows) * -1)
  summariseAllMeanData$offset[summariseAllMeanData$offset < 0] <- 0
  summariseAllMeanData$failed[summariseAllMeanData$failed < 0] <- 0
  
  # dfAllDataRows -------------------------------------------------------------------
  
  preparedDataFrameAllDataRows <-
    data.frame(
      "RL" = c(rep(
        c("RL=200", "RL=400", "RL=800", "RL=1600"), 4
      )),
      "placeholder_name" = summariseAllMeanData$mrows[which(summariseAllMeanData$fullBenchmarkName ==
                                                              tempName)],
      "Category" = c(rep("BI=1s", 4), rep("BI=2s", 4), rep("BI=5s", 4), rep("BI=10s", 4))
    )
  
  names(preparedDataFrameAllDataRows)[names(preparedDataFrameAllDataRows) == "placeholder_name"] <-
    benchmark
  
  longFormatAllDataRows <-
    melt(
      setDT(preparedDataFrameAllDataRows),
      id.vars = c("RL", "Category"),
      variable.name = "BenchmarkName"
    )
  longFormatAllDataRows$BenchmarkName <-
    gsub("\\.", "-", longFormatAllDataRows$BenchmarkName)
  
  longFormatAllDataRows$RL <-
    factor(longFormatAllDataRows$RL,
           levels = c("RL=200", "RL=400", "RL=800", "RL=1600"))
  longFormatAllDataRows$BenchmarkName <-
    factor(longFormatAllDataRows$BenchmarkName, levels = benchmark)
  longFormatAllDataRows$Category <-
    factor(longFormatAllDataRows$Category,
           levels = c("BI=1s", "BI=2s", "BI=5s", "BI=10s"))
  
  longFormatAllDataRows$sdmrows <-
    summariseAllMeanData$sdmrows[which(summariseAllMeanData$fullBenchmarkName ==
                                         tempName)]
  
  longFormatAllDataRows$mrows <-
    summariseAllMeanData$mrows[which(summariseAllMeanData$fullBenchmarkName ==
                                       tempName)]
  longFormatAllDataRows$expected <-
    summariseAllMeanData$expected[which(summariseAllMeanData$fullBenchmarkName ==
                                          tempName)]
  longFormatAllDataRows$failed <-
    summariseAllMeanData$failed[which(summariseAllMeanData$fullBenchmarkName ==
                                        tempName)]
  longFormatAllDataRows$offset <-
    summariseAllMeanData$offset[which(summariseAllMeanData$fullBenchmarkName ==
                                        tempName)]

  longFormatAllDataRows$semmrows <-
    summariseAllMeanData$semmrows[which(summariseAllMeanData$fullBenchmarkName ==
                                          tempName)]
  longFormatAllDataRows$CI_low_mrows <-
    summariseAllMeanData$CI_low_mrows[which(summariseAllMeanData$fullBenchmarkName ==
                                              tempName)]
  
  longFormatAllDataRows$CI_high_mrows <-
    summariseAllMeanData$CI_high_mrows[which(summariseAllMeanData$fullBenchmarkName ==
                                               tempName)]
  
  longFormatAllDataRows <- subset(longFormatAllDataRows, Category != "BI=2s" & Category != "BI=5s" & Category != "BI=10s")
  longFormatAllDataRows <- subset(longFormatAllDataRows, RL != "RL=200" & RL != "RL=400")
  
  expectedTemp <- longFormatAllDataRows
  expectedTemp$e <- "expected"
  mrowsTemp <- longFormatAllDataRows
  mrowsTemp$m <- "mrows"
  failedTemp <- longFormatAllDataRows
  failedTemp$f <- "failed"
  
  # plotAllDataRows -------------------------------------------------------------------
  
  mrowsOnlyVal <- subset(mrowsTemp, select = -c(value, expected, failed, offset, sdmrows, semmrows, CI_low_mrows, CI_high_mrows))
  failedOnlyVal <- subset(failedTemp, select = -c(value, expected, mrows, offset, sdmrows, semmrows, CI_low_mrows, CI_high_mrows))
  colnames(mrowsOnlyVal)[4] <- "barplotVal"
  colnames(failedOnlyVal)[4] <- "barplotVal"
  colnames(mrowsOnlyVal)[5] <- "status"
  colnames(failedOnlyVal)[5] <- "status"
  allBarPlotVals <- rbind(mrowsOnlyVal, failedOnlyVal)
  fullBarPlotVals <- melt(setDT(allBarPlotVals), id.vars = c("RL","Category", "BenchmarkName", "status"), variable.name = c("barplotVal"))
  
  plotAllDataRows = ggplot(data = longFormatAllDataRows, aes(x = RL)) + #, shape = BenchmarkName)) +
    #geom_line(data = expectedTemp,
    #          aes(x = RL, y = expected, group = 1),
    #          color = "#39568CFF") +
    #geom_point(data = expectedTemp,
    #           shape = 18,
    #           aes(x = RL,
    #               y = expected,
    #               # shape = BenchmarkName,
    #               color = e),
    #           size = 2) +
    
    #geom_line(data = mrowsTemp,
    #          aes(x = RL, y = mrows, group = 1),
    #          color = "#95D840FF") +
    geom_point(data = mrowsTemp,
               shape = 18,
               aes(x = RL,
                   y = mrows,
                   # shape = BenchmarkName,
                   color = m),
               size = 3) +
    geom_bar(data = fullBarPlotVals, aes(x = RL, y = value, fill=status),alpha=0.2,position = "stack",stat="identity", show.legend = FALSE) +
#    geom_bar(data = fullBarPlotVals, aes(x = RL, y = value, fill=status),alpha=0.2,position = position_dodge(width = 0),stat="identity", show.legend = FALSE) +
    #geom_line(data = failedTemp,
    #          aes(x = RL, y = failed, group = 1),
    #          color = "#482677FF") +
    geom_point(data = failedTemp,
               shape = 17,
               aes(x = RL,
                   y = failed,
                   # shape = BenchmarkName,
                   color = f),
               size = 3) +
    #geom_bar(data = failedTemp, aes(x = RL, y = failed), fill="#482677FF",alpha=1.0,position="stack",stat="identity") +
    geom_errorbar(
      aes(ymin = mrows, ymax = mrows + sdmrows),
      width = .1,
      position = position_dodge(0.05),
      color = "snow4"
    ) +
    
    facet_wrap(
      ~ Category,
      strip.position = "bottom",
      scales = "free_x",
      nrow = 1
    ) +
    theme(
      panel.spacing = unit(0.0, "lines"),
      strip.background = element_blank(),
      axis.title.x = element_blank()
    ) +
    cleanTpl() +
    #xlab("") + ylab("Number of events") +
    xlab("") + ylab("NoT") +
    #labs(caption = paste("<span style='color:black'><b>", tempName, "</b></span>")) +
    scale_y_continuous(#limits = c(0, round(max(longFormatAllDataRows$expected+(longFormatAllDataRows$offset*2), na.rm = TRUE), digits=-4)),
      #breaks = seq(0, max(longFormatAllDataRows$expected+(longFormatAllDataRows$offset*2), na.rm = TRUE), by = 60000)) +
      #breaks = c(0, 60000, 120000, 240000, 480000, max(longFormatAllDataRows$expected+(longFormatAllDataRows$offset*2), na.rm = TRUE))) +
      #breaks = c(0, 60000, 120000, 240000, 480000, round(max(longFormatAllDataRows$expected+(longFormatAllDataRows$offset*2), na.rm = TRUE), digits=-4))) +
      limits = c(0, 540000),
      breaks = c(0, 60000, 120000, 240000, 480000, 540000)) +
    
    scale_fill_manual(
      values = c(
        #"expected" = "#39568CFF",
        "failed" = "#482677FF",
        "mrows" = "#95D840FF"
      )
    ) +
    
    scale_colour_manual(
      #labels = c("Received", "Not received", "Expected"), #"Total expected"),
      labels = c("Received", "Not received"), #"Total expected"),
      values = c(
        #"expected" = "#39568CFF",
        "failed" = "#482677FF",
        "mrows" = "#95D840FF"
      )
    ) +
    theme(
      strip.background = element_rect(
        color = "black",
        size = 0,
        fill = "grey92"
      ),
      strip.text = element_text(
        color = "black",
        size = 9,
        face = "bold"
      ),
      #plot.margin = unit(c(0, 0, 1, 0), "lines"),
      plot.margin = unit(c(0, 1, 1, 0), "lines"),
      #plot.margin = unit(c(1, 1, 1, 1), "lines"),
      strip.placement = "bottom",
    ) +
    guides(frame.colour = "black",
           # shape = guide_legend(
           #  order = 2,
           #  nrow = 1,
           #  override.aes = list(
           #    size = 1,
           #    color = "black",
           #    shape = c(NA)
           #  )
           # ),
           color = guide_legend(
             order = 1,
             nrow = 1,
             override.aes = list(size = 2, color = c("#95D840FF", "#482677FF"),
                                 shape = c(18, 17)
             )#, "#39568CFF"))
           ))
  
  plot_listFailures[[counter]] = plotAllDataRows
  datalistFailures[[counter]] = longFormatAllDataRows
  save(paste("graphene-plot-all-data-rows-", tempName, sep = ""),
       plotAllDataRows, "sentfailed")
  
  # plotTps -------------------------------------------------------------------
  
  plotTps = ggplot(data = longFormatTps, aes(x = RL, y = value)) + #, shape = BenchmarkName)) + #,color = BI.1
    #geom_line(data = longFormatTps, aes(x = RL, y = value, group = 1)) +
    geom_point(data = longFormatTps,
               aes(x = RL, y = value),
               #, shape = BenchmarkName),
               color = "black",
               size = 2) +
    geom_bar(width=0.5, data = longFormatTps, aes(x = RL, y = value), fill="black",alpha=0.2,position="stack",stat="identity") +
    #geom_label(
    #  aes(
    #    label = round(value, digits = 2),
    #    fontface="bold"
    #  ),
    #  label.size = NA,
    #  hjust=-0.25,
    #  vjust=-0.1,
    #  size=1 # 2.5
    #) +
    geom_point(data = longFormatIsMax,
               aes(x = RL, y = value),
               #, shape = BenchmarkName),
               shape=15,
               color = "#95D840FF",
               size = 3) +
    geom_bar(width=0.5, data = longFormatIsMax, aes(x = RL, y = value), fill="#95D840FF",alpha=0.2,position="stack",stat="identity") +
    geom_point(
      data = longFormatTpsTemp[longFormatTpsTemp$value == 0],
      aes(x = RL, y = value),
      shape = 18,
      color = "#482677FF",
      size = 4
    ) +
    geom_bar(width=0.5, data = longFormatTpsTemp[longFormatTpsTemp$value == 0], aes(x = RL, y = value), fill="#482677FF",alpha=0.2,position="stack",stat="identity") +
    geom_errorbar(
      aes(ymin = value, ymax = value + SDTPS),
      width = .1,
      position = position_dodge(0.05),
      color = "snow4"
    ) +
    scale_colour_manual(values = c(
      "normal" = "black",
      "max" = "#95D840FF",
      "failed" = "#482677FF"
    )) +
    facet_wrap(
      ~ Category,
      strip.position = "bottom",
      scales = "free_x",
      nrow = 1
    ) +
    theme(
      panel.spacing = unit(0.0, "lines"),
      strip.background = element_blank(),
      axis.title.x = element_blank(),
    ) +
    cleanTpl() +
    #xlab("") + ylab("Mean EPS") +
    xlab("") + ylab("MTPS") +
    
    guides(shape = guide_legend(
      nrow = 1,
      override.aes = list(size = 0, color = "black")
    )) +
    scale_y_continuous(limits = c(0
                                  , ceiling(
#                                    max(summariseByMeanTpsAndLatency$tps, na.rm = TRUE) + (max(
#                                      summariseByMeanTpsAndLatency$tps, na.rm = TRUE
                                    max(longFormatTps$value, na.rm = TRUE) + (max(
                                      longFormatTps$value, na.rm = TRUE
                                    ) / 10)
                                  ))) +
    theme(
      axis.text.x = element_blank(),
      axis.line.x = element_blank(),
      #element_line(color = "white", size = 0.0),
      axis.title.x = element_blank(),
      axis.ticks.x = element_blank(),
      strip.background = element_blank(),
      strip.text = element_blank(),
      legend.text = element_blank(),
      plot.margin = unit(c(0, 1, 1, 0), "lines"),
      #plot.margin = unit(c(1, 1, 1, 1), "lines"),
      strip.placement = "bottom",
    )
  
  plot_listTps[[counter]] = plotTps
  datalistTps[[counter]] = longFormatTps
  save(paste("graphene-plot-tps-", tempName, sep = ""),
       plotTps, "parts")
  
  longFormatLatencyTemp <- longFormatLatency
  longFormatLatencyTemp$highlight <-
    ifelse((longFormatLatency$value == 0),
           "failed",
           longFormatLatency$highlight)
  longFormatLatency$normaltag <- "normal"
  longFormatIsMin$mintag <- "minimum"
  longFormatLatencyTemp$failedtag <- "failed"
  
  # plotLatency -------------------------------------------------------------------
  
  plotLatency = ggplot(data = longFormatLatency, aes(x = RL, y = value)) + #, shape = BenchmarkName)) + #,color = BI.1
    #geom_line(data = longFormatLatency, aes(x = RL, y = value, group = 1)) +
    geom_point(data = longFormatLatency,
               aes(x = RL,
                   y = value,
                   #shape = BenchmarkName,
                   color = normaltag),
               size = 2) +
    geom_bar(width=0.5, data = longFormatLatency, aes(x = RL, y = value), fill="black",alpha=0.2,position="stack",stat="identity") +    #geom_label(
    #  aes(
    #    label = round(value, digits = 2),
    #    fontface="bold"
    #  ),
    #  label.size = NA,
    #  hjust=-0.25,
    #  vjust=-0.1,
    #  size=1 # 2.5
    #) +
    geom_point(data = longFormatIsMin,
               aes(x = RL,
                   y = value,
                   #shape = BenchmarkName,
                   color = mintag),
               shape = 17,
               size = 3) +
    geom_bar(width=0.5, data = longFormatIsMin, aes(x = RL, y = value), fill = "#20A387FF",alpha=0.2,position="stack",stat="identity") +
    geom_point(
      data = longFormatLatencyTemp[longFormatLatencyTemp$value == 0],
      aes(x = RL, y = value, color = failedtag),
      shape = 18,
      size = 4
    ) +
    geom_bar(width=0.5, data = longFormatLatencyTemp[longFormatLatencyTemp$value == 0], aes(x = RL, y = value), fill="#20A387FF",alpha=0.2,position="stack",stat="identity") +
    geom_errorbar(
      aes(ymin = value, ymax = value + SDLATENCY),
      width = .1,
      position = position_dodge(0.05),
      color = "snow4"
    ) +
    facet_wrap(
      ~ Category,
      strip.position = "bottom",
      scales = "free_x",
      nrow = 1
    ) +
    theme(
      panel.spacing = unit(0.0, "lines"),
      strip.background = element_blank(),
      axis.title.x = element_blank(),
    ) +
    cleanTpl() +
    #xlab("") + ylab("Mean finalization latency in s") +
    xlab("") + ylab("MFLS") +
    scale_y_continuous(limits = c(0,
                                  ceiling(
#                                    max(summariseByMeanTpsAndLatency$avglatency, na.rm = TRUE) + (
#                                      max(summariseByMeanTpsAndLatency$avglatency, na.rm = TRUE) / 10
                                    max(longFormatLatency$value, na.rm = TRUE) + (
                                      max(longFormatLatency$value, na.rm = TRUE) / 10
                                    )
                                  ))) +
    
    scale_colour_manual(
      #labels = c("Maximum EPS", "Minimum Latency", "Failed Benchmark", ""),
      labels = c("Maximum MTPS", "Minimum MFLS", "Failed benchmark", ""),
      values = c(
        "minimum" = "#20A387FF",
        "failed" = "#482677FF",
        "maxtag" = "#95D840FF",
        "normal" = "black"
      )
    ) +
    theme(
      strip.background = element_rect(
        color = "black",
        size = 0,
        fill = "grey92"
      ),
      strip.text = element_text(
        color = "black",
        size = 9,
        face = "bold"
      ),
      plot.margin = unit(c(0, 1, 1, 0), "lines"),
      #plot.margin = unit(c(1, 1, 1, 1), "lines"),
      strip.placement = "bottom",
    ) +
    guides(frame.colour = "black",
           #shape = guide_legend(
           #  order = 2,
           #  nrow = 1,
           #  override.aes = list(
           #    size = 1,
           #    color = "black",
           #    shape = c(NA)
           #  )
           #),
           color = guide_legend(
             order = 1,
             nrow = 1, # 1
             override.aes = list(
               size = 2#,
               #            color = c("black", "red", "green", "blue"),
#               color = c("#95D840FF", "#20A387FF", "#482677FF", "black"),
               #shape = c(16, 16, 15, NA)
#               shape = c(15, 17, 18, NA)#(16, 16, 15, NA)
             )
           )) #+
  #labs(caption = paste("<span style='color:black'><b>", tempName, "</b></span>"))
  
  plot_listLatency[[counter]] = plotLatency
  datalistLatency[[counter]] = longFormatLatency
  save(paste("graphene-plot-latency-", tempName, sep = ""),
       plotLatency, "parts")
  
  save(
    paste("graphene-plot-tpsandlatency-", tempName, sep = ""),
    egg::ggarrange(plotTps, plotLatency), "merged"
  )
  
  datalistSubsetTps[[counter]] = preparedDataFrameTps
  datalistSubsetLatency[[counter]] = preparedDataFrameLatency
  datalistSubsetFailures[[counter]] = longFormatAllDataRows
  
}

egg::ggarrange(plot_listTps[1][[1]],
               plot_listLatency[1][[1]])
# heights = c(0.33, 0.33))

# maxTable ----------------------------------------------------------------

getByMax <-
  as.data.frame(do.call(rbind, lapply(datalistTps, function(x)
    x[which(x$value == max(x$value, na.rm = TRUE))])))
getByHighlight <-
  as.data.frame(do.call(rbind, lapply(datalistTps, function(x)
    x[x$highlight == "highlight"])))

getByHighlight <-
  subset(getByHighlight, select = -c(normaltag, highlight, SDTPS, SEMTPS, CI_low_tps, CI_high_tps))

colnames(getByHighlight)[2] <- "BI"
colnames(getByHighlight)[4] <- "Max TPS"

getByHighlight <-
  getByHighlight[c("BenchmarkName", "RL", "BI", "Max TPS")]

getByHighlight$RL = str_replace(getByHighlight$RL, "RL=", "")
getByHighlight$BI = str_replace(getByHighlight$BI, "BI=", "")
getByHighlight$BI = str_replace(getByHighlight$BI, "s", "")

datalistLatencyTemp <- datalistLatency
for (i in 1:length(datalistLatencyTemp)) {
  datalistLatencyTemp[[i]]$RL <- gsub("RL=", "", datalistLatencyTemp[[i]]$RL)
  datalistLatencyTemp[[i]]$Category <- gsub("BI=", "", datalistLatencyTemp[[i]]$Category)
  datalistLatencyTemp[[i]]$Category <- gsub("s", "", datalistLatencyTemp[[i]]$Category)
}

latencyListForHighlight <- c()
for(i in 1:length(datalistLatencyTemp)) {
  for(j in 1:nrow(datalistLatencyTemp[[i]])) {
    for(k in 1:nrow(getByHighlight)) {
      if(as.numeric(as.character(datalistLatencyTemp[[i]]$RL[j])) == getByHighlight$RL[k]
         & as.numeric(as.character(datalistLatencyTemp[[i]]$Category[j])) == getByHighlight$BI[k]
         & datalistLatencyTemp[[i]]$BenchmarkName[j] == getByHighlight$BenchmarkName[k]) {
        latencyListForHighlight[k] <- datalistLatencyTemp[[i]]$value[j]
      }
      if(getByHighlight$RL[k]==0 
         & datalistLatencyTemp[[i]]$BenchmarkName[j] == getByHighlight$BenchmarkName[k]) {
        latencyListForHighlight[k] <- 0.0
      }
    }}}
getByHighlight$latency <- do.call(cbind, 
                                  list(latencyListForHighlight))
colnames(getByHighlight)[5] <- "Latency"

durationList <- c()
bmsDuration <- c("DoNothing DoNothing", "KeyValue Set", "KeyValue Get", 
                 "BankingApp CreateAccount", "BankingApp SendPayment", "BankingApp Balance"
)
cntDuration <- 0
for(duration in bmsDuration) {
  cntDuration <- cntDuration + 1
  if(length(summariseByMeanTpsAndLatency[summariseByMeanTpsAndLatency$fullBenchmarkName==duration &
                                         getByHighlight[cntDuration, ]$RL == as.character(as.numeric(summariseByMeanTpsAndLatency$rl)*4) &
                                         getByHighlight[cntDuration, ]$BI == summariseByMeanTpsAndLatency$cutCriteria
                                         ,]$duration) == 0 ||
     is.na(summariseByMeanTpsAndLatency[summariseByMeanTpsAndLatency$fullBenchmarkName==duration &
                                        getByHighlight[cntDuration, ]$RL == as.character(as.numeric(summariseByMeanTpsAndLatency$rl)*4) &
                                        getByHighlight[cntDuration, ]$BI == summariseByMeanTpsAndLatency$cutCriteria
                                        ,]$duration) ||
     is.nan(  summariseByMeanTpsAndLatency[summariseByMeanTpsAndLatency$fullBenchmarkName==duration &
                                           getByHighlight[cntDuration, ]$RL == as.character(as.numeric(summariseByMeanTpsAndLatency$rl)*4) &
                                           getByHighlight[cntDuration, ]$BI == summariseByMeanTpsAndLatency$cutCriteria
                                           ,]$duration)) {
    durationList <- append(durationList, 0.0)  
  } else {
    durationList <- append(durationList,
                           summariseByMeanTpsAndLatency[summariseByMeanTpsAndLatency$fullBenchmarkName==duration &
                                                          getByHighlight[cntDuration, ]$RL == as.character(as.numeric(summariseByMeanTpsAndLatency$rl)*4) &
                                                          getByHighlight[cntDuration, ]$BI == summariseByMeanTpsAndLatency$cutCriteria
                                                        ,]$duration)
  }
}
getByHighlight$duration <- do.call(cbind, 
                                   list(durationList))
colnames(getByHighlight)[6] <- "Duration"

jacksonList <- list()
for (i in 1:length(datalistFailures)) {
  testx <- datalistFailures[[i]]
  testx$RL <- gsub("RL=", "", testx$RL)
  testx$Category <- gsub("BI=", "", testx$Category)
  testx$Category <- gsub("s", "", testx$Category)
  t <- testx[which(getByHighlight[i,]$BenchmarkName == testx$BenchmarkName & getByHighlight[i,]$RL == testx$RL & getByHighlight[i,]$BI == testx$Category),]$value
  jacksonList <- append(jacksonList, t)
  }
getByHighlight$testx <- do.call(cbind, 
                                list(jacksonList))
colnames(getByHighlight)[7] <- "Jacksons"

xt <-
  xtable(
    getByHighlight,
    digits = 2,
    align = "lccccccc",
    caption = "Graphene",
    #"Sawtooth",
    sanitize.text.function = identity
  )

#digits(xt) <- 4
align(xt) <- xalign(xt)
#digits(xt) <- xdigits(xt)
#display(xt) <- xdisplay(xt)

print(
  xtable(xt, align = "l|cc|ccccc", caption = "Graphene"),
  #"Sawtooth"),
  include.rownames = FALSE,
  sanitize.text.function = identity
)

# failedTable ----------------------------------------------------------------

successfulAndFailedGroup <-
  tpsAndLatencyData %>% group_by(fullBenchmarkName, cutCriteria, rl) #bm, bmf,

summariseByMaxFailedAndSuccessful <-
  successfulAndFailedGroup %>% summarise(
    successful = max(successful, na.rm = TRUE),
    failed = max(failed, na.rm = TRUE),
    .groups = "keep"
  ) %>% arrange(match(
    fullBenchmarkName,
    c(
      "DoNothing DoNothing",
      "KeyValue Set",
      "KeyValue Get",
      "BankingApp CreateAccount",
      "BankingApp SendPayment",
      "BankingApp Balance"
    )
  ),
  match(rl, c("50", "100", "200", "400")),
  match(cutCriteria, c("1", "2", "5", "10")))#, desc(rl), desc(tps))

optList <- c()
for (n in 1:nrow(summariseByMaxFailedAndSuccessful)) {
  #grepl(".*-donothing-doNothing-.*-opt-100-.*|.*-keyvalue-set-.*-opt-50-.*|.*-keyvalue-get-.*-opt-50-.*|.*-sb-createAccount-.*-opt-50-.*|.*-sb-sendPayment-.*-opt-100-.*|.*-sb-balance-.*-opt-100-.*", run_id, ignore.case = FALSE))
  if(summariseByMaxFailedAndSuccessful[n,]$fullBenchmarkName == "DoNothing DoNothing") {
    optList <- append(optList, 100)
  } else if(summariseByMaxFailedAndSuccessful[n,]$fullBenchmarkName == "KeyValue Set") {
    optList <- append(optList, 50)
  }else if(summariseByMaxFailedAndSuccessful[n,]$fullBenchmarkName == "KeyValue Get") {
    optList <- append(optList, 50)
  } else if(summariseByMaxFailedAndSuccessful[n,]$fullBenchmarkName == "BankingApp CreateAccount") {
    optList <- append(optList, 50)
  }else if(summariseByMaxFailedAndSuccessful[n,]$fullBenchmarkName == "BankingApp SendPayment") {
    optList <- append(optList, 100)
  }else if(summariseByMaxFailedAndSuccessful[n,]$fullBenchmarkName == "BankingApp Balance") {
    optList <- append(optList, 100)
  } else {
    optList <- append(optList, 0)
  }
}
summariseByMaxFailedAndSuccessful$opt <- do.call(cbind, 
                                                 list(optList))

#colnames(summariseByMaxFailedAndSuccessful)[1] <- "Benchmark"
#colnames(summariseByMaxFailedAndSuccessful)[2] <- "Function"

colnames(summariseByMaxFailedAndSuccessful)[1] <- "Benchmark"
colnames(summariseByMaxFailedAndSuccessful)[2] <- "BI"
colnames(summariseByMaxFailedAndSuccessful)[3] <- "RL"
colnames(summariseByMaxFailedAndSuccessful)[4] <- "Successful"
colnames(summariseByMaxFailedAndSuccessful)[5] <- "Failed"
colnames(summariseByMaxFailedAndSuccessful)[6] <- "Opt"


summariseByMaxFailedAndSuccessful <-
  summariseByMaxFailedAndSuccessful[c("Benchmark", "RL", "BI", "Successful", "Failed", "Opt")]

summariseByMaxFailedAndSuccessful$Failed <-
  ifelse(
    summariseByMaxFailedAndSuccessful$Failed > 0,
    paste("\\textbf{", summariseByMaxFailedAndSuccessful$Failed, "}"),
    summariseByMaxFailedAndSuccessful$Failed
  )

xt <-
  xtable(
    summariseByMaxFailedAndSuccessful,
    digits = 2,
    align = "l|cccccc",
    caption = "Graphene",
    #"Sawtooth",
    sanitize.text.function = identity
  )

#digits(xt) <- 4
align(xt) <- xalign(xt)
#digits(xt) <- xdigits(xt)
#display(xt) <- xdisplay(xt)

print(
  xtable(xt, align = "l|cccccc", caption = "Graphene"),
  #"Sawtooth"),
  include.rownames = FALSE,
  sanitize.text.function = identity,
  type = 'latex'
)

# newTables ---------------------------------------------------------------

# longFormatLatencyBak <- datalistLatency[[1]] #longFormatLatency
# longFormatLatencyBak$RL <- apply(longFormatLatencyBak, 1, function(x) gsub("RL=", " ", x[["RL"]], fixed = TRUE))
# longFormatLatencyBak$SDLATENCY <- round(longFormatLatencyBak$SDLATENCY, digits = 2)
# longFormatLatencyBak$value <- round(longFormatLatencyBak$value, digits = 2)
# longFormatLatencyBak <- longFormatLatencyBak[,-6:-7]
# longFormatLatencyBak <- longFormatLatencyBak[,-4]
# longFormatLatencyBak <- longFormatLatencyBak[,c(1,2,4,3)]
# names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'value'] <- 'MFLS'
# names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'SDLATENCY'] <- 'SD'
# 
# longFormatTpsBak <- datalistTps[[1]] #longFormatTps
# longFormatTpsBak$RL <- apply(longFormatTpsBak, 1, function(x) gsub("RL=", " ", x[["RL"]], fixed = TRUE))
# longFormatTpsBak$SDTPS <- round(longFormatTps$SDTPS, digits = 2)
# longFormatTpsBak$value <- round(longFormatTpsBak$value, digits = 2)
# longFormatTpsBak <- longFormatTpsBak[,-6:-7]
# longFormatTpsBak <- longFormatTpsBak[,-4]
# longFormatTpsBak <- longFormatTpsBak[,c(1,2,4,3)]
# names(longFormatTpsBak)[names(longFormatTpsBak) == 'value'] <- 'MTPS'
# names(longFormatTpsBak)[names(longFormatTpsBak) == 'SDTPS'] <- 'SD'
# 
# longFormatAllDataRowsBak <- datalistFailures[[1]] #longFormatAllDataRows
# longFormatAllDataRowsBak$RL <- apply(longFormatAllDataRowsBak, 1, function(x) gsub("RL=", " ", x[["RL"]], fixed = TRUE))
# longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,-3]
# longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,-5]
# longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,-6:-7]
# longFormatAllDataRowsBak$sdmrows <- round(longFormatAllDataRowsBak$sdmrows, digits = 2)
# longFormatAllDataRowsBak$value <- round(longFormatAllDataRowsBak$value, digits = 2)
# longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,c(1,2,3,5,4)]
# names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'value'] <- 'Received NoT'
# names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'sdmrows'] <- 'SD'
# names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'expected'] <- 'Expected NoT'

longFormatLatencyBak <- datalistLatency[[1]] #longFormatLatency
longFormatLatencyBak$RL <- apply(longFormatLatencyBak, 1, function(x) gsub("RL=", " ", x[["RL"]], fixed = TRUE))
longFormatLatencyBak$SDLATENCY <- round(longFormatLatencyBak$SDLATENCY, digits = 2)
longFormatLatencyBak$value <- round(longFormatLatencyBak$value, digits = 2)
longFormatLatencyBak$SEMLATENCY <- round(longFormatLatencyBak$SEMLATENCY, digits = 2)
longFormatLatencyBak$pm_value <- longFormatLatencyBak$CI_high_latency - longFormatLatencyBak$value
longFormatLatencyBak$pm_value <- paste("$\\pm$",round(longFormatLatencyBak$pm_value, digits = 2), sep="")
longFormatLatencyBak <- longFormatLatencyBak[,-7]
longFormatLatencyBak <- longFormatLatencyBak[,-8:-9]
#longFormatLatencyBak <- longFormatLatencyBak[,-1:-2]
longFormatLatencyBak <- longFormatLatencyBak[,c(1,2,7,3,4,8)]
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'value'] <- 'MFLS'
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'SDLATENCY'] <- 'SD'
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'SEMLATENCY'] <- 'SEM'
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'pm_value'] <- '95\\% CI'

longFormatTpsBak <- datalistTps[[1]] #longFormatTps
longFormatTpsBak$RL <- apply(longFormatTpsBak, 1, function(x) gsub("RL=", " ", x[["RL"]], fixed = TRUE))
longFormatTpsBak$SDTPS <- round(longFormatTpsBak$SDTPS, digits = 2)
longFormatTpsBak$value <- round(longFormatTpsBak$value, digits = 2)
longFormatTpsBak$SEMTPS <- round(longFormatTpsBak$SEMTPS, digits = 2)
longFormatTpsBak$pm_value <- longFormatTpsBak$CI_high_tps - longFormatTpsBak$value
longFormatTpsBak$pm_value <- paste("$\\pm$",round(longFormatTpsBak$pm_value, digits = 2), sep="")
longFormatTpsBak <- longFormatTpsBak[,-9:-10]
longFormatTpsBak <- longFormatTpsBak[,-7]
longFormatTpsBak <- longFormatTpsBak[,c(1,2,7,3,4,8)]
names(longFormatTpsBak)[names(longFormatTpsBak) == 'value'] <- 'MTPS'
names(longFormatTpsBak)[names(longFormatTpsBak) == 'SDTPS'] <- 'SD'
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'SEMTPS'] <- 'SEM'
names(longFormatTpsBak)[names(longFormatTpsBak) == 'pm_value'] <- '95\\% CI'

longFormatAllDataRowsBak <- datalistFailures[[1]] #longFormatAllDataRows
longFormatAllDataRowsBak$RL <- apply(longFormatAllDataRowsBak, 1, function(x) gsub("RL=", " ", x[["RL"]], fixed = TRUE))
longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,-3]
longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,-7:-8]
longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,-5]
longFormatAllDataRowsBak$sdmrows <- round(longFormatAllDataRowsBak$sdmrows, digits = 2)
longFormatAllDataRowsBak$value <- round(longFormatAllDataRowsBak$value, digits = 2)
longFormatAllDataRowsBak$semmrows <- round(longFormatAllDataRowsBak$semmrows, digits = 2)
longFormatAllDataRowsBak$pm_value <- longFormatAllDataRowsBak$CI_high_mrows - longFormatAllDataRowsBak$value
longFormatAllDataRowsBak$pm_value <- paste("$\\pm$",round(longFormatAllDataRowsBak$pm_value, digits = 2), sep="")
longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,c(1,2,3,5,4,6,9)]
names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'value'] <- 'Received NoT'
names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'sdmrows'] <- 'SD'
names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'expected'] <- 'Expected NoT'
names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'semmrows'] <- 'SEM'
names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'pm_value'] <- '95\\% CI'

longFormatLatencyBak$Category <- apply(longFormatLatencyBak, 1, function(x) gsub("BI=|BP=|BS=|MM=|PD=", " ", x[["Category"]], fixed = FALSE))
longFormatTpsBak$Category <- apply(longFormatTpsBak, 1, function(x) gsub("BI=|BP=|BS=|MM=|PD=", " ", x[["Category"]], fixed = FALSE))
longFormatAllDataRowsBak$Category <- apply(longFormatAllDataRowsBak, 1, function(x) gsub("BI=|BP=|BS=|MM=|PD=", " ", x[["Category"]], fixed = FALSE))
colnames(longFormatLatencyBak)[2] <- "block_interval"
colnames(longFormatTpsBak)[2] <- "block_interval"
colnames(longFormatAllDataRowsBak)[2] <- "block_interval"


multi_xtable <- function(...)
{
  vars <- as.list(match.call(expand.dots = TRUE))[-1]
  df_list <- lapply(vars, eval)
  num_cols <- sapply(df_list, length)
  if (!all(num_cols == num_cols[1]))
    stop("All data frames must have equal number of columns")  
  xtables <- lapply(df_list, function(x) capture.output(xtable::xtable(x)
  ))
  if (length(xtables) == 1) 
    return(xtables[[1]])  
  header <- xtables[[1]][1:6]
  tail <- xtables[[1]][length(xtables[[1]]) + (-1:0)]
  xtables <- lapply(xtables, function(x) x[7:(length(x) - 2)])
  xtables <- do.call("c", xtables)  
  cat(header, xtables, tail, sep = "\n")
}

makeTbl <- function(tbl, cpt, aln1, aln2) {
  xt <-
    xtable(
      tbl,
      digits = 2,
      align = aln1,
      caption = cpt,
      sanitize.text.function = identity
    )
  
  #digits(xt) <- 4
  align(xt) <- xalign(xt)
  #digits(xt) <- xdigits(xt)
  display(xt) <- xdisplay(xt)
  
  print(
    xtable(xt, align = aln2, caption = cpt),
    #"Sawtooth"),
    include.rownames = FALSE,
    sanitize.text.function = identity
  )
  
  return(xt)
  
}

#longFormatTpsBakT <- makeTbl(longFormatTpsBak, "test", "ccccc", "ccc|cc")
#longFormatLatencyBakT <- makeTbl(longFormatLatencyBak, "test", "ccccc", "ccc|cc")
#multi_xtable(longFormatTpsBakT, longFormatLatencyBakT)
makeTbl(longFormatAllDataRowsBak, "test",  "cccccccc", "cccc|cccc")

makeTbl(cbind(longFormatTpsBak, longFormatLatencyBak[, 3:6]), "test2", "ccccccccccc", "ccccc|ccc|ccc")