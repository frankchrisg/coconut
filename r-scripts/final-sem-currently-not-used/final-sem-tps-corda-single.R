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
library(sdamr)

source(
  "https://raw.githubusercontent.com/datavizpyr/data/master/half_flat_violinplot.R"
)
source("https://raw.githubusercontent.com/easystats/see/master/R/geom_violindot.R")

basicSystem <-
  #read.table('C:/Users/parallels/Downloads/cordaos.txt',
             read.table('C:/Users/parallels/Downloads/cordaenterprise.txt',
             sep = '&',
             comment.char = '\\')
#basicSystem$bs <- "Corda Open Source"
basicSystem$bs <- "Corda Enterprise"

cleanTpl <-
  function (base_size = 10,
            base_family = "",
            ...) {
    modifyList (
      theme_minimal (base_size = base_size, base_family = base_family),
      list (axis.line = element_line (colour = "black"))
    ) + theme(
      legend.title = element_blank(),
      legend.position = "bottom",
      axis.text.y = element_text(size = 7, color = "black"),
      axis.title.y = element_text(size = 7, color = "black"),
      axis.text.x = element_markdown(
        color = "black",
        size = 7,
        angle = 0,
        vjust = 0.0
      ),
      axis.title.x = element_text(size = 7, color = "black"),
      axis.line.x = element_line(color = "grey", size = 0.5),
      plot.caption = element_markdown(
        hjust = 0.9,
        vjust = -0.5,
        size = 6
      ),
      legend.key.size = unit(0.7, "line"),
      legend.text = element_markdown(
        colour = "darkgrey",
        size = 6,
        face = "bold"
      ),
      legend.box.margin = margin(-15,-15,-10,-15),
    )
  }

MinMeanSEMMax <-
  function(val,
           benchmarkNameParam,
           rateLimiterParam) {
    # set manually in case of direct call
    
    if(rateLimiterParam == 0) {
      print(paste("Failed benchmark detected, not processing: ", benchmarkNameParam))
    }
    
    if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam
    )] == "BankingApp Balance") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "BankingApp Balance")])#/4
      print(paste(
        "Optimal values for BankingApp Balance",
        rateLimiterParam,
        sep = " "
      ))
    } else if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam
    )] == "BankingApp SendPayment") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "BankingApp SendPayment")])#/4
      print(paste(
        "Optimal values for BankingApp SendPayment",
        rateLimiterParam,
        sep = " "
      ))
    } else if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam
    )] == "BankingApp CreateAccount") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "BankingApp CreateAccount")])#/4
      print(paste(
        "Optimal values for BankingApp CreateAccount",
        rateLimiterParam,
        sep = " "
      ))
    } else if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam
    )] == "KeyValue Set") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "KeyValue Set")])#/4
      print(paste(
        "Optimal values for KeyValue Set",
        rateLimiterParam,
        sep = " "
      ))
    } else if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam
    )] == "KeyValue Get") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "KeyValue Get")])#/4
      print(paste(
        "Optimal values for KeyValue Get",
        rateLimiterParam,
        sep = " "
      ))
    } else if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam
    )] == "DoNothing DoNothing") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "DoNothing DoNothing")])#/4
      print(paste(
        "Optimal values for DoNothing DoNothing",
        rateLimiterParam,
        sep = " "
      ))
    }
    
    semData <- c(
      summariseByMeanAndSd$mean[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam
      )] - summariseByMeanAndSd$sd[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam
      )],
      summariseByMeanAndSd$mean[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam
      )] - summariseByMeanAndSd$sd[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam
      )] / sqrt(summariseByMeanAndSd$n[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam
      )]),
      summariseByMeanAndSd$mean[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam
      )],
      summariseByMeanAndSd$mean[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam
      )] + summariseByMeanAndSd$sd[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam
      )] / sqrt(summariseByMeanAndSd$n[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam
      )]),
      summariseByMeanAndSd$mean[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam
      )] + summariseByMeanAndSd$sd[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam
      )]
    )
    names(semData) <- c("ymin", "lower", "middle", "upper", "ymax")
    semData
  }

