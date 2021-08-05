//
//  Simulator.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/21.
//

import UIKit
import SceneKit

class Simulator: SCNNode {
    var generation = 0
    var snakes: [Snake]!
    var colorList: [String] = ["", "", "Ivory", "", ""]
    
    weak var delegate: generationLabelDelegate?
    
    init(size: Int) {
        super.init()
        snakes = []
        for i in 0..<size {
            if let snake: Snake = fileSelectedIn(file: String(generation) + "-" + String(i), color: colorList[i]) {
                snakes.append(snake)
                addChildNode(snake)
            }
        }
    }
    
    init(modelGeneration: Int) {
        super.init()
        snakes = []
        generation = modelGeneration
        if let snake: Snake = fileSelectedIn(file: String(generation) + "-" + "0", color: colorList[0]) {
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
        delegate?.generationDidChange(leftValue: String(generation))
    }
    
    func clear() {
        for i in 0..<snakes.count {
            snakes[i].removeFromParentNode()
            snakes[i].cleanup()
        }
    }
    
    func nextGeneration() {
        generation += 1
        for i in 0..<snakes.count {
            if let snake: Snake = fileSelectedIn(file: String(generation) + "-" + String(i), color: colorList[i]) {
                snakes[i].removeFromParentNode()
                snakes[i] = snake
                addChildNode(snakes[i])
            } else {
                generation -= 1
            }
        }
        delegate?.generationDidChange(leftValue: String(generation))
    }
    
    func fileSelectedIn(file: String, color: String = "")-> Snake? {
        guard let filepath = Bundle.main.path(forResource: file, ofType: "csv") else {
            return nil
        }
        
        var data = ""
        do {
            data = try String(contentsOfFile: filepath)
        } catch {
            print(error)
            return nil
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
        var arr = [[Double]](repeating: [Double](repeating: 0.0, count: 25), count: hiddenNodes)
        
        for i in 0..<16 {
            for j in 0..<25 {
                arr[i][j] = Double(modelTable[j+i*25][0])!
            }
        }

        weights.append(Matrix(m: arr))

        for h in 1..<hiddenLayers {
            var hid = [[Double]](repeating: [Double](repeating: 0.0, count: hiddenNodes+1), count: hiddenNodes)
            for i in 0..<hiddenNodes {
                for j in 0..<hiddenNodes+1 {
                    hid[i][j] = Double(modelTable[j+i*(hiddenNodes+1)][h])!
                }
            }
            weights.append(Matrix(m: hid))
        }

        arr = [[Double]](repeating: [Double](repeating: 0.0, count: hiddenNodes+1), count: 4)
    
        for i in 0..<4 {
            for j in 0..<hiddenNodes+1 {
                arr[i][j] = Double(modelTable[j+i*(hiddenNodes+1)][2])!
            }
        }
        
        weights.append(Matrix(m: arr))
        
        let model = Snake(color: color)
        model.brain.load(loadedWeights: weights)
        
        return model
        
    }
    
}
