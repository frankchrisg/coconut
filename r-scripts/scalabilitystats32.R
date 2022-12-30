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
library(ggpmisc)

library(cowplot)
library(remotes)
#remotes::install_version("Rttf2pt1", version = "1.3.8")
library(extrafont) 
#font_import(paths = "C:/Users/parallels/Downloads/linux_libertine", prompt=FALSE)
#font_import(pattern = "LMRoman*") 
loadfonts()
loadfonts(device = "win") 
loadfonts(); windowsFonts()

cleanTpl <-
  function (base_size = 9,
            base_family = "Linux Libertine",
            ...) {
    modifyList (
      theme_minimal (base_size = base_size, base_family = base_family),
      list (axis.line = element_line (colour = "black"))
    ) + theme(
      legend.title = element_blank(),
      #legend.title = element_markdown(
      #  colour = "black",#"darkgrey",
      #  size = 9,
      #  face = "bold"
      #),
      legend.title.align = 0.5,
      legend.position = "none",
      #legend.position = "bottom",
      axis.text.y = element_text(size = 9, color = "black", face="bold"),
      #axis.text.y = element_blank(),#element_text(size = 9, color = "black", angle = 90, hjust=0.5),
      axis.title.y = element_text(size = 9, color = "black", face="bold"),
      axis.text.x = element_text(size = 9, color = "black"),
      axis.title.x = element_text(size = 9, color = "black", face="bold"),
      axis.line.x = element_line(color = "grey", size = 0.5),
      plot.caption = element_markdown(
        hjust = 0.9,
        vjust = -0.5,
        size = 9
      ),
      legend.key.size = unit(1, "line"),
      legend.spacing.x = unit(0.3, 'cm'),
      legend.text = element_markdown(
        colour = "black",#"darkgrey",
        size = 9,
        face = "bold"
      ),
      legend.box.margin = margin(-15, -15, -10, -15),
    )
  }

ggplot2::update_geom_defaults("text", list(color = "black", family = "Linux Libertine", size=9*(1/72 * 25.4)))

save <- function(titleVar, plot, type) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/parallels/Downloads/final-plots/", titleVar, ".png"),
    fixed = TRUE
  ))
  
  if(type=="plot") {
    ggsave(
      fileName,
      plot = plot,
      device = "png",
      path = NULL,
      scale = 1,
      width = 24.00,#20.94, #20
      #NA,
      height = 14,
      #NA,
      units = c("cm"),
      #"in"),
      dpi = 320,
      #320,
      limitsize = TRUE,
      bg = "white"
    )} else if (type == "heatmap") {
      ggsave(
        fileName,
        plot = plot,
        device = "png",
        path = NULL,
        scale = 1,
        width = 25.00,
        #NA,
        height = 17.50,
        #NA,
        units = c("cm"),
        #"in"),
        dpi = 320,
        #320,
        limitsize = TRUE,
        bg = "white"
      )
    }
}

prepareFiles <- function(fileName, getAll) {
  fNameFullAll <- fileName
  fileToUseFullAll <-
    read.csv(gsub(" ", "", paste(fNameFullAll)), dec = ".")
  
  if(!getAll) {
    fileToUseFullAll <-
      filter(
        fileToUseFullAll,
        grepl("4000000-.*donothing.*", run_id, ignore.case = FALSE)
        #grepl("4000000-sawtoothConfiguration-.*", run_id, ignore.case = FALSE)
      )
  } else {
    fileToUseFullAll <-
      filter(
        fileToUseFullAll,
        grepl("4000000-.*", run_id, ignore.case = FALSE)
        #grepl("4000000-sawtoothConfiguration-.*", run_id, ignore.case = FALSE)
      )
  }
  
  fileToUseFullAll$run_id <-
    sub("repid-.*?-", "repid-0-", fileToUseFullAll$run_id)
  
  return (fileToUseFullAll)
}

