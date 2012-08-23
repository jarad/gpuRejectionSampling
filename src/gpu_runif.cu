#include <curand_kernel.h>
#include "cutil_inline.h"

#define THREADS_PER_BLOCK 256

__global__ void setup_prng(curandState *state)
{
    int id = threadIdx.x + blockIdx.x * THREADS_PER_BLOCK;
    curand_init(1234, id, 0, &state[id]);
}

__global__ void runif_kernel(curandState *state, double upperBound, int ni, int nd, 
                             double *uniforms, int *int_ops, double *dou_ops)
{
    int i, a, id = threadIdx.x + blockIdx.x * THREADS_PER_BLOCK;
    double b, u;

    // Copy state to local memory for efficiency */
    curandState localState = state[id];

    // Find random uniform below the upper bound 
    while ( (u=curand_uniform(&localState))>upperBound ) 
    {
        a=0;
        b=1;
        for (i=0; i<ni; i++) a += 1; 
        for (i=0; i<nd; i++) b *= 1.00001;
    }

    // Copy state back to global memory */
    state[id] = localState ;

    // Store results */
    uniforms[id] = u;
    int_ops[id] = a;
    dou_ops[id] = b;
}



//CURAND_RNG_PSEUDO_MTGP32
//__global__ void runif_kernel(int n, double ub,

extern "C" {

void gpu_runif(int *n, double *ub, int *ni, int *nd, double *u, int *nIO, double *nDO) 
{
    int nBlocks = *n/THREADS_PER_BLOCK, *d_io;
    size_t u_size = *n *sizeof(double), o_size = *n *sizeof(int);
    double *d_u, *d_do;

    cutilSafeCall( cudaMalloc((void**)&d_u,  u_size) );
    cutilSafeCall( cudaMalloc((void**)&d_io, o_size) );
    cutilSafeCall( cudaMalloc((void**)&d_do, u_size) );

    // Setup prng states
    curandState *d_states;
    cutilSafeCall( cudaMalloc((void**)&d_states, nBlocks*THREADS_PER_BLOCK*sizeof(curandState)) );
    setup_prng<<<nBlocks,THREADS_PER_BLOCK>>>(d_states);

    runif_kernel<<<nBlocks,THREADS_PER_BLOCK>>>(d_states, *ub, *ni, *nd, d_u, d_io, d_do);   
 
    cutilSafeCall( cudaMemcpy(u,   d_u,  u_size, cudaMemcpyDeviceToHost) );
    cutilSafeCall( cudaMemcpy(nIO, d_io, o_size, cudaMemcpyDeviceToHost) );
    cutilSafeCall( cudaMemcpy(nDO, d_do, u_size, cudaMemcpyDeviceToHost) );

    cutilSafeCall( cudaFree(d_u)      );
    cutilSafeCall( cudaFree(d_io)     );
    cutilSafeCall( cudaFree(d_do)     );
    cutilSafeCall( cudaFree(d_states) );
}

} // end of extern "C"
