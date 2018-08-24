//
//  GameScene.swift
//  CashCatcher
//
//  Created by TONY on 24/08/2018.
//  Copyright © 2018 TONY COMPANY. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameTimer: Timer!
    var intervalForCash: Double = 8 {
        didSet {
            if intervalForCash < 2 {
                intervalForCash = 1
            }
        }
    }
    
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
            if score % 100 == 0 {
                intervalForCash -= 0.5
            }
        }
    }
    
    let playerCategory:UInt32 = 0x1 << 1
    let cashCategory:UInt32 = 0x1 << 0
    
    let motionManger = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    override func didMove(to view: SKView) {
        
        scoreLabel = SKLabelNode(text: "SCORE: 0")
        scoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 60)
        scoreLabel.fontName = "Times"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = UIColor.white
        score = 0
        self.addChild(scoreLabel)
        
        self.player = SKSpriteNode(imageNamed: "wallet.png")
        player.size.width = 60
        player.size.height = 50
        player.position = CGPoint(x: self.frame.size.width / 2, y: player.size.height / 2 + 10)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = cashCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addCash), userInfo: nil, repeats: true)
        
        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                 self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
    }
    
    @objc func addCash() {
        let cash = SKSpriteNode(imageNamed: "cash.png")
        cash.size.width = 40
        cash.size.height = 40
        
        let randomPosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(self.frame.size.width))
        let position = CGFloat(randomPosition.nextInt())
        
        cash.position = CGPoint(x: position, y: self.frame.size.height)
        
        cash.physicsBody = SKPhysicsBody(rectangleOf: cash.size)
        cash.physicsBody?.isDynamic = true
        
        cash.physicsBody?.categoryBitMask = cashCategory
        cash.physicsBody?.contactTestBitMask = playerCategory
        player.physicsBody?.collisionBitMask = 0
        
        self.addChild(cash)
        
        let animationDuration:TimeInterval = TimeInterval(intervalForCash)
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -cash.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        cash.run(SKAction.sequence(actionArray))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody == player.physicsBody {
            catchCash(cashNode: secondBody.node as! SKSpriteNode)
        }
        if secondBody == player.physicsBody {
            catchCash(cashNode: firstBody.node as! SKSpriteNode)
        }
    }
    
    override func didSimulatePhysics() {
        
        player.position.x += xAcceleration * 20
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
    }
    
    func catchCash(cashNode:SKSpriteNode) {
        self.run(SKAction.playSoundFileNamed("CashRegister.wav", waitForCompletion: false))
     
        cashNode.removeFromParent()
     
        score += 10
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
