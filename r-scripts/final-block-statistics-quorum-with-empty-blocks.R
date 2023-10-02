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
library(data.table)
library(forcats)

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
      axis.text.y = element_text(size = 9, color = "black", angle = 90, hjust=0.5),
      axis.title.y = element_text(size = 9, color = "black", face="bold"),
      axis.text.x = element_text(size = 9, color = "black"),
      axis.title.x = element_text(size = 9, color = "black"),
      axis.line.x = element_line(color = "grey", size = 0.5),
      plot.caption = element_markdown(
        hjust = 0.9,
        vjust = -0.5,
        size = 9
      ),
      legend.key.size = unit(0.7, "line"),
      legend.text = element_markdown(
        colour = "black",#"darkgrey",
        size = 9#,
        #face = "bold"
      ),
      legend.box.margin = margin(-15, -15, -10, -15),
    )
  }

ggplot2::update_geom_defaults("text", list(color = "black", family = "Linux Libertine", size=9*(1/72 * 25.4)))

bsName <- "quorum"
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
      grepl("4000000-quorumConfiguration-.*", run_id, ignore.case = FALSE)
    )
  
  fileToUseFullAll <- fileToUseFullAll[!(fileToUseFullAll$run_id %in% failureEvalList),]
  
  fileToUseFullAll$run_id <-
    sub("repid-.*?-", "repid-0-", fileToUseFullAll$run_id)
  
  return (fileToUseFullAll)
}

prepareFilesWithoutRepidReplacement <- function(fileName) {
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
      grepl("4000000-quorumConfiguration-.*", run_id, ignore.case = FALSE)
    )
  
  fileToUseFullAll <- fileToUseFullAll[!(fileToUseFullAll$run_id %in% failureEvalList),]
  
  return (fileToUseFullAll)
}

save <- function(titleVar, plot) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/final-plots/blockdata/", titleVar, ".png"),
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

fNameAllBlocks <- "C:/Users/frank/Downloads/allblockdataonly"
fNameAllBlocksFailed <- "C:/Users/frank/Downloads/allfailedx3"

allBlocks <- prepareFiles(fNameAllBlocks)
failedBlocks <- prepareFiles(fNameAllBlocksFailed)

failedTemp <-
  failedBlocks[!(failedBlocks$run_id %in% allBlocks$run_id),]
failedTemp <-  subset( failedTemp, select = -c(successful, failed))
failedTemp <- failedTemp[, colnames(allBlocks)]
allBlocks <- rbind(allBlocks, failedTemp)

fNameFullAllRep <-
  "C:/Users/frank/Downloads/failed7query-rt-cid-rid-data-1657982395344.csv" #fabric
allBlocksRep <- prepareFiles(fNameFullAllRep)
allBlocksRep <- allBlocksRep[allBlocksRep$run_id != "4000000-quorumConfiguration-keyvalue-set-40-flalv-rn-1-hetzner-repid-0-quorum-rl-100-ib-10",]
allBlocksRep <- allBlocksRep[allBlocksRep$run_id != "4000000-quorumConfiguration-sb-createAccount-40-flalv-rn-1-hetzner-repid-0-quorum-rl-400-ib-5",]
allBlocksRep <- allBlocksRep[allBlocksRep$run_id != "4000000-quorumConfiguration-sb-sendPayment-40-flalv-rn-1-hetzner-repid-0-quorum-rl-400-ib-5" | (allBlocksRep$run_id == "4000000-quorumConfiguration-sb-sendPayment-40-flalv-rn-1-hetzner-repid-0-quorum-rl-400-ib-5" & as.integer(as.POSIXct(allBlocksRep$received_time))>= as.integer(as.POSIXct("2022-07-20 09:50:43+02"))),]
allBlocksRep <- allBlocksRep[allBlocksRep$run_id != "4000000-quorumConfiguration-sb-balance-40-flalv-rn-1-hetzner-repid-0-quorum-rl-400-ib-5" | (allBlocksRep$run_id == "4000000-quorumConfiguration-sb-balance-40-flalv-rn-1-hetzner-repid-0-quorum-rl-400-ib-5" & as.integer(as.POSIXct(allBlocksRep$received_time))>= as.integer(as.POSIXct("2022-07-20 10:01:56+02"))),]
bs <- c()
bm <- c()
bmf <- c()
for(j in 1:nrow(allBlocksRep))  {
  bs <- append(bs, allBlocks[match(allBlocksRep[j,]$run_id, allBlocks$run_id),]$bs)
  bm <- append(bm, allBlocks[match(allBlocksRep[j,]$run_id, allBlocks$run_id),]$bm)
  bmf <- append(bmf, allBlocks[match(allBlocksRep[j,]$run_id, allBlocks$run_id),]$bmf)
}
allBlocksRep <- cbind(allBlocksRep, bs)
allBlocksRep <- cbind(allBlocksRep, bm)
allBlocksRep <- cbind(allBlocksRep, bmf)
allBlocks <- merge(
  allBlocks,
  allBlocksRep,
  all = T,
  all.x = T,
  all.y = T
)

