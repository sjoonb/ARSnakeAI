//
//  NeuralNet.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/14.
//

class NeuralNet {
    var iNodes, hNodes, oNodes, hLayers: Int
    var weights: [Matrix]!
    
    init(input: Int, hidden: Int, output: Int, hiddenLayers: Int) {
        iNodes = input
        hNodes = hidden
        oNodes = output
        hLayers = hiddenLayers
        
        weights = [Matrix]()
        weights.append(Matrix(r: hNodes, c: iNodes+1))
        for _ in 1..<hLayers {
            weights.append(Matrix(r: hNodes, c: hNodes+1))
        }
        weights.append(Matrix(r: oNodes, c: hNodes+1))
        
        weights.forEach { matrix in
            matrix.randomize()
        }
        
    }
    
    func output(inputsArr: [Double]) -> [Double] {
        let inputs: Matrix = weights[0].singleColumnMatrixFromArray(arr: inputsArr)
        var currBias: Matrix = inputs.addBias()
        
        for i in 0..<hLayers {
            let hiddedIp: Matrix = weights[i].dot(input: currBias)
            let hiddenOp: Matrix = hiddedIp.activate()
            currBias = hiddenOp.addBias()
        }
        
        let outputIp: Matrix = weights[weights.count - 1].dot(input: currBias)
        let output: Matrix = outputIp.activate()
        
        return output.toArray()
    }
}
