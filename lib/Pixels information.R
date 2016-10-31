#Use face pixels to do PCA
#library(pixmap)
library(EBImage)
library(rpart)
setwd("~/Documents/Courses/ADS/Project 3/Project3_poodleKFC_train")

Filenames <- dir("images")
Filelabel= as.numeric(substr(labels, 1,1) == "c")
#labels= substr(labels,1,nchar(labels)-4)
#labels.df = data.frame(filename= labels, filelabel= filelabel)
for(i in 1:length(Filenames)){
  img_temp= readImage(paste("images/",Filenames[i],sep=""))
  img_temp_gray= channel(img_temp,"gray")
  size= min(dim(img_temp_gray))/2
  img_temp_resize= img_temp_gray[(dim(img_temp_gray)[1]/2-size): (dim(img_temp_gray)[1]/2+size),
                                 (dim(img_temp_gray)[2]/2-size): (dim(img_temp_gray)[2]/2+size)]
  #x <- makeBrush(size = 9, shape = 'gaussian', sigma = 5)
  #img_brush <- filter2(img_temp_resize, x)
  #img_brush_resize <- resize(img_brush, 100, 100)
  #f_high <- matrix(0.5, nc=3, nr=3)
  #f_high[2,2] <- -3
  #img_highPass <- filter2(img_temp_resize, f_high)
  #img_resize2= resize(img_highPass,100,100)
  img_vector= as.vector(img_brush_resize)
  if (i==1){
    face_matrix= img_vector
  }
  else{
    face_matrix= rbind(face_matrix, img_vector)
  }
  if ( i%%10 == 0)  print(i)
}
mean_face_vector= colMeans(face_matrix)
face_centered= face_matrix- matrix(rep(mean_face_vector, times=2000),nrow=2000, byrow=T )
face_pca= prcomp(face_centered)
sample= sample(2000,1600)
labels <- dir("images")
filelabel= as.numeric(substr(labels, 1,1) == "c")
data= as.data.frame(cbind(face_pca$x,filelabel))
names(data)[2001]= "filelabel"
data.train= data[sample,c(1:1000,2001)]
data.test=data[-sample,c(1:1000,2001)]
data.all= data[,c(1:1000,2001)]

library(ada)
ada.fit= ada(filelabel~.,data=data.train,iter=20,nu=1,type="discrete")
ada.predict <- predict(ada.fit,newdata=data.test,type="vector")
mean(data.test$filelabel==ada.predict)  #0.58
ada.predict.all=predict(ada.fit,newdata=data.all,type="vector")
mean(data.all$filelabel==ada.predict.all) #0.9
ada.predict.train=predict(ada.fit,newdata=data.train,type="vector")
mean(data.train$filelabel==ada.predict.train)  