allBlocks$rl = str_split_fixed(allBlocks$run_id, "-", Inf)[, 14]
allBlocks$cutCriteria <-
  str_split_fixed(allBlocks$run_id, "-", Inf)[, 16]
allBlocks$fullBenchmarkName <- paste(allBlocks$bm, allBlocks$bmf)

allBlocks$cnt <- replace(allBlocks$cnt, allBlocks$cnt == 0, NA)
allBlocks$sumnof <-
  replace(allBlocks$sumnof, allBlocks$sumnof == 0, NA)
allBlocks$sumnoa <-
  replace(allBlocks$sumnoa, allBlocks$sumnoa == 0, NA)

generalGroup <-
  allBlocks %>% group_by(fullBenchmarkName, cutCriteria, rl)

#####

fNameAllBlocksCid <- "C:/Users/frank/Downloads/allblockdataonly"
fNameAllBlocksFailedCid <- "C:/Users/frank/Downloads/allfailedx3"

allBlocksCid <- prepareFilesWithoutRepidReplacement(fNameAllBlocksCid)
failedBlocksCid <- prepareFiles(fNameAllBlocksFailedCid)

failedTempCid <-
  failedBlocksCid[!(failedBlocksCid$run_id %in% allBlocksCid$run_id),]
failedTempCid <-  subset( failedTempCid, select = -c(successful, failed))
failedTempCid <- failedTempCid[, colnames(allBlocksCid)]
allBlocksCid <- rbind(allBlocksCid, failedTempCid)

fNameFullAllRepCid <-
  "C:/Users/frank/Downloads/failed7query-rt-cid-rid-data-1657982395344.csv" #fabric
