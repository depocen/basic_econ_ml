# This is an educational repository that teaches how to generate random numbers with various parameter settings 
# using probability density functions (PDF) and probability mass functions (PMF); it also plots the simulated 
# (generated) data showing the parameters values and the corresponding graphs. Briefly, it
# simulates univariate continuous probability distribution
# simulates univariate discrete probability distribution
# simulates bi-variate normal distribution in various covariance matrix (requires 'mvtnorm' package)
# plots the data using traditional plot system i.e. graphics package
# declares runifd,qunifd, punifd and dunifd functions to support discrete uniform distribution



# discrete uniform distribution (not part of base R)
dunifd <- function(x, min=0, max=1)
  ifelse(x>=min & x<=max & round(x)==x, 1/(max-min+1), 0)
punifd <- function(q, min=0, max=1)
  ifelse(q<min, 0, ifelse(q>=max, 1, (floor(q)-min+1)/(max-min+1)))
qunifd <- function(p, min=0, max=1)
  floor(p*(max-min+1))
runifd <- function(n, min=0, max=1)
  sample(min:max, n, replace=T)


# Uniform
min <- c(-5,-2)
max <- c(5, 2)
xscale <- c(-6,6)
simdist <- sim_dist(min,max,xscale,dunif)

# Logistic
location <- c(0,0,0,-2)
scale <- c(.2,1,5,.5)
xscale <- c(-5,5)
simdist <- sim_dist(location,scale,xscale,dlogis)

# Normal
mu <- c(0,0,0,-2)
sdev <- c(.2,1,5,.5)
xscale <- c(-5,5)
simdist <- sim_dist(mu,sdev,xscale,dnorm)
#CDF
#simdist <- sim_dist(size,prob,xscale,pnorm)

# LogNormal
mu <- c(0,2,0,0.5,0.25,0.125)
sdev <- c(3,2,1,1,1,1)
xscale <- c(0.1,5)
simdist <- sim_dist(mu,sdev,xscale,dlnorm)

# StudentT
dfree <- c(1,2,5,Inf, 5)
ncp <- c(0,0,0,0, 2.5)
xscale <- c(-5,8)
simdist <- sim_dist(dfree,ncp,xscale,dt)

# F
df1 <- c(1,2,5,100,100)
df2 <- c(1,1,2,1,100)
ncp <- c(rep(0,5))
xscale <- c(0,5)
simdist <- sim_dist(df1,df2,xscale,df)

# dchisq
# df <= 2 is like exponential and df > 2 is like ?
k <- 1:5
#k <- seq(1,3,.2)
xscale <- c(0,10)
simdist <- sim_dist(k,NULL,xscale,dchisq)

# dgamma
shape <- c(1,2,7,5,9)
rate <- 1/c(2,2,1,0.5)
xscale <- c(0,20)
simdist <- sim_dist(shape,rate,xscale,dgamma)


# dbeta
shp1 <- c(0.5 ,5 ,1 ,2 ,2 )
shp2 <- c(0.5,1,3,2,5)
xscale<- 0:1
simdist <- sim_dist(shp1,shp2,xscale,dbeta)

# dexp
rate <- .5:2.5
xscale <- 0:5
simdist <- sim_dist(rate,NULL,xscale,dexp)

# Weibull
shape <- rep(1,4)
scale <- c(.5, 1 ,1.5 , 5)
xscale<- c(0,2.5)
simdist <- sim_dist(shape,scale,xscale,dweibull)

# Binomial
size <- c(40,30,25)
prob <- c(.3,.6,.9)
xscale<- c(0,40)
simdist <- sim_dist(size,prob,xscale,dbinom)
#CDF
#simdist <- sim_dist(size,prob,xscale,pbinom)

# uniform
source('unifd.r')
min <- c(-5,-2)
max <- c(5, 2)
xscale <- c(-5,5)
simdist <- sim_dist(min, max, xscale, dunifd)

# Geometric
prob <- c(.2,.5,.8,1)
xscale <- c(0,10)
simdist <- sim_dist(prob,NULL,xscale,dgeom)

# Negative Binomial
size <- c(1,5,10,20,40)
prob <- rep(.5,5)
xscale <- c(0,20)
simdist <- sim_dist(size,prob,xscale,dnbinom)

# Poisson
lambda <-c(1,4,10)
xscale <- c(0,20)
simdist <- sim_dist(lambda,NULL,xscale,dpois) 

