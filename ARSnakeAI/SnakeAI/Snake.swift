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
            return PVector(x: 0, y: 1)
        case .right:
            return PVector(x: 1, y: 0)
        case .down:
            return PVector(x: 0, y: -1)
        case .left:
            return PVector(x: -1, y: 0)
        }
    }
}


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
    var sceneSize = 15
    
    var direction: SnakeDirection = .down
    
    var xVel: Int32 = 0
    var yVel: Int32 = 0
    
    var head: PVector!
    var body: [PVector]!
    
    var headNode: SnakeNode!
    var bodyNodes: [SnakeNode] = []
    
    var food: Food!
    
    public var dead: Bool = false
    
    // MARK: - Snake AI prpoerties
    
    var vision: [Double]!
    var decision: [Double]!
    
    var brain: NeuralNet!
    
    var hiddenNodes: Int = 16
    var hiddenLayers: Int = 2
    
    var lifeLeft = 50
    var lifeTime = 0

    
    override init() {
        super.init()
        head = PVector(0, 0)
        body = []
        vision = [Double](repeating: 0, count: 24)
        decision = [Double](repeating: 0, count: 4)
        brain = NeuralNet(input: 24, hidden: hiddenNodes, output: 4, hiddenLayers: hiddenLayers)
        food = Food(size: sceneSize)
        addChildNode(food)
        
        headNode = SnakeNode(pos: head)
        addChildNode(headNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func move() {
        if(!dead) {
            shiftBody()
            if(!humanPlaying) {
                lifeTime += 1
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

    }
    
    func eat() {
        let len = body.count-1
        var pos: PVector
        var snakeNode: SnakeNode
        if(len >= 0) {
            pos = PVector(body[len].x, body[len].y)
        } else {
            pos = PVector(head.x, head.y)
        }
        body.append(pos)
        snakeNode = SnakeNode(pos: pos)
        addChildNode(snakeNode)
        bodyNodes.append(snakeNode)
        
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
    
    func turnLeft() {
        let t = (direction.rawValue + 1) % 4
        direction = SnakeDirection(rawValue: t)!
        xVel = direction.asInt2.x
        yVel = direction.asInt2.y
    }
    
    func turnRight() {
        let t = (direction.rawValue - 1 + 4) % 4
        direction = SnakeDirection(rawValue: t)!
        xVel = direction.asInt2.x
        yVel = direction.asInt2.y
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
        
        func turnLeft() {
            let t = (direction.rawValue + 1) % 4
            direction = SnakeDirection(rawValue: t)!
            xVel = direction.asInt2.x
            yVel = direction.asInt2.y
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
        
//        let rand = Int.random(in: 0..<2)
//        switch rand {
//        case 0:
//            turnLeft()
//
//        case 1:
//            turnRight()
//
//        default:
//            break
//
//        }
    }
    
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
