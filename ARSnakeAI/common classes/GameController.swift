//
//  GameController.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/13.
//

import SceneKit

let humanPlaying: Bool = false
let modelPlaying: Bool = true
var hidden_nodes = 16
var hidden_layers = 2

final class GameController {
    private var timer: Timer!
    public var worldSceneNode: SCNNode?

    var snake: Snake!
    var model: Snake!
    var pop: Population!
    var popSize: Int = 1
    
    // MARK: - Game Lifecycle
    init() {
        if let worldScene = SCNScene(named: "worldScene2.scn") {
            worldSceneNode = worldScene.rootNode.childNode(withName: "worldScene", recursively: true)
            worldSceneNode?.removeFromParentNode()
        }
    }
    
    func setup() {
        if(humanPlaying) {
        
            snake = Snake()
            worldSceneNode?.addChildNode(snake)
            
        } else {
            
            if(modelPlaying) {
                fileSelectedIn()
                
            }
            
            else {
                pop = Population(size: popSize)
                worldSceneNode?.addChildNode(pop)
                
            }

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
                model.look()
                model.think()
                model.move()
                model.show()
                
                if(model.dead) {
                    model.removeFromParentNode()
                    let temp: Snake = Snake()
                    temp.brain = model.brain.clone()
                    model = temp
                    worldSceneNode?.addChildNode(model)
                    
                }
            }
            
            else {
                if(pop.done()) {
                    pop.clear()
                    pop.removeFromParentNode()
                    pop = Population(size: popSize)
                    worldSceneNode?.addChildNode(pop)
                    
                    
                } else {
                    pop.update()
                    pop.show()
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
