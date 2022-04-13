//
//  LinearListAdd.swift
//  M1-GPU-Compute
//
//  Created by Paul Serbanescu on 4/13/22.
//

import MetalKit

struct LinearListAdd {
    mutating func run(arraySize: Int) {
        // timing
        let start = CFAbsoluteTimeGetCurrent()

        // Get GPU
        let device = MTLCreateSystemDefaultDevice()
        print()

        // number of items in each array
        let N = arraySize

        var arrayGPU1 = createRandomArrayGPU()
        var arrayGPU2 = createRandomArrayGPU()

        //var arr1 = createRandomArray()
        //var arr2 = createRandomArray()

        // add functions
        //forLoopAdd(arr1: arr1, arr2: arr2)
        computeAdd(arr1: arrayGPU1, arr2: arrayGPU2)

        // uses GPU and metal compute shader to add 2 arrays
        func computeAdd(arr1: UnsafeMutablePointer<Float>, arr2: UnsafeMutablePointer<Float>) {
            let start = CFAbsoluteTimeGetCurrent()
            
            // FIFO queue for sending instructions to GPU
            let commandQueue = device?.makeCommandQueue()
            
            // library for getting our metal functions
            let gpuFunctionLibrary = device?.makeDefaultLibrary()
            
            // grab metal function
            let additionGPUFunction = gpuFunctionLibrary?.makeFunction(name: "addition_compute_function")
            
            // create pipeline
            var additionComputePipelineState: MTLComputePipelineState!
            do {
                additionComputePipelineState = try device?.makeComputePipelineState(function: additionGPUFunction!)
            } catch {
                print(error)
            }
            
            // create buffers from arrays to be sent to GPU
            let arr1Buffer = device?.makeBuffer(bytes: arr1,
                                                length: MemoryLayout<Float>.size * N,
                                                options: .storageModeShared)
            
            let arr2Buffer = device?.makeBuffer(bytes: arr2,
                                                length: MemoryLayout<Float>.size * N,
                                                options: .storageModeShared)
            
            let resultBuffer = device?.makeBuffer(length: MemoryLayout<Float>.size * N,
                                                  options: .storageModeShared)
            
            // create buffer to be sent to command queue
            let commandBuffer = commandQueue?.makeCommandBuffer()
            
            // create encoder to set values on the compute function
            let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
            commandEncoder?.setComputePipelineState(additionComputePipelineState)
            
            // set parameters of GPU function
            commandEncoder?.setBuffer(arr1Buffer, offset: 0, index: 0)
            commandEncoder?.setBuffer(arr2Buffer, offset: 0, index: 1)
            commandEncoder?.setBuffer(resultBuffer, offset: 0, index: 2)
            
            // figure out how many threads needed for operation
            let threadsPerGrid = MTLSize(width: N, height: 1, depth: 1)
            let maxThreadsPerGroup = additionComputePipelineState.maxTotalThreadsPerThreadgroup
            let threadsPerThreadgroup = MTLSize(width: maxThreadsPerGroup, height: 1, depth: 1)
            commandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            
            // tell encoder it is done
            commandEncoder?.endEncoding()
            
            // push command to queue for execution
            commandBuffer?.commit()
            
            // wait untill GPU function completes
            // NOTE: do not do this - CPU is paused
            commandBuffer?.waitUntilCompleted()
            
            // get pointer to beginning of the data
            _ = resultBuffer?.contents().bindMemory(to: Float.self, capacity: MemoryLayout<Float>.size * N)
            
            print()
            print("Adding using GPU...")
            
            // print first 3 additions of arrays
        //    for i in 0..<3 {
        //        print("\(arr1[i]) + \(arr2[i]) = \(Float(resultBufferPointer!.pointee) as Any)")
        //        resultBufferPointer = resultBufferPointer?.advanced(by: 1)
        //    }
            
            let time = CFAbsoluteTimeGetCurrent() - start
            print("Addition Time elapsed: \(String(format: "%0.5f", time)) seconds")
            print()
        }

        // helper function
        func createRandomArrayGPU() -> UnsafeMutablePointer<Float> {
            let initStart = CFAbsoluteTimeGetCurrent()
            
            let result = [Float].init(repeating: 0.0, count: N)
            
            let initTime = CFAbsoluteTimeGetCurrent() - initStart
            print("Random Array Init time elapsed: \(String(format: "%0.5f", initTime))seconds")
            
            let populateStart = CFAbsoluteTimeGetCurrent()
            
            let commandQueue = device?.makeCommandQueue()
            let gpuFunctionLibrary = device?.makeDefaultLibrary()
            let populateGPUFunction = gpuFunctionLibrary?.makeFunction(name: "populate_array_function")
            var populateComputePipelineState: MTLComputePipelineState!
            do {
                populateComputePipelineState = try device?.makeComputePipelineState(function: populateGPUFunction!)
            } catch {
                print(error)
            }
            let resultBuffer = device?.makeBuffer(bytes: result,
                                                  length: MemoryLayout<Float>.size * N,
                                                  options: .storageModeShared)
            let commandBuffer = commandQueue?.makeCommandBuffer()
            let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
            commandEncoder?.setComputePipelineState(populateComputePipelineState)
            commandEncoder?.setBuffer(resultBuffer, offset: 0, index: 0)
            let threadsPerGrid = MTLSize(width: N, height: 1, depth: 1)
            let maxThreadsPerGroup = populateComputePipelineState.maxTotalThreadsPerThreadgroup
            let threadsPerThreadgroup = MTLSize(width: maxThreadsPerGroup, height: 1, depth: 1)
            commandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            commandEncoder?.endEncoding()
            commandBuffer?.commit()
            commandBuffer?.waitUntilCompleted()
            let resultBufferPointer = resultBuffer?.contents().bindMemory(to: Float.self, capacity: MemoryLayout<Float>.size * N)
            
            let populateTime = CFAbsoluteTimeGetCurrent() - populateStart
            print("Random Array Populate time elapsed: \(String(format: "%0.5f", populateTime)) seconds")
            print()
            
            return resultBufferPointer!
        }

        let totalTime = CFAbsoluteTimeGetCurrent() - start

        print("With array size: \(N)\nTotal Program time elapsed: \(String(format: "%0.5f", totalTime)) seconds")
        print()


        // uses for loop to add 2 arrays
        func forLoopAdd(arr1: [Float], arr2: [Float]) {
            print("Adding using for loop...")
            
            let start = CFAbsoluteTimeGetCurrent()
            
            var result = [Float].init(repeating: 0.0, count: N)
            
            // process additions
            for i in 0..<N {
                result[i] = arr1[i] + arr2[i]
            }
            
            // print first 3 additions of arrays
            for i in 0..<3 {
                print("\(arr1[i]) + \(arr2[i]) = \(result[i])")
            }
            
            let time = CFAbsoluteTimeGetCurrent() - start
            print("Time elapsed: \(String(format: "%0.5f", time)) seconds")
            print()
        }

        // helper function
        func createRandomArray() -> [Float] {
            let initStart = CFAbsoluteTimeGetCurrent()
            
            var result = [Float].init(repeating: 0.0, count: N)
            
            let initTime = CFAbsoluteTimeGetCurrent() - initStart
            print("Init time elapsed: \(String(format: "%0.5f", initTime))seconds")
            
            let populateStart = CFAbsoluteTimeGetCurrent()
            
            for i in 0..<N {
                result[i] = Float(arc4random_uniform(10))
            }
            
            let populateTime = CFAbsoluteTimeGetCurrent() - populateStart
            print("Populate time elapsed: \(String(format: "%0.5f", populateTime))seconds")
            print()
            
            return result
        }

    }
}
