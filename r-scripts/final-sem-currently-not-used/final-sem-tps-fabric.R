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
  read.table('C:/Users/parallels/Downloads/fabric.txt',
             sep = '&',
             comment.char = '\\')
basicSystem$bs <- "Hyperledger Fabric"

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
           cutCriteriaParam,
           rateLimiterParam) {
    # set manually in case of direct call
    functionCounter <<- functionCounter + 1
    
    benchmarkNameParam <- benchmarkNameParam[functionCounter]
    
    if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam &
      summariseByMeanAndSd$cutCriteria == cutCriteriaParam
    )] == "BankingApp Balance") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "BankingApp Balance")])#/4
      cutCriteriaParam <-
        as.numeric(getByHighlight$cutCriteria[(getByHighlight$BenchmarkName == "BankingApp Balance")])
      print(paste(
        "Optimal values for BankingApp Balance",
        rateLimiterParam,
        cutCriteriaParam,
        sep = " "
      ))
    } else if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam &
      summariseByMeanAndSd$cutCriteria == cutCriteriaParam
    )] == "BankingApp SendPayment") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "BankingApp SendPayment")])#/4
      cutCriteriaParam <-
        as.numeric(getByHighlight$cutCriteria[(getByHighlight$BenchmarkName == "BankingApp SendPayment")])
      print(paste(
        "Optimal values for BankingApp SendPayment",
        rateLimiterParam,
        cutCriteriaParam,
        sep = " "
      ))
    } else if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam &
      summariseByMeanAndSd$cutCriteria == cutCriteriaParam
    )] == "BankingApp CreateAccount") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "BankingApp CreateAccount")])#/4
      cutCriteriaParam <-
        as.numeric(getByHighlight$cutCriteria[(getByHighlight$BenchmarkName == "BankingApp CreateAccount")])
      print(paste(
        "Optimal values for BankingApp CreateAccount",
        rateLimiterParam,
        cutCriteriaParam,
        sep = " "
      ))
    } else if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam &
      summariseByMeanAndSd$cutCriteria == cutCriteriaParam
    )] == "KeyValue Set") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "KeyValue Set")])#/4
      cutCriteriaParam <-
        as.numeric(getByHighlight$cutCriteria[(getByHighlight$BenchmarkName == "KeyValue Set")])
      print(paste(
        "Optimal values for KeyValue Set",
        rateLimiterParam,
        cutCriteriaParam,
        sep = " "
      ))
    } else if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam &
      summariseByMeanAndSd$cutCriteria == cutCriteriaParam
    )] == "KeyValue Get") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "KeyValue Get")])#/4
      cutCriteriaParam <-
        as.numeric(getByHighlight$cutCriteria[(getByHighlight$BenchmarkName == "KeyValue Get")])
      print(paste(
        "Optimal values for KeyValue Get",
        rateLimiterParam,
        cutCriteriaParam,
        sep = " "
      ))
    } else if (summariseByMeanAndSd$fullBenchmarkName[which(
      summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
      summariseByMeanAndSd$rl == rateLimiterParam &
      summariseByMeanAndSd$cutCriteria == cutCriteriaParam
    )] == "DoNothing DoNothing") {
      rateLimiterParam <-
        as.numeric(getByHighlight$RL[(getByHighlight$BenchmarkName == "DoNothing DoNothing")])#/4
      cutCriteriaParam <-
        as.numeric(getByHighlight$cutCriteria[(getByHighlight$BenchmarkName == "DoNothing DoNothing")])
      print(paste(
        "Optimal values for DoNothing DoNothing",
        rateLimiterParam,
        cutCriteriaParam,
        sep = " "
      ))
    }
    
    semData <- c(
      summariseByMeanAndSd$mean[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam &
          summariseByMeanAndSd$cutCriteria == cutCriteriaParam
      )] - summariseByMeanAndSd$sd[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam &
          summariseByMeanAndSd$cutCriteria == cutCriteriaParam
      )],
      summariseByMeanAndSd$mean[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam &
          summariseByMeanAndSd$cutCriteria == cutCriteriaParam
      )] - summariseByMeanAndSd$sd[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam &
          summariseByMeanAndSd$cutCriteria == cutCriteriaParam
      )] / sqrt(summariseByMeanAndSd$n[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam &
          summariseByMeanAndSd$cutCriteria == cutCriteriaParam
      )]),
      summariseByMeanAndSd$mean[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam &
          summariseByMeanAndSd$cutCriteria == cutCriteriaParam
      )],
      summariseByMeanAndSd$mean[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam &
          summariseByMeanAndSd$cutCriteria == cutCriteriaParam
      )] + summariseByMeanAndSd$sd[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam &
          summariseByMeanAndSd$cutCriteria == cutCriteriaParam
      )] / sqrt(summariseByMeanAndSd$n[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam &
          summariseByMeanAndSd$cutCriteria == cutCriteriaParam
      )]),
      summariseByMeanAndSd$mean[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam &
          summariseByMeanAndSd$cutCriteria == cutCriteriaParam
      )] + summariseByMeanAndSd$sd[which(
        summariseByMeanAndSd$fullBenchmarkName == benchmarkNameParam &
          summariseByMeanAndSd$rl == rateLimiterParam &
          summariseByMeanAndSd$cutCriteria == cutCriteriaParam
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
      grepl("4000000-fabricConfiguration-.*", run_id, ignore.case = FALSE)
    )
  
  fileToUseFullAll$run_id <-
    sub("repid-.*?-", "repid-0-", fileToUseFullAll$run_id)
  
  return (fileToUseFullAll)
}

