if (!is.loaded("mu_runif")) dyn.load("../src/my_runif.so")

my.runif = function(n, ub, engine="R")
{
    engine = pmatch(engine, c("R","C","GPU"))

    switch(engine,
    {
        # R implementation
        u = rep(Inf,n)
        for (i in 1:n) while( (u[i] <- runif(1))>ub ) {}
        return(u)
    },
    {
        # C implementationa
        out = .C("my_runif", as.integer(n), as.double(ub), u=double(n))
        return(out$u)
    },
    {
        # GPU implementation
    })
}