getPlot <- function(fNameFullAll, paramName) {
  
  allData <- prepareFiles(fNameFullAll, FALSE)
  
  allData$bm = str_split_fixed(allData$run_id, "-", Inf)[, 3]
  allData$bmf = str_split_fixed(allData$run_id, "-", Inf)[, 4]
  allData$fullBenchmarkName <- paste(allData$bm, allData$bmf)
  
  allData$servers = str_split_fixed(allData$run_id, "-", Inf)[, 9]
  allData$bs = str_split_fixed(allData$run_id, "-", Inf)[, 12]
  allData$bs <- ifelse(allData$bs=="0", str_split_fixed(allData$run_id, "-", Inf)[, 13], allData$bs)
  
  allData$fullBenchmarkName <- paste(allData$fullBenchmarkName, allData$bs)
  
  if(grepl( "8peers", fNameFullAll, fixed = TRUE)) {
    print("8peers nothing to replace")
  } else if(grepl( "16peers", fNameFullAll, fixed = TRUE)) {
    #print("16peers nothing to replace")
    allData <- allData  %>% add_row(fullBenchmarkName = "donothing doNothing fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "donothing doNothing sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
  } else if(grepl( "32peers", fNameFullAll, fixed = TRUE)) {
    # allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment cordaenterprise", bs = "cordaenterprise"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "sb balance cordaenterprise", bs = "cordaenterprise"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # 
    allData <- allData  %>% add_row(fullBenchmarkName = "donothing doNothing cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment cordaos", bs = "cordaos"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "sb createAccount cordaos", bs = "cordaos"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue set cordaos", bs = "cordaos"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue get cordaos", bs = "cordaos"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # 
    #rem  # allData <- allData  %>% add_row(fullBenchmarkName = "sb balance graphene", bs = "graphene"
    #rem  #                                 , 
    #rem  #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # 
    # allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment fabric", bs = "fabric"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "sb createAccount fabric", bs = "fabric"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "sb balance fabric", bs = "fabric"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue set fabric", bs = "fabric"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue get fabric", bs = "fabric"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "donothing doNothing fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    # 
    # allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment sawtooth", bs = "sawtooth"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "sb createAccount sawtooth", bs = "sawtooth"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "sb balance sawtooth", bs = "sawtooth"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue set sawtooth", bs = "sawtooth"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    # allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue get sawtooth", bs = "sawtooth"
    #                                 , 
    #                                 tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "donothing doNothing sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
  }
  
  generalGroup <-
    allData %>% group_by(fullBenchmarkName, bs) # %>% filter(tps == max(tps))
  
  summariseByMeanTpsAndLatency <-
    generalGroup %>% summarise(
      sdtps = sd(tps, na.rm = TRUE),
      sdavglatency = sd(avglatency, na.rm = TRUE),
      tps = mean(tps, na.rm = TRUE),
      avglatency = mean(avglatency, na.rm = TRUE),
      duration = mean(duration, na.rm = TRUE),
      .groups = "keep"
    )
  
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="cordaenterprise",
                                             "Corda Enterprise",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="cordaos",
                                             "Corda OS",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="graphene",
                                             "BitShares",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="fabric",
                                             "Fabric",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="quorum",
                                             "Quorum",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="sawtooth",
                                             "Sawtooth",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="diem",
                                             "Diem",
                                             summariseByMeanTpsAndLatency$bs)
  
  summariseByMeanTpsAndLatency$bs <- fct_rev(factor(summariseByMeanTpsAndLatency$bs,
                                                    levels = c(      "Corda OS",
                                                                     "Corda Enterprise",
                                                                     "BitShares",
                                                                     "Fabric",
                                                                     "Quorum",
                                                                     "Sawtooth",
                                                                     "Diem")))
  
  summariseByMeanTpsAndLatency$fullBenchmarkName <- fct_rev(factor(summariseByMeanTpsAndLatency$fullBenchmarkName,
                                                                   levels = c(      "donothing doNothing cordaos",
                                                                                    "donothing doNothing cordaenterprise",
                                                                                    "donothing doNothing graphene",
                                                                                    "donothing doNothing fabric",
                                                                                    "donothing doNothing quorum",
                                                                                    "donothing doNothing sawtooth",
                                                                                    "donothing doNothing diem")))
  
  bsScale <- rev(c("Corda OS", "Corda Enterprise", "BitShares", "Fabric", "Quorum", "Sawtooth", "Diem"))
  
  plotScalability<-ggplot(data=summariseByMeanTpsAndLatency, aes(fill=bs, x=fullBenchmarkName, y=get(paramName))) +
    scale_x_discrete(labels= bsScale) +
    geom_bar(position = "dodge", stat = "identity", alpha=0.2) +
    geom_point(position = position_dodge(width = .9), aes(color = bs), shape=8, size=2) + #"\U1F965", size=2) + #"\u25BA", size=2) + 
    geom_text(
      aes(
        fontface=2,
        label = paste(format(round(get(paramName), digits = 2), nsmall = 2), ",\U03C3=", str_trim(sub("NA", "0.00", ifelse(bs=="Corda OS",format(round(get(paste("sd", paramName, sep="")), digits = 2), nsmall = 2), 
                                                                                                                           ifelse(bs=="Corda Enterprise",format(round(get(paste("sd", paramName, sep="")), digits = 2), nsmall = 2),
                                                                                                                                  ifelse(bs=="BitShares",format(round(get(paste("sd", paramName, sep="")), digits = 2), nsmall = 2), 
                                                                                                                                         ifelse(bs=="Fabric",format(round(get(paste("sd", paramName, sep="")), digits = 2), nsmall = 2),
                                                                                                                                                ifelse(bs=="Quorum",format(round(get(paste("sd", paramName, sep="")), digits = 2), nsmall = 2),
                                                                                                                                                       ifelse(bs=="Sawtooth",format(round(get(paste("sd", paramName, sep="")), digits = 2), nsmall = 2),
                                                                                                                                                              ifelse(bs=="Diem",format(round(get(paste("sd", paramName, sep="")), digits = 2), nsmall = 2), "unknown"))))))) 
        ), "both")
        , sep=""),
        y = as.numeric(format(round(get(paramName), digits = 2), nsmall = 2)) + 0.5
      ),
      position = position_dodge(width = .9),
      #size = 9,
      #family = "Linux Libertine",
      #size = 9,#2.2,
      hjust = -0.20
    ) +
    xlab("") + ylab("MTPS") +
    scale_y_continuous(limits = c(0
                                  , ceiling(max(get(paramName, summariseByMeanTpsAndLatency),na.rm=TRUE) + (
                                    max(get(paramName, summariseByMeanTpsAndLatency),na.rm=TRUE) / 10
                                  )))) +
    theme(
      panel.spacing = unit(0.0, "lines"),
      strip.background = element_blank()#,
      #axis.title.x = element_blank(),
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
      #plot.margin = unit(c(0, 2, 1, 0), "lines"),
      plot.margin = unit(c(0, 1, 1, 0), "lines"),
      #plot.margin = unit(c(0, 0, 1, 0), "lines"),
      #plot.margin = unit(c(1, 1, 1, 1), "lines"),      
      strip.placement = "bottom",
    ) +
    scale_fill_manual(
      name="Distributed Ledger System",
      labels = c(
        "Corda OS",
        "Corda Enterprise",
        "BitShares",
        "Fabric",
        "Quorum",
        "Sawtooth",
        "Diem"
      ),
      values = viridis(140)[seq.int(1L, length(viridis(140)), 20L)]
    ) +
    scale_color_manual(
      name="Distributed Ledger System",
      labels = c(
        "Corda OS",
        "Corda Enterprise",
        "BitShares",
        "Fabric",
        "Quorum",
        "Sawtooth",
        "Diem"
      ),
      values = viridis(140)[seq.int(1L, length(viridis(140)), 20L)]
    ) +
    guides(
      fill = guide_legend(title.position = "bottom",nrow=1,override.aes = list(size = 2,
                                                                               shape = c(8,8,8,8,8,8,8),
                                                                               fill = NA,#rev(viridis(140)[seq.int(1L, length(viridis(140)), 20L)]),
                                                                               linetype = c(0, 0, 0, 0, 0, 0, 0)
      ))
      ,
      color = guide_legend(title.position = "bottom",override.aes = list(color=rev(viridis(140)[seq.int(1L, length(viridis(140)), 20L)])))) +
    cleanTpl() +
    coord_flip()
  
  print("ccccccccccccccccccc")
  print(summariseByMeanTpsAndLatency)
  print("ccccccccccccccccccc")
    
  plotScalability
  return (plotScalability)
}

plotParam <- "tps" #"avglatency" # "tps"
fNameFullAll8Peers <-
  "C:/Users/parallels/Downloads/8peers.csv"
peers8 <- getPlot(fNameFullAll8Peers, plotParam)
fNameFullAll16Peers <-
  "C:/Users/parallels/Downloads/16peers.csv"
peers16 <- getPlot(fNameFullAll16Peers, plotParam)
fNameFullAll32Peers <-
  "C:/Users/parallels/Downloads/32peers.csv"
peers32 <- getPlot(fNameFullAll32Peers, plotParam)
p8 <- peers8 + theme(legend.position="none") + labs(caption  = "<span style='color:black'><b><i>8 nodes</i></b></span>")
p16 <- peers16 + theme(legend.position="none") + labs(caption  = "<span style='color:black'><b><i>16 nodes</i></b></span>")
legend32 <- get_legend(peers32)
p32 <- peers32 + theme(legend.position="none") + labs(caption  = "<span style='color:black'><b><i>32 nodes</i></b></span>")

mergedPlot <- cowplot::plot_grid(p8, p16, p32, legend32, rel_heights = c(1,1,1,0.22), ncol=1, nrow=4)
save(paste("scalability-",plotParam,sep=""), mergedPlot, "plot")
mergedPlot

# heatMap -----------------------------------------------------------------

getHeatmap <- function(fNameFullAll, paramName) {
  
  allData <- prepareFiles(fNameFullAll, TRUE)
  
  allData$bm = str_split_fixed(allData$run_id, "-", Inf)[, 3]
  allData$bmf = str_split_fixed(allData$run_id, "-", Inf)[, 4]
  allData$fullBenchmarkName <- paste(allData$bm, allData$bmf)
  
  allData$servers = str_split_fixed(allData$run_id, "-", Inf)[, 9]
  allData$bs = str_split_fixed(allData$run_id, "-", Inf)[, 12]
  allData$bs <- ifelse(allData$bs=="0", str_split_fixed(allData$run_id, "-", Inf)[, 13], allData$bs)
  
  allData$fullBenchmarkName <- paste(allData$fullBenchmarkName, allData$bs)
  
  if(grepl( "8peers", fNameFullAll, fixed = TRUE)) {
    #print("8peers nothing to replace")
    allData <- allData  %>% add_row(fullBenchmarkName = "sb balance cordaenterprise", bs = "cordaenterprise"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment cordaenterprise", bs = "cordaenterprise"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue set cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue get cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    
  } else if(grepl( "16peers", fNameFullAll, fixed = TRUE)) {
    #print("16peers nothing to replace")
    allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment cordaenterprise", bs = "cordaenterprise"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb balance cordaenterprise", bs = "cordaenterprise"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    
    allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue set cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue get cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    
    allData <- allData  %>% add_row(fullBenchmarkName = "sb balance graphene", bs = "graphene"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    
    allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb createAccount fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb balance fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue set fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue get fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "donothing doNothing fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    
    allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb createAccount sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb balance sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue set sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue get sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "donothing doNothing sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
  } else if(grepl( "32peers", fNameFullAll, fixed = TRUE)) {
    allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment cordaenterprise", bs = "cordaenterprise"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb balance cordaenterprise", bs = "cordaenterprise"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    
    allData <- allData  %>% add_row(fullBenchmarkName = "donothing doNothing cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb createAccount cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue set cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue get cordaos", bs = "cordaos"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    
    allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb createAccount fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb balance fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue set fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue get fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "donothing doNothing fabric", bs = "fabric"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    
    allData <- allData  %>% add_row(fullBenchmarkName = "sb sendPayment sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb createAccount sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "sb balance sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue set sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "keyvalue get sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
    allData <- allData  %>% add_row(fullBenchmarkName = "donothing doNothing sawtooth", bs = "sawtooth"
                                    , 
                                    tps=0.0, avglatency=0.0, duration=0.0)
  }
  
  generalGroup <-
    allData %>% group_by(fullBenchmarkName, bs) # %>% filter(tps == max(tps))
  
  summariseByMeanTpsAndLatency <-
    generalGroup %>% summarise(
      sdtps = sd(tps, na.rm = TRUE),
      sdavglatency = sd(avglatency, na.rm = TRUE),
      tps = mean(tps, na.rm = TRUE),
      avglatency = mean(avglatency, na.rm = TRUE),
      duration = mean(duration, na.rm = TRUE),
      n = ifelse(tps == 0 && avglatency == 0, 0, n()),
      .groups = "keep"
    )
  
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="cordaenterprise",
                                             "Corda Enterprise",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="cordaos",
                                             "Corda OS",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="graphene",
                                             "BitShares",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="fabric",
                                             "Fabric",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="quorum",
                                             "Quorum",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="sawtooth",
                                             "Sawtooth",
                                             summariseByMeanTpsAndLatency$bs)
  summariseByMeanTpsAndLatency$bs <- ifelse (summariseByMeanTpsAndLatency$bs=="diem",
                                             "Diem",
                                             summariseByMeanTpsAndLatency$bs)
  
  splitVariableForBenchmarkName <- strsplit(summariseByMeanTpsAndLatency$fullBenchmarkName, " ")
  summariseByMeanTpsAndLatencyTemp <- summariseByMeanTpsAndLatency
  summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly <- sapply(strsplit(as.character(summariseByMeanTpsAndLatencyTemp$fullBenchmarkName), " "), function(splitVariableForBenchmarkName) paste(splitVariableForBenchmarkName[[1]], splitVariableForBenchmarkName[[2]], sep=""))
  summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly <- sapply(strsplit(as.character(summariseByMeanTpsAndLatencyTemp$fullBenchmarkName), " "), function(splitVariableForBenchmarkName) splitVariableForBenchmarkName[[3]])
  
  summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly == "cordaos", "Corda OS", summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly)
  summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly == "cordaenterprise", "Corda Enterprise", summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly)
  summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly == "graphene", "BitShares", summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly)
  summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly == "fabric", "Fabric", summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly)
  summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly == "quorum", "Quorum", summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly)
  summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly == "sawtooth", "Sawtooth", summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly)
  summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly == "diem", "Diem", summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly)
  
  summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly <-
    factor(
      summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly,
      levels = c(
        "Corda OS",
        "Corda Enterprise",
        "BitShares",
        "Fabric",
        "Quorum",
        "Sawtooth",
        "Diem"
      )
    )
  
  summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly == "donothingdoNothing", "DoNothing DoNothing", summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly)
  summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly == "keyvalueget", "KeyValue-Get", summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly)
  summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly == "keyvalueset", "KeyValue-Set", summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly)
  summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly == "sbcreateAccount", "BankingApp-CreateAccount", summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly)
  summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly == "sbsendPayment", "BankingApp-SendPayment", summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly)
  summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly <- ifelse(summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly == "sbbalance", "BankingApp-Balance", summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly)
  
  summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly <-
    factor(
      summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly,
      levels = c(
        "DoNothing DoNothing",
        "KeyValue-Get",
        "KeyValue-Set",
        "BankingApp-CreateAccount",
        "BankingApp-SendPayment",
        "BankingApp-Balance"
      )
    )
  
  heatmap <-
    ggplot(summariseByMeanTpsAndLatencyTemp, aes(basicSystemNameOnly, benchmarkNameOnly)) +
    cleanTpl() +
    theme(
      axis.text.y = element_markdown(size = 9, color = "black", angle = 0))+#, hjust=0.5)) +
    #  axis.text.y = element_text(size = 9, color = "black", angle = 90, hjust=0.5)) +
    geom_tile(color = "white",
              lwd = 0.4,
              linetype = 1,
              aes(fill = tps)) +
    geom_richtext(
      fill = NA,
      label.color = NA,
      label.padding = grid::unit(rep(0, 4), "pt"),
      lineheight=1.5,
      aes(
        label = paste(
          "<span style='font-size:11pt;font-weight:bold; color:black'>",#<b>",
          "MEPS=",
          format(round(tps, digits = 2), nsmall = 2), "<br/ >",
          #"<br/ >", ", \U03C3=", format(round(sdtps, digits = 2), nsmall = 2), "<br/ >",
          
          "MFLS=",
          format(round(avglatency, digits = 2), nsmall = 2), "<br/ >", 
          #"<br/ >", ", \U03C3=", format(round(sdavglatency, digits = 2), nsmall = 2), "<br/ >",
          
          "D=",
          format(round(duration, digits = 2), nsmall = 2), "<br/ >",
          "Successful=",
          n,
          "</span>",
          #"</b></span>",
          sep = ""
        )
      )
    ) +
    #  scale_fill_gradient(low = "#77aaff", high = "#3366ff") +
    scale_fill_gradient(low = "#F3F2C9", high = "#f8a288") + #"#FCF7A4", high = "#F57D58") +
    theme(legend.position = "none") +
    scale_x_discrete(labels = paste(levels(summariseByMeanTpsAndLatencyTemp$basicSystemNameOnly))) +
    scale_y_discrete(labels = paste(levels(summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly)), limits = rev(levels(summariseByMeanTpsAndLatencyTemp$benchmarkNameOnly))) +
    ylab(substitute(paste(bold("Benchmark")))) + xlab(substitute(paste(bold("Basic System"))))
  
  
  summariseByMeanTpsAndLatencyTemp$tps <- format(round(as.numeric(summariseByMeanTpsAndLatencyTemp$tps), digits = 2), nsmall = 2)
  summariseByMeanTpsAndLatencyTemp$avglatency <- format(round(as.numeric(summariseByMeanTpsAndLatencyTemp$avglatency), digits = 2), nsmall = 2)
  summariseByMeanTpsAndLatencyTemp$duration <- format(round(as.numeric(summariseByMeanTpsAndLatencyTemp$duration), digits = 2), nsmall = 2)
  
  summariseByMeanTpsAndLatencyTemp$fullBenchmarkName <- ifelse(summariseByMeanTpsAndLatencyTemp$fullBenchmarkName %like% "donothing doNothing", "DoNothing DoNothing", summariseByMeanTpsAndLatencyTemp$fullBenchmarkName)
  summariseByMeanTpsAndLatencyTemp$fullBenchmarkName <- ifelse(summariseByMeanTpsAndLatencyTemp$fullBenchmarkName %like% "keyvalue get", "KeyValue-Get", summariseByMeanTpsAndLatencyTemp$fullBenchmarkName)
  summariseByMeanTpsAndLatencyTemp$fullBenchmarkName <- ifelse(summariseByMeanTpsAndLatencyTemp$fullBenchmarkName %like% "keyvalue set", "KeyValue-Set", summariseByMeanTpsAndLatencyTemp$fullBenchmarkName)
  summariseByMeanTpsAndLatencyTemp$fullBenchmarkName <- ifelse(summariseByMeanTpsAndLatencyTemp$fullBenchmarkName %like% "sb createAccount", "BankingApp-CreateAccount", summariseByMeanTpsAndLatencyTemp$fullBenchmarkName)
  summariseByMeanTpsAndLatencyTemp$fullBenchmarkName <- ifelse(summariseByMeanTpsAndLatencyTemp$fullBenchmarkName %like% "sb sendPayment", "BankingApp-SendPayment", summariseByMeanTpsAndLatencyTemp$fullBenchmarkName)
  summariseByMeanTpsAndLatencyTemp$fullBenchmarkName <- ifelse(summariseByMeanTpsAndLatencyTemp$fullBenchmarkName %like% "sb balance", "BankingApp-Balance", summariseByMeanTpsAndLatencyTemp$fullBenchmarkName)
  
  summariseByMeanTpsAndLatencyTemp <-
    select(summariseByMeanTpsAndLatencyTemp, c(-benchmarkNameOnly, -basicSystemNameOnly))
  
  summariseByMeanTpsAndLatencyTemp <- summariseByMeanTpsAndLatencyTemp[,c(2,1,5,3,6,4,7,8)]
  
  xtHeatmap <-
    xtable(
      summariseByMeanTpsAndLatencyTemp,
      digits = 2,
      align = "l|cccccccc",
      caption = "Heatmap",
      sanitize.text.function = identity
    )
  
  #digits(xtOptimal) <- 4
  align(xtHeatmap) <- xalign(xtHeatmap)
  #digits(xtOptimal) <- xdigits(xtOptimal)
  display(xtHeatmap) <- xdisplay(xtHeatmap)
  print(
    xtable(xtHeatmap, align = "l|cccccccc", caption = "Heatmap"),
    include.rownames = FALSE,
    sanitize.text.function = identity
  )
  
  return (heatmap)
  
}

