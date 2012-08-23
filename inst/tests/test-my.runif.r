context("my.runif")

n.reps = 9

test_that("my.runif returns results less than cutoff",
{
    for (i in 1:n.reps) 
    {
        n = rpois(1,10)+1
        ub = runif(1)
        expect_true(all(my.runif(n,ub,engine="R")<ub))
        expect_true(all(my.runif(n,ub,engine="C")<ub))
    }
})


