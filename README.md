# M1-GPU-Compute
Using Swift and Apple's Metal API to utilize the GPUs on M1 equipped Macs

### Adding Two Arrays
CPUs perform computations sequentially, waiting for the previous computation to finish before moving onto the next one.
Let's say we wanted to add two arrays together:
```Swift
let array1 = [3, 2, 4, 1, 5]
let array2 = [1, 5, 2, 7, 3]
```
The CPU would go in order, adding each index from left to right.
An example of CPU implementation:
```Swift
let result = [0, 0, 0, 0, 0]

for i in 0..<5 {
    result[i] = array1[i] + array2[i]
}
```
CPUs would add 3 and 1 then place 4 into the result array, then move on to the next index:

3 + 1 = **4**<br>
2 + 5 = **7**<br>
4 + 2 = **6**<br>
1 + 7 = **8**<br>
5 + 3 = **8**<br>

While this is very easy for the CPU to do and will happen in 0.01 of a millisecond, it will get really slow, really fast as the array grows to millions or even billions in length.

This is where a GPU comes in really handy. GPUs are great at doing repetative, simple tasks, like adding two numbers, but instead of doing them one at a time, a GPU splits the task and computes the entire resulting array in one go.

This is what the GPU function inside `compute.metal` looks like:
```c
kernel void addition_compute_function(constant float *arr1        [[ buffer(0) ]],
                                      constant float *arr2        [[ buffer(1) ]],
                                      device   float *resultArray [[ buffer(2) ]],
                                      uint  index        [[ thread_position_in_grid ]]) {
    resultArray[index] = arr1[index] + arr2[index];
}
```
It takes in the two arrays and resulting array as parameters and also `uint index [[ thread_position_in_grid ]]` which is a thread specifcially assigned to perform the addition on `index` of the array

## Results
My specs: M1 Max 10-core CPU, 24-core GPU, 32GB RAM
| Array Size | CPU Time (seconds) | GPU Time (seconds) |
| :--------: | :-------------:| :-: |
| 5 | 0.00001 | 0.00070 |
| 100,000 | 0.03356 | 0.00707 |
| 1,000,000 | 0.33692 | 0.00990 |
| 50,000,000 | 16.86406 | 0.07883 |
| 100,000,000 | 33.44142 | 0.15101 |
| 500,000,000 | N/A | 0.80057 |
| 1,000,000,000| N/A | 1.41739 |
| 1,700,000,000 | N/A | 24.19244 |

Note: Adding two 1.7 billion length arrays uses all 32GB of memory

This time is only for the adding portion of the function. The creation of arrays and populating them with random values also takes a considerable portion of time, and can also be accelerated by the GPU


... 