allBlocksRepCid <- prepareFilesWithoutRepidReplacement(fNameFullAllRepCid)
allBlocksRepCid <- allBlocksRepCid[!(allBlocksRepCid$run_id %like% "4000000-quorumConfiguration-keyvalue-set-40-flalv-rn-1-hetzner-repid-.*-quorum-rl-100-ib-10"),]
allBlocksRepCid <- allBlocksRepCid[!(allBlocksRepCid$run_id %like% "4000000-quorumConfiguration-sb-createAccount-40-flalv-rn-1-hetzner-repid-.*-quorum-rl-400-ib-5"),]
allBlocksRepCid <- allBlocksRepCid[!(allBlocksRepCid$run_id %like% "4000000-quorumConfiguration-sb-sendPayment-40-flalv-rn-1-hetzner-repid-.*-quorum-rl-400-ib-5") | (allBlocksRepCid$run_id %like% "4000000-quorumConfiguration-sb-sendPayment-40-flalv-rn-1-hetzner-repid-.*-quorum-rl-400-ib-5" & as.integer(as.POSIXct(allBlocksRepCid$received_time))>= as.integer(as.POSIXct("2022-07-20 09:50:43+02"))),]
allBlocksRepCid <- allBlocksRepCid[!(allBlocksRepCid$run_id %like% "4000000-quorumConfiguration-sb-balance-40-flalv-rn-1-hetzner-repid-.*-quorum-rl-400-ib-5") | (allBlocksRepCid$run_id %like% "4000000-quorumConfiguration-sb-balance-40-flalv-rn-1-hetzner-repid-.*-quorum-rl-400-ib-5" & as.integer(as.POSIXct(allBlocksRepCid$received_time))>= as.integer(as.POSIXct("2022-07-20 10:01:56+02"))),]
bs <- c()
bm <- c()
bmf <- c()
allBlocksCid2 <- allBlocksCid
allBlocksRepCid2 <- allBlocksRepCid
allBlocksCid2$run_id <- unlist(lapply(allBlocksCid$run_id, function(x) gsub("repid-.*-", "repid-0-", x)))
allBlocksRepCid2$run_id <- unlist(lapply(allBlocksRepCid$run_id, function(x) gsub("repid-.*-", "repid-0-", x)))
for(j in 1:nrow(allBlocksRepCid))  {
  bs <- append(bs, allBlocksCid2[match(allBlocksRepCid2[j,]$run_id, allBlocksCid2$run_id),]$bs)
  bm <- append(bm, allBlocksCid2[match(allBlocksRepCid2[j,]$run_id, allBlocksCid2$run_id),]$bm)
  bmf <- append(bmf, allBlocksCid2[match(allBlocksRepCid2[j,]$run_id, allBlocksCid2$run_id),]$bmf)
}
allBlocksRepCid <- cbind(allBlocksRepCid, bs)
allBlocksRepCid <- cbind(allBlocksRepCid, bm)
allBlocksRepCid <- cbind(allBlocksRepCid, bmf)
allBlocksCid <- merge(
  allBlocksCid,
  allBlocksRepCid,
  all = T,
  all.x = T,
  all.y = T
)

allBlocksCid$rl = str_split_fixed(allBlocksCid$run_id, "-", Inf)[, 14]
allBlocksCid$cutCriteria <-
  str_split_fixed(allBlocksCid$run_id, "-", Inf)[, 16]
allBlocksCid$fullBenchmarkName <- paste(allBlocksCid$bm, allBlocksCid$bmf)
allBlocksCid$repid <- str_split_fixed(allBlocksCid$run_id, "-", Inf)[, 11]

allBlocksCidEmpty <- allBlocksCid

allBlocksCid$cnt <- replace(allBlocksCid$cnt, allBlocksCid$cnt == 0, NA)

##########

if(length(allBlocksCidEmpty[allBlocksCidEmpty$cnt >= 1 & (allBlocksCidEmpty$sumnof>0 | allBlocksCidEmpty$sumnoa>0),]$cnt) > 0) {
  allBlocksCidEmpty[allBlocksCidEmpty$cnt >= 1 & (allBlocksCidEmpty$sumnof>0 | allBlocksCidEmpty$sumnoa>0),]$cnt <- -1
}
allBlocksCidEmpty$cnt <- replace(allBlocksCidEmpty$cnt, allBlocksCidEmpty$cnt == -1, NA)

cidGroupEmpty <-
  allBlocksCidEmpty %>% group_by(fullBenchmarkName, cutCriteria, rl, cid, repid)

summariseByCountCidEmpty <- cidGroupEmpty %>% filter(cid != "0") %>% summarise(countVar = sum(cnt, na.rm = TRUE))
summariseByCountFailedCidEmpty <- cidGroupEmpty %>% filter(cid == "0") %>% summarise(countVar = 0,)

