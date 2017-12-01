# load packages
library(Metrics)
library(pROC)
# load data
load("/Users/lijingkai/Documents/fall2017-project4-grrp3/data/movie_data_train_wide.Rdata")
load("/Users/lijingkai/Documents/fall2017-project4-grrp3/data/movie_data_test_wide.Rdata")

movie.train<-as.matrix(movie.data.train)
rownames(movie.train)<-movie.train[,1]
movie.train<-movie.train[,-1]
colnames(movie.train)<-substring(colnames(movie.train),7,10)

movie.test<-as.matrix(movie.data.test)
rownames(movie.test)<-movie.test[,1]
movie.test<-movie.test[,-1]
colnames(movie.test)<-substring(colnames(movie.test),7,10)

# neighbour matrix
neighbour<-read.csv("method_1_MSD.csv")
rownames(neighbour)<-neighbour[,1]
colnames(neighbour)<-colnames(neighbour)
neighbour<-neighbour[,-1]

# similarity matrix
similarity<-read.csv("MSDsim_movie.csv")
similarity<-similarity[,-1]
rownames(similarity)<-rownames(movie.train)
colnames(similarity)<-rownames(movie.train)

# change NA to 0
adjust2<-function(matrix){
  matrix[is.na(matrix)]<-0
  return(matrix)
}

#### deviation from mean

# calculate user average rate
mean.rate<-rowMeans(movie.train[,-1],na.rm = TRUE)

# calculate user rate's variance
var.cal<-function(matrix){
  var<-var(matrix,na.rm=TRUE)
  return(var)
}
var.rate<-apply(movie.train[,-1],1,var.cal)

# extract neighbour of a
neighbour_a<-function(a){
  a.neighbour<-neighbour[rownames(neighbour)==a,]
  a.neighbour<-a.neighbour[is.na(a.neighbour)==FALSE]
  return(a.neighbour)
}


# Extract position of neighbour of a
position<-function(neighboura){
  position_a<-match(neighboura,rownames(similarity))
  return(position_a)
}


# prediction for each user a
meanpredict<-function(a){
  neighboura<-neighbour_a(a)
  n<-length(neighboura)
  pos<-position(neighboura)
  mean.a<-mean.rate[rownames(movie.train)==a]
  mean.u<-mean.rate[pos]
  if(all(is.na(neighboura))==TRUE){
    return(rep(mean.a,ncol(movie.train)))
  } else {
    diff.u<-movie.train[pos,]-matrix(rep(mean.u,ncol(movie.train)),ncol=ncol(movie.train))
    diff.u<-sapply(diff.u,as.numeric)
    diff.u<-matrix(diff.u,ncol=ncol(movie.train))
    diff.u<-adjust2(diff.u)
    
    weight.au<-similarity[rownames(similarity)==a,pos]
    weight.au<-as.numeric(weight.au)
    weight.au<-adjust2(weight.au)
    mul<-as.matrix(t(weight.au)) %*% as.matrix(diff.u)
    
    mean.predict.a<-mean.a+mul/sum(weight.au)
    return(mean.predict.a)
  }
}



mean.predict<-apply(as.matrix(as.numeric(rownames(similarity))),1,meanpredict)
mean.predict<-t(mean.predict)
rownames(mean.predict)<-rownames(movie.train)
colnames(mean.predict)<-colnames(movie.train)




#### z-scores
zpredict<-function(a){
  neighboura<-neighbour_a(a)
  n<-length(neighboura)
  pos<-position(neighboura)
  mean.a<-mean.rate[rownames(movie.train)==a]
  mean.u<-mean.rate[pos]
  var.a<-var.rate[rownames(movie.train)==a]
  var.u<-var.rate[pos]
  
  if(all(is.na(neighboura))==TRUE){
    return(rep(mean.a,ncol(movie.train)))
  } else {
  diff.u<-movie.train[pos,]-matrix(rep(mean.u,ncol(movie.train)),ncol=ncol(movie.train))
  diff.u<-sapply(diff.u,as.numeric)
  diff.u<-matrix(diff.u,ncol=ncol(movie.train))
  diff.u<-adjust2(diff.u)

  weight.au<-similarity[rownames(similarity)==a,pos]
  weight.au<-as.numeric(weight.au)
  weight.au<-adjust2(weight.au)
  
  new.var.u<-matrix(rep(var.u,ncol(movie.train)),ncol=ncol(movie.train))
  new.var.u<-sapply(new.var.u,as.numeric)
  new.var.u<-matrix(new.var.u,ncol=ncol(movie.train))
  
  division<-as.matrix(t(weight.au))%*%as.matrix(diff.u/new.var.u)

  
  z.predict.a<-mean.a+var.a*(division/sum(weight.au))
  return(z.predict.a)
}
}

z.predict<-apply(as.matrix(as.numeric(rownames(similarity))),1,zpredict)
z.predict<-t(z.predict)
rownames(z.predict)<-rownames(movie.train)
colnames(z.predict)<-colnames(movie.train)




#### Evaluation
#MAE
# modify prediction matrix to make it the same order as test data
posit<-match(colnames(movie.test),colnames(mean.predict))
mean.newpredict<-mean.predict[,posit]
z.newpredict<-z.predict[,posit]
# create MAE function
MAE<-function(predict){
  accuracy.mae<-NA
  for (i in 1:nrow(movie.test)){
  position<-which(!is.na(movie.test[i,]))
  prediction<-predict[i,position]
  actual<-movie.test[i,position]
  accuracy.mae[i]<-mae(actual,prediction)
  }
  return(accuracy.mae)
}
# MAE result for both method
mean.mae<-mean(MAE(mean.newpredict))
z.mae<-mean(MAE(z.newpredict))


# ROC
# modify test data
adjust<-function(matrix){
  matrix[matrix<4]<-0
  matrix[matrix>=4]<-1
  return(matrix)
}
test.roc<-adjust(movie.test)
# create ROC function
ROC<-function(predict){
  accuracy.mae<-NA
  for (i in 1:nrow(test.roc)){
    position<-which(!is.na(test.roc[i,]))
    prediction<-predict[i,position]
    actual<-test.roc[i,position]
    accuracy.mae[i]<-auc(actual,predicted=prediction)
  }
  return(accuracy.mae)
}
# ROC result for both method
mean.roc<-mean(ROC(mean.newpredict),na.rm = TRUE)
z.roc<-mean(ROC(z.newpredict),na.rm=TRUE)

