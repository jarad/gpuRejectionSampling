if (!is.loaded("gpu_runif")) dyn.load("../src/runif.so")
source("../R/my.runif.r")

# 
library(ks.test)

TPB = 256

system.time(my.runif(TPB,1,1,1,engine="R"))
system.time(my.runif(TPB,1,1,1,engine="C"))

# Initial call to gpu
(initalization.time = system.time(my.runif(TPB,1,1,1,engine="G")))

rep        = 1:10
n.uniforms = TPB*10^ (0:3)
p.accepts  =     10^-(0:3)
n.intops   =     10^ (0:3)
n.douops   =     10^ (0:3)
engines    =c("C","G")

# For one-sample discrete distribution
# obtained using install.packages("ks.test", repos="http://R-Forge.R-project.org")
# version 1.4 installed
library(ks.test) 
# Create necessary empirical cdfs
ecdfs = list()
for (i in 1:length(p.accepts)) ecdfs[[i]] = ecdf(rgeom(1e6, p.accepts[i]))

exp = expand.grid(rep        = rep,
                  n.uniforms = n.uniforms,
                  p.accepts  = p.accepts,
                  n.intops   = n.intops,
                  n.douops   = n.douops,
                  engines    = engines,
                  pvalueUnif = NA,
                  pvalueGeom = NA,
                  user       = NA,
                  system     = NA,
                  elapsed    = NA)

iseed = sample(1e6,1)

for (i in 1:nrow(exp)) {
  print(paste(i,"out of", nrow(exp),"=",round(100*i/nrow(exp)),"%:   ", 
              paste(exp[i,2:6],collapse=" ")))
  exp[i,9:11] =  system.time(o <- my.runif(exp[i,2],exp[i,3],exp[i,4],exp[i,5],exp[i,6],iseed+i))[1:3]
  exp[i,7] = stats::ks.test(o$u, function(x) punif(x,0,exp[i,3]))$p

  exp[i,8] = ks.test::ks.test(o$count, ecdfs[[which(exp[i,3]==p.accepts)]])$p


  write.csv(exp,"comparison.csv",row.names=F)
}


