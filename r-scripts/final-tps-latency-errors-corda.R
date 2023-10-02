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
      grepl(
        "4000000-cordaConfiguration-.*-cordaos-.*",
        #"4000000-cordaConfiguration-.*-cordaenterprise-.*",
        run_id,
        ignore.case = FALSE
      )
      #      grepl("4000000-sawtoothConfiguration-.*", run_id, ignore.case = FALSE)
    )
  #             "4000000-grapheneConfiguration-.*donothing-.*", run_id, ignore.case = FALSE))
  #  fileToUseFullAll <-
  #    filter(fileToUseFullAll,
  #           grepl(".*-opt-50-.*", run_id, ignore.case = FALSE))
  #           grepl(".*-notpbpc-100-.*", run_id, ignore.case = FALSE))
  
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
    paste("C:/Users/frank/Downloads/final-plots/corda-os/",path,"/", titleVar, ".png"),
    #paste("C:/Users/parallels/Downloads/final-plots/corda-enterprise/",path,"/",titleVar, ".png"),
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
  "C:/Users/frank/Downloads/testwr-cordaos"
#"C:/Users/parallels/Downloads/testwr-cordaenterprise"

tpsAndLatencyData <- prepareFiles(fNameFullAll)

fNameFullAllRep <-
  "C:/Users/frank/Downloads/failed1query-rid-data-1657910318868.csv" #fabric
tpsAndLatencyDataRep <- prepareFiles(fNameFullAllRep)
tpsAndLatencyDataRep <- tpsAndLatencyDataRep[tpsAndLatencyDataRep$run_id != "4000000-cordaConfiguration-sb-createAccount-40-flalv-rn-1-hetzner-repid-0-cordaenterprise-rl-10",]
tpsAndLatencyDataRep <- tpsAndLatencyDataRep[tpsAndLatencyDataRep$run_id != "4000000-cordaConfiguration-sb-balance-40-flalv-rn-1-hetzner-repid-0-cordaenterprise-rl-10",]
for (i in 1:nrow(tpsAndLatencyData))
{
  if(nrow(tpsAndLatencyDataRep) > 0) {
    for(j in 1:nrow(tpsAndLatencyDataRep)) 
      if(tpsAndLatencyData[i,]$stf=="1970-01-01 00:59:59+01" & tpsAndLatencyData[i,]$run_id ==tpsAndLatencyDataRep[j,]$run_id) {
        print(paste("Replacing: ", tpsAndLatencyData[i, ]$run_id))
        tpsAndLatencyData[i, 1:20] <- tpsAndLatencyDataRep[j, ]
      }
  }
}

tpsAndLatencyData$rl = str_split_fixed(tpsAndLatencyData$run_id, "-", Inf)[, 14]
tpsAndLatencyData$fullBenchmarkName <-
  paste(tpsAndLatencyData$bm, tpsAndLatencyData$bmf)

tpsAndLatencyData$avglatency <-
  replace(tpsAndLatencyData$avglatency,
          tpsAndLatencyData$avglatency == 0,
          NA)
tpsAndLatencyData$tps <-
  replace(tpsAndLatencyData$tps, tpsAndLatencyData$tps == 0, NA)

generalGroup <-
  tpsAndLatencyData %>% group_by(fullBenchmarkName, rl) # %>% filter(tps == max(tps))

#summariseByMeanTpsAndLatency <-
#  generalGroup %>% summarise(
#    sdtps = sd(tps, na.rm = TRUE),
#    sdavglatency = sd(avglatency, na.rm = TRUE),
#    tps = mean(tps, na.rm = TRUE),
#    avglatency = mean(avglatency, na.rm = TRUE),
#    duration = mean(duration, na.rm = TRUE),
#    .groups = "keep"
#  ) %>% arrange(match(rl, c("5", "10", "20", "40")))#, desc(rl), desc(tps))
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
  ) %>% arrange(match(rl, c("5", "10", "20", "40")))

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
summariseByMeanTpsAndLatency$duration<-ifelse (summariseByMeanTpsAndLatency$avglatency == 0 | summariseByMeanTpsAndLatency$tps == 0,
                                               0,
                                               summariseByMeanTpsAndLatency$duration)

