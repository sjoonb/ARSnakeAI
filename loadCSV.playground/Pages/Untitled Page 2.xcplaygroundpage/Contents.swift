//: [Previous](@previous)

import UIKit

var hidden_nodes = 16
var hidden_layers = 2

func fileSelectedIn() {
    guard let filepath = Bundle.main.path(forResource: "lifeTime50_gen19", ofType: "csv") else {
        return
    }
    
    var data = ""
    do {
        data = try String(contentsOfFile: filepath)
    } catch {
        print(error)
        return
    }
    var rows = data.components(separatedBy: "\n")

    //if you have a header row, remove it here
    rows.removeFirst()
    
    var modelTable: [[String]] = []
    for i in 0..<rows.count-1 {
        let rowTable: [String] = rows[i].components(separatedBy: ",")
        modelTable.append(rowTable)
    }
    
    var weights: [Matrix] = []
    
    var arr = [[Double]](repeating: [Double](repeating: 0.0, count: 25), count: hidden_nodes)
    
    for i in 0..<16 {
        for j in 0..<25 {
            arr[i][j] = Double(modelTable[j+i*25][0])!
        }
    }

    weights.append(Matrix(m: arr))

    for h in 1..<hidden_layers {
        var hid = [[Double]](repeating: [Double](repeating: 0.0, count: hidden_nodes+1), count: hidden_nodes)
        for i in 0..<hidden_nodes {
            for j in 0..<hidden_nodes+1 {
                hid[i][j] = Double(modelTable[j+i*(hidden_nodes+1)][h])!
            }
        }
        weights.append(Matrix(m: hid))
    }

    arr = [[Double]](repeating: [Double](repeating: 0.0, count: hidden_nodes+1), count: 4)
    
    for i in 0..<4 {
        for j in 0..<hidden_nodes+1 {
            arr[i][j] = Double(modelTable[j+i*(hidden_nodes+1)][2])!
        }
    }
    
    weights.append(Matrix(m: arr))
    
}
//: [Next](@next)

fileSelectedIn()
