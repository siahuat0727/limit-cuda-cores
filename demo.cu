#include <iostream>
#include <vector>
#include <stdlib.h>
#include <time.h>
#include <cuda_runtime.h>
#include <math.h>
#include <unistd.h>
#include <assert.h>

using namespace std;
using clock_value_t = long long;

static __device__ __inline__ uint32_t __mysmid() {
    uint32_t smid;
    asm volatile("mov.u32 %0, %%smid;" : "=r"(smid));
    return smid;
}

__device__ void sleepForever()
{
    clock_value_t sleep_cycles = 800000000000LL;  // TODO can we sleep forever?
    clock_value_t start = clock64();
    clock_value_t cycles_elapsed;
    do { 
        cycles_elapsed = clock64() - start; 
    } while (cycles_elapsed < sleep_cycles);

    printf("Never reach here!");
}

__device__ void smSleep(clock_value_t sleep_cycles)
{
    clock_value_t start = clock64();
    clock_value_t cycles_elapsed;
    do { 
        cycles_elapsed = clock64() - start; 
    } while (cycles_elapsed < sleep_cycles);
}

__global__ void sleepKernel(int target_cores_num) {
    uint32_t smid = __mysmid();
    if (smid >= target_cores_num) {
        printf("My SM ID is %d, sleep forever\n", smid);
        sleepForever();
    } else {
        printf("My SM ID is %d, take a snap about 2 s\n", smid);
        smSleep(5000000000LL);  // TODO can convert to seconds?
    }
    printf("My SM ID is %d, wake up!\n", smid);
}

__global__ void helloWorldKernel() {
    uint32_t smid = __mysmid();
    printf("Hello world! My SM ID is %d\n", smid);
}

void doLimitSM(int target_cores_num, cudaStream_t stream){
    dim3 threadsPerBlock(1, 1);
    dim3 blocksPerGrid(68, 1);  // TODO get this automatically
    sleepKernel<<<blocksPerGrid,threadsPerBlock, 0, stream>>>(target_cores_num);
}

void limitSM(int target_cores_num) {
    int max_stream = 16; // TODO get this automatically
    cudaStream_t stream[max_stream];
    for (int i = 0; i < max_stream; ++i) {
        cudaStreamCreate(&stream[i]);
        doLimitSM(target_cores_num, stream[i]);
    }
}

void helloWorld(cudaStream_t stream){
    dim3 threadsPerBlock(1, 1);
    dim3 blocksPerGrid(68, 1);
    helloWorldKernel<<<blocksPerGrid,threadsPerBlock, 0, stream>>>();
}

void mainTask() {
    cudaStream_t stream;
    cudaStreamCreate(&stream);

    helloWorld(stream);

    cudaStreamSynchronize(stream);
}

int main()
{
    int target_cores_num = 2;
    limitSM(target_cores_num);

    sleep(5);

    puts("-----");
    puts("Main task start");
    mainTask();
    puts("Main task end");

    return 0;
}