failedTempSummariseByCountCidEmpty <-
  summariseByCountFailedCidEmpty[!(paste(summariseByCountFailedCidEmpty$fullBenchmarkName,
                                         summariseByCountFailedCidEmpty$rl,
                                         summariseByCountFailedCidEmpty$cutCriteria, sep="-")
                                   %in%
                                     paste(summariseByCountCidEmpty$fullBenchmarkName,
                                           summariseByCountCidEmpty$rl,
                                           summariseByCountCidEmpty$cutCriteria, sep="-")),]
failedTempSummariseByCountCidEmpty <- failedTempSummariseByCountCidEmpty[, colnames(summariseByCountCidEmpty)]
summariseByCountCidEmpty <- rbind(summariseByCountCidEmpty, failedTempSummariseByCountCidEmpty)

reSummariseByGeneralCidEmpty <-
  summariseByCountCidEmpty %>% group_by(fullBenchmarkName, cutCriteria, rl)

summariseMeanCountEmpty <-
  reSummariseByGeneralCidEmpty %>% summarise(countVarx = mean(countVar, na.rm = TRUE),
                                             sdcountvar = sd(countVar, na.rm = TRUE),
                                             .groups = "keep")  %>% arrange(match(cutCriteria, c("1", "2", "5", "10")), match(rl, c("50", "100", "200", "400")))

##########

cidGroup <-
  allBlocksCid %>% group_by(fullBenchmarkName, cutCriteria, rl, cid, repid)

summariseByCountCid <- cidGroup %>% filter(cid != "0") %>% summarise(countVar = sum(cnt, na.rm = TRUE))
summariseByCountFailedCid <- cidGroup %>% filter(cid == "0") %>% summarise(countVar = 0,)

failedTempSummariseByCountCid <-
  summariseByCountFailedCid[!(paste(summariseByCountFailedCid$fullBenchmarkName,
                                    summariseByCountFailedCid$rl,
                                    summariseByCountFailedCid$cutCriteria, sep="-")
                              %in%
                                paste(summariseByCountCid$fullBenchmarkName,
                                      summariseByCountCid$rl,
                                      summariseByCountCid$cutCriteria, sep="-")),]
failedTempSummariseByCountCid <- failedTempSummariseByCountCid[, colnames(summariseByCountCid)]
summariseByCountCid <- rbind(summariseByCountCid, failedTempSummariseByCountCid)

reSummariseByGeneralCid <-
  summariseByCountCid %>% group_by(fullBenchmarkName, cutCriteria, rl)

summariseMeanCount <-
  reSummariseByGeneralCid %>% summarise(countVarx = mean(countVar, na.rm = TRUE),
                                        sdcountvar = sd(countVar, na.rm = TRUE),
                                        .groups = "keep")  %>% arrange(match(cutCriteria, c("1", "2", "5", "10")), match(rl, c("50", "100", "200", "400")))

#####

summariseMeanData <- generalGroup %>% summarise(
  mblocks = mean(cnt, na.rm = TRUE),
  mtxs = mean(sumnof, na.rm = TRUE),
  mact = mean(sumnoa, na.rm = TRUE),
  sdmblocks = sd(cnt, na.rm = TRUE),
  sdmtxs = sd(sumnof, na.rm = TRUE),
  sdmact = sd(sumnoa, na.rm = TRUE),
  .groups = "keep"
)  %>% arrange(match(cutCriteria, c("1", "2", "5", "10")), match(rl, c("50", "100", "200", "400")))

preparedData <-
  data.frame(
    summariseMeanData$fullBenchmarkName,
    summariseMeanData$rl,
    summariseMeanData$cutCriteria,
    summariseMeanData$mblocks,
    summariseMeanData$mtxs,
    summariseMeanData$mact,
    summariseMeanCount$countVarx,
    summariseMeanCountEmpty$countVarx,
    summariseMeanData$sdmblocks,
    summariseMeanData$sdmtxs,
    summariseMeanData$sdmact,
    summariseMeanCount$sdcountvar,
    summariseMeanCountEmpty$sdcountvar
  )

