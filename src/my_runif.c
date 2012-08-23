#include <R.h>
#include <Rmath.h>

void my_runif(int *n, double *ub, double *u)
{
    int i;
    GetRNGstate();
    for (i=0;i<*n;i++) 
    {
        u[i] = runif(0,1);
        //while (u[i]>*ub) u[i] = runif(0,1);
    }
    PutRNGstate();
}

