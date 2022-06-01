# Install and load required libraries
if(!requireNamespace("TreeTools", quietly = TRUE)) {
  install.packages("TreeTools")
}
library("TreeTools")

if(!requireNamespace("TreeDist", quietly = TRUE)) {
  install.packages("TreeDist")
}

if(!requireNamespace("protoclust", quietly = TRUE)) {
  install.packages("protoclust")
}
library("protoclust")

library("shiny")
if (!requireNamespace("shinyjs", quietly = TRUE,
                      exclude = c("colourInput", "updateColourInput",
                                  "colourPicker", "runExample"))) {
  install.packages("shinyjs")
  install.packages("colourpicker") # Necessarily absent, as imports shinyjs
}
library("shinyjs", exclude = c("colourInput", "colourPicker",
                               "updateColourInput", "runExample"))

if (!requireNamespace("colourpicker", quietly = TRUE)) {
  install.packages("colourpicker")
}
library("colourpicker")


# Configure palettes and custom input selectors
palettes <- list("#91aaa7",
                 c("#969660", "#c3dfca"),
                 c("#be83ae", "#2ea7af", "#fbcdcf"),
                 c("#72c5a9", "#b7c5ff", "#dbdabb", "#a28bac"),
                 c("#59c4c0", "#ea9a9a", "#7998a6", "#e9d7a9", "#9c9379"),
                 c("#e8b889", "#67c6eb", "#e5d5c2", "#938fba", "#64b69a", "#779c7b"),
                 c("#c4808f", "#5ba08f", "#f0a693", "#ccd7fe", "#cdb87e", "#c6aae2", "#d2dad8"),
                 c("#d0847f", "#63a5d7", "#d7b981", "#5a9bbb", "#9bb67e", "#dea6d5", "#91967e", "#ca7f96"),
                 c("#8b93a8", "#ccb97e", "#8e9dd7", "#57a384", "#dbb1e7", "#2da7af", "#d68986", "#75d2f9", "#e4d1f0"),
                 c("#dfcf92", "#40b3cb", "#b88a61", "#ecb2e0", "#d6dbbc", "#a28bae", "#edcfeb", "#7498ab", "#b187a0", "#8f939c"),
                 c("#a98f70", "#7be5e2", "#d295c0", "#9ae2bd", "#d3b7f1", "#eca88d", "#8993cd", "#ffc7bb", "#8695a8", "#b3e1df", "#b6878a"),
                 c("#eaa9d3", "#7ac09b", "#fdaca8", "#8ce7e4", "#eed69b", "#70a4d9", "#e8d6ba", "#589bbb", "#959672", "#d0dbd1", "#9b9282", "#d9d9c6"),
                 c("#7498ab", "#e5bd8a", "#7ed8ff", "#de8f8e", "#46bac6", "#ffc0d3", "#57ae96", "#f7cddd", "#50a098", "#b58a6d", "#add49d", "#a18da1", "#cedad9"),
                 c("#8097a4", "#d0dea9", "#a78cc3", "#aee4bf", "#bb82a8", "#5dc9c6", "#b88690", "#26a3b9", "#ad8e6f", "#a4e2ef", "#869a65", "#efcfdd", "#60a089", "#9e927b"),
                 c("#b9aae5", "#bbd69c", "#e2adde", "#77a777", "#f8abc8", "#8ee7ce", "#f2a1a5", "#81bdf1", "#f2bb91", "#b8dcfe", "#aeb276", "#f2cdef", "#e8d6b2", "#8d92b0", "#b7878d"),
                 c("#c3d79b", "#b28cc0", "#64a985", "#e3a7d4", "#2ea2aa", "#e69892", "#85c6f9", "#fbd1a0", "#7696be", "#89996c", "#ddcdff", "#719d89", "#f5cde6", "#b6e0da", "#e8d4cd", "#b5ddfa"),
                 c("#a98d83", "#84e1ff", "#bb8964", "#46b1d1", "#ffbfa5", "#6199c0", "#bbcb8f", "#bf82ab", "#85ddc4", "#eea0ba", "#c1d8ff", "#c3818b", "#c5c6ff", "#999388", "#e8cbff", "#ffb5b6", "#d2dad7"),
                 c("#faccde", "#60a987", "#c6abe4", "#6f9e77", "#c48093", "#a5e5d3", "#cc8f6f", "#499fae", "#d9dca6", "#7796b8", "#bee1ba", "#b4daff", "#919583", "#e2d3e9", "#47a19b", "#ebd4bc", "#7c9993", "#a9e3e0"),
                 c("#739e6e", "#ffbfd9", "#43b6bb", "#e8ad88", "#5e9bce", "#c2af75", "#a8e0fe", "#fad0a8", "#679e8d", "#ffc7b1", "#abe5c0", "#ac8d78", "#c5dddc", "#a48f84", "#cadfb0", "#899694", "#fdcdc1", "#d1dad5", "#dfd8c4"),
                 c("#6e9c93", "#ffb4b3", "#7ec6a2", "#eeccfe", "#cddb9d", "#8a90c5", "#dcb983", "#77bff0", "#f0ab92", "#90ddff", "#f1d3a9", "#b5c2fe", "#c1e1b7", "#7596ba", "#bce1c4", "#a88c96", "#5a9daf", "#b18b80", "#d4d6f3", "#949577"),
                 c("#e7d6bb", "#749ed5", "#f9d29d", "#67b3e2", "#d09773", "#65ccec", "#d38585", "#7fe8ef", "#cf8190", "#94e8cd", "#ae8cc1", "#b3cf95", "#cbc0fc", "#94a66c", "#eeccff", "#ada368", "#e9a6ce", "#48a297", "#ffc1df", "#799c7a", "#facbe0", "#5d9e9a", "#ffc6c1", "#619bb0", "#fccdcb", "#7197bb", "#b1e4c3", "#9390b1", "#c3e0c0", "#a98c90", "#ade3ce", "#9c927d", "#c2dafe", "#869881", "#e6d3dc", "#6e9ba4", "#bde0d0", "#8196a4", "#b2e1df", "#b9deea")
)

