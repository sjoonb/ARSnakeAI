//
//  Simulator.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/21.
//

import UIKit
import SceneKit

class Simulator: SCNNode {
    var snakes: [Snake]!
    
    init(size: Int) {
        super.init()
        snakes = []
        for _ in 0..<size {
            let snake: Snake = fileSelectedIn()
            snakes.append(snake)
            addChildNode(snake)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func done() -> Bool {
        for i in 0..<snakes.count {
            if(!snakes[i].dead) {
                return false
            }
        }
        return true
    }
    
    func update() {
        for i in 0..<snakes.count {
            snakes[i].look()
            snakes[i].think()
            snakes[i].move()
        }
    }
    
    func show() {
        for i in 0..<snakes.count {
            snakes[i].show()
        }
    }
    
    func reset() {
        for i in 0..<snakes.count {
            snakes[i].removeFromParentNode()
            let temp: Snake = Snake()
            temp.brain = snakes[i].brain.clone()
            snakes[i] = temp
            addChildNode(snakes[i])
        }
    }
    
    func fileSelectedIn()-> Snake {
        guard let filepath = Bundle.main.path(forResource: "lifeTime50_gen19", ofType: "csv") else {
            return Snake()
        }
        
        var data = ""
        do {
            data = try String(contentsOfFile: filepath)
        } catch {
            print(error)
            return Snake()
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
        
        let model = Snake()
//        worldSceneNode?.addChildNode(model)
        
        model.brain.load(loadedWeights: weights)
        
        return model
        
    }
    
}
