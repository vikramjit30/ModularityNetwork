dir <- getwd()
setwd(dir)
library(igraph)

## Reading all graph (.edges) files from the folder
files = list.files(pattern = "edges$") 
for ( g in files)
  {
    ## Acquiring the corresponding membership file
    membership1 =  gsub("network","mem",g)
    membership = gsub("edges","dat",membership1)
    
  
    louvain_membership1 =  gsub("network","Louvain_method",g)
    louvain_membershipFile = gsub("edges","dat",louvain_membership1)
    
    print(louvain_membershipFile)
    
    graph <- read.graph(g, "edgelist", directed = FALSE)
    edges <- get.edgelist(graph)
    edges <- edges[,] - 1
    
    
    ### fastgreedy.community to detect the communities (Louvain Method)
    fc <- fastgreedy.community(graph)
    allCommunities = membership(fc)
    
    allCommunities <- as.array(allCommunities)
    
    write(allCommunities,file=louvain_membershipFile,sep="\n",append=TRUE)
    
  


## Calculate the percentage of correction between Louvain method and actual standard way (manual)

## Read line by line Louvain membership files and change it to new membership array where communities starts with 0

memb <- scan(membership)
louvainMemb  <- scan(louvain_membershipFile)

changed_louv_comm = array()
new_comm  = 0
old_comm = array()
value = 0

if (length(memb) == length(louvainMemb))
{
    for (i in 1:length(louvainMemb))
      {
          if (i == 1) { 
                        changed_louv_comm <- c(changed_louv_comm,new_comm)
                        value = louvainMemb[i]
                        old_comm <- c(old_comm,value)
                         old_comm <- old_comm[-1]
                         next }
      
      
      value  <- louvainMemb[i] %in% old_comm
      if ( value == TRUE)
      {
        value = match(louvainMemb[i],old_comm)
        comm = value - 1 
        changed_louv_comm <- c(changed_louv_comm,comm)
     
      }else {
        new_comm = new_comm + 1 
        changed_louv_comm <- c(changed_louv_comm,new_comm)
        value = louvainMemb[i]
        old_comm <- c(old_comm,value)
      }
  }
  
 }else
    {
        print("Error in finding communities by Louvain Method")
    }

changed_louv_comm <- changed_louv_comm[-1]

## Compare the actual communities with Louvain community detection method
diff = 0
for (i in 1:length(changed_louv_comm) )
{
  if (changed_louv_comm[i] != memb[i])
     diff = diff + 1
      
}

total_comm = length((changed_louv_comm))


correctness = (total_comm - diff) *100 / total_comm

data = paste("Percentage of correctness is: ",correctness,"%",sep="")
write(data,file="Louvain_comparison_result.txt",sep="\n",append=TRUE)

}


################################## TO plot graphs with Color on different communities #########################
#com<-community.to.membership(BarbasiGraph, fc$merges, steps= which.max(fc$modularity)-1)

#V(BarbasiGraph)$color <- com$membership+1
#BarbasiGraph$layout <- layout.fruchterman.reingold
#plot(BarbasiGraph, vertex.label=NA)