save <- function(titleVar, plot) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/parallels/Downloads/final-plots/sem-tps-fabric/", titleVar, ".png"),
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
  allTpsAndBlockData$cutCriteria <-
    str_split_fixed(allTpsAndBlockData$run_id, "-", Inf)[, 16]
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
  
  functionCounter <- 0
  cutCriteriaParam <- 0
  rateLimiterParam <- 0
  
  colnames(basicSystem)[1] <- "BenchmarkName"
  colnames(basicSystem)[2] <- "RL"
  colnames(basicSystem)[3] <- "cutCriteria"
  colnames(basicSystem)[4] <- "tps"
  colnames(basicSystem)[5] <- "basicSystem"
  
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
    allTpsAndBlockData %>% group_by(fullBenchmarkName, cutCriteria, rl, etf)
  
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
  summariseByMeanAndSd <- allTpsAndBlockData %>% group_by(fullBenchmarkName, cutCriteria, rl) %>% summarise(
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
  
  counter <- 0
  
  dataListSem = list()
  plotListSem = list()
  
  cutCriteriaList <- c(100, 500, 1000, 2000)
  rateLimiterList <- c(50, 100, 200, 400)
  for (cutCriteriaParam in cutCriteriaList) {
    for (rateLimiterParam in rateLimiterList) {
      counter <- counter + 1
      
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
          "BankingApp Balance" = summariseByMeanAndSd$mean[which(summariseByMeanAndSd$fullBenchmarkName == "BankingApp Balance")],
          "Category" = c(
            rep("MM=100", 4),
            rep("MM=500", 4),
            rep("MM=1000", 4),
            rep("MM=2000", 4)
          )
        )
      
      preparedDataFrameSummary <- data.frame(
        "CutCriteria" = allTpsAndBlockData$cutCriteria,
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
                                    getByHighlight$RL,
                                    "++",
                                    getByHighlight$cutCriteria)
      
      allTpsAndBlockData$idOpt <- paste(allTpsAndBlockData$fullBenchmarkName,
                                        "++",
                                        allTpsAndBlockData$rl,
                                        "++",
                                        allTpsAndBlockData$cutCriteria)
      
      preparedDataFrameSummaryOpt <- filter(allTpsAndBlockData,
                                            idOpt %in% getByHighlight$idOpt)
      
      longFormatMean <-
        melt(
          setDT(preparedDataFrameMean),
          id.vars = c("RL", "Category"),
          variable.name = "BenchmarkName"
        )
      longFormatMean$BenchmarkName <-
        gsub("\\.", " ", longFormatMean$BenchmarkName)
      
      # plotSem -----------------------------------------------------------------
      
      plotSem <-
        ggplot(data = longFormatMean, aes(
          factor(
            longFormatMean$BenchmarkName,
            levels = c(
              "DoNothing DoNothing",
              "KeyValue Set",
              "KeyValue Get",
              "BankingApp CreateAccount",
              "BankingApp SendPayment",
              "BankingApp Balance"
            )
          ),
          longFormatMean$value
        )) +
        stat_summary(
          fun.data = MinMeanSEMMax,
          fun.args = list(rep(
            unique(longFormatMean$BenchmarkName), 16
          ), cutCriteriaParam, rateLimiterParam),
          geom = "boxplot",
          colour = "darkgrey",
          size = 0.8
        ) +
        cleanTpl() +
        xlab("") + ylab(yAxisVal) +
        scale_x_discrete(labels = c(
          paste(
            "<span style='color:black'><b>",
            "DoNothing",
            "</b></span>" ,
            "<br />DoNothing<br />n=",
            summariseByMeanAndSd$n[which(
              summariseByMeanAndSd$fullBenchmarkName == "DoNothing DoNothing" &
                summariseByMeanAndSd$cutCriteria == getByHighlight[getByHighlight$BenchmarkName == "DoNothing DoNothing", ]$cutCriteria &
                summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == "DoNothing DoNothing", ]$RL
            )],
            " MM=",
            getByHighlight[getByHighlight$BenchmarkName == "DoNothing DoNothing", ]$cutCriteria,
            " RL=",
            getByHighlight[getByHighlight$BenchmarkName == "DoNothing DoNothing", ]$RL,
            sep = ""
          ),
          paste(
            "<span style='color:black'><b>",
            "KeyValue",
            "</b></span>" ,
            "<br />Set<br />n=",
            summariseByMeanAndSd$n[which(
              summariseByMeanAndSd$fullBenchmarkName == "KeyValue Set" &
                summariseByMeanAndSd$cutCriteria == getByHighlight[getByHighlight$BenchmarkName == "KeyValue Set", ]$cutCriteria &
                summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == "KeyValue Set", ]$RL
            )],
            " MM=",
            getByHighlight[getByHighlight$BenchmarkName == "KeyValue Set", ]$cutCriteria,
            " RL=",
            getByHighlight[getByHighlight$BenchmarkName == "KeyValue Set", ]$RL,
            sep = ""
          ),
          paste(
            "<span style='color:black'><b>",
            "KeyValue",
            "</b></span>" ,
            "<br />Get<br />n=",
            summariseByMeanAndSd$n[which(
              summariseByMeanAndSd$fullBenchmarkName == "KeyValue Get" &
                summariseByMeanAndSd$cutCriteria == getByHighlight[getByHighlight$BenchmarkName == "KeyValue Get", ]$cutCriteria &
                summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == "KeyValue Get", ]$RL
            )],
            " MM=",
            getByHighlight[getByHighlight$BenchmarkName == "KeyValue Get", ]$cutCriteria,
            " RL=",
            getByHighlight[getByHighlight$BenchmarkName == "KeyValue Get", ]$RL,
            sep = ""
          ),
          paste(
            "<span style='color:black'><b>",
            "BankingApp",
            "</b></span>" ,
            "<br />CreateAccount<br />n=",
            summariseByMeanAndSd$n[which(
              summariseByMeanAndSd$fullBenchmarkName == "BankingApp CreateAccount" &
                summariseByMeanAndSd$cutCriteria == getByHighlight[getByHighlight$BenchmarkName == "BankingApp CreateAccount", ]$cutCriteria &
                summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == "BankingApp CreateAccount", ]$RL
            )],
            " MM=",
            getByHighlight[getByHighlight$BenchmarkName == "BankingApp CreateAccount", ]$cutCriteria,
            " RL=",
            getByHighlight[getByHighlight$BenchmarkName == "BankingApp CreateAccount", ]$RL,
            sep = ""
          ),
          paste(
            "<span style='color:black'><b>",
            "BankingApp",
            "</b></span>" ,
            "<br />SendPayment<br />n=",
            summariseByMeanAndSd$n[which(
              summariseByMeanAndSd$fullBenchmarkName == "BankingApp SendPayment" &
                summariseByMeanAndSd$cutCriteria == getByHighlight[getByHighlight$BenchmarkName == "BankingApp SendPayment", ]$cutCriteria &
                summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == "BankingApp SendPayment", ]$RL
            )],
            " MM=",
            getByHighlight[getByHighlight$BenchmarkName == "BankingApp SendPayment", ]$cutCriteria,
            " RL=",
            getByHighlight[getByHighlight$BenchmarkName == "BankingApp SendPayment", ]$RL,
            sep = ""
          ),
          paste(
            "<span style='color:black'><b>",
            "BankingApp",
            "</b></span>",
            "<br />Balance<br />n=",
            summariseByMeanAndSd$n[which(
              summariseByMeanAndSd$fullBenchmarkName == "BankingApp Balance" &
                summariseByMeanAndSd$cutCriteria == getByHighlight[getByHighlight$BenchmarkName == "BankingApp Balance", ]$cutCriteria &
                summariseByMeanAndSd$rl == getByHighlight[getByHighlight$BenchmarkName == "BankingApp Balance", ]$RL
            )],
            " MM=",
            getByHighlight[getByHighlight$BenchmarkName == "BankingApp Balance", ]$cutCriteria,
            " RL=",
            getByHighlight[getByHighlight$BenchmarkName == "BankingApp Balance", ]$RL,
            sep = ""
          )
        )) +
        geom_flat_violin(
          data = preparedDataFrameSummaryOpt,
          aes(x = fullBenchmarkName,
              y = eval(parse(text = valueToUse)),
              fill = values),
          alpha = 0.2,
          colour = "#111111",
          fill = "#777777",
          position = position_nudge(x = 0.05, y = 0)
        ) + 
        geom_point(data = preparedDataFrameSummaryOpt,
                   alpha = 0.2,
                   aes(x = fullBenchmarkName,
                       y = eval(parse(text = valueToUse))), size=0.2,
                   position = position_jitternudge(nudge.x = -0.25))
      
      plotListSem[[counter]] = plotSem
      dataListSem[[counter]] = longFormatMean
      
    }
  }
  
  plotListSem[1][[1]]
  
  save(paste(unique(basicSystem$basicSystem), "-plot-sem-", valueToUse, sep = ""),
       plotListSem[1][[1]])
}