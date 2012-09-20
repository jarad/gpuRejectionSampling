dyn.load("../src/runif.so")
source("../R/my.runif.r")

system.time(my.runif(256,1,1,1,engine="R"))
system.time(my.runif(256,1,1,1,engine="C"))


dyn.unload("../src/runif.so")
dyn.load("../src/runif.so")

# Above works properly
# Below causes seg fault when library is unloaded

# Initial call to gpu
initalization.time = system.time(my.runif(256,1,1,1,engine="G"))

dyn.unload("../src/runif.so")

