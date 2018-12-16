//
//  Met.swift
//  Saiyan Man
//
//  Created by Kyle Jones on 12/21/17.
//  Copyright © 2017 AngelGenie. All rights reserved.
//

import Foundation
import SpriteKit

class Met: Enemy {
    
    var hideTexture = SKTexture()
    var metBuster = SKSpriteNode()
    
    var metMovingLeft = true
    var moveCounter: Double = 0
    var isClose = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(texture: SKTexture?, color: NSColor, size: CGSize) {
        print("New Met?")
        
        //Mandatory super.init()
        super.init(texture: texture, color: color, size: size)
        
        let textureAtlas = SKTextureAtlas(named: "Enemies")
        hideTexture = textureAtlas.textureNamed("met0.png")
        hideTexture.filteringMode = .nearest
        health = 2
        self.texture = hideTexture
        self.zPosition = 1
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 16), center: CGPoint(x: 0, y: -2))
        setDefaultPhysics_Collisions()
        name = "Met"
        
    }
    

    func moveMet(gokuPosition: CGPoint, metPosition: CGPoint ) {
        run(animateRunning(aPosition: gokuPosition), withKey:"moveMet")
    }
    
    func addBuster(aPosition: CGPoint) {
        //Create the default standing MM Sprite using SKTexture
        let busterTexture = SKTexture(image: #imageLiteral(resourceName: "enemyBuster.png"))
        busterTexture.filteringMode = .nearest
        let metBuster = SKSpriteNode(texture: busterTexture)
        
        metBuster.name = "metBuster"
        
        //SSG Buster Attributes
        var busterSpeed: TimeInterval        
        busterSpeed = 5

        
        
        //Set particle's physicsbody
        metBuster.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        metBuster.physicsBody?.categoryBitMask = Met.PhysicsCategory.weaponCategory
        metBuster.physicsBody?.collisionBitMask = GameScene.PhysicsCategory.playerCategory
        metBuster.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.playerCategory
        metBuster.physicsBody?.linearDamping = 0
        metBuster.physicsBody?.affectedByGravity = false
        metBuster.physicsBody?.isDynamic = false
        metBuster.physicsBody?.mass = 0.00001
        metBuster.zPosition = 1
        
        if (xScale >= 1) {
            metBuster.position = CGPoint(x: self.position.x, y: self.position.y)
            metBuster.run(SKAction.moveBy(x: -667, y: 0, duration: TimeInterval(busterSpeed)), completion: {print("metBuster gone...")})
            scene?.addChild(metBuster)
            
        } else {
            metBuster.position = CGPoint(x: self.position.x, y: self.position.y)
            metBuster.run(SKAction.moveBy(x: 667, y: 0, duration: TimeInterval(busterSpeed)), completion: {print("metBuster gone...")})
            scene?.addChild(metBuster)
            
        }
    }
    
    func animateRunning(aPosition: CGPoint) -> SKAction {
        var moveAction: SKAction
        print(xScale)
        if aPosition.x > position.x {
            
            xScale = -1
            moveAction = (SKAction.moveBy(x: 50, y:0, duration: 0.3))
        } else {
            xScale = 1
            moveAction = (SKAction.moveBy(x: -50, y:0, duration: 0.3))
        }
        
        
        let showMetAction = SKAction.animate(with: getSprites(nameOfSprite: "", folder: "Enemies", action: "met", theFrames: [0,1]), timePerFrame: 0.05)
        var walkingMetAction = SKAction.animate(with: getSprites(nameOfSprite: "", folder: "Enemies", action: "met", theFrames: [2,3]), timePerFrame: 0.1)
        walkingMetAction = SKAction.repeat(walkingMetAction, count: 2)
        
        let moveWalkAction = SKAction.group([moveAction, walkingMetAction])
        let hideMetAction = SKAction.animate(with: getSprites(nameOfSprite: "", folder: "Enemies", action: "met", theFrames: [1,0]), timePerFrame: 0.05)
        let wait = SKAction.wait(forDuration: 2)
        let metBuster = SKAction.run {self.addBuster(aPosition: CGPoint(x: self.position.x, y: self.position.y-15) )}
        
        let moveMetForever = SKAction.sequence([metBuster, showMetAction, moveWalkAction, hideMetAction, wait])

        
        return moveMetForever
    }
    
}


