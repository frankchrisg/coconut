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
library(tidyr)
library(xtable)

library(remotes)
#remotes::install_version("Rttf2pt1", version = "1.3.8")
library(extrafont) 
#font_import(paths = "C:/Users/parallels/Downloads/linux_libertine", prompt=FALSE)
#font_import(pattern = "LMRoman*")

loadfonts()
loadfonts(device = "win") 
loadfonts(); windowsFonts()

ggplot2::update_geom_defaults("richtext", list(color = "black", family = "Linux Libertine", size=9*(1/72 * 25.4)))

cleanTpl <-
  function (base_size = 9,
            base_family = "Linux Libertine",
            ...) {
    modifyList (
      theme_minimal (base_size = base_size, base_family = base_family),
      list (axis.line = element_line (colour = "black"))
    ) + theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      #legend.title = element_blank(),
      legend.position = "bottom",
      axis.text.y = element_markdown(size = 9, color = "black", face = "bold", lineheight=1.2),
      axis.title.y = element_text(size = 9, color = "black", margin = margin(t = 0, r = 10, b = 0, l = 0)),
      axis.text.x = element_markdown(
        color = "black",
        size = 9,
        angle = 0,
        vjust = 0,
        face = "bold",
        lineheight=1.2
      ),
      axis.title.x = element_text(size = 9, color = "black", margin = margin(t = 10, r = 0, b = 0, l = 0)),
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

save <- function(titleVar, plot) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/parallels/Downloads/final-plots/heatmap/", titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    #    width = 38.94, #28.94 #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    #    height =  22.67, #16.67 #8.47,
    width = 26.00,#26.00, #28.94 #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height =  22.00,#22.00,#19.50, #16.67 #8.47,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

cordaos <-
  read.table('C:/Users/parallels/Downloads/final-txts/cordaos.txt',
             sep = '&',
             comment.char = '\\')
cordaos$eptx <- -1
cordaos$bs <- "Corda OS"
cordaos <- add_column(cordaos, V3 = rep("-", 6), .after = 2)
colnames(cordaos) <- c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8")
cordaenterprise <-
  read.table(
    'C:/Users/parallels/Downloads/final-txts/cordaenterprise.txt',
    sep = '&',
    comment.char = '\\'
  )
cordaenterprise$eptx <- -1
cordaenterprise$bs <- "Corda Enterprise"
cordaenterprise <-
  add_column(cordaenterprise, V3 = rep("-", 6), .after = 2)
colnames(cordaenterprise) <- c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8")
graphene <-
  read.table('C:/Users/parallels/Downloads/final-txts/graphene.txt',
             sep = '&',
             comment.char = '\\')
graphene$bs <- "BitShares"
colnames(graphene) <- c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8")
fabric <-
  read.table('C:/Users/parallels/Downloads/final-txts/fabric.txt',
             sep = '&',
             comment.char = '\\')
fabric$eptx <- -1
fabric$bs <- "Fabric"
colnames(fabric) <- c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8")
quorum <-
  read.table('C:/Users/parallels/Downloads/final-txts/quorum.txt',
             sep = '&',
             comment.char = '\\')
quorum$eptx <- -1
quorum$bs <- "Quorum"
colnames(quorum) <- c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8")
sawtooth <-
  read.table('C:/Users/parallels/Downloads/final-txts/sawtooth.txt',
             sep = '&',
             comment.char = '\\')
sawtooth$bs <- "Sawtooth"
colnames(sawtooth) <- c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8")
diem <-
  read.table('C:/Users/parallels/Downloads/final-txts/diem.txt',
             sep = '&',
             comment.char = '\\')
diem$eptx <- -1
diem$bs <- "Diem"
colnames(diem) <- c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8")

preparedDataFrame <- data.frame()
preparedDataFrame <- rbind(preparedDataFrame, cordaos)
preparedDataFrame <- rbind(preparedDataFrame, cordaenterprise)
preparedDataFrame <- rbind(preparedDataFrame, graphene)
preparedDataFrame <- rbind(preparedDataFrame, fabric)
preparedDataFrame <- rbind(preparedDataFrame, quorum)
preparedDataFrame <- rbind(preparedDataFrame, sawtooth)
preparedDataFrame <- rbind(preparedDataFrame, diem)

colnames(preparedDataFrame)[1] <- "benchmarkName"
colnames(preparedDataFrame)[2] <- "rateLimiter"
colnames(preparedDataFrame)[3] <- "cutCriteria"
colnames(preparedDataFrame)[4] <- "tps"
colnames(preparedDataFrame)[5] <- "latency"
colnames(preparedDataFrame)[6] <- "duration"
colnames(preparedDataFrame)[7] <- "txs"
colnames(preparedDataFrame)[8] <- "basicSystem"

preparedDataFrame$fullBenchmarkName <-
  paste(preparedDataFrame$bs, preparedDataFrame$benchmarkName, sep = " ")

preparedDataFrame$benchmarkName <-
  trimws(preparedDataFrame$benchmarkName, "r")

basicSystems <-
  c(
    "Corda OS",
    "Corda Enterprise",
    "BitShares",
    "Fabric",
    "Quorum",
    "Sawtooth",
    "Diem"
  )

yAxis <-
  rev(
    c(
      "DoNothing<br />",#DoNothing",
      "KeyValue<br />Set",
      "KeyValue<br />Get",
      "BankingApp<br />CreateAccount",
      "BankingApp<br />SendPayment",
      "BankingApp<br />Balance"
    )
  )

preparedDataFrame$basicSystem <-
  factor(
    preparedDataFrame$basicSystem,
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

preparedDataFrame$benchmarkName <-
  factor(
    preparedDataFrame$benchmarkName,
    levels = c(
      "DoNothing",
      "KeyValue-Set",
      "KeyValue-Get",
      "Banking-Create",
      "Banking-Send",
      "Banking-Balance"
    )
  )

cutCriteriaLabel <-
  c(rep((""), 6),
    rep((""), 6),
    rep(("<br />BI="), 6),
    rep(("<br />MM="), 6),
    rep(("<br />BP="), 6),
    rep(("<br />PD="), 6),
    rep(("<br />BS="), 6))

preparedDataFrame$cutCriteria <-
  ifelse(preparedDataFrame$cutCriteria == "-",
         "",
         preparedDataFrame$cutCriteria)

#preparedDataFrame <- subset(preparedDataFrame, basicSystem != "Corda OS")
#cutCriteriaLabel <- subset(cutCriteriaLabel, cutCriteriaLabel!="")
#basicSystems <- subset(basicSystems, basicSystems!="Corda OS")

#preparedDataFrame <- subset(preparedDataFrame, basicSystem != "Corda Enterprise")
#cutCriteriaLabel <- subset(cutCriteriaLabel, cutCriteriaLabel!="")
#basicSystems <- subset(basicSystems, basicSystems!="Corda Enterprise")

#preparedDataFrame <- subset(preparedDataFrame, basicSystem != "BitShares")
#cutCriteriaLabel <- subset(cutCriteriaLabel, cutCriteriaLabel!=" | BI=")
#basicSystems <- subset(basicSystems, basicSystems!="BitShares")

#preparedDataFrame <- subset(preparedDataFrame, basicSystem != "Fabric")
#cutCriteriaLabel <- subset(cutCriteriaLabel, cutCriteriaLabel!=" | MM=")
#basicSystems <- subset(basicSystems, basicSystems!="Fabric")

#preparedDataFrame <- subset(preparedDataFrame, basicSystem != "Quorum")
#cutCriteriaLabel <- subset(cutCriteriaLabel, cutCriteriaLabel!=" | BP=")
#basicSystems <- subset(basicSystems, basicSystems!="Quorum")

#preparedDataFrame <- subset(preparedDataFrame, basicSystem != "Sawtooth")
#cutCriteriaLabel <- subset(cutCriteriaLabel, cutCriteriaLabel!=" | PD=")
#basicSystems <- subset(basicSystems, basicSystems!="Sawtooth")

#preparedDataFrame <- subset(preparedDataFrame, basicSystem != "Diem")
#cutCriteriaLabel <- subset(cutCriteriaLabel, cutCriteriaLabel!=" | BS=")
#basicSystems <- subset(basicSystems, basicSystems!="Diem")

heatmap <-
  ggplot(preparedDataFrame, aes(basicSystem, benchmarkName)) +
  cleanTpl() +
  geom_tile(color = "white",
            lwd = 0.4,
            linetype = 1,
            aes(fill = tps)) +
  geom_richtext(
    fill = NA,
    label.color = NA,
    label.padding = unit(c(0.25, 0.25, 0.25, 0.25), "cm"),
    #label.padding = grid::unit(rep(0, 4), "pt"),
    lineheight=1.5,
    aes(
      fontface=2,
      label = paste(
        "<span style='font-size:11pt;font-weight:bold; color:black'>",#<b>",
        "MTPS=",
        gsub(" ", "", format(round(tps, digits = 2), nsmall = 2)),
        #"</b></span>",
        "<br /> RL=",
        rateLimiter,
        cutCriteriaLabel,
        cutCriteria,
        "<br /> MFLS=", gsub(" ", "", format(round(latency, digits = 2), nsmall = 2)), "s",
        "<br />D=", gsub(" ", "", format(round(duration, digits = 2), nsmall = 2)), "s",
        ifelse (txs >= 1, gsub(" ", "", paste("<br />" , "Actions=", txs)), ""),
        "</span>",
        #"</b></span>",
        sep = ""
      ) 
    )
  ) +
  #  scale_fill_gradient(low = "#77aaff", high = "#3366ff") +
  ##scale_fill_gradient(low = "#F3F2C9", high = "#f8a288") + #"#FCF7A4", high = "#F57D58") +
  ##scale_fill_gradient(low = "#F3F2C9", high = "#f8a288",
  ##                    limits=c(0, 1600), breaks=seq(0,1600,by=50)) +
  scale_fill_distiller(palette = "YlOrRd", limits=c(0, 1600), breaks=seq(0,1600,by=50)) +
  theme(legend.position = "none") +
  scale_x_discrete(labels = paste(basicSystems)) +
  scale_y_discrete(labels = yAxis, limits = rev(levels(preparedDataFrame$benchmarkName))) +
  ylab(substitute(paste(bold("Benchmark")))) + xlab(substitute(paste(bold("Distributed Ledger System"))))

heatmap

save(paste("heatmap", sep = ""),
     heatmap)

preparedDataFrame$tps <- format(round(preparedDataFrame$tps, digits = 2), nsmall = 2)
preparedDataFrame$latency <- format(round(preparedDataFrame$latency, digits = 2), nsmall = 2)
preparedDataFrame$duration <- format(round(preparedDataFrame$duration, digits = 2), nsmall = 2)
preparedDataFrame$txs <- ifelse (preparedDataFrame$txs >= 1, preparedDataFrame$txs, 1)
preparedDataFrame$txs <- format(round(preparedDataFrame$txs, digits = 0), nsmall = 0)

xtHeatmap <-
  xtable(
    preparedDataFrame,
    digits = 2,
    align = "l|ccccccccc",
    caption = "Heatmap",
    sanitize.text.function = identity
  )

#digits(xtOptimal) <- 4
align(xtHeatmap) <- xalign(xtHeatmap)
#digits(xtOptimal) <- xdigits(xtOptimal)
display(xtHeatmap) <- xdisplay(xtHeatmap)
print(
  xtable(xtHeatmap, align = "l|ccccccccc", caption = "Heatmap"),
  include.rownames = FALSE,
  sanitize.text.function = identity
)



savewithlegend <- function(titleVar, plot) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/parallels/Downloads/final-plots/heatmap/", titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    #    width = 38.94, #28.94 #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    #    height =  22.67, #16.67 #8.47,
    width = 30.00,#26.00, #28.94 #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height =  22.00,#22.00,#19.50, #16.67 #8.47,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

heatmapwithlegend <- heatmap +   
  scale_fill_distiller(palette = "YlOrRd", limits=c(0, 1600), breaks=seq(0,1600,by=50)) +
  #scale_fill_gradient(low = "#F3F2C9", high = "#f8a288",
  #  limits=c(0, 1600), breaks=seq(0,1600,by=50)) + 
  theme(legend.position = "right",
        legend.key.size = unit(3.0, 'cm'), #change legend key size
        legend.key.height = unit(3.0, 'cm'), #change legend key height
        legend.key.width = unit(3.0, 'cm'), #change legend key width
        #legend.title = element_blank(), #change legend title font size
        legend.text = element_markdown(
          colour = "black",
          size = 11#,
          #face = "bold"
        ),
        legend.title = element_markdown(
          colour = "black",
          size = 11,
          face = "bold.italic"
        ),
        legend.box.margin = margin(0, 7, 0, -2),
        #legend.box.margin = margin(-15, -15, -10, -15),
  ) + labs(fill="MTPS")

savewithlegend(paste("heatmapwithlegend", sep = ""),
               heatmapwithlegend)

heatmapwithlegend