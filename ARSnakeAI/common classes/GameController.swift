//
//  GameController.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/13.
//

import SceneKit

var humanPlaying: Bool = true
var modelPlaying: Bool = false
var modelSelected: Bool = false
let hiddenNodes = 16
let hiddenLayers = 2

protocol generationLabelDelegate: AnyObject {
    func generationDidChange(leftValue: String)
}


final class GameController: generationLabelDelegate {
    func generationDidChange(leftValue: String) {
        delegate?.generationDidChange(leftValue: leftValue)
    }
    
    // MARK: - Properties
    
    private var timer: Timer!
    public var worldSceneNode: SCNNode?

    // for single play
    var snake: Snake!
    
    // for simulator
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
    
    func startGame() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(draw), userInfo: nil, repeats: true)
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
    
    // MARK: - Gestures
    
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
}