ltyInput <- function (id, name, val, none = TRUE) {
  selectInput(id, paste(name, "line type"),
              c(if (none) list("None" = "blank"),
                list("Solid" = "solid", "Dotted" = "dotted",
                     "Dashed" = "dashed", "Dot-Dash" = "dotdash",
                     "Long-dash" = "longdash", "Two-dash" = "twodash")),
              val)
}
pchInput <- function (id, name, val) {
  selectInput(id, name, 
              list(
                "Data column 4" = 904,
                "Data column 5" = 905,
                "Data column 6" = 906,
                "Square" = 0,
                "Circle" = 1,
                "Triangle-up" = 2,
                "Plus" = 3,
                "Cross" = 4,
                "Diamond" = 5,
                "Triangle-down" = 6,
                "Crossed-square" = 7,
                "Star" = 8,
                "Plussed-diamond" = 9,
                "Plussed-circle" = 10,
                "Snowflake" = 11,
                "Plussed-square" = 12,
                "Crossed-circle" = 13,
                "Triangle-in-square" = 14,
                "Filled square" = 15,
                "Filled circle" = 16,
                "Filled triangle" = 17,
                "Filled diamond" = 18
              ),
              val)
}
cexInput <- function (id, name, val) {
  sliderInput(id, name, 0, 4, val, step = 0.01)
}
lwdInput <- function (id, name, val) {
  sliderInput(id, paste(name, "line width"), 0, 6, val, step = 0.01)
}
fontInput <- function (id, name, val) {
  selectInput(id, paste0(name, " font style"),
              list("Plain" = 1, "Bold" = 2, "Italic" = 3, "Bold-italic" = 4),
              val)
}


