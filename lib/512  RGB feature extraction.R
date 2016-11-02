#################################################
#    Extract 512 RGB features for training set  #
#################################################


img_dir <- "~/Google Drive/Columbia/5243 ADS/Project 3/Project3_poodleKFC_train/images/"
img_name <- "chicken"

library("EBImage")
file_names <- list.files(img_dir)
n_files <- length(list.files(img_dir))

########### RGB features prep ##############
nR <- 8
nG <- 8
nB <- 8 
rBin <- seq(0, 1, length.out=nR)
gBin <- seq(0, 1, length.out=nG)
bBin <- seq(0, 1, length.out=nB)
mat=array()
freq_rgb=array()
rgb_chicken=matrix(nrow=1000, ncol=nR*nG*nB)

############# Real business starts here #######################
###### Extract 800 RGB features for chicken #########

for (i in 1:1000){
  mat <- imageData(readImage(paste0(img_dir, img_name, "_", sprintf("%04s", i), ".jpg")))
  freq_rgb <- as.data.frame(table(factor(findInterval(mat[,,1], rBin), levels=1:nR), factor(findInterval(mat[,,2], gBin), levels=1:nG), factor(findInterval(mat[,,3], bBin), levels=1:nB)))
  rgb_chicken[i,] <- as.numeric(freq_rgb$Freq)/(ncol(mat)*nrow(mat)) # normalization
} #12.5min


###### Extract 800 RGB & 360 HSV features for dogs #########
rgb_dog=matrix(nrow=1000, ncol=nR*nG*nB)

for (i in 1:1000){
  mat <- imageData(readImage(paste0(img_dir,"dog", "_", sprintf("%04s", i), ".jpg")))
  freq_rgb <- as.data.frame(table(factor(findInterval(mat[,,1], rBin), levels=1:nR), factor(findInterval(mat[,,2], gBin), levels=1:nG), factor(findInterval(mat[,,3], bBin), levels=1:nB)))
  rgb_dog[i,] <- as.numeric(freq_rgb$Freq)/(ncol(mat)*nrow(mat)) # normalization
}  # took 9 minutes to run

### combine RGB and HSV features of chicken and dog 
rgb_feature=rbind(rgb_chicken,rgb_dog)

### add feature names
colnames(rgb_feature) <- paste0("RGB",1:512)

save(rgb_feature, file="~/Google Drive/Columbia/5243 ADS/Project 3/Fall2016-proj3-grp7/output/rgb_512feature_train.RData")

