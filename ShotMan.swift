//
//  ShotMan.swift
//  MegaManMAC
//
//  Created by Kyle Jones on 12/9/18.
//  Copyright © 2018 Kyle Mocca. All rights reserved.
//

import Foundation
import SpriteKit

class ShotMan: Enemy {
    
    var shotManBuster = SKSpriteNode()
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override init(texture: SKTexture?, color: NSColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        let textureAtlas = SKTextureAtlas(named: "Enemies")
        let shotmanTexture0 = textureAtlas.textureNamed("shotman0.png")
        shotmanTexture0.filteringMode = .nearest
        health = 7
        self.texture = shotmanTexture0
        self.zPosition = 1
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 20), center: CGPoint(x: 0, y: -2))
        setDefaultPhysics_Collisions()
        name = "ShotMan"
        
    }
    
    func shotman(gokuPosition: CGPoint) {
        run(animateShotMan(aPosition: gokuPosition), withKey:"shotman")
    }
    
    func animateShotMan(aPosition: CGPoint) -> SKAction {
        
        let pointGunUpAction = SKAction.animate(with: getSprites(nameOfSprite: "", folder: "Enemies", action: "shotman", theFrames: [0,1,0,1,2,3,2,3,4,5,4,5]), timePerFrame: 0.05)
        
        let pointGunDownAction = SKAction.animate(with: getSprites(nameOfSprite: "", folder: "Enemies", action: "shotman", theFrames: [5,4,5,4,3,2,3,2,1,0,1,0]), timePerFrame: 0.05)
        let wait = SKAction.wait(forDuration: 0.5)
        let shootSide = SKAction.run {
            self.addBuster(aPosition: CGPoint(x: self.position.x, y: self.position.y), direction: "side", vector: CGVector(dx: -15, dy: 35))
            self.addBuster(aPosition: CGPoint(x: self.position.x, y: self.position.y), direction: "side", vector: CGVector(dx: -25, dy: 25))
            
//            self.shotManBuster.physicsBody?.applyImpulse(CGVector(dx: -25, dy: 25))
//            self.shotManBuster.run(SKAction.wait(forDuration: 3))
            
        }
        
        let shootUp = SKAction.run {
            self.addBuster(aPosition: CGPoint(x: self.position.x, y: self.position.y+20), direction: "up", vector: CGVector(dx: -2, dy: 45))
            self.addBuster(aPosition: CGPoint(x: self.position.x, y: self.position.y+20), direction: "up", vector: CGVector(dx: 0, dy: 45))
            
//            self.shotManBuster.physicsBody?.applyImpulse(CGVector(dx: -2, dy: 40))
//            self.shotManBuster.run(SKAction.wait(forDuration: 3))
            
        }
        
        var shotManForever = SKAction.sequence([shootSide, wait, shootSide, wait, shootSide, wait, shootSide, wait, shootSide, wait, shootSide, wait, pointGunUpAction, shootUp, wait, shootUp, wait, shootUp, wait, shootUp, wait, shootUp, wait, shootUp, wait, pointGunDownAction])
        
        shotManForever = SKAction.repeatForever(shotManForever)
        
        self.shotManBuster.physicsBody?.applyAngularImpulse(360)

        
        return shotManForever
        
    }
    
    func addBuster(aPosition: CGPoint, direction: String, vector: CGVector) {
        //Create the default standing MM Sprite using SKTexture
        let busterTexture = SKTexture(image: #imageLiteral(resourceName: "enemyBuster.png"))
        busterTexture.filteringMode = .nearest
        let shotManBuster = SKSpriteNode(texture: busterTexture)
        
        shotManBuster.name = "shotManBuster"
        
        //Set particle's physicsbody
        shotManBuster.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        shotManBuster.physicsBody?.categoryBitMask = ShotMan.PhysicsCategory.weaponCategory
        shotManBuster.physicsBody?.collisionBitMask = 0
        shotManBuster.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.playerCategory
        shotManBuster.physicsBody?.linearDamping = 0
        shotManBuster.physicsBody?.restitution = 0
        shotManBuster.physicsBody?.affectedByGravity = true
        shotManBuster.physicsBody?.isDynamic = true
        shotManBuster.physicsBody?.mass = 0.1
        shotManBuster.zPosition = 1

        if (xScale >= 0.33) {
            shotManBuster.position = CGPoint(x: self.position.x-10, y: self.position.y)
//            self.shotManBuster = shotManBuster
            scene?.addChild(shotManBuster)
            shotManBuster.physicsBody?.applyImpulse(vector)
            shotManBuster.run(SKAction.wait(forDuration: 3))

        } else {
            shotManBuster.position = CGPoint(x: self.position.x+10, y: self.position.y)
//            self.shotManBuster = shotManBuster
            scene?.addChild(shotManBuster)
            shotManBuster.physicsBody?.applyImpulse(vector)
            shotManBuster.run(SKAction.wait(forDuration: 3))


        }
    }

}
