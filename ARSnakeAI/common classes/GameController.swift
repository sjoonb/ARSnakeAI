//
//  GameController.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/13.
//

import SceneKit

var humanPlaying: Bool = false
var modelPlaying: Bool = true
var modelSelected: Bool = false
let hidden_nodes = 16
let hidden_layers = 2

protocol generationLabelDelegate: AnyObject {
    func generationDidChange(leftValue: String)
}


final class GameController: generationLabelDelegate {
    func generationDidChange(leftValue: String) {
        delegate?.generationDidChange(leftValue: leftValue)
    }
    
    private var timer: Timer!
    public var worldSceneNode: SCNNode?

    var snake: Snake!
    var model: Snake!
    
    var sim: Simulator!

    var simSize: Int = 5
    var selectedModelGeneration: Int?

    weak var delegate: generationLabelDelegate?
    
    // MARK: - Game Lifecycle
    init() {
        if let worldScene = SCNScene(named: "worldScene.scn") {
            worldSceneNode = worldScene.rootNode.childNode(withName: "worldScene", recursively: true)
            worldSceneNode?.removeFromParentNode()
        }
    }
    
    func reset() {
        sim.clear()
    }
    
    func setup() {
        if(humanPlaying) {
        
            snake = Snake()
            worldSceneNode?.addChildNode(snake)
            
        } else {

            if(modelPlaying) {
                sim = Simulator(size: simSize)
                worldSceneNode?.addChildNode(sim)
                
            } else if(modelSelected) {
                sim = Simulator(modelGeneration: selectedModelGeneration ?? 0)
                worldSceneNode?.addChildNode(sim)
                
            }
            
            sim.delegate = self
            delegate?.generationDidChange(leftValue: String(sim.generation))

        }
        
    }
    
    func startGame() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(draw), userInfo: nil, repeats: true)
    }
    
    @objc func draw(timer: Timer) {
        if(humanPlaying) {
            snake.move()
            snake.show()
            
            if(snake.dead) {
                snake.removeFromParentNode()
                snake = Snake()
                worldSceneNode?.addChildNode(snake)
            }
            
        } else {
            
            if(modelPlaying) {
                if(sim.done()) {
                    sim.nextGeneration()
                }
                
                else {
                    sim.update()
                    sim.show()
                    
                }
            } else if(modelSelected) {
                if(sim.done()) {
                    sim.reset()
                }
                
                else {
                    sim.update()
                    sim.show()
                    
                }
                
            }
        }
    }
    
    func addToNode(rootNode: SCNNode) {
        guard let worldScene = worldSceneNode else {
            return
        }
        worldScene.removeFromParentNode()
        rootNode.addChildNode(worldScene)
        worldScene.scale = SCNVector3(0.04, 0.04, 0.04)
    }
    
    func turnLeft() {
        if(humanPlaying) {
            snake.turnLeft()
        }
    }
    
    func turnRight() {
        if(humanPlaying) {
            snake.turnRight()
        }
    }
    
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
        
        model = Snake()
        worldSceneNode?.addChildNode(model)
        
        model.brain.load(loadedWeights: weights)
        
        
    }
    
}

extension SCNNode {
    func cleanup() {
        for child in childNodes {
            child.cleanup()
        }
        geometry = nil
    }
}
