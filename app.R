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
      fileInput("treeFile", "Load tree",
                placeholder = "No tree file selected"),
      hidden(numericInput("whichTree", "Use tree number:",
                          min = 1, max = 1, value = 1, step = 1)),
      tags$div("Upload a csv or spreadsheet, where the first column",
               "lists the name of each sample, as given in the tree."),
      fileInput("metaFile", "Metadata",
                placeholder = "No metadata file selected",
                accept = c('.csv', '.txt', '.xls', '.xlsx')),
      tags$div("Upload a csv or spreadsheet, where the first two columns list ",
               "the \"from\" and \"to\" of each contact event."),
      fileInput("contactFile", "Contacts",
                placeholder = "No contact tracing file selected",
                accept = c('.csv', '.txt', '.xls', '.xlsx')),
      textOutput(outputId = "dataStatus"),
    ),

    mainPanel(
      fluidRow(
        column(3,
               plotOutput(outputId = "treePlot", height = "600px")
        ),
        column(9,
               d3Output(outputId = "d3Plot", height = "600px", width = "600px")
        ),
      ),
      fluidRow(textOutput(outputId = "plotQual")),
      # fluidRow(id = "saveButtons",
      #          tags$span("Save as: "),
      #         downloadButton('saveR', 'R script'),
      #         downloadButton('savePdf', 'PDF'),
      #         downloadButton('savePng', 'PNG'),
      #         tags$span("PNG size: ", id = 'pngSizeLabel'),
      #         numericInput('pngSize', NULL, 800, 100,
      #                      width = "70px", step = 10),
      #         tags$span("pixels"),
      # ),

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

  contactPath <- reactive({
    fileInput <- input$contactFile
    exampleFile <- ""
    if (is.null(fileInput)) {
      if (exampleFile == "") {
        ghFile <- "https://raw.githubusercontent.com/ms609/TODO/master/example.csv"
        candidate <- tryCatch({
          read.csv(ghFile)
          output$dataStatus <- renderText(
            "Contact / example files not found; loaded from GitHub.")
          ghFile
        }, warning = function (e) {
          output$dataStatus <- renderText(
            "Contact / example files not found; could not load from GitHub.")
          ""
        })
      } else {
        output$dataStatus <- renderText(paste(
          "Contact tracing file not found; using example from", exampleFile))
        candidate <- exampleFile
      }
    } else {
      candidate <- fileInput$datapath
      if (is.null(candidate)) {
        output$dataStatus <- renderText({"Contact file not found; using example."})
        candidate <- exampleFile
      } else {
        r$fileName <- fileInput$name
        output$dataStatus <- renderText({paste0("Loaded contacts from ", fileInput$name)})
      }
    }

    # Return:
    candidate
  })

  Extension <- function(fp) {
    if (nchar(fp) < 2) "<none>" else substr(fp, nchar(fp) - 3, nchar(fp))
  }

  ReadExcel <- function(path) {
    if(!requireNamespace("readxl", quietly = TRUE)) {
      install.packages("readxl")
    }
    x <- readxl::read_excel(path)
    rownames(x) <- x[, 1]
    x[, -1]
  }
  
  ReadTabular <- function(fp, ...) {
    ret <- switch(Extension(fp),
                  ".csv" = read.csv(fp, ...),
                  ".txt" = read.table(fp, ...),
                  ".xls" = ReadExcel(fp),
                  "xlsx" = ReadExcel(fp),
                  {
                    output$dataStatus <- renderText({
                      paste0("Unsupported file extension: ", Extension(fp))})
                    matrix(0, 0, 3)
                  }
    )
    
    ret
  }

  metadata <- reactive({
    ReadTabular(metaPath(), row.names = 1)
  })
  
  contacts <- reactive({
    ReadTabular(contactPath())
  })
  
  metaCols <- reactive({
    vapply(metadata(), function (x) {
      fac <- as.factor(x)
      nLevel <- length(levels(fac))
      hcl.colors(nLevel, "dark2")[fac]
    }, character(nrow(metadata())))
  })

  TreePlot <- function() {
    if (treeLoaded()) {
      cluster <- clusters()$clust
      colby <- hcl.colors(max(cluster), "dark2")[cluster]
      
      par(mar = rep(0, 4))
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
      
      cluster <- clusters()$clust
      clusterCol <- hcl.colors(max(cluster), "dark2")[cluster]
      
      
      md <- metadata()
      mc <- metaCols()
      colnames(mc) <- paste0(colnames(mc), "_col")
      
      d3Data <- cbind(d, m,
                      cluster = cluster,
                      Cluster_col = clusterCol,
                      metadata(),
                      mc,
                      "_row" = rownames(md)
                      )
      
      
      if (length(contacts())) {
        fromI <- match(contacts()[, 1], tree()$tip.label)
        toI <- match(contacts()[, 2], tree()$tip.label)
      } else {
        fromI <- integer(0)
        toI <- integer(0)
      }
      
      r2d3(d3Data, script = "plot.js",
           options = list(
             meta = colnames(md),
             from = fromI,
             to = toI
           ),
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
