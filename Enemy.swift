//
//  Enemy.swift
//  MegaManMAC
//
//  Created by Kyle Jones on 12/9/18.
//  Copyright © 2018 Kyle Mocca. All rights reserved.
//

import SpriteKit

class Enemy: SKSpriteNode {

struct PhysicsCategory {
    static let weaponCategory: UInt32 = 0x1 << 5
    
}
    
    var health: Int
    
    required init?(coder aDecoder: NSCoder) {
        health = 0
        super.init(coder: aDecoder)
    }
    
    override init(texture: SKTexture?, color: NSColor, size: CGSize) {
        //Mandatory super.init()
        health = 0
        super.init(texture: texture, color: color, size: size)
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 16), center: CGPoint(x: 0, y: 0))
        
        
        //Physics Categories
        setDefaultPhysics_Collisions()
    
    }
    
    func setDefaultPhysics_Collisions() { //GameScene.PhysicsCategory.playerCategory
        
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = true
        physicsBody?.isDynamic = true
        physicsBody?.restitution = 0
        
        physicsBody?.categoryBitMask = GameScene.PhysicsCategory.enemyCategory
        physicsBody?.collisionBitMask = Goku.PhysicsCategory.weaponCategory | GameScene.PhysicsCategory.wallCategory
        physicsBody?.contactTestBitMask = Goku.PhysicsCategory.weaponCategory | GameScene.PhysicsCategory.wallCategory
    }
    
    func getSprites(nameOfSprite: String, folder: String, action: String, theFrames: [Int]) -> [SKTexture] {
        
        let aTextureAtlas = SKTextureAtlas(named: folder)
        var aTextureArray = [SKTexture]()
        
        for i in 0...theFrames.count-1 {
            let name = "\(nameOfSprite)\(action)\(theFrames[i]).png"
            let temp = aTextureAtlas.textureNamed(name)
            temp.filteringMode = .nearest
            aTextureArray.append(temp)
        }
        
        return aTextureArray
    }
    
    func getSprite(folder: String, name: String, frameNum: Int) -> SKTexture {
        
        let aTextureAtlas = SKTextureAtlas(named: folder)
        var aTexture = SKTexture()
        aTexture = aTextureAtlas.textureNamed("\(name)\(frameNum)")
        aTexture.filteringMode = .nearest
        
        return aTexture
    }
    
    func Flash(){
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.05)
        let fadeIn = SKAction.fadeIn(withDuration: 0.05)
        
        let flashAction = SKAction.sequence([fadeOut, fadeIn])
        let flash = SKAction.repeat(flashAction, count: 1)
        
        run(flash)
    }
    
    func Explosion() {

        
        removeAllActions()
        let textureAtlas = SKTextureAtlas(named: "Misc")
        var explosionFrames = [SKTexture]()
        
        for i in 1...4 {
            let anExplosionFrame = textureAtlas.textureNamed("explosion\(i).png")
            anExplosionFrame.filteringMode = .nearest
            
            explosionFrames.append(anExplosionFrame)
        }
        
        let explosionAnimation = SKAction.animate(with: explosionFrames, timePerFrame: 0.06, resize: true, restore: false)
        let removeExplosion = SKAction.run {
            self.removeFromParent()
        }
        
        run(SKAction.sequence([explosionAnimation, removeExplosion]))
        
        
    }
    
}
