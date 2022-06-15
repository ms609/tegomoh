library("TreeTools")
tree <- read.tree("Testing_Nextstrain_Tree.nwk")
distances <- cophenetic.phylo(tree)
mapping <- cmdscale(distances, k = 2)

clusters <- {
  possibleClusters <- 2:20
  
  pamClusters <- lapply(possibleClusters,
                        function(k) cluster::pam(distances, k = k))
  pamSils <- vapply(pamClusters, function(pamCluster) {
    mean(cluster::silhouette(pamCluster)[, 3])
  }, double(1))
  
  bestPam <- which.max(pamSils)
  pamSil <- pamSils[bestPam]
  pamCluster <- pamClusters[[bestPam]]$cluster
  
  hTree <- protoclust::protoclust(as.dist(distances))
  hClusters <- lapply(possibleClusters, function(k) cutree(hTree, k = k))
  hSils <- vapply(hClusters, function(hCluster) {
    mean(cluster::silhouette(hCluster, distances)[, 3])
  }, double(1))
  
  
  bestH <- which.max(hSils)
  hSil <- hSils[bestH]
  hCluster <- hClusters[[bestH]]
  
  if (hSil > pamSil) {
    list(clust = hCluster, sil = hSil)
  } else {
    list(clust = pamCluster, sil = pamSil)
  }
}


d <- distances
colnames(d) <- paste0("d", seq_len(ncol(d)) - 1)

m <- mapping
m <- m + min(m)
m <- m / max(m)
colnames(m) <- c("mappedX", "mappedY")

cluster <- clusters$clust
clusterCol <- hcl.colors(max(cluster), "dark2")[cluster]

md <- read.csv("Testing_Nextstrain_Metadata.csv", row.names = 1)
mc <- vapply(md, function (x) {
  fac <- as.factor(x)
  nLevel <- length(levels(fac))
  hcl.colors(nLevel, "dark2")[fac]
}, character(nrow(md)))

colnames(mc) <- paste0(colnames(mc), "_col")
if (useMetadata <- FALSE) {
  md <- structure(list(), names = character(0), class = "data.frame",
              row.names = tree$tip)
  mc <- unname(md)
}

rownames(d) <- rownames(md)

d3Data <- cbind(d, m,
                cluster = cluster,
                Cluster_col = clusterCol,
                md,
                mc,
                "_row" = rownames(d)
)

