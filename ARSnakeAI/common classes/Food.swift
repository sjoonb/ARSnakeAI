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

    init(size: Int) {
        super.init()
        if let scene = SCNScene(named: "food.scn"), let mushroomNode = scene.rootNode.childNode(withName: "food", recursively: true) {
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

}
