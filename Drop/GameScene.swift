//
//  GameScene.swift
//  Drop
//
//  Created by HPro2 on 10/8/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            if score < 0 {
                score = 0
            }
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var balls = 0
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -4
        background.blendMode = .replace
        addChild(background)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))

        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x:  896, y: 0), isGood: false)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 984, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 75, y: 700)
        addChild(editLabel)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let objects = nodes(at: location)
            if objects.contains(editLabel) {
                editingMode = !editingMode
            } else {
                if editingMode {
                    let box = SKSpriteNode(color: randomColor(), size: CGSize(width:Int.random(in: 42...142), height: 16))
                    box.position = location
                    box.name = "box"
                    box.zRotation = CGFloat.random(in: 0...CGFloat.pi)
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody!.isDynamic = false
                    addChild(box)
                } else {
                    if location.y > 720.0 {
                        if balls < 5 {
                            let random = Int.random(in: 1...7)
                            var color = ""
                            switch random {
                            case 1:
                                color = "Blue"
                            case 2:
                                color = "Cyan"
                            case 3:
                                color = "Green"
                            case 4:
                                color = "Grey"
                            case 5:
                                color = "Purple"
                            case 6:
                                color = "Red"
                            case 7:
                                color = "Yellow"
                            default:
                                color = "Red"
                            }
                            let ball = SKSpriteNode(imageNamed: "ball\(color)")
                            ball.name = "ball"
                            ball.position = location
                            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                            ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                            ball.physicsBody!.restitution = 0.4
                            ball.zPosition = 1
                            addChild(ball)
                            balls += 1
                        }
                    }
                }
            }
            
        }
    }
    
    func makeBouncer (at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody!.isDynamic = false
        bouncer.zPosition = 2
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotGlow.position = position
        slotGlow.zPosition = 0
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody!.isDynamic = false
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 4)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "ball" {
            collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    
    func collisionBetween(ball: SKNode, object: SKNode?) {
        if object?.name == "good" {
            score += 1
            balls -= 1
            destroy(ball: ball, state: "good")
        } else if object?.name == "bad" {
            score -= 1
            destroy(ball: ball, state: "bad")
        } else if object?.name == "box" {
            destroy(box: object!)
        }
        
    }
    
    func destroy(ball: SKNode, state: String) {
        if state == "good" {
            if let spark = SKEmitterNode(fileNamed: "Spark") {
                spark.position = ball.position
                addChild(spark)
            }
        } else if state == "bad" {
            if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                fireParticles.position = ball.position
                addChild(fireParticles)
            }
        }
        ball.removeFromParent()
    }
    
    func destroy(box: SKNode) {
        box.removeFromParent()
    }
    
    func randomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
}