summariseByMeanTpsAndLatency$tps<-ifelse (summariseByMeanTpsAndLatency$avglatency == 0,
                                          0,
                                          summariseByMeanTpsAndLatency$tps)

summariseByMeanTpsAndLatency$avglatency<-ifelse (summariseByMeanTpsAndLatency$tps == 0,
                                                 0,
                                                 summariseByMeanTpsAndLatency$avglatency)

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

toAppendDfForGetByHighlightTps <- data.frame()
toAppendDfForGetByHighlightLatency <- data.frame()
#colnames(toAppendDfForGetByHighlightTps) <- c("BenchmarkName", "RL", "Max TPS")
#colnames(toAppendDfForGetByHighlightLatency) <- c("BenchmarkName", "RL", "Min Latency")

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
    data.frame("RL" = c(rep(
      c("RL=20", "RL=40", "RL=80", "RL=160"), 1
    )),
    "placeholder_name" = summariseByMeanTpsAndLatency$tps[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                  tempName)],
    "SDTPS" = summariseByMeanTpsAndLatency$sdtps[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                         tempName)],
    "SEMTPS" = summariseByMeanTpsAndLatency$semtps[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                          tempName)],
    "CI_low_tps" = summariseByMeanTpsAndLatency$CI_low_tps[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                           tempName)],
    "CI_high_tps" = summariseByMeanTpsAndLatency$CI_high_tps[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                 tempName)])
  
  print(preparedDataFrameTps)
  
  preparedDataFrameTps <- subset(preparedDataFrameTps, RL != "RL=40" & RL != "RL=80")
  
  names(preparedDataFrameTps)[names(preparedDataFrameTps) == "placeholder_name"] <-
    benchmark
  
  longFormatTps <-
    melt(
      setDT(preparedDataFrameTps),
      id.vars = c("RL", "SDTPS", "SEMTPS", "CI_low_tps", "CI_high_tps"),
      variable.name = "BenchmarkName"
    )
  longFormatTps$BenchmarkName <-
    gsub("\\.", "-", longFormatTps$BenchmarkName)
  
  longFormatTps$RL <-
    factor(longFormatTps$RL,
           levels = c("RL=20", "RL=40", "RL=80", "RL=160"))
  longFormatTps$BenchmarkName <-
    factor(longFormatTps$BenchmarkName, levels = benchmark)
  
  tmpVecForFailedGetByHighlightTps <- c()
  
  if (all(longFormatTps$value == 0)) {
    if (length(tmpVecForFailedGetByHighlightTps) == 0) {
      val <-
        aggregate(value ~ BenchmarkName, FUN = head, 1, data = longFormatTps)
      tmpVecForFailedGetByHighlightTps <-
        append(tmpVecForFailedGetByHighlightTps, val)
      toAppendDfForGetByHighlightTps <-
        rbind(
          toAppendDfForGetByHighlightTps,
          data.frame(
            "BenchmarkName" = val$BenchmarkName,
            "RL" = 0,
            "Max TPS" = val$value
          )
        )
    }
  } else {
    aggDataMaxTps <-
      aggregate(x = value ~ BenchmarkName,
                FUN = max,
                data = longFormatTps)
  }
  
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
    data.frame("RL" = c(rep(
      c("RL=20", "RL=40", "RL=80", "RL=160"), 1
    )),
    "placeholder_name" = summariseByMeanTpsAndLatency$avglatency[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                         tempName)],
    "SDLATENCY" = summariseByMeanTpsAndLatency$sdavglatency[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                    tempName)],
    "SEMLATENCY" = summariseByMeanTpsAndLatency$semavglatency[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                           tempName)],
    "CI_low_latency" = summariseByMeanTpsAndLatency$CI_low_avglatency[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                   tempName)],
    "CI_high_latency" = summariseByMeanTpsAndLatency$CI_high_avglatency[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                     tempName)]
    )
  
  preparedDataFrameLatency <- subset(preparedDataFrameLatency, RL != "RL=40" & RL != "RL=80")
  
  names(preparedDataFrameLatency)[names(preparedDataFrameLatency) == "placeholder_name"] <-
    benchmark
  
  longFormatLatency <-
    melt(
      setDT(preparedDataFrameLatency),
      id.vars = c("RL", "SDLATENCY", "SEMLATENCY", "CI_low_latency", "CI_high_latency"),
      variable.name = "BenchmarkName"
    )
  longFormatLatency$BenchmarkName <-
    gsub("\\.", "-", longFormatLatency$BenchmarkName)
  
  longFormatLatency$RL <-
    factor(longFormatLatency$RL,
           levels = c("RL=20", "RL=40", "RL=80", "RL=160"))
  longFormatLatency$BenchmarkName <-
    factor(longFormatLatency$BenchmarkName, levels = benchmark)
  
  tmpVecForFailedGetByHighlightLatency <- c()
  
  if (all(longFormatLatency$value == 0)) {
    if (length(tmpVecForFailedGetByHighlightLatency) == 0) {
      val <-
        aggregate(value ~ BenchmarkName, FUN = head, 1, data = longFormatLatency)
      tmpVecForFailedGetByHighlightLatency <-
        append(tmpVecForFailedGetByHighlightLatency, val)
      toAppendDfForGetByHighlightLatency <-
        rbind(
          toAppendDfForGetByHighlightLatency,
          data.frame(
            "BenchmarkName" = val$BenchmarkName,
            "RL" = 0,
            "Min Latency" = val$value
          )
        )
    }
  } else {
    aggDataMinLatency <-
      aggregate(
        x = value ~ BenchmarkName,
        FUN = min,
        data = longFormatLatency,
        subset = value > 0
      )
  }
  
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
      .groups = "keep") %>% arrange(match(rl, c("5", "10", "20", "40")))
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
    data.frame("RL" = c(rep(
      c("RL=20", "RL=40", "RL=80", "RL=160"), 1
    )),
    "placeholder_name" = summariseAllMeanData$mrows[which(summariseAllMeanData$fullBenchmarkName ==
                                                            tempName)])
  
  names(preparedDataFrameAllDataRows)[names(preparedDataFrameAllDataRows) == "placeholder_name"] <-
    benchmark
  
  longFormatAllDataRows <-
    melt(
      setDT(preparedDataFrameAllDataRows),
      id.vars = c("RL"),
      variable.name = "BenchmarkName"
    )
  longFormatAllDataRows$BenchmarkName <-
    gsub("\\.", "-", longFormatAllDataRows$BenchmarkName)
  
  longFormatAllDataRows$RL <-
    factor(longFormatAllDataRows$RL,
           levels = c("RL=20", "RL=40", "RL=80", "RL=160"))
  longFormatAllDataRows$BenchmarkName <-
    factor(longFormatAllDataRows$BenchmarkName, levels = benchmark)
  
  longFormatAllDataRows$sdmrows <-
    summariseAllMeanData$sdmrows[which(summariseAllMeanData$fullBenchmarkName ==
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
  
  longFormatAllDataRows <- subset(longFormatAllDataRows, RL != "RL=40" & RL != "RL=80")
  
  expectedTemp <- longFormatAllDataRows
  expectedTemp$e <- "expected"
  mrowsTemp <- longFormatAllDataRows
  mrowsTemp$m <- "mrows"
  failedTemp <- longFormatAllDataRows
  failedTemp$f <- "failed"
  
  # plotAllDataRows -------------------------------------------------------------------
  
  mrowsOnlyVal <- subset(mrowsTemp, select = -c(value, expected, failed, offset, sdmrows, semmrows, CI_low_mrows, CI_high_mrows))
  failedOnlyVal <- subset(failedTemp, select = -c(value, expected, mrows, offset, sdmrows, semmrows, CI_low_mrows, CI_high_mrows))
  colnames(mrowsOnlyVal)[3] <- "barplotVal"
  colnames(failedOnlyVal)[3] <- "barplotVal"
  colnames(mrowsOnlyVal)[4] <- "status"
  colnames(failedOnlyVal)[4] <- "status"
  allBarPlotVals <- rbind(mrowsOnlyVal, failedOnlyVal)
  fullBarPlotVals <- melt(setDT(allBarPlotVals), id.vars = c("RL", "BenchmarkName", "status"), variable.name = c("barplotVal"))
  
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
    geom_errorbar(
      aes(ymin = mrows, ymax = mrows + sdmrows),
      width = .1,
      position = position_dodge(0.05),
      color = "snow4"
    ) +
    geom_bar(data = fullBarPlotVals, aes(x = RL, y = value, fill=status),alpha=0.2,position = "stack",stat="identity", show.legend = FALSE) +
    #geom_bar(data = fullBarPlotVals, aes(x = RL, y = value, fill=status),alpha=0.2,position = position_dodge(width = 0),stat="identity", show.legend = FALSE) +
    #geom_line(data = failedTemp,
    #          aes(x = RL, y = failed, group = 1),
    #          color = "#482677FF") +
    geom_point(data = failedTemp,
               shape = 17, #18,
               aes(x = RL,
                   y = failed,
                   # shape = BenchmarkName,
                   color = f),
               size = 3) +
    #geom_bar(data = failedTemp, aes(x = RL, y = failed), fill="#482677FF",alpha=1.0,position="stack",stat="identity") +
    
    #facet_wrap(
    #  ~ Category,
    #  strip.position = "bottom",
    #  scales = "free_x",
    #  nrow = 1
    #) +
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
      limits = c(0, 54000),
      breaks = c(0, 6000, 12000, 24000, 48000, 54000)) +
    
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
  save(paste("cordaOs-plot-all-data-rows-", tempName, sep = ""),
       #  save(paste("cordaEnterprise-plot-all-data-rows-", tempName, sep = ""),
       plotAllDataRows, "sentfailed")
  
  # plotTps -------------------------------------------------------------------
  
  plotTps = ggplot(data = longFormatTps, aes(x = RL, y = value)) + #, shape = BenchmarkName)) + #,color = BS.1
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
    #facet_wrap(
    #  ~ Category,
    #  strip.position = "bottom",
    #  scales = "free_x",
    #  nrow = 1
    #) +
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
    ylim(0, NA) +
    scale_y_continuous(limits = c(0,
                                  ifelse(                                  ceiling(
                                    #                                    max(summariseByMeanTpsAndLatency$tps, na.rm = TRUE) + (
                                    #                                      max(summariseByMeanTpsAndLatency$tps, na.rm = TRUE) / 10
                                    max(longFormatTps$value, na.rm = TRUE) + (
                                      max(longFormatTps$value, na.rm = TRUE) / 10
                                    )
                                  ) == 0, 0.2,
                                  ceiling(
                                    #                                    max(summariseByMeanTpsAndLatency$tps, na.rm = TRUE) + (
                                    #                                      max(summariseByMeanTpsAndLatency$tps, na.rm = TRUE) / 10
                                    max(longFormatTps$value, na.rm = TRUE) + (
                                      max(longFormatTps$value, na.rm = TRUE) / 10
                                    )
                                  )))) +
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
  save(paste("cordaOs-plot-tps-", tempName, sep = ""),
       #save(paste("cordaEnterprise-plot-tps-", tempName, sep = ""),
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
  
  plotLatency = ggplot(data = longFormatLatency, aes(x = RL, y = value)) + #, shape = BenchmarkName)) + #,color = BS.1
    #geom_line(data = longFormatLatency, aes(x = RL, y = value, group = 1)) +
    geom_point(data = longFormatLatency,
               aes(x = RL,
                   y = value,
                   #shape = BenchmarkName,
                   color = normaltag),
               size = 2) +
    geom_bar(width=0.5, data = longFormatLatency, aes(x = RL, y = value), fill="black",alpha=0.2,position="stack",stat="identity") +    #geom_label(
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
    geom_point(data = longFormatIsMin,
               aes(x = RL,
                   y = value,
                   #shape = BenchmarkName,
                   #shape = 17,
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
    #facet_wrap(
    #  ~ Category,
    #  strip.position = "bottom",
    #  scales = "free_x",
    #  nrow = 1
    #) +
    geom_errorbar(
      aes(ymin = value, ymax = value + SDLATENCY),
      width = .1,
      position = position_dodge(0.05),
      color = "snow4"
    ) +
    theme(
      panel.spacing = unit(0.0, "lines"),
      strip.background = element_blank(),
      axis.title.x = element_blank(),
    ) +
    cleanTpl() +
    expand_limits(y = 0) +
    ylim(0.0, NA) +
    #xlab("") + ylab("Mean finalization latency in s") +
    xlab("") + ylab("MFLS") +
    #coord_cartesian(ylim = c(0, NA)) +
    scale_y_continuous(limits = c(0,
                                  ifelse(                                  ceiling(
                                    #                                    max(summariseByMeanTpsAndLatency$avglatency, na.rm = TRUE) + (
                                    #                                      max(summariseByMeanTpsAndLatency$avglatency, na.rm = TRUE) / 10
                                    max(longFormatLatency$value, na.rm = TRUE) + (
                                      max(longFormatLatency$value, na.rm = TRUE) / 10
                                    )
                                  ) == 0, 0.2,
                                  ceiling(
                                    #                                    max(summariseByMeanTpsAndLatency$avglatency, na.rm = TRUE) + (
                                    #                                      max(summariseByMeanTpsAndLatency$avglatency, na.rm = TRUE) / 10
                                    max(longFormatLatency$value, na.rm = TRUE) + (
                                      max(longFormatLatency$value, na.rm = TRUE) / 10
                                    )
                                  )))) +
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
             nrow = 1,
             override.aes = list(
               size = 2#,
               #            color = c("black", "red", "green", "blue"),
#               color = c("#95D840FF", "#20A387FF", "#482677FF", "black"),
#               shape = c(15, 17, 18, NA)#(16, 16, 15, NA)
             )
           )) #+
  #labs(caption = paste("<span style='color:black'><b>", tempName, "</b></span>"))
  
  plot_listLatency[[counter]] = plotLatency
  datalistLatency[[counter]] = longFormatLatency
  save(paste("cordaOs-plot-latency-", tempName, sep = ""),
       #save(paste("cordaEnterprise-plot-latency-", tempName, sep = ""),
       plotLatency, "parts")
  
  save(
    paste("cordaOs-plot-tpsandlatency-", tempName, sep = ""),
    #paste("cordaEnterprise-plot-tpsandlatency-", tempName, sep = ""),
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

colnames(getByHighlight)[3] <- "Max TPS"

getByHighlight <-
  getByHighlight[c("BenchmarkName", "RL", "Max TPS")]

getByHighlight$RL = str_replace(getByHighlight$RL, "RL=", "")

if (length(toAppendDfForGetByHighlightTps) > 0 &&
    length(toAppendDfForGetByHighlightLatency) > 0) {
  names(toAppendDfForGetByHighlightTps)[3] <- "Max TPS"
  names(toAppendDfForGetByHighlightLatency)[3] <- "Min Latency"
  
  getByHighlight <-
    rbind(getByHighlight, toAppendDfForGetByHighlightTps)
  benchmarkListOrder <-
    c(
      "DoNothing",
      "KeyValue-Set",
      "KeyValue-Get",
      "Banking-Create",
      "Banking-Send",
      "Banking-Balance"
    )
  getByHighlight$BenchmarkName <-
    factor(as.character(getByHighlight$BenchmarkName), levels = benchmarkListOrder)
  getByHighlight <-
    getByHighlight[order(getByHighlight$BenchmarkName),]
}

datalistLatencyTemp <- datalistLatency
for (i in 1:length(datalistLatencyTemp)) {
  datalistLatencyTemp[[i]]$RL <- gsub("RL=", "", datalistLatencyTemp[[i]]$RL)
}

latencyListForHighlight <- c()
for(i in 1:length(datalistLatencyTemp)) {
  for(j in 1:nrow(datalistLatencyTemp[[i]])) {
    for(k in 1:nrow(getByHighlight)) {
      if(as.numeric(as.character(datalistLatencyTemp[[i]]$RL[j])) == getByHighlight$RL[k]
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
colnames(getByHighlight)[4] <- "Latency"

durationList <- c()
bmsDuration <- c("DoNothing DoNothing", "KeyValue Set", "KeyValue Get", 
                 "BankingApp CreateAccount", "BankingApp SendPayment", "BankingApp Balance"
)
cntDuration <- 0
for(duration in bmsDuration) {
  cntDuration <- cntDuration + 1
  if(length(summariseByMeanTpsAndLatency[summariseByMeanTpsAndLatency$fullBenchmarkName==duration &
                                         getByHighlight[cntDuration, ]$RL == as.character(as.numeric(summariseByMeanTpsAndLatency$rl)*4)
                                         ,]$duration) == 0 ||
     is.na(summariseByMeanTpsAndLatency[summariseByMeanTpsAndLatency$fullBenchmarkName==duration &
                                        getByHighlight[cntDuration, ]$RL == as.character(as.numeric(summariseByMeanTpsAndLatency$rl)*4)
                                        ,]$duration) ||
     is.nan(  summariseByMeanTpsAndLatency[summariseByMeanTpsAndLatency$fullBenchmarkName==duration &
                                           getByHighlight[cntDuration, ]$RL == as.character(as.numeric(summariseByMeanTpsAndLatency$rl)*4)
                                           ,]$duration)) {
    durationList <- append(durationList, 0.0)  
  } else {
    durationList <- append(durationList,
                           summariseByMeanTpsAndLatency[summariseByMeanTpsAndLatency$fullBenchmarkName==duration &
                                                          getByHighlight[cntDuration, ]$RL == as.character(as.numeric(summariseByMeanTpsAndLatency$rl)*4)
                                                        ,]$duration)
  }
}
getByHighlight$duration <- do.call(cbind, 
                                   list(durationList))
colnames(getByHighlight)[5] <- "Duration"

xt <-
  xtable(
    getByHighlight,
    digits = 2,
    align = "lccccc",
    caption = "Corda Open Source",
    #caption = "Corda Enterprise",
    sanitize.text.function = identity
  )

#digits(xt) <- 4
align(xt) <- xalign(xt)
#digits(xt) <- xdigits(xt)
#display(xt) <- xdisplay(xt)

print(
  xtable(xt, align = "l|c|cccc", 
         caption = "Corda Open Source"
         #caption = "Corda Enterprise"
  ),
  include.rownames = FALSE,
  sanitize.text.function = identity
)

# failedTable ----------------------------------------------------------------

successfulAndFailedGroup <-
  tpsAndLatencyData %>% group_by(fullBenchmarkName, rl) #bm, bmf,

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
  match(rl, c("5", "10", "20", "40")))#, desc(rl), desc(tps))

#colnames(summariseByMaxFailedAndSuccessful)[1] <- "Benchmark"
#colnames(summariseByMaxFailedAndSuccessful)[2] <- "Function"

colnames(summariseByMaxFailedAndSuccessful)[1] <- "Benchmark"
colnames(summariseByMaxFailedAndSuccessful)[2] <- "RL"
colnames(summariseByMaxFailedAndSuccessful)[3] <- "Successful"
colnames(summariseByMaxFailedAndSuccessful)[4] <- "Failed"

summariseByMaxFailedAndSuccessful <-
  summariseByMaxFailedAndSuccessful[c("Benchmark", "RL", "Successful", "Failed")]

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
    align = "l|cccc",
    caption = "Corda Open Source",
    #caption = "Corda Enterprise",
    sanitize.text.function = identity
  )

#digits(xt) <- 4
align(xt) <- xalign(xt)
#digits(xt) <- xdigits(xt)
display(xt) <- xdisplay(xt)

print(
  xtable(xt, align = "l|cccc", 
         caption = "Corda Open Source"
         #caption = "Corda Enterprise"
  ),
  include.rownames = FALSE,
  sanitize.text.function = identity,
  type = 'latex'
)

# newTables ---------------------------------------------------------------

longFormatLatencyBak <- datalistLatency[[2]] #longFormatLatency
longFormatLatencyBak$RL <- apply(longFormatLatencyBak, 1, function(x) gsub("RL=", " ", x[["RL"]], fixed = TRUE))
longFormatLatencyBak$SDLATENCY <- round(longFormatLatencyBak$SDLATENCY, digits = 2)
longFormatLatencyBak$value <- round(longFormatLatencyBak$value, digits = 2)
longFormatLatencyBak$SEMLATENCY <- round(longFormatLatencyBak$SEMLATENCY, digits = 2)
longFormatLatencyBak$pm_value <- longFormatLatencyBak$CI_high_latency - longFormatLatencyBak$value
longFormatLatencyBak$pm_value <- paste("$\\pm$",round(longFormatLatencyBak$pm_value, digits = 2), sep="")
longFormatLatencyBak <- longFormatLatencyBak[,-4:-5]
longFormatLatencyBak <- longFormatLatencyBak[,-6:-7]
longFormatLatencyBak <- longFormatLatencyBak[,-4]
longFormatLatencyBak <- longFormatLatencyBak[,c(1,4,2,3,5)]
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'value'] <- 'MFLS'
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'SDLATENCY'] <- 'SD'
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'SEMLATENCY'] <- 'SEM'
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'pm_value'] <- '95\\% CI'

longFormatTpsBak <- datalistTps[[2]] #longFormatTps
longFormatTpsBak$RL <- apply(longFormatTpsBak, 1, function(x) gsub("RL=", " ", x[["RL"]], fixed = TRUE))
longFormatTpsBak$SDTPS <- round(longFormatTpsBak$SDTPS, digits = 2)
longFormatTpsBak$value <- round(longFormatTpsBak$value, digits = 2)
longFormatTpsBak$SEMTPS <- round(longFormatTpsBak$SEMTPS, digits = 2)
longFormatTpsBak$pm_value <- longFormatTpsBak$CI_high_tps - longFormatTpsBak$value
longFormatTpsBak$pm_value <- paste("$\\pm$",round(longFormatTpsBak$pm_value, digits = 2), sep="")
longFormatTpsBak <- longFormatTpsBak[,-4:-5]
longFormatTpsBak <- longFormatTpsBak[,-6:-7]
longFormatTpsBak <- longFormatTpsBak[,-4]
longFormatTpsBak <- longFormatTpsBak[,c(1,4,2,3,5)]
names(longFormatTpsBak)[names(longFormatTpsBak) == 'value'] <- 'MTPS'
names(longFormatTpsBak)[names(longFormatTpsBak) == 'SDTPS'] <- 'SD'
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'SEMTPS'] <- 'SEM'
names(longFormatTpsBak)[names(longFormatTpsBak) == 'pm_value'] <- '95\\% CI'

