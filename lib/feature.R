#############################################################
### Construct visual features for training/testing images ###
#############################################################

### Author: Wanyi Zhang
### Project 7
### ADS Fall 2016

if(!require(EBImage)){
  source("http://bioconductor.org/biocLite.R")
  biocLite("EBImage")
  library(EBImage)
}

feature <- function(img_dir, img_name){
  
  ### Construct RGB features for training/testing images

  ### Input: a directory that contains images ready for processing
  ### Output: an .RData file contains processed RGB features for the images
  
  ### Load libraries
  library("EBImage")
  
  ### Count number of images
  n_files <- length(list.files(img_dir))
  
  ### RGB feature extraction prep 
  nR <- 10
  nG <- 8
  nB <- 10 # Caution: the bins should be consistent across all images!
  rBin <- seq(0, 1, length.out=nR)
  gBin <- seq(0, 1, length.out=nG)
  bBin <- seq(0, 1, length.out=nB)
  mat=array()
  freq_rgb=array()
  rgb_feature=matrix(nrow=n_files, ncol=nR*nG*nB)
  
  ### Extract 800 RGB features
  for (i in 1:n_files){
    mat <- imageData(readImage(paste0(img_dir,"/", img_name, "_", sprintf("%04s", i), ".jpg")))
    freq_rgb <- as.data.frame(table(factor(findInterval(mat[,,1], rBin), levels=1:nR), factor(findInterval(mat[,,2], gBin), levels=1:nG), factor(findInterval(mat[,,3], bBin), levels=1:nB)))
    rgb_feature[i,] <- as.numeric(freq_rgb$Freq)/(ncol(mat)*nrow(mat)) # normalization
  }
  
  ### Rename features
  colnames(rgb_feature) <- paste0("RGB",1:800)
  
  ### Conbine RGB features with SIFT features into final features
  sift_features <- read.csv(paste0(img_dir,"/sift_features.csv"))
  Feature_eval <- as.data.frame(cbind(rgb_feature, t(sift_features)))
  
  ### output constructed features
  save(Feature_eval, file=paste0(img_dir,"/Feature_eval.RData"))
  return(Feature_eval)
}
