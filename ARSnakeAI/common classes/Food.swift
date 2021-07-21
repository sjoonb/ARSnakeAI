//
//  Food.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/13.
//

import SceneKit

class Food: SCNNode {
    var pos: PVector!
    var sceneSize: Int!
    
    // MARK: - Lifecycle
    init(size: Int) {
        super.init()
        if let scene = SCNScene(named: "mushroom.scn"), let mushroomNode = scene.rootNode.childNode(withName: "mushroom", recursively: true) {
            addChildNode(mushroomNode)
        }
        sceneSize = size
        let x = Int32(arc4random() % UInt32((sceneSize))) - 18
        let y = Int32(arc4random() % UInt32((sceneSize))) - 18
        pos = PVector(x, y)
        position =  SCNVector3(Float(pos.x), 0, Float(pos.y))
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func show() {
        
    }

}
