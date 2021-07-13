//
//  GameController.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/13.
//

import SceneKit

final class GameController {
    private var timer: Timer!
    
    public var worldSceneNode: SCNNode?
    var snake: Snake!
    
    // MARK: - Game Lifecycle
    init() {
        if let worldScene = SCNScene(named: "worldScene.scn") {
            worldSceneNode = worldScene.rootNode.childNode(withName: "worldScene", recursively: true)
            worldSceneNode?.removeFromParentNode()
        }
    }
    
    func setup() {
        snake = Snake()
        worldSceneNode?.addChildNode(snake)
    }
    
    func startGame() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(draw), userInfo: nil, repeats: true)
    }
    
    @objc func draw(timer: Timer) {
        snake.move()
        snake.show()
        if(snake.dead) {
            self.snake = Snake()
            worldSceneNode?.removeFromParentNode()
            worldSceneNode?.addChildNode(snake)
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
    
}
