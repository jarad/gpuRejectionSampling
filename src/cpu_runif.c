//#include <Rmath.h>
#include <stdlib.h>

void cpu_runif(int *n, double *ub, int *ni, int *nd, double *u)
{
    int i, j, a;
    double b;
    //GetRNGstate();
    for (i=0;i<*n;i++) 
    {
        //while ( (u[i]=runif(0,1)) > *ub ) {}
        while ( (u[i]=u[i] = rand()/((double)RAND_MAX + 1)) > *ub ) 
        {
            a=0;
            b=1;
            for (j=0; j<*ni; j++) a += 1;
            for (j=0; j<*nd; j++) b *= 1.00001;
        }
    }
    //PutRNGstate();
}

