if (is.loaded("cpu_runif")) 
{
    dyn.unload("../src/runif.so")
    dyn.load("../src/runif.so")
} else 
{
    dyn.load("../src/runif.so")
}

my.runif = function(n, ub, ni=1, nd=1, engine="R")
{
    engine = pmatch(engine, c("R","C","GPU"))

    switch(engine,
    {
        # R implementation
        u = rep(Inf,n)
        for (i in 1:n) while( (u[i] <- runif(1))>ub ) 
        {
            a = 0
            b = 1
            for (j in 1:ni) a = a + 1
            for (j in 1:nd) b = b * 1.00001
        }
        return(u)
    },
    {
        # C implementationa
        out = .C("cpu_runif", as.integer(n), as.double(ub), 
                              as.integer(ni), as.integer(nd),
                              u=double(n))
        return(out$u)
    },
    {
        # GPU implementation
        out = .C("gpu_runif", as.integer(n), as.double(ub), 
                              as.integer(ni), as.integer(nd),
                              u=double(n), ni=integer(n), b=double(n))
        return(list(u=out$u,ni=out$ni,b=out$b))
    })
}

