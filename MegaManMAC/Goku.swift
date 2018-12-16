//
//  MegaMan.swift
//  Saiyan Man
//
//  Created by Kyle Jones on 12/11/17.
//  Copyright © 2017 AngelGenie. All rights reserved.
//

import SpriteKit
import GameplayKit

extension SKSpriteNode {
    
    func addGlow(radius: Float = 50) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius":radius])
    }
}

class Goku: SKSpriteNode {
    
    struct PhysicsCategory {
        static let weaponCategory: UInt32 = 0x1 << 2
    }
    
    var stateMachine: GKStateMachine!
    var health = 28
    
    var meter = SKSpriteNode()
    var meterTextures = [SKTexture]()
    
    var barrier = SKNode()

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
    var currentContactPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    let UIAura = SKEmitterNode(fileNamed: "MegamanAura.sks")
    let UILight = SKLightNode()
    
    var standTexture = SKTexture(image: #imageLiteral(resourceName: "gokuStanding"))
    var standAndShootTexture = SKTexture(image: #imageLiteral(resourceName: "gokuStandingShooting"))
    var jumpTexture = SKTexture(image: #imageLiteral(resourceName: "gokuJumping"))
    var jumpAndShootTexture = SKTexture(image: #imageLiteral(resourceName: "gokuJumpingShooting"))
    var blinkTexture = SKTexture(image: #imageLiteral(resourceName: "gokuBlinking"))
    var dashTexture = SKTexture(image: #imageLiteral(resourceName: "gokuDashing"))
    var dashShootTexture = SKTexture(image: #imageLiteral(resourceName: "gokuDashingShooting"))
    var floatTexture = SKTexture(image: #imageLiteral(resourceName: "gokuFloating"))
    var floatAndShootTexture = SKTexture(image: #imageLiteral(resourceName: "gokuFloatingShooting"))
    var leanTexture = SKTexture(image: #imageLiteral(resourceName: "gokuLeaning"))
    var damageTexture = SKTexture(image: #imageLiteral(resourceName: "gokuHit1"))
    var charge1Texture = SKTexture(image: #imageLiteral(resourceName: "gokuCharge1"))
    var charge2Texture = SKTexture(image: #imageLiteral(resourceName: "gokuCharge2"))
    var charge3Texture = SKTexture(image: #imageLiteral(resourceName: "gokuCharge3"))
    var fireChargedTexture = SKTexture(image: #imageLiteral(resourceName: "gokuFireCharged"))
    
    
    
    var mmActions: ActionOptions = []
    
    
    struct ActionOptions: OptionSet {
        let rawValue: Int
        
        static let jumping    = ActionOptions(rawValue: 1 << 0)
        static let dashingAndShooting    = ActionOptions(rawValue: 1 << 1)
        static let charging = ActionOptions(rawValue: 1 << 2)
        static let shooting   = ActionOptions(rawValue: 1 << 3)
        static let standing   = ActionOptions(rawValue: 1 << 4)
        static let floating   = ActionOptions(rawValue: 1 << 5)
        static let transforming   = ActionOptions(rawValue: 1 << 6)
        static let faceLeft = ActionOptions(rawValue: 1 << 7)
        static let faceRight = ActionOptions(rawValue: 1 << 8)
        static let dashing = ActionOptions(rawValue: 1 << 9)
//        static let takeDamage = ActionOptions(rawValue: 1 << 10)
        static let chargingLargeBuster = ActionOptions(rawValue: 1 << 11)
        
        
        static let jumpingRight: ActionOptions = [.faceRight, .dashing, .jumping]
        static let jumpingLeft: ActionOptions = [.faceLeft, .dashing, .jumping]
    }
    
    var weapons: WeaponOptions = []
    
    
    struct WeaponOptions: OptionSet {
        let rawValue: Int
        
        static let largeBuster    = WeaponOptions(rawValue: 1 << 0)
        
    }
    
    
    
    override init(texture: SKTexture?, color: NSColor, size: CGSize) {
        
        //Mandatory super.init()
        super.init(texture: texture, color: color, size: size)
        
        position = CGPoint(x: 125, y: 150)
        //Set the default size and position of the MM Sprite
        xScale = 0.33
        yScale = 0.33
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 15, height: 23), center: CGPoint(x: 0, y: -13))
//        physicsBody = SKPhysicsBody(texture: standTexture, size: CGSize(width: 21*2, height: 24*2))
//        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 9, height: 24))
        physicsBody?.usesPreciseCollisionDetection = true
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = true
        physicsBody?.isDynamic = true
        physicsBody?.restitution = 0
        physicsBody?.mass = 0.1
        physicsBody?.categoryBitMask = GameScene.PhysicsCategory.playerCategory
        physicsBody?.collisionBitMask = GameScene.PhysicsCategory.wallCategory
        physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.wallCategory | GameScene.PhysicsCategory.enemyCategory
 
        name = "Goku"
        
        
        //Create meter textures and add them in the array
        getMeterTextures()
        
        faceRight()
        
        //Start megaman in the jumping pose
        mmActions.insert(.jumping)

        //Init stateMachine to start enter states for goku sprite
        stateMachine = GokuStateMachine(player: self)
        
        //Set the default state for Megaman
        stateMachine.enter(Jumping.self)
        
        
        //Always start MM facing right
        mmActions.insert(.faceRight)

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
        
        let wait = SKAction.wait(forDuration: 2)
        let blinkAction = SKAction.animate(with: [standTexture, blinkTexture], timePerFrame: 0.1, resize: false, restore: false).reversed()
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
    
    func dash() {
        
        var moveValue: CGFloat
        
        //Determine which direction MegaMan is facing and should start running towards
        if mmActions.contains(.faceRight) {
            moveValue = 13
        } else {
            
            moveValue = -13
        }
        
        if action(forKey: "Dash") != nil {
            return
        }
        mmActions.insert(.dashing)
        var dash = SKAction.moveBy(x: moveValue, y: 0, duration: 0.1)
        dash = SKAction.repeatForever(dash)
        if mmActions.contains(.shooting) && mmActions.contains(.jumping) {
            texture = jumpAndShootTexture
        } else if mmActions.contains(.shooting) {
            texture = dashShootTexture
        } else if mmActions.contains(.jumping) {
            texture = jumpTexture
        } else {
            texture = dashTexture
        }
        run(dash, withKey: "Dash")
        
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
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        let jumpAction = SKAction.repeatForever(SKAction.moveBy(x: 0, y: 15, duration: 0.1))
        run(jumpAction, withKey: "Jumping")
        
        
    }
    
    func stopJump() {
        removeAction(forKey: "Jumping")
        physicsBody?.affectedByGravity = true
        jumpPressed = false
        jumpTimer = 0
    }
    
    func float() {
        
        //If MegaMan is transforming, then do nothing #Wait
        if mmActions.contains(.transforming) {
            return
        }
        
        let moveValue: CGFloat = 20
        
        //Create the action that will move megaman up in the air
        let moveUp = (SKAction.moveBy(x: 0, y: moveValue, duration: 0.5))
        let hoverUp = SKAction.moveBy(x: 0, y: 5, duration: 0.5)
        let hoverDown = SKAction.moveBy(x: 0, y: -5, duration: 0.5)
        
        var hover = SKAction.sequence([hoverUp, hoverDown])
        hover = SKAction.repeatForever(hover)
        
        
        run(moveUp)
        run(hover, withKey:"Float")
        
        //Create Jumping animation
        if isSSG == false {
            texture = floatTexture
        } else {
            
        }
        physicsBody?.affectedByGravity = false
        
    }
    
    func stopFloating() {
        physicsBody?.affectedByGravity = true
    }
    
    func flash(){
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.05)
        let fadeIn = SKAction.fadeIn(withDuration: 0.05)
        
        let flashAction = SKAction.sequence([fadeOut, fadeIn])
        let flash = SKAction.repeat(flashAction, count: 15)
        
        run(flash, completion:{self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.playerCategory})
    }
    
    func takeDamge() {
        
        let hitAction = SKAction.animate(with: getSprites(nameOfSprite: "", folder: "GokuHit", action: "gokuHit", theFrames: [1,2,2,1,2,2,1,2,2]), timePerFrame: 0.1, resize: true, restore: true)
        
        flash()
        run(hitAction, withKey: "Damage")
        
        if mmActions.contains(.faceRight) {
            physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        } else {
            physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
            
        }
        run(SKAction.playSoundFileNamed("MM_Hurt.wav", waitForCompletion: false))
        
        
    }
    
    func chargeUp() {
        
        let charge = SKAction.animate(with: getSprites(nameOfSprite: "", folder: "Goku", action: "gokuCharge", theFrames: [1,2,3,4,5,6]), timePerFrame: 0.1)
        var charged = SKAction.animate(with: getSprites(nameOfSprite: "", folder: "Goku", action: "gokuCharged", theFrames: [1,2,3,4,5,6,7,8]), timePerFrame: 0.1)
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
        
        texture = fireChargedTexture
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
        print("MOVE OFF!")
        var moveValue: CGFloat = 0
        if mmActions.contains(.faceRight) {
            moveValue = -5
            
        } else if mmActions.contains(.faceLeft) {
            moveValue = 5

        }
        run(SKAction.moveBy(x: moveValue, y:0, duration: 0.01))
        physicsBody?.applyImpulse(CGVector(dx: moveValue, dy: 0))
    }
    
    func handleGokuBarrier(name: String) {
        switch name {
            
        case "ground":
            
            isFalling = false
            
            switch stateMachine.currentState {
            case is JumpingAndShooting:
                stateMachine.enter(StandingAndShooting.self)
                
            case is Jumping:
                stateMachine.enter(Standing.self)
                
            case is DashingAndJumping:
                stateMachine.enter(Dashing.self)
                
            case is DashingAndJumpingAndShooting:
                stateMachine.enter(DashingAndShooting.self)
                
            case is TakingDamage:
                print("wait")
            default:
                ()
            }
        case "roof":
            stopJump()
            //            switch self.goku.stateMachine.currentState {
            //            case is TakingDamage:
            //                print("wait")
            //            default:
            //                ()
            //
        //            }
        default:
            ()
        }
    }
    
    func getSprites(nameOfSprite: String, folder: String, action: String, theFrames: [Int]) -> [SKTexture] {
        
        let aTextureAtlas = SKTextureAtlas(named: folder)
        var aTextureArray = [SKTexture]()
        
        for i in 0...theFrames.count-1 {
            let name = "\(nameOfSprite)\(action)\(theFrames[i]).png"
            //                        print(name)
            aTextureArray.append(aTextureAtlas.textureNamed(name))
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



