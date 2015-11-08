dir <- getwd()
setwd(dir)
library(igraph)
library(caTools)

## Function to calculate the area of with respect to the interval provided using Trapz method

findAreas <- function(data, g, membership, node,interval, mainlab, finalData)
{
  per_value = array()
  
  graph <- read.graph(g, "edgelist")
  memb <- scan(membership)
  data <- read.table(data, header = FALSE)
    
  edges <- get.edgelist(graph)
  
  edges <- edges[,] - 1
  
  
  node_name <- paste("V", sep="", node+2)
  node_vec <- data[node]
  node_vec <- (as.vector(node_vec)[,])[interval[1]:interval[2]]
 
# ylab = expression(paste(sigma,"(v,", w[i],")"))
 # plot(node_vec, ylim=c(-1,1), xlim=interval, type="n", main=mainlab, ylab=ylab, xlab="t" )
  
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
      
      ## Again find the column_name for the particular node
     # target_node_column = match(target_id-1,node)
     
      target_name <- paste("V", sep="", target_id+2)
      target_vec <- data[target_name]
      target_vec <- (as.vector(target_vec)[,])[interval[1]:interval[2]]
      if(src_community == trgt_community)
      {
        col="black"
      }
      
      per_value = sin(node_vec - target_vec)+1
      
      period  <- c(1: (interval_end - interval_start + 1))
      
      Area <- trapz(period,per_value)
      result <-  paste(Area,col,sep=" ")
      finalData <- paste(finalData,result,sep=" ")
      
      #print(finalData)
      # lines(sin(node_vec - target_vec),col=col,type="l")
      
    }
    
  }
  finalData
}


## variables initializations 
## Defines the time interval till where we want to run the case and calculate area
interval_start = 180
interval_end = 850

interval <- c(interval_start,interval_end)
result_file = NULL
finalData = array()


## Reading all graph (.edges) files from the folder
files = list.files(pattern = "edges$") 
for ( g in files)
{
  ## Acquiring the corresponding membership file and the result file
  membership1 =  gsub("network","mem",g)
  membership = gsub("edges","dat",membership1)
  
  ## find number of nodes by spliting the graph name 
  
  nodeTemp =  as.array(strsplit(g, "_N"))[[1]]
  nodeTemp1 = as.array(strsplit(nodeTemp[2],"_"))[[1]]
  nodes = as.numeric(nodeTemp1[1])
  
  
  data1 = gsub("network","res",g)
  data  = gsub("edges","dat",data1)
  
  interval_period = paste(interval_start,interval_end,sep="_")
  modifiedName = paste("Area_interval",interval_period,sep="_")
  
  nodeName =  gsub("network",modifiedName,g)
  nodeNameFile = gsub("edges","txt",nodeName)
  
  fileName = paste("Area/",nodeNameFile,sep="")
  
  for (node in 4:35)
  {
    
    finalData = node
    ## The function read.graph(g, "edgelist") upploads nodes and increments their value by 1
    ## Ex: Node1 becomes Node2, Node2 becomes Node3
    ## So we increment the value of node  by 1
    ## Find the column number for this (node-1, since result file is different) and pass it to function 
    
    
    ## we use below information, in case we want to see the plots
    #node_column = match(node,column_values)
    mainlab3 = paste("Signal_",g,sep="")
    mainlab2 =  gsub("network_","",mainlab3)
    mainlab1 = gsub(".edges","",mainlab2)
    mainlab = paste(mainlab1,"_Node",node,sep="")
  
    # Calling the main method here
    finalData1 = findAreas(data, g, membership, node,interval, mainlab,finalData)
    write(finalData1,file=fileName,sep="\n",append = TRUE)
    
  }
}

## To detect the communities using areas

# DetectCommunitiesWithArea(filename)