plot_listBlockStats = list()
data_listBlockStats = list()
datalistSubsetBlocks = list()
counter <- 0

benchmarkList <-
  c(
    "DoNothing DoNothing",
    "KeyValue Set",
    "KeyValue Get",
    "BankingApp CreateAccount",
    "BankingApp SendPayment",
    "BankingApp Balance"
  )
for (benchmark in benchmarkList) {
  counter <- counter + 1
  
  divisionByBlocks <- 1
  if(!is.nan(preparedData$summariseMeanData.mblocks[preparedData$summariseMeanData.fullBenchmarkName == benchmark])
     && !is.na(preparedData$summariseMeanData.mblocks[preparedData$summariseMeanData.fullBenchmarkName == benchmark])
     && preparedData$summariseMeanData.mblocks[preparedData$summariseMeanData.fullBenchmarkName == benchmark] > 0) {
    divisionByBlocks <- preparedData$summariseMeanData.mblocks[preparedData$summariseMeanData.fullBenchmarkName == benchmark]
  }
  
  preparedDataFrame <-
    data.frame(
      "RL" = c(rep(
        c("RL=200", "RL=400", "RL=800", "RL=1600"), 4
      )),
      
      "countVarMean" = preparedData$summariseMeanCount.countVarx[preparedData$summariseMeanData.fullBenchmarkName == benchmark],
      "countVarMeanEmpty" = preparedData$summariseMeanCountEmpty.countVarx[preparedData$summariseMeanData.fullBenchmarkName == benchmark],
      "mact" = preparedData$summariseMeanData.mact[preparedData$summariseMeanData.fullBenchmarkName == benchmark] / divisionByBlocks,
      "mtxs" = preparedData$summariseMeanData.mtxs[preparedData$summariseMeanData.fullBenchmarkName == benchmark] / divisionByBlocks,
      "mblocks" = preparedData$summariseMeanData.mblocks[preparedData$summariseMeanData.fullBenchmarkName == benchmark],
      
      "sdmblocks" = preparedData$summariseMeanData.sdmblocks[preparedData$summariseMeanData.fullBenchmarkName == benchmark],
      "sdmtxs" = preparedData$summariseMeanData.sdmtxs[preparedData$summariseMeanData.fullBenchmarkName == benchmark] / divisionByBlocks,
      "sdmact" = preparedData$summariseMeanData.sdmact[preparedData$summariseMeanData.fullBenchmarkName == benchmark] / divisionByBlocks,
      "sdcountvar" = preparedData$summariseMeanCount.sdcountvar[preparedData$summariseMeanData.fullBenchmarkName == benchmark],
      "sdcountvarempty" = preparedData$summariseMeanCountEmpty.sdcountvar[preparedData$summariseMeanData.fullBenchmarkName == benchmark],
      
      "Category" = c(rep("BP=1s", 4), rep("BP=2s", 4), rep("BP=5s", 4), rep("BP=10s", 4))
    )
  
  ## remove from dataframe
  preparedDataFrame <- subset(preparedDataFrame, Category != "BP=1s" & Category != "BP=10s")
  preparedDataFrame <- subset(preparedDataFrame, RL != "RL=200" & RL != "RL=800" & RL != "RL=1600")
  
  longFormat <-
    melt(setDT(preparedDataFrame), id.vars = c("RL", "Category", "sdmblocks", "sdmtxs", "sdmact", "sdcountvar", "sdcountvarempty"))
  
  longFormatBak <-
    melt(setDT(preparedDataFrame), id.vars = c("RL", "Category"))
  
  longFormat$RL <-
    fct_rev(factor(
      longFormat$RL,
      levels = c("RL=200", "RL=400", "RL=800", "RL=1600")
    ))
  longFormat$variable <-
    fct_rev(factor(longFormat$variable, levels = unique(longFormat$variable)))
  longFormat$Category <-
    factor(longFormat$Category,
           levels = c("BP=1s", "BP=2s", "BP=5s", "BP=10s"))
  
  longFormat$value[is.na(longFormat$value) | is.nan(longFormat$value)] <- 0
  
  # blockPlot ---------------------------------------------------------------
  
  blockPlot <-
    ggplot(longFormat, aes(fill = variable, y = value, x = RL)) +
    geom_bar(position = "dodge", stat = "identity", alpha=0.2) +
    #geom_point(position = position_dodge(width = .9), aes(color = variable), shape="\u25BA", size=2) +
    geom_point(position = position_dodge(width = .9), aes(color = variable), shape=c(1,2,5,6,7,1,2,5,6,7),  size=3) +#"\u25BA", size=2) +
    geom_text(
      aes(
        label = paste(format(round(value, digits = 2), nsmall = 2), ", \U03C3=", str_trim(sub("NA", "0.00", ifelse(variable=="countVarMean",format(round(sdcountvar, digits = 2), nsmall = 2), 
                                                                                                        ifelse(variable=="countVarMeanEmpty",format(round(sdcountvarempty, digits = 2), nsmall = 2),
                                                                                                               ifelse(variable=="mact",format(round(sdmact, digits = 2), nsmall = 2), 
                                                                                                                      ifelse(variable=="mtxs",format(round(sdmtxs, digits = 2), nsmall = 2),
                                                                                                                             ifelse(variable=="mblocks",format(round(sdmblocks, digits = 2), nsmall = 2), "unknown"))))) 
                                                                                              ), "both"
        )
        , sep=""), #round(value, digits = 2),
        #label = paste(format(round(value, digits = 2), nsmall = 2), ", \U03C3=", ifelse(is.nan(ifelse(variable=="countVarMean",format(round(sdcountvar, digits = 2), nsmall = 2), 
        #                                                                                ifelse(variable=="countVarMeanEmpty",format(round(sdcountvarempty, digits = 2), nsmall = 2),
        #                                                                                       ifelse(variable=="mact",format(round(sdmact, digits = 2), nsmall = 2), 
        #                                                                                              ifelse(variable=="mtxs",format(round(sdmtxs, digits = 2), nsmall = 2),
        #                                                                                                     ifelse(variable=="mblocks",format(round(sdmblocks, digits = 2), nsmall = 2), "unknown")))))), "0.00", 
        #                                                                                
        #                                                                                (ifelse(variable=="countVarMean",format(round(sdcountvar, digits = 2), nsmall = 2), 
        #                                                                                       ifelse(variable=="countVarMeanEmpty",format(round(sdcountvarempty, digits = 2), nsmall = 2),
        #                                                                                              ifelse(variable=="mact",format(round(sdmact, digits = 2), nsmall = 2), 
        #                                                                                                     ifelse(variable=="mtxs",format(round(sdmtxs, digits = 2), nsmall = 2),
        #                                                                                                            ifelse(variable=="mblocks",format(round(sdmblocks, digits = 2), nsmall = 2)))))))
        #                                                                                
        #)
        #, sep=""), #round(value, digits = 2),
        y = as.numeric(format(round(value, digits = 2), nsmall = 2)) + 0.5 #round(value, digits = 2) + 0.5
      ),
      position = position_dodge(width = .9),
      #size = 9,
      #family = "Linux Libertine",
      #size = 9,#2.2,
      hjust = -0.20
    ) +
    facet_wrap(
      ~ Category,
      strip.position = "bottom",
      scales = "free_x",
      nrow = 1
    ) +
    xlab("Rate Limiter") + ylab("") +
    #labs(caption = paste("<span style='color:black'><b>", benchmark, "</b></span>")) +
    scale_y_continuous(limits = c(0
                                  , ceiling(max(longFormat$value,na.rm=TRUE) + (
                                    max(longFormat$value,na.rm=TRUE) / 10 * 20
                                  )))) +
    theme(
      panel.spacing = unit(0.0, "lines"),
      strip.background = element_blank(),
      axis.title.x = element_blank(),
    ) +
    scale_fill_manual(
      name="blockstats",
      labels = c(
        #"Mean number of blocks received by all clients",
        #"Mean number of empty blocks received by all clients",
        #"Mean actions per block",
        #"Mean transactions per block",
        #"Mean blocks received by all datapoints"
        "Mean number of blocks",
        "Mean number of empty blocks",
        "Mean actions per block",
        "Mean transactions per block",
        "Mean number of blocks by datapoint"
      ),
      values = viridis(100)[seq.int(1L, length(viridis(100)), 20L)]
    ) +
    scale_color_manual(
      name="blockstats",
      labels = c(
        "Mean number of blocks",
        "Mean number of empty blocks",
        "Mean actions per block",
        "Mean transactions per block",
        "Mean number of blocks by datapoint"
      ),
      values = viridis(100)[seq.int(1L, length(viridis(100)), 20L)]
    ) +
    #scale_color_manual(
    #  values = viridis(100)[seq.int(1L, length(viridis(100)), 20L)],
    #) +
    guides(
      fill = guide_legend(nrow=1,override.aes = list(size = 2,
                                                     shape = c(1,2,5,6,7),#"\u25BA","\u25BA","\u25BA","\u25BA","\u25BA"),
                                                     fill = NA,
                                                     linetype = c(0, 0, 0, 0, 0)
      ))
      ,
      color = guide_legend(override.aes = list(color=rev(viridis(100)[seq.int(1L, length(viridis(100)), 20L)])))) +
    
    cleanTpl() +
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
      #plot.margin = unit(c(0, 2, 1, 0), "lines"),
      plot.margin = unit(c(0, 1, 1, 0), "lines"),
      #plot.margin = unit(c(0, 0, 1, 0), "lines"),
      #plot.margin = unit(c(1, 1, 1, 1), "lines"),      
      strip.placement = "bottom",
    ) + coord_flip()
  
  plot_listBlockStats[[counter]] = blockPlot
  data_listBlockStats[[counter]] = longFormat
  
  save(paste("blockStatistics-", bsName, "-", benchmark, sep = ""),
       blockPlot)
  
  datalistSubsetBlocks[[counter]] = preparedDataFrame
  
}
blockPlot

