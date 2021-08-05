//
//  Extension.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/08/05.
//

import SceneKit

extension SCNNode {
    func cleanup() {
        for child in childNodes {
            child.cleanup()
        }
        geometry = nil
    }
}
