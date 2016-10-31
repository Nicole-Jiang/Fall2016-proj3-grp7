########### RGB & HSV feature training ############
########### Saved rgb_feature_train.RData and hsv_feature_train.RData in Output folder######



img_dir <- "~/Google Drive/Columbia/5243 ADS/Project 3/Project3_poodleKFC_train/images/"
img_name <- "chicken"

library("EBImage")
file_names <- list.files(img_dir)
n_files <- length(list.files(img_dir))

########### RGB features prep ##############
nR <- 10
nG <- 8
nB <- 10 
rBin <- seq(0, 1, length.out=nR)
gBin <- seq(0, 1, length.out=nG)
bBin <- seq(0, 1, length.out=nB)
mat=array()
freq_rgb=array()
rgb_feature=matrix(nrow=1000, ncol=nR*nG*nB)

########### HSV features prep ##############
library(grDevices)
nH <- 10
nS <- 6
nV <- 6
hBin <- seq(0, 1, length.out=nH)
sBin <- seq(0, 1, length.out=nS)
vBin <- seq(0, 0.005, length.out=nV) 
hsv_feature <- matrix(nrow=1000, ncol=nH*nS*nV)

############# Real business starts here #######################
###### Extract 800 RGB & 360 HSV features for chicken #########

for (i in 1:1000){
  mat <- imageData(readImage(paste0(img_dir, img_name, "_", sprintf("%04s", i), ".jpg")))
  freq_rgb <- as.data.frame(table(factor(findInterval(mat[,,1], rBin), levels=1:nR), factor(findInterval(mat[,,2], gBin), levels=1:nG), factor(findInterval(mat[,,3], bBin), levels=1:nB)))
  rgb_feature[i,] <- as.numeric(freq_rgb$Freq)/(ncol(mat)*nrow(mat)) # normalization
  
  mat_rgb <- mat
  dim(mat_rgb) <- c(nrow(mat)*ncol(mat), 3)
  mat_hsv <- rgb2hsv(t(mat_rgb))
  freq_hsv <- as.data.frame(table(factor(findInterval(mat_hsv[1,], hBin), levels=1:nH), factor(findInterval(mat_hsv[2,], sBin), levels=1:nS),  factor(findInterval(mat_hsv[3,], vBin), levels=1:nV)))
  hsv_feature[i,] <- as.numeric(freq_hsv$Freq)/(ncol(mat)*nrow(mat)) # normalization
}

rgb_chicken <- rgb_feature
hsv_chicken <- hsv_feature

###### Extract 800 RGB & 360 HSV features for dogs #########
rgb_dog=matrix(nrow=1000, ncol=nR*nG*nB)
hsv_dog <- matrix(nrow=1000, ncol=nH*nS*nV)

for (i in 1:1000){
  mat <- imageData(readImage(paste0(img_dir,"dog", "_", sprintf("%04s", i), ".jpg")))
  freq_rgb <- as.data.frame(table(factor(findInterval(mat[,,1], rBin), levels=1:nR), factor(findInterval(mat[,,2], gBin), levels=1:nG), factor(findInterval(mat[,,3], bBin), levels=1:nB)))
  rgb_dog[i,] <- as.numeric(freq_rgb$Freq)/(ncol(mat)*nrow(mat)) # normalization
  
  mat_rgb <- mat
  dim(mat_rgb) <- c(nrow(mat)*ncol(mat), 3)
  mat_hsv <- rgb2hsv(t(mat_rgb))
  freq_hsv <- as.data.frame(table(factor(findInterval(mat_hsv[1,], hBin), levels=1:nH), factor(findInterval(mat_hsv[2,], sBin), levels=1:nS),  factor(findInterval(mat_hsv[3,], vBin), levels=1:nV)))
  hsv_dog[i,] <- as.numeric(freq_hsv$Freq)/(ncol(mat)*nrow(mat)) # normalization
}  # took 9 minutes to run


rgb_feature=rbind(rgb_chicken,rgb_dog)
hsv_feature=rbind(hsv_chicken,hsv_dog)
colnames(rgb_feature) <- paste0("RGB",1:800)
colnames(hsv_feature) <- paste0("HSV",1:360)
label <- c(rep(1,1000),rep(0,1000))
rgb_feature=cbind(rgb_feature,label)
hsv_feature=cbind(hsv_feature,label)


save(rgb_feature, file="~/Google Drive/Columbia/5243 ADS/Project 3/Fall2016-proj3-grp7/output/rgb_feature_train.RData")
save(hsv_feature, file="~/Google Drive/Columbia/5243 ADS/Project 3/Fall2016-proj3-grp7/output/hsv_feature_train.RData")