#' Simulate a probability density or mass function and plot it
#' 
#' This func
#' @param p1 a numeric vector to pass to the distribution function (dist1)
#' @param p2 a numeric vector to pass to the distribution function (dist1)
#' @param xscale range of x to simulate and plot
#' @param dist1 distribution function
#' @param plot whether to plot
#'
#' @return simulated data grouped by parameters
#'
#' @examples
#' shape <- c(1,2,7,5,9)
#' rate <- 1/c(2,2,1,0.5)
#' xscale <- c(0,20)
#' dist1 <- dgamma
#' simdist <- sim_dist(shape,rate,xscale,dist1)
sim_dist <- function(p1=c(5,10),p2 = NULL,xscale = c(0, 20),
                          dist1 = dnorm, plot = T) {
  dist_name <- deparse(substitute(dist1))
  dist_name <- substr(dist_name,2,nchar(dist_name))
  discrete_dist <- c("unifd", "binom", "geom", "pois", "multinom", "hyper", "nbinom","dmultinom")
  is_discrete <- dist_name %in% discrete_dist

  if(!is_discrete)
    x <- seq(xscale[1], xscale[2], length.out =  100)
  else
    x <- seq(xscale[1], xscale[2])

  p1_s <- deparse(substitute(p1))
  p2_s <- deparse(substitute(p2))

  p2_isnull <- rep(is.null(p2), length(x))
  dsts <- lapply(1:length(p1),
                 function(i)
                   cbind(x = x,
                         distrib = ifelse(p2_isnull,
                                          dist1(x, p1[i]),
                                          dist1(x, p1[i], p2[i])),
                         fact = i,
                         params = ifelse(p2_isnull,
                                         paste0(p1_s,"=",p1[i]),
                                         paste0(p1_s,"=",p1[i], ", ",p2_s,"=",p2[i])
                         )
                   ))
  dsts <- do.call(rbind, dsts)

  type1 <- ifelse(is_discrete,"p","n")
  if (plot)
  {
    plot_line_color(x = dsts[, 1], y = dsts[, 2], fact = dsts[, 3],
                    type=type1)
    title(dist_name)
    uu <- unique(dsts[,4])
    legend("topright",legend=uu,col=seq_along(uu),lty=1:length(uu),lwd=2,
           bty = "n",bg="transparent")
  }
  return(dsts)
}

#' Plot color lines
#'
#' @param x
#' @param y
#' @param fact a factor variable to be used for coloring
#' @param lwd line width
#' @param ... params to pass to the lines function
#'
#' @return
#' @export
#'
#' @examples
#' k <- 1:5
#' x <- seq(0,10,length.out =  100)
#' dsts <- lapply(1:length(k), function(i) cbind(x=x, distri=dchisq(x,k[i]),fact=i) )
#' dsts <- do.call(rbind,dsts)
#' plot_line_color(x=dsts[,1],y=dsts[,2],fact=dsts[,3]),legend_draw=T)
plot_line_color <- function(x,y,fact,type='n',lwd=2,legend_draw=F,...)
{
  plot(x,y,col=fact,pch=19,type=type)
  xy <- cbind(x,y)
  facts <- unique(fact)
  invisible(
    lapply(seq_along(fact), function(j) {
      xy2 <- subset(xy,fact==j)
      lines(xy2[ ,1],xy2[,2],col=j,lty=j,lwd=lwd,...)
    })
  )
  if (legend_draw)
    legend("topright",legend=facts,col=1:length(facts),lty=1:length(facts),
         bty = "n",bg="transparent")

  grid()
}
                 
                 
if(!require('mvtnorm', quietly = TRUE))
    install.packages("mvtnorm")

x <- seq(-3,3,length.out = 100)
y <- x

sigma <- list(
  sigma1 = c(1,0,0,1),
  sigma2 = c(2,0,0,2),
  sigma3 = c(2,0,0,1),
  sigma4 = c(1,0,0,2),
  sigma5 = c(1,.5,.5,1),
  sigma6 = c(1,-.5,-.5,1)
)

mvnorm_single_plot <- function(x,y,sigma){
  xy <- expand.grid(x,y)
  sig_mat <- matrix(sigma,2,2)
  z <- mvtnorm::dmvnorm(xy,mean = c(0,0),sigma=sig_mat)
  z_mat <- matrix(z,length(x))

  a <- apply(sig_mat,1,paste,collapse=' ')
  exp <- substitute(Sigma==bgroup("(", atop(x,y) ,")"), list(x=a[1],y=a[2]) )

  image(x,y,z_mat,col=topo.colors(20),main=exp , asp=1 )
}
bb <- lapply(sigma, mvnorm_single_plot,x=x,y=y)
                 
## all possible outcomes of Multinom(size = 5, K = 4)
X <- t(as.matrix(expand.grid(0:5, 0:5, 0:5)))
X <- X[, colSums(X) <= 5]
X <- rbind(X, 5 - colSums(X))
round(apply(X, 2, function(x) dmultinom(x, prob = c(1,2,5,5))), 5)

rmultinom(10,12,c(.1,.2,.7))
dmultinom(c(0,0,3),prob=c(1,2,5),3)

# Binomial is a special case of Multinomial 
rmultinom(10, 20,c(.5,.5))[1,] # two prob is needed. one for success and one for failure
rbinom(10,20,.5)
dmultinom(c(1,2),3,prob=c(.5,.5))
dbinom(2,3,.5) #2 win

## TODO first do with image. then persp for bi-norm and binom
rmultinom(100,5,c(1/2,1/3,1/6))[,]
  %>% plot3D::hist3D(z=.)                 