# newTables ---------------------------------------------------------------

longFormatBak <- longFormat
longFormatBak$RL <- apply(longFormatBak, 1, function(x) gsub("RL=", " ", x[["RL"]], fixed = TRUE))
longFormatBak <- longFormatBak[order(longFormatBak$RL,decreasing=TRUE),]
longFormatBak <- longFormatBak[order(longFormatBak$Category,decreasing=FALSE),]

longFormatBak$variable <- str_replace(longFormatBak$variable, "mact$", "Mean actions per block")
longFormatBak <- longFormatBak[!(longFormatBak$variable=="Mean actions per block"),]

longFormatBak <- longFormatBak[,-3:-7]
longFormatBak$variable <- str_replace(longFormatBak$variable, "countVarMean$", "Mean number of blocks")
longFormatBak$variable <- str_replace(longFormatBak$variable, "countVarMeanEmpty$", "Mean number of empty blocks")
longFormatBak$variable <- str_replace(longFormatBak$variable, "mtxs$", "Mean transactions per block")
longFormatBak$variable <- str_replace(longFormatBak$variable, "mblocks$", "Mean number of blocks by datapoint")

longFormatBak$value <- round(longFormatBak$value, digits = 2)
longFormatBak$Category <- apply(longFormatBak, 1, function(x) gsub("BI=|BP=|BS=|MM=|PD=", " ", x[["Category"]], fixed = FALSE))
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'variable'] <- 'Variable'
names(longFormatLatencyBak)[names(longFormatLatencyBak) == 'value'] <- 'Value'

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
}

makeTbl(longFormatBak, "x", "ccccc", "ccc|cc")