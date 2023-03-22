# hipfort-dgemm-perf
Tool to measure HIPBLAS DGEMM performance via HIPFORT

# How to build

`export HIPFORT=/path/to/hipfort`
`make`

# How to execute

`./hip_dgemm.x <rows of [A]> <columns/rows of [A]/[B]> <columns of [B]> <# runs> <op([A]) 'N' or 'T'> <op([A]) 'N' or 'T'>`

For example:

```
./hip_dgemm.x 16000 14000 16000 10 N N
./hip_dgemm.x 16000 14000 16000 10 N T
./hip_dgemm.x 16000 14000 16000 10 T N
./hip_dgemm.x 16000 14000 16000 10 T N
```

# Sample output for CCE 14.0.3 and ROCM 5.2 on MI250X

```
$ ./hip_dgemm.x  16000 14000 16000 10 T T
 Performing 10 repetitions of 16000 * 14000 by 14000 * 16000
Time(s):         24.741
GFLOP/s:       2897.188
```