ui <- fluidPage(
  title = "Strain analysis", theme = "style.css",
  useShinyjs(),
  
  sidebarLayout(
    sidebarPanel(
      tabsetPanel(
        tabPanel("Load data",
                 fileInput("treeFile", "Load tree",
                           placeholder = "No tree file selected"),
                 hidden(numericInput("whichTree", "Use tree number:",
                                     min = 1, max = 1, value = 1, step = 1)),
                 tags$div("Upload a csv or spreadsheet, where the first column",
                                       "lists the name of each point, as given in the tree."),
                 fileInput("metaFile", "Metadata", placeholder = "No metadata file selected",
                           accept = c('.csv', '.txt', '.xls', '.xlsx')),
                 textOutput(outputId = "dataStatus"),
                 hidden(selectInput("ptCol", "Colour points by",
                                    list("Cluster" = "Cluster",
                                         "Fixed" = "Fixed"), "Cluster")),
                 hidden(selectInput("pch", "oints by",
                                    list("Cluster" = "Cluster",
                                         "Fixed" = "Fixed"), "Fixed")),
                 sliderInput("ptCex", "Point size", 0.5, 9.5, 2.5)
        ),
        tabPanel("Plot display",
                 
                 
                 colourInput('col', 'Background colour', '#ffffff'),
                 checkboxGroupInput('display', 'Display options', 
                                    list('Clockwise' = 'clockwise',
                                         'Isometric' = 'isometric',
                                         'Tip labels' = 'show.tip.labels',
                                         'Axis labels' = 'show.axis.labels',
                                         'Axis tick labels' = 'axis.labels',
                                         'Axis tick marks' = 'axis.tick',
                                         'Rotate tick labels' = 'axis.rotate'), 
                                    c('clockwise', 'isometric', 'axis.labels',
                                      'show.axis.labels', 'axis.tick', 'axis.rotate')),
                 lwdInput('axis.lwd', 'Axis', 1),
                 ltyInput('axis.lty', 'Axis', 'solid'),
                 colourInput('axis.col', 'Axis colour', "black"),
                 lwdInput('ticks.lwd', 'Axis ticks', 1),
                 sliderInput('ticks.length', 'Axis tick length', 0, 0.1, 0.025),
                 colourInput('ticks.col', 'Axis tick colour', "darkgrey"),

        ),

        tabPanel('Points',
                 selectInput('points.type', 'Plot type', 
                             list('Points only' = 'p',
                                  'Lines' = 'l',
                                  'Connected points' = 'b',
                                  'Text' = 'text'),
                             'p'),
                 selectInput('text.source', 'Text to display',
                             list('Row names' = 0,
                                  'Data column 4' = 4,
                                  'Data column 5' = 5,
                                  'Data column 6' = 6),
                             0),
                 pchInput('points.pch', 'Point shape', 16),
                 selectInput('points.col.by', 'Point colour',
                             list('Data column 4' = 4,
                                  'Data column 5' = 5,
                                  'Data column 6' = 6,
                                  'User-specified' = 0),
                             0),
                 colourInput('points.col', 'Colour', '#222222'),
                 cexInput('points.cex', 'Point size', 1.8),
                 lwdInput('points.lwd', 'Connecting', 1),
                 ltyInput('points.lty', 'Connecting', 'solid', FALSE),
        )
      ),
    ),
    
    mainPanel(
      fluidRow(plotOutput(outputId = "mainPlot", width = "70%", height = "800px")),
      fluidRow(textOutput(outputId = "plotQual")),
      fluidRow(id = "saveButtons",
               tags$span("Save as: "),
              downloadButton('saveR', 'R script'),
              downloadButton('savePdf', 'PDF'),
              downloadButton('savePng', 'PNG'),
              tags$span("PNG size: ", id = 'pngSizeLabel'),
              numericInput('pngSize', NULL, 800, 100,
                           width = "70px", step = 10),
              tags$span("pixels"),
      ),

      withTags(
        div(id = 'caption',
           p("If using figures in a publication, please cite Smith (2017). ",
             '"Ternary: An R Package for Creating Ternary Plots." ',
             "Comprehensive R Archive Network, doi:",
             a(href = "https://dx.doi.org/10.5281/zenodo.1068996",
               "10.5281/zenodo.1068996")
            ),
        )
      ),
    )
  )
)


