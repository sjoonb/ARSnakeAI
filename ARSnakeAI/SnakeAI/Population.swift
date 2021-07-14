//
//  Population.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/14.
//

import UIKit
import SceneKit

class Population: SCNNode {
    
    var snakes: [Snake]!
    
    init(size: Int) {
        super.init()
        snakes = []
        for _ in 0..<size {
            let snake: Snake = Snake()
            snakes.append(snake)
            addChildNode(snake)
        }
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
    
    func clear() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
