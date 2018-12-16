//
//  MegaMan.swift
//  Saiyan Man
//
//  Created by Kyle Jones on 12/11/17.
//  Copyright © 2017 AngelGenie. All rights reserved.
//

import SpriteKit
import GameplayKit

class MegaMan: SKSpriteNode {
    
    struct PhysicsCategory {
        static let weaponCategory: UInt32 = 0x1 << 2
    }
    
    var stateMachine: GKStateMachine!
    var health = 28
    
    var meter = SKSpriteNode()
    var meterTextures = [SKTexture]()
    
    var isShooting = false
    var isShootingChargeShot = false
    var isCharging = false
    var isSSG = false
    var isUI = false
    var isFalling = false
    var isTakingDamage = false
    var isCharged = false
    var rightPressed = false
    var leftPressed = false
    var jumpPressed = false
    var shootPressed = false
    
    var jumpForce: CGFloat = 0
    var shotTimer: Int = 0
    var jumpTimer: Int = 0
    var damageTimer: Int = 0
    var UITimer: Int = 0
    var runFrame: String = "0"
    var runTimer: TimeInterval = 60
    
    var runFrames = [SKTexture]()
    var runShootFrames = [SKTexture]()
    
    let UIAura = SKEmitterNode(fileNamed: "MegamanAura.sks")
    let UILight = SKLightNode()
    
