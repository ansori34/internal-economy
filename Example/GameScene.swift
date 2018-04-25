//
//  GameScene.swift
//  Example
//
//  Created by teknologi game on 29/03/18.
//  Copyright © 2018 PENS. All rights reserved.
//

import SpriteKit
import GameplayKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x * x + y * y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1
    static let Projectile: UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "slasher")
    var monstersDestroyed = 0
    let ammoText = SKLabelNode(fontNamed: "Chalkduster")
    var ammoCount = 20
    let hitText = SKLabelNode(fontNamed: "Chalkduster")
    var hitCount = 0
    let scoreText = SKLabelNode(fontNamed: "Chalkduster")
    var score = 0
    
    let buttonText = SKLabelNode(fontNamed: "Chalkduster")
    var button = SKSpriteNode(color: SKColor.red, size: CGSize(width: 170, height: 60))
    var aiScore = 0
    var aiAmmoSize = 100.0
    var playerAmmoSize = 20.0
    let ammoSizeText = SKLabelNode(fontNamed: "Chalkduster")
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        button.name = "upgrade"
        button.position = CGPoint(x: 120, y: 70)
        
        buttonText.name = "upgradeText"
        buttonText.text = "Upgrade Bedil"
        buttonText.fontSize = 18
        buttonText.fontColor = SKColor.white
        buttonText.horizontalAlignmentMode = .center
        buttonText.verticalAlignmentMode = .center
        
        button.addChild(buttonText)
        addChild(button)
        
        ammoSizeText.text = "Ammo Size = \(playerAmmoSize)"
        ammoSizeText.fontSize = 20
        ammoSizeText.fontColor = SKColor.black
        ammoSizeText.position = CGPoint(x: 700, y: size.height - 40)
        addChild(ammoSizeText)
        
        player.size.width *= 0.1
        player.size.height *= 0.1
        
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(player)
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 1.0)
            ])
        ))
        
        scoreText.text = "Score = \(score)"
        scoreText.fontSize = 20
        scoreText.fontColor = SKColor.black
        scoreText.position = CGPoint(x: 100, y: size.height - 40)
        addChild(scoreText)
        
        ammoText.text = "Ammo = \(ammoCount)"
        ammoText.fontSize = 20
        ammoText.fontColor = SKColor.black
        ammoText.position = CGPoint(x: 300, y: size.height - 40)
        addChild(ammoText)
        
        hitText.text = "Hit Count = \(hitCount)"
        hitText.fontSize = 20
        hitText.fontColor = SKColor.black
        hitText.position = CGPoint(x: 500, y: size.height - 40)
        addChild(hitText)
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster()
    {
        let monster = SKSpriteNode(imageNamed: "patrick")
        monster.size.width = size.width * 0.1
        monster.size.height = size.height * 0.1
        
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        addChild(monster)
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
//        let actionMoveDone = SKAction.removeFromParent()
        
//        let loseAction = SKAction.run() {
//            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//            let gameOverScene = GameOverScene(size: self.size, won: false)
//            self.view?.presentScene(gameOverScene, transition: reveal)
//        }
//
//        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
        monster.run(SKAction.sequence([actionMove]))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        let touchedNode = self.atPoint(touchLocation)
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        let offset = touchLocation - projectile.position
        
        if (offset.x < 0) { return }
        
        // If button touched
        if(touchedNode.name == "upgrade" || touchedNode.name == "upgradeText" && score >= 20 && aiAmmoSize > 0) {
            playerAmmoSize += 5.0
            aiAmmoSize -= 5.0
            score -= 20
            updateText()
            print("Bedil Upgraded")
            print("NPC Ammo Size Pool = \(aiAmmoSize)")
            print("Player Ammo Size = \(playerAmmoSize)")
        }
        
        if (ammoCount > 0 && touchedNode.name != "upgrade" && touchedNode.name != "upgradeText") {
            run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
            projectile.size.width = CGFloat(playerAmmoSize)
            projectile.size.height = CGFloat(playerAmmoSize)
            addChild(projectile)
            
            let direction = offset.normalized()
            
            let shootAmount = direction * 1000
            
            let realDest = shootAmount + projectile.position
            
            let actionMove = SKAction.move(to: realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
            
            // Decrease Count of Ammo
            ammoCount -= 1
        }
        
        updateText()
    }
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        hitCount += 1
        score += 5
        
        if (hitCount >= 3)
        {
            ammoCount += 5
            hitCount = 0
        }
        
        updateText()
        
        projectile.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed += 1
        if (monstersDestroyed >= 100) {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode, let
                projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
        
    }
    
    func updateText() {
        scoreText.text = "Score = \(score)"
        hitText.text = "Hit Count = \(hitCount)"
        ammoText.text = "Ammo = \(ammoCount)"
        ammoSizeText.text = "Ammo Size = \(playerAmmoSize)"
    }
}
