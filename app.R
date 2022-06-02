# Install and load required libraries
Require <- function (packages) {
  for (pkg in packages) {
    if(!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  }
}
  
Require(c("TreeTools", "TreeDist", "protoclust", "shiny", "r2d3"))

if (!requireNamespace("shinyjs", quietly = TRUE,
                      exclude = "runExample")) {
  install.packages("shinyjs")
}
library("shinyjs", exclude = "runExample")


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
      # tabsetPanel(
        # tabPanel("Load data",
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
                 hidden(selectInput("pch", "Style points by",
                                    list("Cluster" = "Cluster",
                                         "Fixed" = "Fixed"), "Fixed")),
                 sliderInput("ptCex", "Point size", 0.5, 9.5, 2.5),
                 checkboxGroupInput("Display", "Display:",
                                    list("Cluster boundaries" = "hulls"),
                                    c("hulls"))
        # ),
        # tabPanel("Plot display",
        #
        #
        #          colourInput('col', 'Background colour', '#ffffff'),
        #          checkboxGroupInput('display', 'Display options',
        #                             list('Clockwise' = 'clockwise',
        #                                  'Isometric' = 'isometric',
        #                                  'Tip labels' = 'show.tip.labels',
        #                                  'Axis labels' = 'show.axis.labels',
        #                                  'Axis tick labels' = 'axis.labels',
        #                                  'Axis tick marks' = 'axis.tick',
        #                                  'Rotate tick labels' = 'axis.rotate'),
        #                             c('clockwise', 'isometric', 'axis.labels',
        #                               'show.axis.labels', 'axis.tick', 'axis.rotate')),
        #          lwdInput('axis.lwd', 'Axis', 1),
        #          ltyInput('axis.lty', 'Axis', 'solid'),
        #          colourInput('axis.col', 'Axis colour', "black"),
        #          lwdInput('ticks.lwd', 'Axis ticks', 1),
        #          sliderInput('ticks.length', 'Axis tick length', 0, 0.1, 0.025),
        #          colourInput('ticks.col', 'Axis tick colour', "darkgrey"),
        #
        # ),
        #
        # tabPanel('Points',
        #          selectInput('points.type', 'Plot type',
        #                      list('Points only' = 'p',
        #                           'Lines' = 'l',
        #                           'Connected points' = 'b',
        #                           'Text' = 'text'),
        #                      'p'),
        #          selectInput('text.source', 'Text to display',
        #                      list('Row names' = 0,
        #                           'Data column 4' = 4,
        #                           'Data column 5' = 5,
        #                           'Data column 6' = 6),
        #                      0),
        #          pchInput('points.pch', 'Point shape', 16),
        #          selectInput('points.col.by', 'Point colour',
        #                      list('Data column 4' = 4,
        #                           'Data column 5' = 5,
        #                           'Data column 6' = 6,
        #                           'User-specified' = 0),
        #                      0),
        #          colourInput('points.col', 'Colour', '#222222'),
        #          cexInput('points.cex', 'Point size', 1.8),
        #          lwdInput('points.lwd', 'Connecting', 1),
        #          ltyInput('points.lty', 'Connecting', 'solid', FALSE),
        # )
      # ),
    ),

    mainPanel(
      fluidRow(d3Output(outputId = "d3Plot")),
      fluidRow(plotOutput(outputId = "treePlot", height = "200px")),
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

      # withTags(
      #   div(id = "caption",
      #      p("If using figures in a publication, please cite Smith (2017). ",
      #        '"Ternary: An R Package for Creating Ternary Plots." ',
      #        "Comprehensive R Archive Network, doi:",
      #        a(href = "https://dx.doi.org/10.5281/zenodo.1068996",
      #          "10.5281/zenodo.1068996")
      #       ),
      #   )
      # ),
    )
  )
)


server <- function(input, output, session) {

  r <- reactiveValues()

  treeFile <- reactive({
    fileInput <- input$treeFile
    if (is.null(input)) {
      return("No tree file selected.")
    }
    tmpFile <- fileInput$datapath
    if (is.null(tmpFile)) {
      return ("No trees found.")
    }
    if (length(grep("#NEXUS", toupper(readLines(tmpFile)[1]),
                    fixed = TRUE)) > 0) {
      ret <- read.nexus(tmpFile, force.multi = TRUE)
    } else {
      ret <- ReadTntTree(tmpFile)
      if (length(ret) == 0) ret <- read.tree(tmpFile)
    }

    if (!inherits(ret, c("phylo", "multiPhylo"))) {
      return("Could not read trees from file")
    }

    ret <- c(ret)
    dput(ret)
    nTrees <- length(ret)
    if (nTrees > 1) {
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
      
      hTree <- protoclust(as.dist(distances()))
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
    if (!is.null(dim(ret))) {
      show("ptCol")
      show("pch")
      cn <- colnames(ret)
      metaOpts <- c("Fixed", "Cluster", cn)
      updateSelectInput(session, "ptCol",
                        choices = setNames(metaOpts, metaOpts))
      updateSelectInput(session, "pch",
                        choices = setNames(metaOpts, metaOpts))
    } else {
      hide("ptCol")
      hide("pch")
    }

    ret
  })

  TreePlot <- function() {
    if (treeLoaded()) {

      cluster <- clusters()$clust
      metadata()
      switch(input$ptCol,
             "Cluster" = {
               colby <- hcl.colors(max(cluster), "dark2")[cluster]
             }, "Fixed" = {
               colby <- 1
             }, {
               colCategories <- as.factor(metadata()[names(cluster), input$ptCol])
               pal <- hcl.colors(length(levels(colCategories)), "dark2", 0.9)
               colby <- pal[as.integer(colCategories)]
             }
      )
      switch(input$pch,
             "Cluster" = {
               pchby <- cluster
             }, "Fixed" = {
               pchby <- 16 # filled circle
             }, {
               pchCategories <- as.factor(metadata()[names(cluster), input$pch])
               pchby <- as.integer(pchCategories)
             }
      )
      layout(matrix(1:2, 1), widths = c(1, 3))
      par(mar = rep(0, 4))
      plot.new()
      if (!input$ptCol %in% c("Fixed", "Cluster")) {
        legend("top", pch = 15, col = pal, levels(colCategories),
               bty = "n", pt.cex = 2)
      }
      if (!input$pch %in% c("Fixed", "Cluster")) {
        legend("bottom", col = 1, pt.cex = 2, bty = "n",
               pch = seq_along(levels(pchCategories)),
               levels(pchCategories))
      }
      plot(tree(), tip.color = colby, cex = 0.7)
    }
  }

  MapPlot <- function() {
    if (treeLoaded()) {
      
      d <- distances()
      colnames(d) <- paste0("d", seq_len(ncol(d)) - 1)
      
      m <- mapping()
      m <- m + min(m)
      m <- m / max(m)
      colnames(m) <- c("mappedX", "mappedY")
      
      md <- metadata()
      
      cluster <- clusters()$clust
      clusterCol <- hcl.colors(max(cluster), "dark2")[cluster]
      
      d3Data <- cbind(d, m,
                      cluster = cluster,
                      Cluster_col = clusterCol,
                      md)
      
      r2d3(d3Data, script = "plot.js",
           options = list(meta = rownames(md)),
           container = "div")
    }
  }

  output$treePlot <- renderPlot(TreePlot())
  output$d3Plot <- renderD3(MapPlot())
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
