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
      grepl("4000000-diemConfiguration-.*", run_id, ignore.case = FALSE)
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
    paste("C:/Users/parallels/Downloads/final-plots/diem/",path,"/", titleVar, ".png"),
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
  "C:/Users/parallels/Downloads/testwr-diem"

tpsAndLatencyData <- prepareFiles(fNameFullAll)

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
    sdtps = sd(tps, na.rm = TRUE),
    sdavglatency = sd(avglatency, na.rm = TRUE),
    tps = mean(tps, na.rm = TRUE),
    avglatency = mean(avglatency, na.rm = TRUE),
    duration = mean(duration, na.rm = TRUE),
    .groups = "keep"
  ) %>% arrange(match(cutCriteria, c("100", "500", "1000", "2000")), match(rl, c("50", "100", "200", "400")))#, desc(rl), desc(tps))

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
      "Category" = c(
        rep("BS=100", 4),
        rep("BS=500", 4),
        rep("BS=1000", 4),
        rep("BS=2000", 4)
      ),
      "SDTPS" = summariseByMeanTpsAndLatency$sdtps[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                           tempName)]
    )
  
  preparedDataFrameTps <- subset(preparedDataFrameTps, Category != "BS=500" & Category != "BS=1000")
  preparedDataFrameTps <- subset(preparedDataFrameTps, RL != "RL=400" & RL != "RL=800")
  
  names(preparedDataFrameTps)[names(preparedDataFrameTps) == "placeholder_name"] <-
    benchmark
  
  longFormatTps <-
    melt(
      setDT(preparedDataFrameTps),
      id.vars = c("RL", "Category", "SDTPS"),
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
           levels = c("BS=100", "BS=500", "BS=1000", "BS=2000"))
  
  aggDataMaxTps <-
    aggregate(formula = value ~ BenchmarkName,
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
      if (longFormatTps[i,]$BenchmarkName == aggDataMaxTps[j,]$BenchmarkName &&
          longFormatTps[i,]$value == aggDataMaxTps[j,]$value) {
        longFormatTps[i,]$highlight <- "highlight"
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
      "Category" = c(
        rep("BS=100", 4),
        rep("BS=500", 4),
        rep("BS=1000", 4),
        rep("BS=2000", 4)
      ),
      "SDLATENCY" = summariseByMeanTpsAndLatency$sdavglatency[which(summariseByMeanTpsAndLatency$fullBenchmarkName ==
                                                                      tempName)]
    )
  
  preparedDataFrameLatency <- subset(preparedDataFrameLatency, Category != "BS=500" & Category != "BS=1000")
  preparedDataFrameLatency <- subset(preparedDataFrameLatency, RL != "RL=400" & RL != "RL=800")
  
  names(preparedDataFrameLatency)[names(preparedDataFrameLatency) == "placeholder_name"] <-
    benchmark
  
  longFormatLatency <-
    melt(
      setDT(preparedDataFrameLatency),
      id.vars = c("RL", "Category", "SDLATENCY"),
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
           levels = c("BS=100", "BS=500", "BS=1000", "BS=2000"))
  
  aggDataMinLatency <-
    aggregate(
      formula = value ~ BenchmarkName,
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
      if (longFormatLatency[i,]$BenchmarkName == aggDataMinLatency[j,]$BenchmarkName &&
          longFormatLatency[i,]$value == aggDataMinLatency[j,]$value) {
        longFormatLatency[i,]$highlight <- "highlight"
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
      .groups = "keep") %>% arrange(match(cutCriteria, c("100", "500", "1000", "2000")), match(rl, c("50", "100", "200", "400")))
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
      "Category" = c(
        rep("BS=100", 4),
        rep("BS=500", 4),
        rep("BS=1000", 4),
        rep("BS=2000", 4)
      )
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
    factor(
      longFormatAllDataRows$Category,
      levels = c("BS=100", "BS=500", "BS=1000", "BS=2000")
    )
  
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
  
  longFormatAllDataRows <- subset(longFormatAllDataRows, Category != "BS=500" & Category != "BS=1000")
  longFormatAllDataRows <- subset(longFormatAllDataRows, RL != "RL=400" & RL != "RL=800")
  
  expectedTemp <- longFormatAllDataRows
  expectedTemp$e <- "expected"
  mrowsTemp <- longFormatAllDataRows
  mrowsTemp$m <- "mrows"
  failedTemp <- longFormatAllDataRows
  failedTemp$f <- "failed"
  
  # plotAllDataRows -------------------------------------------------------------------
  
  mrowsOnlyVal <- subset(mrowsTemp, select = -c(value, expected, failed, offset, sdmrows))
  failedOnlyVal <- subset(failedTemp, select = -c(value, expected, mrows, offset, sdmrows))
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
  save(paste("diem-plot-all-data-rows-", tempName, sep = ""),
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
  save(paste("diem-plot-tps-", tempName, sep = ""), plotTps, "parts")
  
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
             nrow = 1,
             override.aes = list(
               size = 2,
               #            color = c("black", "red", "green", "blue"),
               color = c("#95D840FF", "#20A387FF", "#482677FF", "black"),
               #shape = c(16, 16, 15, NA)
               shape = c(15, 17, 18, NA)#(16, 16, 15, NA)
             )
           )) #+
  #labs(caption = paste("<span style='color:black'><b>", tempName, "</b></span>"))
  
  plot_listLatency[[counter]] = plotLatency
  datalistLatency[[counter]] = longFormatLatency
  save(paste("diem-plot-latency-", tempName, sep = ""),
       plotLatency, "parts")
  
  save(
    paste("diem-plot-tpsandlatency-", tempName, sep = ""),
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
  subset(getByHighlight, select = -c(normaltag, highlight, SDTPS))

colnames(getByHighlight)[2] <- "BS"
colnames(getByHighlight)[4] <- "Max TPS"

getByHighlight <-
  getByHighlight[c("BenchmarkName", "RL", "BS", "Max TPS")]

getByHighlight$RL = str_replace(getByHighlight$RL, "RL=", "")
getByHighlight$BS = str_replace(getByHighlight$BS, "BS=", "")

datalistLatencyTemp <- datalistLatency
for (i in 1:length(datalistLatencyTemp)) {
  datalistLatencyTemp[[i]]$RL <- gsub("RL=", "", datalistLatencyTemp[[i]]$RL)
  datalistLatencyTemp[[i]]$Category <- gsub("BS=", "", datalistLatencyTemp[[i]]$Category)
}

latencyListForHighlight <- c()
for(i in 1:length(datalistLatencyTemp)) {
  for(j in 1:nrow(datalistLatencyTemp[[i]])) {
    for(k in 1:nrow(getByHighlight)) {
      if(as.numeric(as.character(datalistLatencyTemp[[i]]$RL[j])) == getByHighlight$RL[k]
         & as.numeric(as.character(datalistLatencyTemp[[i]]$Category[j])) == getByHighlight$BS[k]
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
                                         getByHighlight[cntDuration, ]$BS == summariseByMeanTpsAndLatency$cutCriteria
                                         ,]$duration) == 0 ||
     is.na(summariseByMeanTpsAndLatency[summariseByMeanTpsAndLatency$fullBenchmarkName==duration &
                                        getByHighlight[cntDuration, ]$RL == as.character(as.numeric(summariseByMeanTpsAndLatency$rl)*4) &
                                        getByHighlight[cntDuration, ]$BS == summariseByMeanTpsAndLatency$cutCriteria
                                        ,]$duration) ||
     is.nan(  summariseByMeanTpsAndLatency[summariseByMeanTpsAndLatency$fullBenchmarkName==duration &
                                           getByHighlight[cntDuration, ]$RL == as.character(as.numeric(summariseByMeanTpsAndLatency$rl)*4) &
                                           getByHighlight[cntDuration, ]$BS == summariseByMeanTpsAndLatency$cutCriteria
                                           ,]$duration)) {
    durationList <- append(durationList, 0.0)  
  } else {
    durationList <- append(durationList,
                           summariseByMeanTpsAndLatency[summariseByMeanTpsAndLatency$fullBenchmarkName==duration &
                                                          getByHighlight[cntDuration, ]$RL == as.character(as.numeric(summariseByMeanTpsAndLatency$rl)*4) &
                                                          getByHighlight[cntDuration, ]$BS == summariseByMeanTpsAndLatency$cutCriteria
                                                        ,]$duration)
  }
}
getByHighlight$duration <- do.call(cbind, 
                                   list(durationList))
colnames(getByHighlight)[6] <- "Duration"

xt <-
  xtable(
    getByHighlight,
    digits = 2,
    align = "lcccccc",
    caption = "Diem",
    sanitize.text.function = identity
  )

#digits(xt) <- 4
align(xt) <- xalign(xt)
#digits(xt) <- xdigits(xt)
display(xt) <- xdisplay(xt)

print(
  xtable(xt, align = "l|cc|cccc", caption = "Diem"),
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
  match(cutCriteria, c("100", "500", "1000", "2000")))#, desc(rl), desc(tps))

#colnames(summariseByMaxFailedAndSuccessful)[1] <- "Benchmark"
#colnames(summariseByMaxFailedAndSuccessful)[2] <- "Function"

colnames(summariseByMaxFailedAndSuccessful)[1] <- "Benchmark"
colnames(summariseByMaxFailedAndSuccessful)[2] <- "BS"
colnames(summariseByMaxFailedAndSuccessful)[3] <- "RL"
colnames(summariseByMaxFailedAndSuccessful)[4] <- "Successful"
colnames(summariseByMaxFailedAndSuccessful)[5] <- "Failed"

summariseByMaxFailedAndSuccessful <-
  summariseByMaxFailedAndSuccessful[c("Benchmark", "RL", "BS", "Successful", "Failed")]

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
    align = "l|ccccc",
    caption = "Diem",
    sanitize.text.function = identity
  )

#digits(xt) <- 4
align(xt) <- xalign(xt)
#digits(xt) <- xdigits(xt)
display(xt) <- xdisplay(xt)

print(
  xtable(xt, align = "l|ccccc", caption = "Diem"),
  include.rownames = FALSE,
  sanitize.text.function = identity,
  type = 'latex'
)

