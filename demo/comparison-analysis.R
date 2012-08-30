library(reshape)
library(xtable)
library(ggplot2)

d = read.csv("comparison.csv")

# Check diagnostics
hist(d$pvalueUnif[d$engines=="C"],100)
hist(d$pvalueUnif[d$engines=="G"],100)
hist(d$pvalueGeom[d$engines=="C"],100)
hist(d$pvalueGeom[d$engines=="G"],100)

# Take care of zero times
e = 0.0001
d$user    = d$user   +e
d$system  = d$system +e
d$elapsed = d$elapsed+e

any(d$user[d$engines=="G"]==0)

melt.d = melt(d[,-c(7:8)], measure.vars=c("user","system","elapsed"))

cast.d = cast(melt.d,n.uniforms+p.accepts+n.intops+n.douops~variable|engines,mean)

all = cast.d$C[,1:5]
all[,6] = cast.d$G[,5]
all[,7] = all[,5]/all[,6]
ordr = order(all[,7],decreasing=T)
all = all[ordr,]


# Figure
names(all) = c("n.samples","p.accept","int.ops","dou.ops","cpu","gpu","ratio")
all$n.samples2 = exp(jitter(log(all$n.samples)))
pdf("rejection.pdf")
qplot(n.samples2, ratio, data=all, log='xy', 
      colour=as.factor(int.ops), 
      shape=factor(dou.ops),
      size=factor(p.accept,10^-(0:3)),
      ylab="CPU/GPU user times",
      xlab="Number of accepted samples (jittered)")+
      scale_size_discrete(name="Probability of\nacceptance")+
      scale_shape_discrete(name="# Double\nOperations")+
      scale_colour_discrete(name="# Integer\nOperations")
dev.off()
all$n.samples2 = NULL

# Regression
log.all = log(all)
summary(mod <- lm(ratio~n.samples+I(n.samples^2)+p.accept+dou.ops+int.ops,log.all))

sm = summary(mod)[[4]][-1,1:2]
rownames(sm) = c("Log of number of accepted samples",
                  "Log of number of accepted samples squared",
                  "Log of probability of acceptance",
                  "Log of number of double operations",
                  "Log of number of integer operations")
colnames(sm) = c("Posterior mean","Posterior SD")
sm.tab = xtable(sm,
       caption="Multiple regression, reference prior assumed, parameter estimates for the logarithm of CPU/GPU user time ratio on the logarithm of the number of samples, probability of acceptance, and number of integer/double operations",
       label="tab:ci",
       align="lrr",
       digits=c(0,2,2))
print(sm.tab, type="latex", file="sm.tex")



# Table
sub = all[which(all[,7]>100),]


names(sub) = c("# samples","p acceptance","# Int Ops","# Dou Ops","CPU time","GPU time","Ratio")
rownames(all) = NULL

tab = xtable(sub, 
             caption="Average CPU and GPU user times and their ratio (CPU/GPU) as a function of number of samples required, probability of acceptance, and number of integer/double operations per proposal. Only results with CPU/GPU user time over 100 are reported.", 
             label="tab:rejection",
             align="rrrrr|rr|r", 
             digits=c(0,0,-log10(min(d$p.accepts)),0,0,3,3,0))
             
print(tab,type="latex",file="comparison.tex",include.rownames=F, size="\\tiny")