server <- function(input, output, session) {
  
  r <- reactiveValues()
  
  treeFile <- reactive({
    fileInput <- input$treeFile
    message(fileInput)
    if (is.null(input)) {
      return("No tree file selected.")
    }
    tmpFile <- fileInput$datapath
    if (is.null(tmpFile)) {
      return ("No trees found.")
    }
    if (length(grep("#NEXUS", toupper(readLines(tmpFile)[1]),
                    fixed = TRUE)) > 0) {
      ret <- read.nexus(tmpFile)
    } else {
      ret <- ReadTntTree(tmpFile)
      if (length(ret) == 0) ret <- read.tree(tmpFile)
    }
    
    if (!inherits(ret, c("phylo", "multiPhylo"))) {
      return("Could not read trees from file")
    }
    
    ret <- c(ret)
    nTrees <- length(ret)
    if (nTrees) {
      show("whichTree")
      updateSliderInput(session, "whichTree", value = 1, max = nTrees)
    } else {
      hide("whichTree")
    }
    
    ret
  })
  
  treeLoaded <- reactive({
    !is.character(treeFile())
  })
  
  tree <- reactive({
    treeFile()[[input$whichTree]]
  })
  
  distances <- reactive({
    if (treeLoaded()) {
      cophenetic.phylo(tree())
    }
  })
  
  mapping <- reactive({
    cmdscale(distances(), k = 2)
  })
  
  mapQual <- reactive({
    TreeDist::MappingQuality(distances(), dist(mapping()))
  })
  
  clusters <- reactive({
    if (treeLoaded()) {
      possibleClusters <- 2:20
      
      pamClusters <- lapply(possibleClusters,
                            function(k) cluster::pam(distances(), k = k))
      pamSils <- vapply(pamClusters, function(pamCluster) {
        mean(cluster::silhouette(pamCluster)[, 3])
      }, double(1))
      
      bestPam <- which.max(pamSils)
      pamSil <- pamSils[bestPam]
      pamCluster <- pamClusters[[bestPam]]$cluster
      
      hTree <- protoclust(distances())
      hClusters <- lapply(possibleClusters, function(k) cutree(hTree, k = k))
      hSils <- vapply(hClusters, function(hCluster) {
        mean(cluster::silhouette(hCluster, distances())[, 3])
      }, double(1))
      
      
      bestH <- which.max(hSils)
      hSil <- hSils[bestH]
      hCluster <- hClusters[[bestH]]
      
      if (hSil > pamSil) {
        list(clust = hCluster, sil = hSil)
      } else {
        list(clust = pamCluster, sil = pamSil)
      }
    } else {
      list(clust = NULL, sil = NULL)
    }
  })
  
  metaPath <- reactive({
    fileInput <- input$metaFile
    message("Trying ", fileInput)
    exampleFile <- ""
    if (is.null(fileInput)) {
      if (exampleFile == "") {
        ghFile <- "https://raw.githubusercontent.com/ms609/TODO/master/example.csv"
        ghFile <- "C:/users/pjjg18/downloads/Testing_Nextstrain_Metadata.csv"
        candidate <- tryCatch({
          read.csv(ghFile)
          output$dataStatus <- renderText(
            "Data / example files not found; loaded from GitHub.")
          ghFile
        }, warning = function (e) {
          output$dataStatus <- renderText(
            "Data / example files not found; could not load from GitHub.")
          ""
        })
      } else {
        output$dataStatus <- renderText(paste(
          "Data file not found; using example from", exampleFile))
        candidate <- exampleFile
      }
    } else {
      candidate <- fileInput$datapath
      if (is.null(candidate)) {
        output$dataStatus <- renderText({"Data file not found; using example."})
        candidate <- exampleFile
      } else {
        r$fileName <- fileInput$name
        output$dataStatus <- renderText({paste0("Loaded data from ", fileInput$name)})
      }
    }
    
    # Return:
    candidate
  })
  
  metaExt <- reactive({
    fp <- metaPath()
    if (nchar(fp) < 2) "<none>" else substr(fp, nchar(fp) - 3, nchar(fp))
  })
  
  ReadExcel <- function(path) {
    if(!requireNamespace("readxl", quietly = TRUE)) {
      install.packages("readxl")
    }
    x <- readxl::read_excel(path)
    rownames(x) <- x[, 1]
    x[, -1]
  }
  
  metadata <- reactive({
    fp <- metaPath()
    message(metaExt())
    ret <- switch(metaExt(),
                  ".csv" = read.csv(fp, row.names = 1),
                  ".txt" = read.table(fp, row.names = 1),
                  ".xls" = ReadExcel(fp),
                  "xlsx" = ReadExcel(fp),
                  {
                    output$dataStatus <- renderText({
                      paste0("Unsupported file extension: ", metaExt())})
                    matrix(0, 0, 3)
                  }
    )
    
    message(dim(ret))
    if (!is.null(dim(ret))) {
      show("ptCol")
      show("pch")
      cn <- colnames(ret)
      metaOpts <- c("Fixed", "Cluster", cn)
      updateSelectInput(session, "ptCol",
                        choices = setNames(metaOpts, metaOpts),
                        selected = input$ptCol)
      updateSelectInput(session, "pch",
                        choices = setNames(metaOpts, metaOpts), 
                        selected = cn[1])
    } else {
      dput(ret)
      hide("ptCol")
      hide("pch")
    }
    
    ret
  })
  
  
  DoPlot <- function() {
    if (treeLoaded()) {
      
      cluster <- clusters()$clust
      metadata()
      switch(input$ptCol,
             "Cluster" = {
               colby <- cluster
             }, "Fixed" = {
               colby <- 1
             }, {
               colCategories <- as.factor(metadata()[names(cluster), input$pch])
               colby <- as.integer(colCategories)
             }
      )
      switch(input$pch,
             "Cluster" = {
               pchby <- cluster
             }, "Fixed" = {
               pchby <- 15
             }, {
               pchCategories <- as.factor(metadata()[names(cluster), input$pch])
               pchby <- as.integer(pchCategories)
             }
      )
      
      par(mfrow = c(2, 1), mar = rep(0.1, 4))
      plot(tree(), tip.color = colby, cex = 0.7)
      plot(mapping(), asp = 1, frame.plot = FALSE, axes = FALSE,
           xlab = "", ylab = "", cex = input$ptCex,
           col = colby, pch = pchby)
      
      for (clI in unique(cluster)) {
        inCluster <- cluster == clI
        clusterX <- mapping()[inCluster, 1]
        clusterY <- mapping()[inCluster, 2]
        hull <- chull(clusterX, clusterY)
        grown <- Ternary::GrowPolygon(clusterX[hull], clusterY[hull], 0.3)
        polygon(grown, lty = 1, lwd = 2, border = clI)
        text(mean(clusterX), mean(clusterY), clI, col = clI, font = 2, pos = 1)
      }
      
      corners <- par("usr")
      nSNP <- 5L
      lines(c(corners[2] - 1, corners[2] - 1 - nSNP),
            rep(corners[3], 2) + 1, lwd = 2)
      if (FALSE) {
        legend("topright", pch = 1,
               col = seq_along(levels(categories)),
               levels(categories))
      }
      text(corners[2] - 1 - (nSNP / 2), corners[3] + 1,
           paste0("~", nSNP, " SNP"), pos = 3)
      
      poEdge <- Postorder(tree())$edge
      parent <- poEdge[, 1]
      child <- poEdge[, 2]
      xy <- matrix(0, parent[1], 2)
      xy[seq_len(NTip(tree())), ] <- mapping()
      for (node in unique(parent)) {
        xy[node, ] <- colMeans(xy[child[parent == node], , drop = FALSE])
      }
      segments(xy[parent, 1], xy[parent, 2],
               xy[child, 1], xy[child, 2],
               col = "#00000033")
      points(xy[parent, 1], xy[parent, 2], pch = ".", col = "#00000099")
    }
  }
  
  output$mainPlot <- renderPlot(DoPlot())
  output$plotQual <- renderText({
    if (treeLoaded()) {
      paste0("Trustworthiness: ", signif(mapQual()[1], 3),
             "; Continuity: ", signif(mapQual()[2], 3),
             "l Silhouette: ", signif(clusters()$sil, 3))
    } else {
      "No tree.  Load a tree using the \"Load data\" dialogue panel."
    }
  })
  
}

shinyApp(ui = ui, server = server)

