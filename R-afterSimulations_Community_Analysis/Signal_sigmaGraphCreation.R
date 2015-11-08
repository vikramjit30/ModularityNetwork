dir <- getwd()
setwd(dir)
library(igraph)


PlotSigmaForAllNeighbors <- function(data, g, membership, node, interval, mainlab)
{
  graph <- read.graph(g, "edgelist")
  memb <- scan(membership)
  data <- read.table(data, header = FALSE)
  edges <- get.edgelist(graph)
  
  edges <- edges[,] - 1
  
  node_name <- paste("V", sep="", node+2)
  node_vec <- data[node_name]
  node_vec <- (as.vector(node_vec)[,])[interval[1]:interval[2]]
  ylab = expression(paste(sigma,"(v,", w[i],")"))
  plot(node_vec, ylim=c(-1,1), xlim=interval, type="n", main=mainlab, ylab=ylab, xlab="t" )
  for(i in 1:(length(edges)/2))
  {
    src <- edges[i]
    trgt <- edges[i+(length(edges)/2)]
    src_community <- memb[src+1]
    trgt_community <- memb[trgt+1]
    
    mycolors <- array(c("cadetblue","yellow","darkgreen","seagreen1","darkorange","peru","gray","gold","lawngreen","red","firebrick","pink","chocolate","coral","cyan","darkmagenta","aquamarine","darkcyan","deeppink","lightcoral", "hotpink","lightgoldenrod4"))
    
    if(src == node || trgt == node)
    {
      if(src==node)
      {
        target_id <- trgt
        col <- mycolors[trgt_community]
      }
      else
      {
        target_id <- src
        col <-mycolors[src_community]
      }
      #print(target_id)
      target_name <- paste("V", sep="", target_id+2)
      target_vec <- data[target_name]
      target_vec <- (as.vector(target_vec)[,])[interval[1]:interval[2]]
      
      if(src_community == trgt_community)
      {
        col="black"
      }
      
      
      print(target_id)
      lines(sin(node_vec - target_vec),col=col,type="l")
    }
    
  }
}


## variables initializations 
## Defines the time interval till where we want to run the case

interval <- c(1,1400)
result_file = NULL


## Reading all graph (.edges) files from the folder
files = list.files(pattern = "edges$") 
for ( g in files)
  {
    ## Acquiring the corresponding membership file and the result file
    membership1 =  gsub("network","mem",g)
    membership = gsub("edges","dat",membership1)
    
    data1 = gsub("network","res",g)
    data  = gsub("edges","dat",data1)
    
    for (node in 3:10 )
        {
            mainlab3 = paste("Signal_",g,sep="")
            mainlab2 =  gsub("network_","",mainlab3)
            mainlab1 = gsub(".edges","",mainlab2)
            mainlab = paste(mainlab1,"_Node",node,sep="")
            PlotSigmaForAllNeighbors(data, g, membership, node, interval, mainlab)
      
        }
 }

