//
//  GameViewController.swift
//  3DSnakeARClone
//
//  Created by 백성준 on 2021/06/30.
//

import UIKit
import QuartzCore
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate {
    
    enum ViewState {
        case searchPlanes
        case selectPlane
        case startGame
        case playing
    }
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var startGameButton: UIButton!
    
    var state: ViewState = .searchPlanes {
        didSet {
            print("state changed")
            updateView()
            planes.values.forEach { plane in
                plane.isHidden = true
            }
        }
    }
    
    var gameController: GameController = GameController()
    
    var planes: [ARAnchor: HorizontalPlane] = [:]
    var selectedPlane: HorizontalPlane?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = truesceneView.delegate = self
        
        // create a new scene
        let scene = SCNScene(named: "arscene.scn")!
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: -1, y: 10, z: 1)
        scene.rootNode.addChildNode(lightNode)
        
        
        // Set the scene to the view
        sceneView.scene = scene

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeft.direction = .left
        sceneView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeRight.direction = .right
        sceneView.addGestureRecognizer(swipeRight)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        
    }

    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            if let result = hitResults.first, let selectedPlane = result.node as? HorizontalPlane {
                self.selectedPlane = selectedPlane
                state = .startGame
                gameController.addToNode(rootNode: selectedPlane.parent!)
                gameController.updateGameSceneForAnchor(anchor: selectedPlane.anchor)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        state = .searchPlanes
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("render didAdd works")
        guard state == .searchPlanes || state == .selectPlane else {
            return
        }
        if let anchor = anchor as? ARPlaneAnchor {
            if state == .searchPlanes {
                state = .selectPlane
            }
            let plane = HorizontalPlane(anchor: anchor)
            planes[anchor] = plane
            node.addChildNode(plane)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor,
            let plane = planes[anchor] {
                plane.update(for: anchor)
                if selectedPlane?.anchor == anchor {
                    gameController.updateGameSceneForAnchor(anchor: anchor)
                }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    func updateView() {
        DispatchQueue.main.async {
            switch self.state {
            case .startGame:
                self.startGameButton.isHidden = false
            case .searchPlanes:
                self.startGameButton.isHidden = true
            case .selectPlane:
                self.startGameButton.isHidden = true
            case .playing:
                self.startGameButton.isHidden = true
            }
        }
    }
    
    @IBAction func startButtonTabbed(_ sender: Any) {
        state = .playing
        gameController.setup()
        gameController.startGame()
    }
    
    @objc
    func swipeLeft(_ sender: Any) {
        gameController.turnLeft()
    }
    
    @objc
    func swipeRight(_ sender: Any) {
        gameController.turnRight()
        
    }

}

//extension ViewController: GameControllerDelegate {
//    func gameOver(sender: GameController) {
//        gameController.reset()
//        gameController.startGame()
//    }
//}

extension GameController {
    func updateGameSceneForAnchor(anchor: ARPlaneAnchor) {
        let worldSize: Float = 20.0
        let minSize = min(anchor.extent.x, anchor.extent.z)
        let scale = minSize / worldSize / 3.0
        worldSceneNode?.scale = SCNVector3(x: scale, y: scale, z: scale)
        worldSceneNode?.position = SCNVector3(anchor.center)
    }
}
