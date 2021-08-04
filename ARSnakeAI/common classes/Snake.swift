//
//  Snake.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/13.
//

import SceneKit

typealias PVector = SIMD2<Int32>

enum SnakeDirection: Int {
    case up
    case right
    case down
    case left

    var asInt2: PVector {
        switch self {
        case .up:
            return PVector(x: 0, y: -1)
        case .right:
            return PVector(x: 1, y: 0)
        case .down:
            return PVector(x: 0, y: 1)
        case .left:
            return PVector(x: -1, y: 0)
        }
    }
}


class SnakeNode: SCNNode {
    
    enum SegmentType: Int {
        case head
        case body
        case tail
    }
    
    init(pos: PVector, type: SegmentType = .body, color: String) {
        super.init()
        switch type {
        case .body:
            if let scene = SCNScene(named: "snakeBody" + color + ".scn") {
                if let snakeBody = scene.rootNode.childNode(withName: "snakeBody", recursively: true) {
                    addChildNode(snakeBody)
                }
            }
        case .tail:
            if let scene = SCNScene(named: "snakeTail" + color + ".scn") {
                if let snakeTail = scene.rootNode.childNode(withName: "snakeTail", recursively: true) {
                    addChildNode(snakeTail)
                }
            }
        case .head:
            if let scene = SCNScene(named: "snakeHead" + color + ".scn") {
                if let snakeBody = scene.rootNode.childNode(withName: "snakeHead", recursively: true) {
                    addChildNode(snakeBody)
                }
            }
        }
    
        position = SCNVector3(Float(pos.x), Float(0.5), Float(pos.y))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Snake: SCNNode {
    var sceneSize = 38
    
    var direction: SnakeDirection = .up
    
    var snakeMoved: Bool = false
    
    var xVel: Int32 = 0
    var yVel: Int32 = 0
    
    var head: PVector!
    var body: [PVector]!
    
    var headNode: SnakeNode!
    var bodyNodes: [SnakeNode] = []
    
    var food: Food!
    
    var color: String!
    
    public var dead: Bool = false {
        didSet {
            food.isHidden = true
            let smoke = SCNNode()
            addChildNode(smoke)
            smoke.position = food.position
            smoke.addParticleSystem(SCNParticleSystem(named: "smoke-spread", inDirectory: nil)!)
            
//            food.addParticleSystem(SCNParticleSystem(named: "crashed-snake", inDirectory: nil)!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.food.removeFromParentNode()
                smoke.removeFromParentNode()
            }
            runCrashAnimation()
        }
    }
    
    // MARK: - Snake AI prpoerties
    
    var vision: [Double]!
    var decision: [Double]!
    
    var brain: NeuralNet!
    
    var hiddenNodes: Int = 16
    var hiddenLayers: Int = 2
    
    var lifeLeft = 500
    var lifeTime = 0
    
    init(color: String = "") {
        super.init()
        self.color = color
        
        head = PVector(0, 0)
        body = []
        vision = [Double](repeating: 0, count: 24)
        decision = [Double](repeating: 0, count: 4)
        
        brain = NeuralNet(input: 24, hidden: hiddenNodes, output: 4, hiddenLayers: hiddenLayers)
        
        food = Food(size: sceneSize)
        addChildNode(food)
        
        headNode = SnakeNode(pos: head, type: .head, color: color)
        addChildNode(headNode)
        
        body.append(PVector(0, 1))
        let bodyNode = SnakeNode(pos: body.last!, color: color)
        addChildNode(bodyNode)
        bodyNodes.append(bodyNode)
        
        body.append(PVector(0, 2))
        let tailNode = SnakeNode(pos: body.last!, type: .tail, color: color)
        addChildNode(tailNode)
        bodyNodes.append(tailNode)
        
        if(!humanPlaying) {
            snakeMoved = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func move() {
        if(!dead) {
            shiftBody()
            if(!humanPlaying) {
                lifeLeft -= 1
            }
            if(foodCollide(x: head.x, y:head.y)) {
                eat()
                
            } else if(wallCollide(x: head.x, y: head.y)) {
                dead = true
                
            } else if(bodyCollide(x: head.x, y: head.y)) {
                dead = true
                
            } else if(lifeLeft <= 0 && !humanPlaying) {
                dead = true
            }
            
        }
    }
    
    func show() {
        for (i, node) in bodyNodes.enumerated() {
            let pos = body[i]
            node.position = SCNVector3(Float(pos.x), Float(0.5), Float(pos.y))
        }
        headNode.position = SCNVector3(Float(head.x), Float(0.5), Float(head.y))
        updateHeadNode()
        updateTailNode()
    }
    
    fileprivate func updateHeadNode() {
        switch direction {
        case .right:
            headNode.eulerAngles.y = Float.pi / 2
        case .left:
            headNode.eulerAngles.y = -Float.pi / 2
        case .down:
            headNode.eulerAngles.y = 0
        case .up:
            headNode.eulerAngles.y = -Float.pi
        }
    }
    
    fileprivate func updateTailNode() {
        if let tailNode = bodyNodes.last, let tailPos = body.last {
            let beforeTailPos = body[body.count - 2]
            let dV = PVector(beforeTailPos.x - tailPos.x, beforeTailPos.y - tailPos.y)
            if dV.x == 1 {
                tailNode.eulerAngles.y = Float.pi / 2
            } else if dV.x == -1 {
                tailNode.eulerAngles.y = -Float.pi / 2
            }

            if dV.y == 1 {
                tailNode.eulerAngles.y = 0
            } else if dV.y == -1 {
                tailNode.eulerAngles.y = Float.pi
            }
        }
    }
    
    func eat() {
        if(!humanPlaying) {
            if(lifeLeft < 500) {
                if(lifeLeft > 400) {
                    lifeLeft = 500
                    
                } else {
                    lifeLeft += 100
                }
            }
        }
        
        
        // Configure tail node to last node

        
        let tailPos = body.popLast()
        let tailNode = bodyNodes.popLast()
        
        let len = body.count-1
        var pos: PVector
        var snakeNode: SnakeNode

        pos = PVector(body[len].x, body[len].y)
        body.append(pos)
        snakeNode = SnakeNode(pos: pos, color: self.color)
        addChildNode(snakeNode)
        bodyNodes.append(snakeNode)
        
        body.append(tailPos!)
        bodyNodes.append(tailNode!)
        
        
        food.removeFromParentNode()
        food = Food(size: sceneSize)
        addChildNode(food)


    }
    
    func wallCollide(x: Int32, y: Int32) -> Bool {
        let maxPos = Int(sceneSize / 2)
        return (abs(x) > maxPos || abs(y) > maxPos)
    }
    
    func foodCollide(x: Int32, y: Int32) -> Bool {
        if(x == food.pos.x && y == food.pos.y) {
          return true;
        }
        return false;
    }
    
    func bodyCollide(x: Int32, y: Int32) -> Bool {
        for i in 0..<body.count {
            if(x == body[i].x && y == body[i].y) {
                return true
            }
        }
        return false;
    }
    
    
    func shiftBody() {
        var cx: Int32 = head.x
        var cy: Int32 = head.y
        head.x += xVel;
        head.y += yVel;
        if(snakeMoved) {
            var nx: Int32
            var ny: Int32
            for i in 0..<body.count {
                nx = body[i].x
                ny = body[i].y
                body[i].x = cx;
                body[i].y = cy;
                cx = nx
                cy = ny
            }
        }
    }
    
    func turnLeft() {
        let t = (direction.rawValue - 1 + 4) % 4
        direction = SnakeDirection(rawValue: t)!
        xVel = direction.asInt2.x
        yVel = direction.asInt2.y
        snakeMoved = true
    }
    
    func turnRight() {
        let t = (direction.rawValue + 1) % 4
        direction = SnakeDirection(rawValue: t)!
        xVel = direction.asInt2.x
        yVel = direction.asInt2.y
        snakeMoved = true
    }
    
    func runCrashAnimation() {
        if let headNode = self.headNode,
            let particle = SCNParticleSystem(named: "smoke-spread", inDirectory: nil) {
                headNode.addParticleSystem(particle)
        }
    }
    
    // MARK: - AI Method
    
    func look() {
        var temp: [Double] = lookInDirection(direction: PVector(-1, 0))
        vision[0] = temp[0]
        vision[1] = temp[1]
        vision[2] = temp[2]
        temp = lookInDirection(direction: PVector(-1,-1))
        vision[3] = temp[0]
        vision[4] = temp[1]
        vision[5] = temp[2]
        temp = lookInDirection(direction: PVector(0,-1))
        vision[6] = temp[0]
        vision[7] = temp[1]
        vision[8] = temp[2]
        temp = lookInDirection(direction: PVector(1,-1))
        vision[9] = temp[0]
        vision[10] = temp[1]
        vision[11] = temp[2]
        temp = lookInDirection(direction: PVector(1,0))
        vision[12] = temp[0]
        vision[13] = temp[1]
        vision[14] = temp[2]
        temp = lookInDirection(direction: PVector(1,1))
        vision[15] = temp[0]
        vision[16] = temp[1]
        vision[17] = temp[2]
        temp = lookInDirection(direction: PVector(0,1))
        vision[18] = temp[0]
        vision[19] = temp[1]
        vision[20] = temp[2]
        temp = lookInDirection(direction: PVector(-1,1))
        vision[21] = temp[0]
        vision[22] = temp[1]
        vision[23] = temp[2]
    }
    
    func lookInDirection(direction: PVector) -> [Double] {
        var look: [Double] = [Double](repeating: 0, count:3)
        var pos: PVector = PVector(head.x, head.y)
        var distance: Double = 0
        var foodFound: Bool = false;
        var bodyFound: Bool = false;
        pos.x += direction.x
        pos.y += direction.y
        distance += 1
        while(!wallCollide(x: pos.x, y: pos.y)) {
            if(!foodFound && foodCollide(x: pos.x, y: pos.y)) {
                foodFound = true
                look[0] = 1
            }
            if(!bodyFound && bodyCollide(x: pos.x, y: pos.y)) {
                bodyFound = true
                look[1] = 1
            }
            pos.x += direction.x
            pos.y += direction.y
            distance += 1
        }
        look[2] = 1/distance
        return look
    }
    
    func think() {
        decision = brain.output(inputsArr: vision)
        
        var maxIndex: Int = 0
        var max: Double = 0
        
        for i in 0..<decision.count {
            if(decision[i] > max) {
                max = decision[i]
                maxIndex = i
            }
        }
        
        switch maxIndex {
        case 0:
            moveUp()
        case 1:
            moveDown()
        case 2:
            moveLeft()
        case 3:
            moveRight()
        default:
            break
        }
    
    }

    
    //MARK: - Snake's move
    
    func moveUp() {
        if(direction != SnakeDirection.down) {
            direction = SnakeDirection.up
            xVel = direction.asInt2.x
            yVel = direction.asInt2.y
        }
    }
    
    func moveDown() {
        if(direction != SnakeDirection.up) {
            direction = SnakeDirection.down
            xVel = direction.asInt2.x
            yVel = direction.asInt2.y
        }
    }
    
    func moveLeft() {
        if(direction != SnakeDirection.right) {
            direction = SnakeDirection.left
            xVel = direction.asInt2.x
            yVel = direction.asInt2.y
        }
    }
    
    func moveRight() {
        if(direction != SnakeDirection.left) {
            direction = SnakeDirection.right
            xVel = direction.asInt2.x
            yVel = direction.asInt2.y
        }
    }
    
}
