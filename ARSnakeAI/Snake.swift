//
//  Snake.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/13.
//

import SceneKit

typealias PVector = SIMD2<Int32>

class SnakeNode: SCNNode {
    
    init(pos: PVector) {
        super.init()
        if let scene = SCNScene(named: "snakeBody.scn") {
            if let snakeBody = scene.rootNode.childNode(withName: "snakeBody", recursively: true) {
                addChildNode(snakeBody)
            }
        }
        position = SCNVector3(Float(pos.x), Float(0.5), Float(pos.y))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Snake: SCNNode {
    var head: PVector!
    var body: [PVector]!
    
    var nodes: [SnakeNode] = []
    
    public var dead: Bool = false
    
    override init() {
        super.init()
        head = PVector(0, 0)
        body = [head]
        setHeadNode()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHeadNode() {
        nodes.forEach {
            $0.removeFromParentNode()
        }
        nodes = []
        for i in body {
            nodes += [SnakeNode(pos: i)]
        }
        
        nodes.forEach { (node) in
            addChildNode(node)
        }
    }
    
    func move() {
        
    }
    
    func show() {
        for (i, node) in nodes.enumerated() {
            let pos = body[i]
            node.position = SCNVector3(Float(pos.x), Float(0.5), Float(pos.y))
        }

    }
}