fNameFullAll8PeersHeatmap <-
  "C:/Users/parallels/Downloads/8peers.csv"
peers8Heatmap <- getHeatmap(fNameFullAll8PeersHeatmap)
fNameFullAll16PeersHeatmap <-
  "C:/Users/parallels/Downloads/16peers.csv"
peers16Heatmap <- getHeatmap(fNameFullAll16PeersHeatmap)
fNameFullAll32PeersHeatmap <-
  "C:/Users/parallels/Downloads/32peers.csv"
peers32Heatmap <- getHeatmap(fNameFullAll32PeersHeatmap)
p8Heatmap <- peers8Heatmap + theme(legend.position="none") + labs(caption  = "<span style='color:black'><b><i>8 nodes</i></b></span>")
p16Heatmap <- peers16Heatmap + theme(legend.position="none") + labs(caption  = "<span style='color:black'><b><i>16 nodes</i></b></span>")
legend32Heatmap <- get_legend(peers32Heatmap)
p32Heatmap <- peers32Heatmap + theme(legend.position="none") + labs(caption  = "<span style='color:black'><b><i>32 nodes</i></b></span>")

save("peers8heatmap", p8Heatmap, "heatmap")
save("peers16heatmap", p16Heatmap, "heatmap")
save("peers32heatmap", p32Heatmap, "heatmap")
