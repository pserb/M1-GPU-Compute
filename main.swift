//
//  main.swift
//  M1-GPU-Compute
//
//  Created by Paul Serbanescu on 4/9/22.
//

import MetalKit

var linearAdd = LinearListAdd()
linearAdd.run(arraySize: 100_000)

var matrixAdd = MatrixAdd()
matrixAdd.run(arraySize: 1_000)
