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
#font_import(paths = "C:/Users/frank/Downloads/linux_libertine", prompt=FALSE)
#font_import(pattern = "LMRoman*") 
loadfonts()
loadfonts(device = "win") 
loadfonts(); windowsFonts()

save2 <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 16.94, #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height = 8.47,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

allList <- list()

# cordaosTogether -----------------------------------------------------------

savecordaos1 <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 10.00, #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height = 6,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

savecordaos2 <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 10,#16.94, #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height = 10,#6.66,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

cordaos <- list(plot_listTps[2][[1]],
     plot_listFailures[2][[1]],
     plot_listLatency[2][[1]])

cordaosa <- cowplot::plot_grid(
  cordaos[[1]],
  NULL,
  cordaos[[3]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Corda OS - KeyValue-Set"),#"<span style='color:black'><b>(A) - Corda OS</b></span>"),
  nrow=3,
  rel_heights = c(1, -0.05, 1),
  align="v")
cordaosb <- cowplot::plot_grid(
  cordaos[[2]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Corda OS - KeyValue-Set"),#"<span style='color:black'><b>(B) - Corda OS</b></span>"),
  nrow=1)
cordaosfull <- cowplot::plot_grid(cordaosa, cordaosb, ncol=2, align="vh")

------------------------

saveinline <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 33.15,#16.94, #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height = 15.82,#20.82,#6.66,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

saveinline("inlinemflsandmtps",
        cowplot::plot_grid(
          cowplot::plot_grid(cordaosa, cordaenterprisea, graphenea, fabrica, ncol=4),
          cowplot::plot_grid(quoruma, sawtootha, diema, ncol=3),
          nrow=2), "")

saveinline("inlinenot",
        cowplot::plot_grid(
          cowplot::plot_grid(cordaosb, cordaenterpriseb, grapheneb, fabricb, ncol=4),
          cowplot::plot_grid(quorumb, sawtoothb, diemb, ncol=3),
          nrow=2), "")

saveinline("inlineblocks",
        cowplot::plot_grid(
          cowplot::plot_grid(graphenec, fabricc, quorumc, ncol=3),
          cowplot::plot_grid(sawtoothc, diemc, ncol=2),
          nrow=2), "")

-----------------------

cordaosh <- cowplot::plot_grid(cordaosa, NULL, cordaosb, rel_widths = c(1, -0.02, 1), ncol=3, align="vh")
cordaosv <- cowplot::plot_grid(cordaosa, NULL, cordaosb, rel_heights = c(1, -0.05, 1), nrow=3, align="vh")

cordaosh <- cowplot::ggdraw(cowplot::add_sub(
  cordaosh,
  #"DoNothing",
  "KeyValue-Set",
  #"KeyValue-Get",
  #"BankingApp-CreateAccount",
  #"BankingApp-SendPayment",
  #"BankingApp-Balance",
  x = 0.75,
  y = 0.2,
  hjust = 0.5,
  vjust = -2.5,
  vpadding = grid::unit(0.75, "lines"),
  fontfamily = "Linux Libertine",
  fontface = "bold.italic",
  color = "black",
  size = 9,
  angle = 0,
  lineheight = 0.9,
  "black"
))

cordaosy <- cowplot::ggdraw(cowplot::add_sub(
  cordaosb,
  "(B)",
  x = 0.5,
  y = 0.5,
  hjust = 0.5,
  vjust = -2.5,
  vpadding = grid::unit(1, "lines"),
  fontfamily = "Linux Libertine",
  fontface = "plain",
  color = "black",
  size = 9,
  angle = 0,
  lineheight = 0.9,
  "red"
))

#cordaoshx <- cowplot::plot_grid(cordaosx, NULL, cordaosy, rel_widths = c(1, -0.02, 1), ncol=3, align="vh")

savecordaos1("cordaosh", cordaosh, "")
savecordaos2("cordaosv", cordaosv, "")

save2("cordaos", cordaosfull, "")

# cordaenterpriseTogether -------------------------------------------------

cordaenterprise <- list(plot_listTps[2][[1]],
                    plot_listFailures[2][[1]],
                    plot_listLatency[2][[1]])

cordaenterprisea <- cowplot::plot_grid(
  cordaenterprise[[1]],
  cordaenterprise[[3]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption  = "Corda Enterprise - KeyValue-Set"), #"<span style='color:black'><b>(A) - Corda Enterprise</b></span>"),
  nrow=2,
  align="v")
cordaenterpriseb <- cowplot::plot_grid(
  cordaenterprise[[2]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption  = "Corda Enterprise - KeyValue-Set"), #"<span style='color:black'><b>(B) - Corda Enterprise</b></span>"),
  nrow=1)
cordaenterprisefull <- cowplot::plot_grid(cordaenterprisea, cordaenterpriseb, ncol=2, align="vh")

cordaenterpriseh <- cowplot::plot_grid(cordaenterprisea, NULL, cordaenterpriseb, rel_widths = c(1, -0.02, 1), ncol=3, align="vh")
cordaenterprisev <- cowplot::plot_grid(cordaenterprisea, NULL, cordaenterpriseb, rel_heights = c(1, -0.05, 1), nrow=3, align="vh")

cordaenterpriseh <- cowplot::ggdraw(cowplot::add_sub(
  cordaenterpriseh,
  #"DoNothing",
  "KeyValue-Set",
  #"KeyValue-Get",
  #"BankingApp-CreateAccount",
  #"BankingApp-SendPayment",
  #"BankingApp-Balance",
  x = 0.75,
  y = 0.2,
  hjust = 0.5,
  vjust = -2.5,
  vpadding = grid::unit(0.75, "lines"),
  fontfamily = "Linux Libertine",
  fontface = "bold.italic",
  color = "black",
  size = 9,
  angle = 0,
  lineheight = 0.9,
  "black"
))

savecordaos1("cordaenterpriseh", cordaenterpriseh, "")
savecordaos2("cordaenterprisev", cordaenterprisev, "")

save2("cordaenterprise", cordaenterprisefull, "")

cordaostogether <- cowplot::plot_grid(cordaosfull,cordaenterprisefull, ncol=2, align="vh")
save2("cordatogether", cordaostogether, "")

# grapheneTogether -----------------------------------------------------------

savegraphene1 <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 10.4, #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height = 12,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

savegraphene2 <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 16.94, #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height = 6.66,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

graphene <- list(plot_listTps[1][[1]],
                plot_listFailures[1][[1]],
                plot_listLatency[1][[1]],
                plot_listBlockStats[1][[1]])

graphenea <- cowplot::plot_grid(
  graphene[[1]],
  NULL,
  graphene[[3]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption  = "BitShares - DoNothing"), #"<span style='color:black'><b>(A) - BitShares</b></span>"),
  nrow=3,
  rel_heights = c(1, -0.05, 1),
  align="v")
grapheneb <- cowplot::plot_grid(
  graphene[[2]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption  = "BitShares - DoNothing"), #"<span style='color:black'><b>(B) - BitShares</b></span>"),
  nrow=1)
graphenec <- cowplot::plot_grid(
  graphene[[4]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption  = "BitShares - DoNothing"), #"<span style='color:black'><b>(C) - BitShares</b></span>"),
  nrow=1)
graphenefull <- cowplot::plot_grid(graphenea, grapheneb, graphenec, ncol=3, align="vh")

grapheneah <- cowplot::plot_grid(graphenea, NULL, grapheneb, rel_widths = c(1, -0.02, 1), ncol=3, align="vh")
graphenev <- cowplot::plot_grid(grapheneah, NULL, graphenec, rel_heights = c(1, -0.05, 1), nrow=3, align="vh")

graphenev <- cowplot::ggdraw(cowplot::add_sub(
  graphenev,
  "DoNothing",
  #"KeyValue-Set",
  #"KeyValue-Get",
  #"BankingApp-CreateAccount",
  #"BankingApp-SendPayment",
  #"BankingApp-Balance",
  x = 0.75,
  y = 0.2,
  hjust = 0.5,
  vjust = -2.5,
  vpadding = grid::unit(0.75, "lines"),
  fontfamily = "Linux Libertine",
  fontface = "bold.italic",
  color = "black",
  size = 9,
  angle = 0,
  lineheight = 0.9,
  "black"
))

savegraphene1("graphenetogetherv", graphenev, "")
grapheneh <- cowplot::plot_grid(graphenea, NULL,grapheneb, NULL, graphenec, rel_widths = c(1, -0.03, 1, -0.03, 1), ncol=5, align="vh")
savegraphene2("graphenetogetherh", grapheneh, "")

graphenefull <- ggdraw(add_sub(graphenefull, "BitShares DoNothing-DoNothing", vpadding=grid::unit(0, "lines"),
               y = 3.3, x = 0.89,   fontfamily = "Linux Libertine",
               fontface = "plain",
               color = "black",
               size = 9))

savegraphene1("graphenetogethert1", graphenefull, "")

# grapheneLegend ----------------------------------------------------------

save3 <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 15.00, #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height = 2.00,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

#"#7FD34EFF" "#24AA83FF" "#29798EFF" "#404587FF" "#440154FF"
col1 <- adjustcolor( "#7FD34EFF", alpha.f = 0.2)
col2 <- adjustcolor( "#24AA83FF", alpha.f = 0.2)
col3 <- adjustcolor( "#29798EFF", alpha.f = 0.2)
col4 <- adjustcolor( "#404587FF", alpha.f = 0.2)
col5 <- adjustcolor( "#440154FF", alpha.f = 0.2)

legend_blocks <- get_legend(
  graphene[[4]] + 
    guides(fill = guide_legend(
      nrow = 5, override.aes = list(shape = c( 
                                                      "\u25BA","\u25BA","\u25BA","\u25BA","\u25BA"),
                                    fill = NA, linetype = c(0, 0, 0, 0, 0)))) +
#      override.aes = list(size = 2, fill = NA)), #rev(viridis(
        #100
      #)[seq.int(1L, length(viridis(100)), 20L)])
    ##    c(col1, col2, col3, col4, col5)),
#    color = guide_legend(override.aes = list(color = rev(viridis(
#      100
#      )[seq.int(1L, length(viridis(100)), 20L)]),
#          c(col1, col2, col3, col4, col5))),
#    ) +
    scale_color_manual(
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
      values = rev(viridis(100)[seq.int(1L, length(viridis(100)), 20L)])
    ) +
    theme(#legend.position='bottom', 
      #legend.justification='center',
      #legend.direction='horizontal',
      text=element_text(family="Linux Libertine Display"),
      legend.key=element_blank()
    )
)

legend_failed <- get_legend(
  graphene[[2]] +
    guides(color = guide_legend(
      nrow=5,             override.aes = list(
        color = c("#95D840FF", "#482677FF")#, "#39568CFF")
      ))) +
    theme(#legend.position='bottom', 
      #legend.justification='center',
      #legend.direction='horizontal',
      text=element_text(family="Linux Libertine Display"),
      #legend.margin = margin(r=880)
    ))
legend_tpslatency <- get_legend(
  graphene[[3]] +
    guides(color = guide_legend(
      nrow=5,             override.aes = list(
        color = c("#95D840FF", "#20A387FF", "#482677FF", "black"),
        shape = c(16, 16, 15, NA)
      ))) +
    theme(#legend.position='bottom', 
      #legend.justification='center',
      #legend.direction='horizontal',
      #legend.margin=margin(r=400),
      text=element_text(family="Linux Libertine Display")
    ))

legendfull <- plot_grid(legend_blocks, legend_tpslatency, legend_failed, nrow=1)
save3("withlegend", legendfull, "")

# fabricTogether -----------------------------------------------------------

fabric <- list(plot_listTps[5][[1]],
                 plot_listFailures[5][[1]],
                 plot_listLatency[5][[1]],
                 plot_listBlockStats[5][[1]])

fabrica <- cowplot::plot_grid(
  fabric[[1]],
  fabric[[3]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Fabric - BankingApp-SendPayment"), #"<span style='color:black'><b>(A) - Fabric</b></span>"),
  nrow=2,
  align="v")
fabricb <- cowplot::plot_grid(
  fabric[[2]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Fabric - BankingApp-SendPayment"), #"<span style='color:black'><b>(B) - Fabric</b></span>"),
  nrow=1)
fabricc <- cowplot::plot_grid(
  fabric[[4]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Fabric - BankingApp-SendPayment"), #"<span style='color:black'><b>(C) - Fabric</b></span>"),
  nrow=1)

fabricah <- cowplot::plot_grid(fabrica, NULL, fabricb, rel_widths = c(1, -0.02, 1), ncol=3, align="vh")
fabricv <- cowplot::plot_grid(fabricah, NULL, fabricc, rel_heights = c(1, -0.05, 1), nrow=3, align="vh")

fabricv <- cowplot::ggdraw(cowplot::add_sub(
  fabricv,
  #"DoNothing",
  #"KeyValue-Set",
  #"KeyValue-Get",
  #"BankingApp-CreateAccount",
  "BankingApp-SendPayment",
  #"BankingApp-Balance",
  x = 0.75,
  y = 0.2,
  hjust = 0.5,
  vjust = -2.5,
  vpadding = grid::unit(0.75, "lines"),
  fontfamily = "Linux Libertine",
  fontface = "bold.italic",
  color = "black",
  size = 9,
  angle = 0,
  lineheight = 0.9,
  "black"
))

savegraphene1("fabrictogetherv", fabricv, "")
fabrich <- cowplot::plot_grid(fabrica, NULL,fabricb, NULL, fabricc, rel_widths = c(1, -0.03, 1, -0.03, 1), ncol=5, align="vh")
savegraphene2("fabrictogetherh", fabrich, "")


fabricfull <- cowplot::plot_grid(fabrica, fabricb, fabricc, ncol=3, align="vh")
savegraphene2("fabrictogether", fabricfull, "")

# quorumTogether -----------------------------------------------------------

quorum <- list(plot_listTps[6][[1]],
               plot_listFailures[6][[1]],
               plot_listLatency[6][[1]],
               plot_listBlockStats[6][[1]])

quoruma <- cowplot::plot_grid(
  quorum[[1]],
  quorum[[3]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Quorum - BankingApp-Balance"), #"<span style='color:black'><b>(A) - Quorum</b></span>"),
  nrow=2,
  align="v")
quorumb <- cowplot::plot_grid(
  quorum[[2]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Quorum - BankingApp-Balance"), #"<span style='color:black'><b>(B) - Quorum</b></span>"),
  nrow=1)
quorumc <- cowplot::plot_grid(
  quorum[[4]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Quorum - BankingApp-Balance"), #"<span style='color:black'><b>(C) - Quorum</b></span>"),
  nrow=1)

quorumah <- cowplot::plot_grid(quoruma, NULL, quorumb, rel_widths = c(1, -0.02, 1), ncol=3, align="vh")
quorumv <- cowplot::plot_grid(quorumah, NULL, quorumc, rel_heights = c(1, -0.05, 1), nrow=3, align="vh")

quorumv <- cowplot::ggdraw(cowplot::add_sub(
  quorumv,
  #"DoNothing",
  #"KeyValue-Set",
  #"KeyValue-Get",
  #"BankingApp-CreateAccount",
  #"BankingApp-SendPayment",
  "BankingApp-Balance",
  x = 0.75,
  y = 0.2,
  hjust = 0.5,
  vjust = -2.5,
  vpadding = grid::unit(0.75, "lines"),
  fontfamily = "Linux Libertine",
  fontface = "bold.italic",
  color = "black",
  size = 9,
  angle = 0,
  lineheight = 0.9,
  "black"
))

savegraphene1("quorumtogetherv", quorumv, "")
quorumh <- cowplot::plot_grid(quoruma, NULL,quorumb, NULL, quorumc, rel_widths = c(1, -0.03, 1, -0.03, 1), ncol=5, align="vh")
savegraphene2("quorumtogetherh", quorumh, "")

quorumfull <- cowplot::plot_grid(quoruma, quorumb, quorumc, ncol=3, align="vh")
savegraphene2("quorumtogether", quorumfull, "")

# sawtoothTogether -----------------------------------------------------------

save4 <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 20.94,
    #NA,
    height = 8.47,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

savesawtooth1 <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 13.5, #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height = 12,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

savesawtooth2 <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 19.94, #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height = 6.66,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

sawtooth <- list(plot_listTps[2][[1]],
               plot_listFailures[2][[1]],
               plot_listLatency[2][[1]],
               plot_listBlockStats[2][[1]])

sawtootha <- cowplot::plot_grid(
  sawtooth[[1]],
  sawtooth[[3]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Sawtooth - BankingApp-CreateAccount"), #"<span style='color:black'><b>(A) - Sawtooth</b></span>"),
  nrow=2,
  align="v")
sawtoothb <- cowplot::plot_grid(
  sawtooth[[2]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Sawtooth - BankingApp-CreateAccount"), #"<span style='color:black'><b>(B) - Sawtooth</b></span>"),
  nrow=1)
sawtoothc <- cowplot::plot_grid(
  sawtooth[[4]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Sawtooth - BankingApp-CreateAccount"), #"<span style='color:black'><b>(C) - Sawtooth</b></span>"),
  nrow=1)

sawtoothh <- cowplot::plot_grid(sawtootha, NULL, sawtoothb, rel_widths = c(1, -0.02, 1), ncol=3, align="vh")
sawtoothv <- cowplot::plot_grid(sawtoothh, NULL, sawtoothc, rel_heights = c(1, -0.05, 1), nrow=3, align="vh")

sawtoothv <- cowplot::ggdraw(cowplot::add_sub(
  sawtoothv,
  #"DoNothing",
  #"KeyValue-Set",
  #"KeyValue-Get",
  "BankingApp-CreateAccount",
  #"BankingApp-SendPayment",
  #"BankingApp-Balance",
  x = 0.75,
  y = 0.2,
  hjust = 0.5,
  vjust = -2.5,
  vpadding = grid::unit(0.75, "lines"),
  fontfamily = "Linux Libertine",
  fontface = "bold.italic",
  color = "black",
  size = 9,
  angle = 0,
  lineheight = 0.9,
  "black"
))

savesawtooth1("sawtoothtogetherv", sawtoothv, "")
sawtoothh <- cowplot::plot_grid(sawtootha, NULL,sawtoothb, NULL, sawtoothc, rel_widths = c(1, -0.03, 1, -0.03, 1), ncol=5, align="vh")
savesawtooth2("sawtoothtogetherh", sawtoothh, "")

sawtoothfull <- cowplot::plot_grid(sawtootha, sawtoothb, sawtoothc, ncol=3, align="vh")
save4("sawtoothtogether", sawtoothfull, "")

# diemTogether -----------------------------------------------------------

savediem1 <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 13.5, #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height = 12,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

savediem2 <- function(titleVar, plot, path) {
  fileName = tolower(gsub(
    " ",
    "",
    paste("C:/Users/frank/Downloads/",path,"/",titleVar, ".png"),
    fixed = TRUE
  ))
  ggsave(
    fileName,
    plot = plot,
    device = "png",
    path = NULL,
    scale = 1,
    width = 20.94, #20.94 <- x sawtooth and diem, 16.94,
    #NA,
    height = 6.66,
    #NA,
    units = c("cm"),
    #"in"),
    dpi = 320,
    #320,
    limitsize = TRUE,
    bg = "white"
  )
}

diem <- list(plot_listTps[4][[1]],
                 plot_listFailures[4][[1]],
                 plot_listLatency[4][[1]],
                 plot_listBlockStats[4][[1]])

diema <- cowplot::plot_grid(
  diem[[1]],
  diem[[3]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Diem - KeyValue-Get"), #"<span style='color:black'><b>(A) - Diem</b></span>"),
  nrow=2,
  align="v")
diemb <- cowplot::plot_grid(
  diem[[2]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Diem - KeyValue-Get"), #"<span style='color:black'><b>(B) - Diem</b></span>"),
  nrow=1)
diemc <- cowplot::plot_grid(
  diem[[4]] + theme(legend.position="none",plot.caption.position = "plot", plot.caption = element_blank()) + theme(plot.caption=element_text(face="bold", hjust=0.9)) + labs(caption = "Diem - KeyValue-Get"), #"<span style='color:black'><b>(C) - Diem</b></span>"),
  nrow=1)

#diema <- getCaption(diema, "(A)")
#diemb <- getCaption(diemb, "(B)")
#diemc <- getCaption(diemc, "(C)")

#diemfull <- cowplot::plot_grid(diema, diemb, diemc, ncol=3, align="vh")
#save4("diemtogether", diemfull, "")

diemh <- cowplot::plot_grid(diema, NULL, diemb, rel_widths = c(1, -0.02, 1), ncol=3, align="vh")
diemv <- cowplot::plot_grid(diemh, NULL, diemc, rel_heights = c(1, -0.05, 1), nrow=3, align="vh")

diemv <- cowplot::ggdraw(cowplot::add_sub(
  diemv,
  #"DoNothing",
  #"KeyValue-Set",
  "KeyValue-Get",
  #"BankingApp-CreateAccount",
  #"BankingApp-SendPayment",
  #"BankingApp-Balance",
  x = 0.75,
  y = 0.2,
  hjust = 0.5,
  vjust = -2.5,
  vpadding = grid::unit(0.75, "lines"),
  fontfamily = "Linux Libertine",
  fontface = "bold.italic",
  color = "black",
  size = 9,
  angle = 0,
  lineheight = 0.9,
  "black"
))

savediem1("diemtogetherv", diemv, "")
diemh <- cowplot::plot_grid(diema, NULL,diemb, NULL, diemc, rel_widths = c(1, -0.03, 1, -0.03, 1), ncol=5, align="vh")
savediem2("diemtogetherh", diemh, "")

#allList<- append(allList, cordaos)
#allList <- append(allList, cordaosreal)
#allList <- append(allList, graphene)

getCaption <- function(plot, caption) {
  
  return(cowplot::ggdraw(cowplot::add_sub(
    plot,
    caption,
    x = 0.5,
    y = 0.5,
    hjust = 0.5,
    vjust = -3.5,
    vpadding = grid::unit(1, "lines"),
    fontfamily = "Linux Libertine",
    fontface = "plain",
    color = "black",
    size = 9,
    angle = 0,
    lineheight = 0.9,
    "red"
  )))
  
}

cowplot::ggdraw(cowplot::add_sub(
  graphenev,
  "BitShares",
  x = 0.9,
  y = 0.3,
  hjust = 0.0,
  vjust = -4.5,
  vpadding = grid::unit(1, "lines"),
  fontfamily = "Linux Libertine",
  fontface = "plain",
  color = "black",
  size = 9,
  angle = 0,
  lineheight = 0.9,
  "red"
))