    var standTexture = SKTexture(image: #imageLiteral(resourceName: "mmStanding0"))
    var standAndShootTexture = SKTexture(image: #imageLiteral(resourceName: "mmStandAndShoot1"))
    var jumpTexture = SKTexture(image: #imageLiteral(resourceName: "mmJumpAndShoot0"))
    var jumpAndShootTexture = SKTexture(image: #imageLiteral(resourceName: "mmJumpAndShoot1"))
    var blinkTexture = SKTexture(image: #imageLiteral(resourceName: "mmStanding1"))
    var runTexture0 = SKTexture(image: #imageLiteral(resourceName: "mmRunning0"))
    var runTexture1 = SKTexture(image: #imageLiteral(resourceName: "mmRunning1"))
    var runTexture2 = SKTexture(image: #imageLiteral(resourceName: "mmRunning2"))
    var runTexture3 = SKTexture(image: #imageLiteral(resourceName: "mmRunning1"))
    var runShootTexture0 = SKTexture(image: #imageLiteral(resourceName: "mmRunAndShoot0"))
    var runShootTexture1 = SKTexture(image: #imageLiteral(resourceName: "mmRunAndShoot1"))
    var runShootTexture2 = SKTexture(image: #imageLiteral(resourceName: "mmRunAndShoot2"))
    var runShootTexture3 = SKTexture(image: #imageLiteral(resourceName: "mmRunAndShoot1"))
    
    
//    var leanTexture = SKTexture(image: #imageLiteral(resourceName: "mmLean"))
    var damageTexture = SKTexture(image: #imageLiteral(resourceName: "mmHit"))

    var mmActions: ActionOptions = []
    
    
    struct ActionOptions: OptionSet {
        let rawValue: Int
        
        static let jumping    = ActionOptions(rawValue: 1 << 0)
        static let charging = ActionOptions(rawValue: 1 << 2)
        static let shooting   = ActionOptions(rawValue: 1 << 3)
        static let standing   = ActionOptions(rawValue: 1 << 4)
        static let transforming   = ActionOptions(rawValue: 1 << 6)
        static let faceLeft = ActionOptions(rawValue: 1 << 7)
        static let faceRight = ActionOptions(rawValue: 1 << 8)
        static let running = ActionOptions(rawValue: 1 << 9)
        static let takeDamage = ActionOptions(rawValue: 1 << 10)
        static let chargingLargeBuster = ActionOptions(rawValue: 1 << 11)
        
    }
    
    var weapons: WeaponOptions = []
    
    
    struct WeaponOptions: OptionSet {
        let rawValue: Int
        
        static let largeBuster    = WeaponOptions(rawValue: 1 << 0)
        
    }
    
    
    
    override init(texture: SKTexture?, color: NSColor, size: CGSize) {
        
        //Mandatory super.init()
        super.init(texture: texture, color: color, size: size)
        
        position = CGPoint(x: 125, y: 120)
        //Set the default size and position of the MM Sprite
        xScale = 0.33
        yScale = 0.33
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 21, height: 24), center: CGPoint(x: 0, y: -13))
//        physicsBody = SKPhysicsBody(texture: standTexture, size: CGSize(width: 24, height: 38))
//        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 18, height: 24))
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = true
        physicsBody?.isDynamic = true
        physicsBody?.restitution = 0
        physicsBody?.mass = 0.0
        physicsBody?.categoryBitMask = GameScene.PhysicsCategory.playerCategory
        physicsBody?.collisionBitMask = GameScene.PhysicsCategory.wallCategory
        physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.wallCategory
        physicsBody?.usesPreciseCollisionDetection = true
        
        name = "MM"
        
        
        //Create meter textures and add them in the array
        getMeterTextures()

        faceRight()

        //Start megaman in the jumping pose
        mmActions.insert(.jumping)

        //Init stateMachine to start enter states for megaman sprite
        stateMachine = MegaManStateMachine(player: self)

        //Set the default state for Megaman
        stateMachine.enter(MegaManJumping.self)
        
        print(xScale)
        print(yScale)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func enterDefaultState() {
        self.stateMachine.enter(Standing.self)
    }
    
    func stand() {
        mmActions.insert(.standing)
        if mmActions.contains(.shooting) {
            texture = standAndShootTexture
        } else {
            texture = standTexture
            animateStanding()
        }
 
    }
    
    func animateStanding() {
        
        let wait = SKAction.wait(forDuration: 1.5)
        let blinkAction = SKAction.animate(with: [standTexture, blinkTexture], timePerFrame: 0.1, resize: true, restore: false).reversed()
        let standAction = SKAction.repeatForever(SKAction.sequence([wait, blinkAction]))
        run(standAction, withKey: "Stand")
    }
    
    func faceLeft() {
        mmActions.remove(.faceRight)
        xScale = -0.33
        mmActions.insert(.faceLeft)
    }
    
    func faceRight() {
        mmActions.remove(.faceLeft)
        xScale = 0.33
        mmActions.insert(.faceRight)
    }
    
    func run0() -> SKAction {
        let run0: SKAction = SKAction.run {if self.mmActions.contains(.shooting) {self.texture = self.runShootTexture0} else {self.texture = self.runTexture0}}
        return run0
    }
    
    func run1() -> SKAction {
        let run1: SKAction = SKAction.run {if self.mmActions.contains(.shooting) {self.texture = self.runShootTexture1} else {self.texture = self.runTexture1}}
        return run1
    }
    
    func run2() -> SKAction {
        let run2: SKAction = SKAction.run {if self.mmActions.contains(.shooting) {self.texture = self.runShootTexture2} else {self.texture = self.runTexture2}}
        return run2
    }
    
    func run3() -> SKAction {
        let run3: SKAction = SKAction.run {if self.mmActions.contains(.shooting) {self.texture = self.runShootTexture1} else {self.texture = self.runTexture1}}
        return run3
    }
    
    func run() {
        
        var moveValue: CGFloat
        
        //Determine which direction MegaMan is facing and should start running towards
        if mmActions.contains(.faceRight) {
            moveValue = 8
        } else {
            
            moveValue = -8
        }

        mmActions.insert(.running)
        var move = SKAction.moveBy(x: moveValue, y: 0, duration: 0.1)
        move = SKAction.repeatForever(move)

        run(move, withKey: "Move")
        
    }
    
    func jump() {
        
        //Insert jumping action
        mmActions.insert(.jumping)
        
        if mmActions.contains(.shooting) {
            texture = jumpAndShootTexture
        } else {
            texture = jumpTexture
        }
        if isFalling {
            return
        }
        jumpPressed = true
        physicsBody?.affectedByGravity = false
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
        let jumpAction = SKAction.repeatForever(SKAction.moveBy(x: 0, y: 30, duration: 0.2))
        run(jumpAction, withKey: "Jumping")
        
        
    }
    
    func stopJump() {
        removeAction(forKey: "Jumping")
        physicsBody?.affectedByGravity = true
        jumpPressed = false
        jumpTimer = 0
    }
    
    func stopFloating() {
        physicsBody?.affectedByGravity = true
    }
    
    func Flash(){
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.05)
        let fadeIn = SKAction.fadeIn(withDuration: 0.05)
        
        let flashAction = SKAction.sequence([fadeOut, fadeIn])
        let flash = SKAction.repeat(flashAction, count: 1)
        
        run(flash, completion:{ self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.playerCategory})
    }
    
    func takeDamge() {
        
        var xForce = 0
        if xScale > 0 {
            xForce = -15
        } else {
            xForce = 15
        }
        
        physicsBody?.applyImpulse(CGVector(dx: xForce, dy: 0))
        
        let hitAction = SKAction.animate(with: getSprites(nameOfSprite: "", folder: "MMHit", action: "mmHit", theFrames: [1,1,2,1,1,2,1,1,1]), timePerFrame: 0.1, resize: true, restore: false)
        Flash()
        run(hitAction, withKey: "Damage")
        
    }
    
    func chargeUp() {
        
        let charge = SKAction.animate(with: getSprites(nameOfSprite: "", folder: "Goku", action: "gokuCharge", theFrames: [1,2,3,4,5,6]), timePerFrame: 0.1, resize: true, restore: false)
        var charged = SKAction.animate(with: getSprites(nameOfSprite: "", folder: "Goku", action: "gokuCharged", theFrames: [1,2,3,4,5,6,7,8]), timePerFrame: 0.1, resize: true, restore: false)
        charged = SKAction.repeatForever(charged)
        
        let chargedUP = SKAction.run {
            self.isCharged = true
        }
        
        let fadeOut = SKAction.fadeAlpha(to: 0.8, duration: 0.1)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.1)
        let fadeAction = SKAction.sequence([fadeOut, fadeIn])
        let group = SKAction.group([fadeAction])
        let fade = SKAction.repeatForever(group)
        
        let fadeCharged = SKAction.group([fade, charged])
        
        lightingBitMask = GameScene.PhysicsCategory.playerCategory
        shadowedBitMask = GameScene.PhysicsCategory.playerCategory
        
        let UILight = SKLightNode()
        UILight.name = "chargeLight"
        UILight.categoryBitMask = GameScene.PhysicsCategory.playerCategory
        UILight.lightColor = NSColor.white
        UILight.ambientColor = NSColor.white
        UILight.shadowColor = NSColor.white
        UILight.falloff = 0
        UILight.zPosition = -1
        
        let light1 = SKAction.run {UILight.lightColor = NSColor.white.withAlphaComponent(0.7)}
        let light2 = SKAction.run {UILight.lightColor = NSColor.white.withAlphaComponent(0.8)}
        let light3 = SKAction.run {UILight.lightColor = NSColor.white.withAlphaComponent(1)}
        let wait = SKAction.wait(forDuration: 0.1)
        
        let flashAction = SKAction.sequence([light1, wait, wait, light2, wait, wait, light3, wait, light2, wait, wait])
        let flash = SKAction.repeatForever(flashAction)
        
        
        let chargeShot = SKEmitterNode(fileNamed: "ChargeUp.sks")
        chargeShot?.name = "ChargeBeam"
        //        chargeShot?.targetNode = self.scene
        
        let moveRight = SKAction.move(by: CGVector(dx: 2, dy: 0) , duration: 0.1)
        let moveDown = SKAction.move(by: CGVector(dx: 0, dy: -2) , duration: 0.1)
        let moveLeft = SKAction.move(by: CGVector(dx: -2, dy: 0) , duration: 0.1)
        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 2) , duration: 0.1)
        var moveAround = SKAction.sequence([moveRight, moveDown, moveLeft, moveUp])
        moveAround = SKAction.repeatForever(moveAround)
        
        chargeShot?.position.x = (chargeShot?.position.x)! - 7
        chargeShot?.position.y = (chargeShot?.position.y)! - 1
        chargeShot?.run(moveAround)
        let chargeEffect = SKAction.run {
            self.scene?.addChild(chargeShot!)
        }
        
        UILight.run(flash)
        let lightEffect = SKAction.run {
            self.addChild(UILight)
        }
        run(SKAction.sequence([charge, chargeEffect, lightEffect, chargedUP, fadeCharged]), withKey: "Charging")
    }
    
    func fireChargeBeam() {
        print("Fire Charge Beam")
        removeAction(forKey: "Charging")
        let light = childNode(withName: "chargeLight") as! SKLightNode
        
//        texture = fireChargedTexture
        isShootingChargeShot = true
        //Charge Buster Attributes
        var largeBusterSpeed: TimeInterval
        largeBusterSpeed = 1
        
        let beam = scene?.childNode(withName: "ChargeBeam") as! SKEmitterNode
        beam.targetNode = self
        if (mmActions.contains(.faceRight)) {
            beam.position.x = position.x + 45
            beam.position.y = position.y + 5
        } else {
            beam.position.x = position.x - 45
            beam.position.y = position.y + 5
        }
        beam.targetNode = self.scene
        beam.particleBirthRate = 10000
        beam.particleSpeed = 20
        beam.particleLifetime = 3.5
        beam.particleScale = 0.5
        
        beam.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        beam.physicsBody?.categoryBitMask = PhysicsCategory.weaponCategory
        //        beam.physicsBody?.collisionBitMask = Met.PhysicsCategory.metCategory
        //        beam.physicsBody?.contactTestBitMask = Met.PhysicsCategory.metCategory
        beam.physicsBody?.linearDamping = 0
        beam.physicsBody?.affectedByGravity = false
        beam.setScale(1)
        beam.zPosition = 1
        
        if (mmActions.contains(.faceRight)) {
            beam.xScale = fabs(beam.xScale) * 1
            beam.run(SKAction.moveBy(x: 667, y: 0, duration: TimeInterval(largeBusterSpeed)), completion: {self.scene?.removeChildren(in: [beam]); self.removeChildren(in: [light])})
        } else if mmActions.contains(.faceLeft) {
            beam.xScale = fabs(beam.xScale) * -1
            beam.run(SKAction.moveBy(x: -667, y: 0, duration: TimeInterval(largeBusterSpeed)), completion: {self.scene?.removeChildren(in: [beam]); self.removeChildren(in: [light])})
        }
        isCharged = false
    }
    
    func removeChargeBeam() {
        let beam = scene?.childNode(withName: "ChargeBeam") as! SKEmitterNode
        let light = childNode(withName: "chargeLight") as! SKLightNode
        let removeWeapon = SKAction.run {
            self.scene?.removeChildren(in: [beam])
            self.removeChildren(in: [light])
        }
        let weaponAction = SKAction.sequence([SKAction.wait(forDuration: 0.5), removeWeapon])
        self.scene?.run(weaponAction)
    }
    
    func moveOffWall() {
//        print("MOVE OFF!")
//        var moveValue: CGFloat = 0
//        if mmActions.contains(.faceRight) {
//            moveValue = -1
//            
//        } else if mmActions.contains(.faceLeft) {
//            moveValue = 1
//            
//        }
//        run(SKAction.moveBy(x: moveValue, y:0, duration: 0.01))
//        physicsBody?.applyImpulse(CGVector(dx: moveValue, dy: 0))
    }
    
    func gokuTransformation() {
        
        //****Saiyan Man Frames, Actions and Animations
        let mmTransform = (SKAction.animate(with: getSprites(nameOfSprite: "gokuTransformation", folder: "Goku", action: ""), timePerFrame: 0.1, resize: true, restore: false))
    
        //Get standing action of ssg megaman, set the action to run forever, then transform and re-add the ssg mega man sprite
        run(mmTransform)
        
        
    }
    
    func getSprites(nameOfSprite: String, folder: String, action: String) -> [SKTexture] {
        
        let aTextureAtlas = SKTextureAtlas(named: folder)
        var aTextureArray = [SKTexture]()
        
        
        
        for i in 0...67 {
            let name = "\(nameOfSprite)\(action)\(i).png"
//            print(name)
            let t = aTextureAtlas.textureNamed(name)
            aTextureArray.append(t)
        }
        
        return aTextureArray
    }
    
    func getSprites(nameOfSprite: String, folder: String, action: String, theFrames: [Int]) -> [SKTexture] {
        
        let aTextureAtlas = SKTextureAtlas(named: folder)
        var aTextureArray = [SKTexture]()
        
        for i in 0...theFrames.count-1 {
            let name = "\(nameOfSprite)\(action)\(theFrames[i]).png"
            //                        print(name)
            let t = aTextureAtlas.textureNamed(name)
            aTextureArray.append(t)
        }
        
        return aTextureArray
    }
    
    func getSprite(folder: String, name: String, frameNum: Int) -> SKTexture {
        
        let aTextureAtlas = SKTextureAtlas(named: folder)
        var aTexture = SKTexture()
        aTexture = aTextureAtlas.textureNamed("\(name)\(frameNum)")
        
        return aTexture
    }
    
    func getMeterTextures() {
        let aTextureAtlas = SKTextureAtlas(named: "Meter")
        
        for i in 0...28 {
            let name = "meter\(i).png"
            meterTextures.append(aTextureAtlas.textureNamed(name))
        }
    }

}

/*
 switch runFrame {
 case "1":
 runFrame = "2"
 
 if isShooting {
 texture = runShootTexture2
 } else {
 texture = runTexture2
 }
 
 case "2":
 runFrame = "3"
 
 if isShooting {
 texture = runShootTexture3
 } else {
 texture = runTexture3
 }
 
 case "3":
 runFrame = "4"
 
 if isShooting {
 texture = runShootTexture4
 } else {
 texture = runTexture4
 }
 
 case "4":
 runFrame = "1"
 
 if isShooting {
 texture = runShootTexture1
 } else {
 texture = runTexture1
 }
 
 default:
 runFrame = "1"
 
 if isShooting {
 texture = runShootTexture1
 } else {
 texture = runTexture1
 }
 
 }
 */