prepareFiles <- function(fileName) {
  fNameFullAll <- fileName
  fileToUseFullAll <-
    read.csv(gsub(" ", "", paste(fNameFullAll)), dec = ".")
  
  fileToUseFullAll <-
    filter(
      fileToUseFullAll,!grepl(
        "4000000-sawtoothConfiguration-.*-.*-40-flalv-rn-1-hetzner-repid-.*-sawtooth-rl-.*-notpbpc-.*-nobpc-1-maxbtperbl-.*-notppc-[[:digit:]]+$",
        run_id,
        ignore.case = FALSE
      )
    )
  
  fileToUseFullAll <-
    filter(
      fileToUseFullAll,
      grepl(
        #"4000000-cordaConfiguration-.*-cordaos-.*",
        "4000000-cordaConfiguration-.*-cordaenterprise-.*",
        run_id,
        ignore.case = FALSE
      )
    )
  
  fileToUseFullAll$run_id <-
    sub("repid-.*?-", "repid-0-", fileToUseFullAll$run_id)
  
  return (fileToUseFullAll)
}

save <- function(titleVar, plot) {
  fileName = tolower(gsub(
    " ",
    "",
    #paste("C:/Users/parallels/Downloads/final-plots/sem-tps-cordaos-single/", titleVar, ".png"),
    paste("C:/Users/parallels/Downloads/final-plots/sem-tps-cordaenterprise-single/", titleVar, ".png"),
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

valList <-
  c(
    "duration",
    "tps",
    "avglatency",
    "countallrows"
  )
for (valueToUse in valList) {
  
  yAxisVal <- ""
  if(valueToUse=="duration") {
    yAxisVal <- "Mean duration"
  } else if (valueToUse=="tps"){
    yAxisVal <- "Mean TPS"
  } else if(valueToUse=="avglatency") {
    yAxisVal <- "Mean latency"
  } else if(valueToUse=="countallrows") {
    yAxisVal <- "Mean count"
  }
  
  fNameFullAllSuccessful <-
    "C:/Users/parallels/Downloads/2allblockdataonly-tps"
  
  fNameFullAllFailed <-
    "C:/Users/parallels/Downloads/allfailedx3-tps"
  
  fileToUseFullAll <-
    read.csv(gsub(" ", "", paste(fNameFullAllSuccessful)), dec = ".")
  
  fileToUseFullAllFailed <-
    read.csv(gsub(" ", "", paste(fNameFullAllFailed)), dec = ".")
  
  allTpsAndBlockData <- prepareFiles(fNameFullAllSuccessful)
  allTpsAndBlockDataFailed  <- prepareFiles(fNameFullAllFailed)
  
  allTpsAndBlockData <- allTpsAndBlockData %>% filter(tps != "NULL")
  allTpsAndBlockData$tps <- sapply(allTpsAndBlockData$tps, as.numeric)
  
  allTpsAndBlockData <- merge(
    allTpsAndBlockData,
    allTpsAndBlockDataFailed,
    all = T,
    all.x = T,
    all.y = T
  )
  
  allTpsAndBlockData$rl = str_split_fixed(allTpsAndBlockData$run_id, "-", Inf)[, 14]
  allTpsAndBlockData$fullBenchmarkName <-
    paste(allTpsAndBlockData$bm, allTpsAndBlockData$bmf)
  
  allTpsAndBlockData$countallrows <-  
    replace(
      allTpsAndBlockData$countallrows,
      as.numeric(allTpsAndBlockData$countallrows) == 0,
      NA
    )
  
  allTpsAndBlockData$tps <- 
    replace(
      allTpsAndBlockData$tps,
      as.numeric(allTpsAndBlockData$tps) == 0,
      NA
    )
  
  allTpsAndBlockData$avglatency <-
    replace(
      allTpsAndBlockData$avglatency,
      as.numeric(allTpsAndBlockData$avglatency) == 0,
      NA
    )
  
  allTpsAndBlockData$duration <-
    replace(
      allTpsAndBlockData$duration,
      as.numeric(allTpsAndBlockData$duration) == 0,
      NA
    )  
  
  rateLimiterParam <- 0
  
  colnames(basicSystem)[1] <- "BenchmarkName"
  colnames(basicSystem)[2] <- "RL"
  colnames(basicSystem)[3] <- "tps"
  colnames(basicSystem)[4] <- "basicSystem"
  
  getByHighlight <- basicSystem
  getByHighlight$RL <- as.numeric(getByHighlight$RL)/4
  
  benchmarkList <-
    c(
      "DoNothing DoNothing",
      "KeyValue Set",
      "KeyValue Get",
      "BankingApp CreateAccount",
      "BankingApp SendPayment",
      "BankingApp Balance"
    )
  
  getByHighlight$BenchmarkName <- benchmarkList
  
  generalGroup <-
    allTpsAndBlockData %>% group_by(fullBenchmarkName, rl, etf)
  
  summariseByEtfFirst <- generalGroup %>% summarise(
    # "stf","etf","countallrows","stfe","etfe","duration","tps","minstarttime","maxendtime","avglatency","maxlatency","minlatency","stddevlatency","variancelatency","maxinvalidcounter","maxexististingcounter","maxerrorcounter","maxvalidcounter","cumulativecount","run_id","bs","bm","bmf"
    countallrows = mean(countallrows, na.rm = TRUE),
    tps = mean(tps, na.rm = TRUE),
    avglatency = mean(avglatency, na.rm = TRUE),
    duration = mean(duration, na.rm = TRUE),
    n = n(),
    .groups = "keep"
  )
  
  #summariseByEtfFirst instead of allTpsAndBlockData
  summariseByMeanAndSd <- allTpsAndBlockData %>% group_by(fullBenchmarkName, rl) %>% summarise(
    mean = mean(eval(parse(text = valueToUse)), na.rm = TRUE),
    sd = sd(eval(parse(text = valueToUse)), na.rm = TRUE),
    n = n(),
    .groups = "keep"
  )
  
  summariseByMeanAndSd$mean <-
    replace(summariseByMeanAndSd$mean,
            is.nan(summariseByMeanAndSd$mean) | is.na(summariseByMeanAndSd$mean),
            0)
  
  summariseByMeanAndSd$sd <-
    replace(summariseByMeanAndSd$sd, is.nan(summariseByMeanAndSd$sd) | is.na(summariseByMeanAndSd$sd), 0)
  
  
  dataListSem = list()
  plotListSem = list()
  
  # preparedDataFrameMean ---------------------------------------------------
  
  preparedDataFrameMean <-
    data.frame(
      "RL" = c(rep(
        c("RL=200", "RL=400", "RL=800", "RL=1600"), 4
      )),
      "DoNothing DoNothing" = summariseByMeanAndSd$mean[which(summariseByMeanAndSd$fullBenchmarkName == "DoNothing DoNothing")],
      "KeyValue Set" = summariseByMeanAndSd$mean[which(summariseByMeanAndSd$fullBenchmarkName == "KeyValue Set")],
      "KeyValue Get" = summariseByMeanAndSd$mean[which(summariseByMeanAndSd$fullBenchmarkName == "KeyValue Get")],
      "BankingApp CreateAccount" = summariseByMeanAndSd$mean[which(summariseByMeanAndSd$fullBenchmarkName == "BankingApp CreateAccount")],
      "BankingApp SendPayment" = summariseByMeanAndSd$mean[which(summariseByMeanAndSd$fullBenchmarkName == "BankingApp SendPayment")],
      "BankingApp Balance" = summariseByMeanAndSd$mean[which(summariseByMeanAndSd$fullBenchmarkName == "BankingApp Balance")]
    )
  
  preparedDataFrameSummary <- data.frame(
    "RateLimiter" = allTpsAndBlockData$rl,
    #"CountAll" = allTpsAndBlockData$tps,
    "BenchmarkName" = allTpsAndBlockData$fullBenchmarkName
  )
  
  getByHighlight$BenchmarkName <-
    ifelse((getByHighlight$BenchmarkName == "DoNothing"),
           "DoNothing DoNothing",
           as.character(getByHighlight$BenchmarkName)
    )
  getByHighlight$BenchmarkName <-
    ifelse((getByHighlight$BenchmarkName == "KeyValue-Set"),
           "KeyValue Set",
           as.character(getByHighlight$BenchmarkName)
    )
  getByHighlight$BenchmarkName <-
    ifelse((getByHighlight$BenchmarkName == "KeyValue-Get"),
           "KeyValue Get",
           as.character(getByHighlight$BenchmarkName)
    )
  getByHighlight$BenchmarkName <-
    ifelse((getByHighlight$BenchmarkName == "Banking-Create"),
           "BankingApp CreateAccount",
           as.character(getByHighlight$BenchmarkName)
    )
  getByHighlight$BenchmarkName <-
    ifelse((getByHighlight$BenchmarkName == "Banking-Send"),
           "BankingApp SendPayment",
           as.character(getByHighlight$BenchmarkName)
    )
  getByHighlight$BenchmarkName <-
    ifelse((getByHighlight$BenchmarkName == "Banking-Balance"),
           "BankingApp Balance",
           as.character(getByHighlight$BenchmarkName)
    )
  
  getByHighlight$idOpt <- paste(getByHighlight$BenchmarkName,
                                "++",
                                getByHighlight$RL)
  
  allTpsAndBlockData$idOpt <- paste(allTpsAndBlockData$fullBenchmarkName,
                                    "++",
                                    allTpsAndBlockData$rl)
  
  preparedDataFrameSummaryOpt <- filter(allTpsAndBlockData,
                                        idOpt %in% getByHighlight$idOpt)
  
  longFormatMean <-
    melt(
      setDT(preparedDataFrameMean),
      id.vars = c("RL"),
      variable.name = "BenchmarkName"
    )
  longFormatMean$BenchmarkName <-
    gsub("\\.", " ", longFormatMean$BenchmarkName)
  
  # plotSem -----------------------------------------------------------------
  
  counterBm <- 0
  
  for (benchmark in benchmarkList) {
    
    counterBm <- counterBm + 1
    
    rateLimiterParam <-
      as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == benchmark)])#/4
    
    plotSem <-
      ggplot(data = summariseByMeanAndSd[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmark &
          summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == benchmark, ]$RL
      ),], aes(
        factor(
          benchmark,
          levels = c(
            benchmark
          )
        ),
        x=benchmark,
        y=ifelse(
          length(summariseByMeanAndSd$mean[which(
            summariseByMeanAndSd$fullBenchmarkName == benchmark &
              summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == benchmark, ]$RL
          )]) == 0,
          c(0),
          summariseByMeanAndSd$mean[which(
            summariseByMeanAndSd$fullBenchmarkName == benchmark &
              summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == benchmark, ]$RL
          )]),
      )) +
      stat_summary(
        fun.data = MinMeanSEMMax,
        fun.args = list(ifelse(
          
          length(summariseByMeanAndSd$fullBenchmarkName[which(
            summariseByMeanAndSd$fullBenchmarkName == benchmark &
              summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == benchmark, ]$RL)]) == 0,
            c(benchmark),
          summariseByMeanAndSd$fullBenchmarkName[which(
          summariseByMeanAndSd$fullBenchmarkName == benchmark &
            summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == benchmark, ]$RL
        )]), rateLimiterParam),
        geom = "boxplot",
        colour = "darkgrey",
        size = 0.8
      ) +
      cleanTpl() +
      xlab("") + ylab(yAxisVal) +
      scale_x_discrete(labels = c(
        paste(
          "<span style='color:black'><b>",
          benchmark,
          "</b></span>" ,
          "<br />","n=",
          ifelse(length(summariseByMeanAndSd$n[which(
            summariseByMeanAndSd$fullBenchmarkName == benchmark &
              summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == benchmark, ]$RL)]) == 0,
          0, summariseByMeanAndSd$n[which(
            summariseByMeanAndSd$fullBenchmarkName == benchmark &
              summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == benchmark, ]$RL
          )])
          ,
          " RL=",
          getByHighlight[getByHighlight$BenchmarkName == benchmark, ]$RL,
          sep = ""
        )
      )) +
      geom_flat_violin(
        data = preparedDataFrameSummaryOpt[preparedDataFrameSummaryOpt$fullBenchmarkName==benchmark,],
        aes(x = fullBenchmarkName,
            y = eval(parse(text = valueToUse)),
            fill = values),
        alpha = 0.2,
        colour = "#111111",
        fill = "#777777",
        position = position_nudge(x = 0.05, y = 0)
      ) + 
      geom_point(data = preparedDataFrameSummaryOpt[preparedDataFrameSummaryOpt$fullBenchmarkName==benchmark,],
                 alpha = 0.2,
                 aes(x = fullBenchmarkName,
                     y = eval(parse(text = valueToUse))), size=0.2,
                 position = position_jitternudge(nudge.x = -0.25))
    
    plotListSem[[counterBm]] = plotSem
    dataListSem[[counterBm]] = longFormatMean
    
    save(paste(unique(basicSystem$basicSystem), "-bm-", benchmark , "-plot-sem-", valueToUse, sep = ""),
         plotSem)
    
  }
  
  plotListSem[1][[1]]
  
}