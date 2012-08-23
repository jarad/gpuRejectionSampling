
OBJS := cpu_runif.o
CUDA_OBJS := gpu_runif.o

#compiler/preprocessor options
INCS := -I. -I/usr/local/include -I/usr/local/cuda/include -I/apps/lib64/R/include -I/usr/local/NVIDIA_GPU_Computing_SDK/C/common/inc
PARAMS :=   -Xcompiler -fpic -DRPRINT -DNDEBUG

#linker options
LD_PARAMS :=  -Xlinker -L/usr/local/lib64  
LIBS :=  -L/usr/local/cuda/lib64  -lcublas -lRlapack -L/apps/lib64/R/lib -lRblas -lgfortran -lm -L/usr/local/NVIDIA_GPU_Computing_SDK/C/common/lib/linux 

TARGETS := runif.so

#NVCC := /usr/local/cuda/bin/nvcc -gencode arch=compute_10,code=sm_10 -gencode arch=compute_11,code=sm_11 -gencode arch=compute_12,code=sm_12 -gencode arch=compute_13,code=sm_13 -gencode arch=compute_20,code=sm_20 -arch=sm_20

NVCC := /usr/local/cuda/bin/nvcc -arch=sm_20 



all: $(TARGETS)


$(TARGETS): $(OBJS) $(CUDA_OBJS)
	$(NVCC) -shared $(LD_PARAMS) $(LIBS) $(OBJS13) $(CULA_OBJS) $(OBJS) $(CUDA_OBJS)  -o $@

$(OBJS): %.o: %.c
	$(NVCC) -c $(INCS) $(PARAMS) $^ -o $@

$(CUDA_OBJS): %.o: %.cu
	$(NVCC) -c $(INCS) $(PARAMS) $^ -o $@


clean:
	rm -rf *o

