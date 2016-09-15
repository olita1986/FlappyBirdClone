//
//  GameScene.swift
//  Flappy Bird
//
//  Created by orlando arzola on 13.09.16.
//  Copyright © 2016 orlando arzola. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum ColliderType: UInt32 {
        
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    var gameOver = false
    
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    var score = 0
    
    var hasStarted = false
    
    var gameOverLabel = SKLabelNode()
    
    var timer = Timer()
    
    
    func makePipes () {
        
        // Adding Gap
        
        let gapHeight = bird.size.height * 4
        
        // Adding random height for the pipes
        
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        
        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4
        
        // Adding movement to the pipes
        
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        
        // Adding a Pipe 1
        
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        
        pipe1 = SKSpriteNode(texture: pipeTexture)
        
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture.size().height / 2 + gapHeight / 2 + pipeOffset)
        
        pipe1.run(movePipes)
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1.size)
        
        pipe1.physicsBody!.isDynamic = false
        
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        
        pipe1.zPosition = -1
        
        self.addChild(pipe1)
        
        // Adding a Pipe 2
        
        
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        
        pipe2 = SKSpriteNode(texture: pipeTexture2)
        
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipeTexture.size().height / 2 - gapHeight / 2 + pipeOffset)
        
        pipe2.run(movePipes)
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2.size)
        
        pipe2.physicsBody!.isDynamic = false
        
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        
        pipe2.zPosition = -1
        
        self.addChild(pipe2)
        
        let gap = SKNode()
        
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))
        
        gap.physicsBody!.isDynamic = false
        
        gap.run(movePipes)
        
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        
        self.addChild(gap)
        
        
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        setupGame()
        
    }
    
    func setupGame () {
        
        
        
        // Adding background
        
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        let animation2 = SKAction.move(by: CGVector(dx: -bgTexture.size().width , dy:0), duration: 7)
        let shiftAnimationBG = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        
        let moveBackground = SKAction.repeatForever(SKAction.sequence([animation2, shiftAnimationBG]))
        
        var i: CGFloat = 0
        
        while i < 3 {
            
            background = SKSpriteNode(texture: bgTexture)
            
            background.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            
            background.size.height = self.frame.height
            
            background.run(moveBackground)
            
            background.zPosition = -2
            
            self.addChild(background)
            
            i += 1
        }
        
        
        
        // Adding the bird
        
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        bird.run(makeBirdFlap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        
        bird.physicsBody!.isDynamic = false
        
        // Addin categories to the bird
        bird.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        
        
        self.addChild(bird)
        
        
        // Adding the ground
        
        let ground = SKNode()
        
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        
        ground.physicsBody?.isDynamic = false
        
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground)
        
        
        // Adding a Scoring Label
        
        scoreLabel.fontName = "Helvetica"
        
        scoreLabel.fontSize = 60
        
        scoreLabel.text = "0"
        
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        
        self.addChild(scoreLabel)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if !gameOver {
            
            
            
        
        
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue
        {
           
            
            score += 1
            
            scoreLabel.text = String(score)
            
        } else {
            
                // Adding a Game Over Label
                
                gameOverLabel.fontName = "Helvetica"
                
                gameOverLabel.fontSize = 40
                
                gameOverLabel.text = "Game Over! Tap to play again!"
                
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                
                self.addChild(gameOverLabel)
                
                self.speed = 0
                
                gameOver = true
            
                hasStarted = false
                
                timer.invalidate()
                
            }

        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        // Physics of the bird
        
        if !gameOver {
            
            if !hasStarted {
                // Adding Repeating Pipes
                
                timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.makePipes), userInfo: nil, repeats: true)
                
                hasStarted = true
                
            }
            
            
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 70))
            bird.physicsBody!.isDynamic = true
        } else {
            
            score = 0
            
            self.speed = 1
            
            gameOver = false
            
            self.removeAllChildren()
            
            setupGame()
            
            
        }
        
        
        
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
