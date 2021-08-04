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

protocol generationLabelDelegate: AnyObject {
    func generationDidChange(leftValue: String)
}

class ViewController: UIViewController, ARSCNViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, generationLabelDelegate {
    
    enum ViewState {
        case searchPlanes
        case selectPlane
        case startGame
        case singlePlaying
        case AIPlaying
    }
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var AIPlayButton: UIButton!
    @IBOutlet weak var setGenerationButton: UIButton!
    @IBOutlet weak var generationLabel: UILabel!
    
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
    
    // for picker view
    
    var generationList: [Int] = []
    
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2
    
    

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
        
        gameController.delegate = self
        
        for i in 0...34 {
            generationList.append(i)
        }
        
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

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("render3 work")
        if let plane = planes.removeValue(forKey: anchor) {
            if plane == self.selectedPlane {
                let nextPlane = planes.values.first!
                gameController.addToNode(rootNode: nextPlane)
                gameController.updateGameSceneForAnchor(anchor: nextPlane.anchor)
            }
            plane.removeFromParentNode()
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
                self.AIPlayButton.isHidden = false
                self.setGenerationButton.isHidden = true
                self.generationLabel.isHidden = true
            case .searchPlanes:
                self.startGameButton.isHidden = true
                self.AIPlayButton.isHidden = true
                self.setGenerationButton.isHidden = true
                self.generationLabel.isHidden = true
            case .selectPlane:
                self.startGameButton.isHidden = true
                self.AIPlayButton.isHidden = true
                self.setGenerationButton.isHidden = true
                self.generationLabel.isHidden = true
            case .singlePlaying:
                self.startGameButton.isHidden = true
                self.AIPlayButton.isHidden = true
                self.setGenerationButton.isHidden = true
                self.generationLabel.isHidden = true
            case .AIPlaying:
                self.startGameButton.isHidden = true
                self.AIPlayButton.isHidden = true
                self.setGenerationButton.isHidden = false
                self.generationLabel.isHidden = false
            }
        }
    }
    
    @IBAction func startButtonTabbed(_ sender: Any) {
        state = .singlePlaying
        humanPlaying = true
        modelPlaying = false
        modelSelected = false
        gameController.setup()
        gameController.startGame()
    }
    
    @IBAction func AIPlayButtonTabbed(_ sender: Any) {
        state = .AIPlaying
        humanPlaying = false
        modelPlaying = true
        modelSelected = false
        self.generationLabel.text = "GEN: " + String(0)
        self.generationLabel.textColor = UIColor(white: 1, alpha: 0.75)
        gameController.setup()
        gameController.startGame()
 
    }
    
    @IBAction func setGenerationButtonTabbed(_ sender: Any) {
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select Generation", message: "", preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = setGenerationButton
        alert.popoverPresentationController?.sourceRect = pickerView.bounds
        
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { UIAlertAction in
        }))
        
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { UIAlertAction in
            self.selectedRow = pickerView.selectedRow(inComponent: 0)
            self.gameController.selectedModelGeneration = self.selectedRow
//            self.gameController.sim.generation = self.selectedRow
            
            print(self.selectedRow)
            self.state = .AIPlaying
            self.gameController.reset()
            humanPlaying = false
            modelPlaying = false
            modelSelected = true
            self.gameController.setup()
            self.gameController.startGame()
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    var selectedRow = 0
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return generationList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = String(generationList[row])
        label.sizeToFit()
        return label
    }
    
    @objc
    func swipeLeft(_ sender: Any) {
        gameController.turnLeft()
    }
    
    @objc
    func swipeRight(_ sender: Any) {
        gameController.turnRight()
        
    }
    
    func generationDidChange(leftValue: String) {
        self.generationLabel.text = "GEN: " + String(leftValue)
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

extension SCNNode {
    func cleanup() {
        for child in childNodes {
            child.cleanup()
        }
        geometry = nil
    }
}
