//
//  GameController.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/13.
//

import SceneKit

let humanPlaying: Bool = false

final class GameController {
    private var timer: Timer!
    public var worldSceneNode: SCNNode?

    var snake: Snake!
    var pop: Population!
    var popSize: Int = 100
    
    // MARK: - Game Lifecycle
    init() {
        if let worldScene = SCNScene(named: "worldScene.scn") {
            worldSceneNode = worldScene.rootNode.childNode(withName: "worldScene", recursively: true)
            worldSceneNode?.removeFromParentNode()
        }
    }
    
    func setup() {
        if(humanPlaying) {
            snake = Snake()
            worldSceneNode?.addChildNode(snake)
            
        } else {
            pop = Population(size: popSize)
            worldSceneNode?.addChildNode(pop)
        }
        
    }
    
    func startGame() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(draw), userInfo: nil, repeats: true)
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
    
    func addToNode(rootNode: SCNNode) {
        guard let worldScene = worldSceneNode else {
            return
        }
        worldScene.removeFromParentNode()
        rootNode.addChildNode(worldScene)
        worldScene.scale = SCNVector3(0.07, 0.07, 0.07)
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
    
}
