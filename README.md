# Limit number of CUDA SM cores

A demo to limit the number of CUDA Stream Multiprocessor (SM) cores to run a task.


## Introduction

In this demo, we limited only two SM cores to print "Hello world!".

This trick may be used in some academic research, for example, to simulate the running for a task in lower-level GPU hardware.

Check [this comment](https://forums.developer.nvidia.com/t/how-to-limit-number-of-cuda-cores/42414/6?u=user7977) for a detailed explanation of the implementation.

Noted that we currently hardcode the number of SM cores and the maximum blocks per SM.


## Execution

### Compile and Run

```
nvcc demo.cu -o demo && ./demo
```

### Expected output

```
My SM ID is 0, take a snap for about 2 s
My SM ID is 1, take a snap for about 2 s
...
My SM ID is 65, sleep forever
My SM ID is 64, sleep forever
My SM ID is 65, sleep forever
My SM ID is 1, wake up!
My SM ID is 1, wake up!
...
My SM ID is 0, wake up!
My SM ID is 0, wake up!
-----
Main task start
Hello world! My SM ID is 1
Hello world! My SM ID is 0
Hello world! My SM ID is 1
Hello world! My SM ID is 1
...
Hello world! My SM ID is 0
Hello world! My SM ID is 0
Main task end
```

## Reference

https://forums.developer.nvidia.com/t/how-to-limit-number-of-cuda-cores/42414/5
