feature <- function(img_dir, img_name, data_name=NULL){
  ### Input: a directory that contains images ready for processing
  ### Output: an .RData file contains processed features for the images
  
  library("EBImage")
  file_names <- list.files(img_dir)
  n_files <- length(list.files(img_dir))
  
  ######### Import images to a list ##########
  dat=list()
  for(i in 1:n_files){ ### takes minutes
    dat[[i]] <- readImage(paste0(img_dir, img_name, "_", sprintf("%04s", i), ".jpg"))
  }
  
  ########### Extract 800 RGB features ##############
  nR <- 10
  nG <- 8
  nB <- 10 # Caution: the bins should be consistent across all images!
  rBin <- seq(0, 1, length.out=nR)
  gBin <- seq(0, 1, length.out=nG)
  bBin <- seq(0, 1, length.out=nB)
  mat=list()
  freq_rgb=list()
  rgb_feature=matrix(nrow=n_files, ncol=nR*nG*nB)
  
  for (i in 1:n_files){ ### takes minutes and aborts my RStudio
    mat[[i]] <- imageData(dat[[i]])
    freq_rgb[[i]] <- as.data.frame(table(factor(findInterval(mat[[i]][,,1], rBin), levels=1:nR), factor(findInterval(mat[[i]][,,2], gBin), levels=1:nG), factor(findInterval(mat[[i]][,,3], bBin), levels=1:nB)))
    rgb_feature[i,] <- as.numeric(freq_rgb[[i]]$Freq)/(ncol(mat[[i]])*nrow(mat[[i]])) # normalization
  }
  
  ### output constructed features
  if(!is.null(data_name)){
    save(rgb_feature, file=paste0("./output/feature_", data_name, ".RData"))
  }
  return(rgb_feature)
}