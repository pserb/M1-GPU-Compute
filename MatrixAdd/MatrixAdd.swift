//
//  MatrixAdd.swift
//  M1-GPU-Compute
//
//  Created by Paul Serbanescu on 4/13/22.
//

import MetalKit

// adding two matrices
struct MatrixAdd {
    
    // for loop CPU method
    mutating func run(arraySize: Int) {
        let N = arraySize

        let ye = arc4random_uniform(10)
        let array1 = Array(repeating: Array(repeating: Float(ye), count: N), count: N)

        let ye2 = arc4random_uniform(10)
        let array2 = Array(repeating: Array(repeating: Float(ye2), count: N), count: N)

        var result = Array(repeating: Array(repeating: Float(0), count: N), count: N)

        print("array 1: \(array1[0][0])")
        print("array 2: \(array2[0][0])")

        for row in 0..<N {
            for col in 0..<N {
                result[row][col] = array1[row][col] + array2[row][col]
            }
        }

        print(result[0][0])
    }
}
