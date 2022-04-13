//
//  populate.metal
//  M1-GPU-Compute
//
//  Created by Paul Serbanescu on 4/9/22.
//

#include <metal_stdlib>

using namespace metal;

// Generate a random float in the range [0.0f, 1.0f] using x, y, and z (based on the xor128 algorithm)
float rand(int x, int y, int z)
{
    int seed = x + y * 57 + z * 241;
    seed= (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
}

kernel void populate_array_function(device float *arr [[ buffer(0) ]],
                                    uint index [[ thread_position_in_grid ]]) {
    float randomNumber = rand(index,index,index);
    
    // populate array
    arr[index] = randomNumber;
}