longFormatAllDataRowsBak <- datalistFailures[[2]] #longFormatAllDataRows
longFormatAllDataRowsBak$RL <- apply(longFormatAllDataRowsBak, 1, function(x) gsub("RL=", " ", x[["RL"]], fixed = TRUE))
longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,-2]
longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,-7]
longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,-8:-9]
longFormatAllDataRowsBak$sdmrows <- round(longFormatAllDataRowsBak$sdmrows, digits = 2)
longFormatAllDataRowsBak$value <- round(longFormatAllDataRowsBak$value, digits = 2)
longFormatAllDataRowsBak$semmrows <- round(longFormatAllDataRowsBak$semmrows, digits = 2)
longFormatAllDataRowsBak$pm_value <- longFormatAllDataRowsBak$CI_high_mrows - longFormatAllDataRowsBak$value
longFormatAllDataRowsBak$pm_value <- paste("$\\pm$",round(longFormatAllDataRowsBak$pm_value, digits = 2), sep="")
longFormatAllDataRowsBak <- longFormatAllDataRowsBak[,c(1,2,7,3,4,8)]
names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'value'] <- 'Received NoT'
names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'sdmrows'] <- 'SD'
names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'expected'] <- 'Expected NoT'
names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'semmrows'] <- 'SEM'
names(longFormatAllDataRowsBak)[names(longFormatAllDataRowsBak) == 'pm_value'] <- '95\\% CI'

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

makeTbl(cbind(longFormatTpsBak, longFormatLatencyBak[, 2:5]), "", "cccccccccc", "cc|cc|cc|cc|cc")
makeTbl(longFormatAllDataRowsBak, "",  "ccccccc", "cccc|ccc")