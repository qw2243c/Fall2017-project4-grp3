mycosine <- function(x,y){
  c <- sum(x*y) / (sqrt(sum(x*x)) * sqrt(sum(y*y)))
  return(c)
}

cosinesim <- function(x) {
  # initialize similarity matrix
  m <- matrix(NA, nrow=ncol(x),ncol=ncol(x),dimnames=list(colnames(x),colnames(x)))
  cos <- as.data.frame(m)
  
  for(i in 1:ncol(x)) {
    for(j in i:ncol(x)) {
      co_rate_1 <- x[which(x[,i] & x[,j]),i]
      co_rate_2 <- x[which(x[,i] & x[,j]),j]  
      cos[i,j]= mycosine(co_rate_1,co_rate_2)
      cos[j,i]=cos[i,j]        
    }
  }
  return(cos)
}

load("../data/movie_data_train_wide.Rdata")

matrix3<-movie.data.train
rownames(matrix3)<-movie.data.train$User
matrix3$User<-c()
matrix3<-matrix3[1:1000,]

cosine.user.matrix <- cosinesim(t(matrix3))
userid<-rownames(cosine.user.matrix)
new.matrix<-cbind(userid,cosine.user.matrix)
write.csv(new.matrix, file='users_cosine.csv', row.names = FALSE)


