#############################################################
### Construct visual features for training/testing images ###
#############################################################

if(!require(EBImage)){
  source("http://bioconductor.org/biocLite.R")
  biocLite("EBImage")
  library(EBImage)
}

feature <- function(img_dir, img_name, data_name=NULL){
  ### Input: a directory that contains images ready for processing
  ### Output: an .RData file contains processed features for the images
  
  library("EBImage")
  file_names <- list.files(img_dir)
  n_files <- length(list.files(img_dir))
  
  ########### Extract 800 RGB & 360 HSV features ##############
  nR <- 10
  nG <- 8
  nB <- 10 # Caution: the bins should be consistent across all images!
  rBin <- seq(0, 1, length.out=nR)
  gBin <- seq(0, 1, length.out=nG)
  bBin <- seq(0, 1, length.out=nB)
  mat=array()
  freq_rgb=array()
  rgb_feature=matrix(nrow=n_files, ncol=nR*nG*nB)
  
  for (i in 1:n_files){ ### takes minutes and aborts my RStudio
    mat <- imageData(readImage(paste0(img_dir, img_name, "_", sprintf("%04s", i), ".jpg")))
    freq_rgb <- as.data.frame(table(factor(findInterval(mat[,,1], rBin), levels=1:nR), factor(findInterval(mat[,,2], gBin), levels=1:nG), factor(findInterval(mat[,,3], bBin), levels=1:nB)))
    rgb_feature[i,] <- as.numeric(freq_rgb$Freq)/(ncol(mat)*nrow(mat)) # normalization
    
    mat_rgb <- mat
    dim(mat_rgb) <- c(nrow(mat)*ncol(mat), 3)
    mat_hsv <- rgb2hsv(t(mat_rgb))
    freq_hsv <- as.data.frame(table(factor(findInterval(mat_hsv[1,], hBin), levels=1:nH), factor(findInterval(mat_hsv[2,], sBin), levels=1:nS),  factor(findInterval(mat_hsv[3,], vBin), levels=1:nV)))
    hsv_feature[i,] <- as.numeric(freq_hsv$Freq)/(ncol(mat)*nrow(mat)) # normalization
  }
  
  colnames(rgb_feature) <- paste0("RGB",1:800)
  colnames(hsv_feature) <- paste0("HSV",1:360)
  
  ### output constructed features
  if(!is.null(data_name)){
    save(rgb_feature, file=paste0("./output/feature_", data_name, ".RData"))
  }
  return(rgb_feature)
}