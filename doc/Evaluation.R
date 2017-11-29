#### Evaluation
MAE<-function(predict){
  accuracy.mae<-NA
  for (i in 1:nrow(movie.test)){
    a<-rownames(movie.test)[i]
    position<-which(!is.na(movie.test[a,]))
    prediction<-predict[a,position]
    actual<-movie.test[a,position]
    accuracy.mae[i]<-mae(actual[1],prediction[1])
    out<-mean(accuracy.mae)
    return(out)
  }
}
mean.mae<-MAE(mean.predict)
z.mae<-MAE(z.predict)


# ROC
adjust<-function(matrix){
  matrix[matrix<4]<-0
  matrix[matrix>=4]<-1
  return(matrix)
}
newact<-adjust(actual)
mean.newpred<-adjust(mean.predict)
z.newpred<-adjust(z.predict)

mean.roc<-auc(newact,mean.newpred)
z.roc<-auc(newact,z.newpred)