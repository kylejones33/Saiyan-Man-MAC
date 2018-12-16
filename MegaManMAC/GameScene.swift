//
//  GameScene.swift
//  MegaManMAC
//
//  Created by Kyle Mocca on 5/10/18.
//  Copyright © 2018 Kyle Mocca. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVKit



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var goku = Goku()
    var megaman = MegaMan()
    var met = Met()
    var mets = [Met]()
    var shotMen = [ShotMan]()
    var metPositions = [CGPoint]()
    var shotManPositions = [CGPoint]()
    var shotman = ShotMan()
    
    var spriteCam: SKCameraNode?
    var gate = SKSpriteNode()
    var gate2 = SKSpriteNode()
    
    
    
    var line = SKShapeNode()
    var playerFrame = SKShapeNode()
    
    var isMegaMan = true
    var hasCamAction = false
    var inTransition = false
    var goLeft = true
    var goRight = true
    
    let inGate = false
    
    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()
    
    var openingMusic = SKAudioNode(fileNamed: "Flash Man Stage Music.mp3")
    
    private var SCALEVALUEX: CGFloat = 0.25
    private var SCALEVALUEY: CGFloat = 0.31
    private var MAX_MAP_X: CGFloat = 1824
    private var level: CGFloat = 1//-7
    private var camOffSet: CGFloat = 0
    
    var downKeys = Set<String>()
    
    
    struct PhysicsCategory {
        static let playerCategory: UInt32 = 0x1 << 1
        static let wallCategory: UInt32 = 0x1 << 3
        static let enemyCategory: UInt32 = 0x1 << 4
    }
    
    override func didMove(to view: SKView) {
        //Create the Physics World
        physicsBody = SKPhysicsBody()
        physicsWorld.contactDelegate = self
        
//        met = Met(texture: met.hideTexture)
        
        //Set scene to transition mode
        inTransition = true
        
        //Create Physics Barriers/Bodies
        for child in children {
            if child.name == "barrier" || child.name == "gate" || child.name == "gate2" {
                addPhysicsBody(aBarrier: child as! SKSpriteNode)
            }
        }
        
        //Add all met positions
        metPositions.append(CGPoint(x: 1210, y: 111))
        metPositions.append(CGPoint(x: 1652, y: -358))
        metPositions.append(CGPoint(x: 1850, y: -1485))
        metPositions.append(CGPoint(x: 2560, y: -1485))
        
        //Add all met positions
        shotManPositions.append(CGPoint(x: 640, y: 47))
        shotManPositions.append(CGPoint(x: 925, y: 95))
        shotManPositions.append(CGPoint(x: 1005, y: 95)) //FACE OTHER WAY
        shotManPositions.append(CGPoint(x: 1057, y: 192))
        shotManPositions.append(CGPoint(x: 1605, y: 95)) //FACE OTHER WAY
        
        createPhysicsBarrier(type: "death", pointA: CGPoint(x: 380, y: 0), pointB: CGPoint(x: 1025, y: 0))
        createPhysicsBarrier(type: "death", pointA: CGPoint(x: 1405, y: 0), pointB: CGPoint(x: 1630, y: 0))
        createBossGates()
        initCamera()
        transtion()
        //        addPlayers()
        
        //Testing collisions
        //        playerFrame = SKShapeNode()
        
    }
    
    func createBossGates() {
        gate = (self.childNode(withName: "//gateSprite") as? SKSpriteNode)!
        gate2 = (self.childNode(withName: "//gateSprite2") as? SKSpriteNode)!
        
        let textureAtlas = SKTextureAtlas(named: "Background")
        let gate1Texture = textureAtlas.textureNamed("BG1.png")
        let gate2Texture = textureAtlas.textureNamed("BG1.png")
        
        gate1Texture.filteringMode = .nearest
        gate2Texture.filteringMode = .nearest
        gate.texture = gate1Texture
        gate2.texture = gate2Texture
    }
    
    func transtion() {
        //Start playing music for this level
        openingMusic.run(SKAction.changeVolume(to: 0.5, duration: 0.01))
        addChild(openingMusic)
        
        //Create the "Ready" label and add it to the scene
        let ready = SKLabelNode(text: "READY")
        ready.fontSize = 8
        ready.fontName = "MegaMan 2"
        ready.position = CGPoint(x: 120, y: 130)
        addChild(ready)
        
        //Flash the "Ready" label for a few seconds
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        let flashAction = SKAction.sequence([fadeIn, fadeOut])
        let flash = SKAction.repeat(flashAction, count: 10)
        
        //Run the flash action on the "Ready" level, then add Goku to the scene
        ready.run(flash, completion: addPlayers)
        inTransition = false
    }
    
    func addPlayers () {
        setGoku()
//        setMegaMan()
        addEnemies()
        
//        self.camera?.physicsBody = SKPhysicsBody(circleOfRadius: 2)
//        self.camera?.run(SKAction.applyImpulse(CGVector(dx: 5, dy: 2), duration: 1))
        
    }
    
    func addGoku() {
        
        goku = Goku(texture: goku.jumpTexture)
        goku.meter = SKSpriteNode(texture: goku.meterTextures[goku.health])
        goku.meter.setScale(3.5)
        goku.meter.zPosition = 2
        goku.meter.position = CGPoint(x: -450, y: 150)
        self.camera?.addChild(goku.meter)
        //        addChild(goku)
        
        //Set variable to self and add to Scene
        //        addChild(goku)
        
    }
    
    func addMegaMan() {
        megaman = MegaMan(texture: megaman.jumpTexture)
        megaman.meter = SKSpriteNode(texture: megaman.meterTextures[megaman.health])
        megaman.meter.setScale(3.5)
        megaman.meter.zPosition = 2
        megaman.meter.position = CGPoint(x: -450, y: 150)
        self.camera?.addChild(megaman.meter)
        
        //Set variable to self and add to Scene
        addChild(megaman)
        
    }
    
    func addEnemies() {
        
        for i in 0...metPositions.count - 1 {
            met = Met(texture: met.texture)
            met.position = metPositions[i]
            met.moveMet(gokuPosition: megaman.position, metPosition: met.position)
            met.action(forKey: "moveMet")?.speed = 0
            mets.append(met)
            addChild(met)
        }
        
        for i in 0...shotManPositions.count - 1 {
            shotman = ShotMan(texture: shotman.texture)
            shotman.position = shotManPositions[i]
            shotman.shotman(gokuPosition: megaman.position)
            shotMen.append(shotman)
            addChild(shotman)
        }

    }
    
    func addPhysicsBody(aBarrier: SKSpriteNode) {
        
        //        let barrier = SKSpriteNode()
        //        barrier.lineWidth = 1
        
        
        //        barrier.physicsBody = SKPhysicsBody(edgeLoopFrom: aBarrier.frame)
        aBarrier.physicsBody?.restitution = 0
        aBarrier.physicsBody?.isDynamic = false
        aBarrier.physicsBody?.categoryBitMask = PhysicsCategory.wallCategory
        aBarrier.physicsBody?.collisionBitMask = PhysicsCategory.playerCategory | PhysicsCategory.enemyCategory
        aBarrier.physicsBody?.contactTestBitMask = PhysicsCategory.playerCategory | PhysicsCategory.enemyCategory
        aBarrier.alpha = 0.0
        //        addChild(barrier)
    }
    
    func addPhysicsBody(map: SKTileMapNode) {
        
        print("Create a map...")
        
        let xOffSet: CGFloat = 1040
        let yOffSet: CGFloat = 130
        
        let startingLocation: CGPoint = map.position
        let tileSize = map.tileSize
        
        let halfWidth = CGFloat(map.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(map.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<map.numberOfColumns {
            for row in 0..<map.numberOfRows {
                if let tileDef = map.tileDefinition(atColumn: col, row: row) {
                    
                    
                    let tileArray = tileDef.textures
                    let tileTexture = tileArray[0]
                    
                    let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width/2)
                    let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height/2)
                    
                    let newNode = SKSpriteNode(texture: tileTexture)
                    newNode.position = CGPoint(x: x, y: y)
                    
                    
                    if tileTexture.description.range(of: "cheese") != nil {
                        newNode.zPosition = -1
                        newNode.alpha = 0.6
                        //                        self.addChild(newNode)
                        newNode.position = CGPoint(x: newNode.position.x + startingLocation.x + xOffSet, y: newNode.position.y + startingLocation.y + yOffSet)
                        
                    } else if tileTexture.description.range(of: "gate") != nil {
                        newNode.name = "gate"
                        newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 16))
                        newNode.physicsBody?.linearDamping = 0
                        newNode.physicsBody?.restitution = 0
                        newNode.physicsBody?.isDynamic = false
                        newNode.physicsBody?.categoryBitMask = PhysicsCategory.wallCategory
                        newNode.physicsBody?.collisionBitMask = PhysicsCategory.playerCategory
                        newNode.physicsBody?.contactTestBitMask = PhysicsCategory.playerCategory
                        newNode.physicsBody?.affectedByGravity = false
                        newNode.physicsBody?.allowsRotation = false
                        newNode.physicsBody?.isDynamic = false
                        newNode.physicsBody?.friction = 1
                        self.addChild(newNode)
                        
                        newNode.position = CGPoint(x: newNode.position.x + startingLocation.x + xOffSet, y: newNode.position.y + startingLocation.y + yOffSet)
                        
                        /*
                         else if tileTexture.description.range(of: "Ground") != nil {
                         newNode.name = "barrier"
                         newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 16))
                         newNode.physicsBody?.linearDamping = 0
                         newNode.physicsBody?.restitution = 0
                         newNode.physicsBody?.isDynamic = false
                         newNode.physicsBody?.categoryBitMask = PhysicsCategory.wallCategory
                         newNode.physicsBody?.collisionBitMask = PhysicsCategory.playerCategory
                         newNode.physicsBody?.contactTestBitMask = PhysicsCategory.playerCategory
                         newNode.physicsBody?.affectedByGravity = false
                         newNode.physicsBody?.allowsRotation = false
                         newNode.physicsBody?.isDynamic = false
                         newNode.physicsBody?.friction = 1
                         self.addChild(newNode)
                         
                         
                         newNode.position = CGPoint(x: newNode.position.x + startingLocation.x + xOffSet, y: newNode.position.y + startingLocation.y + yOffSet)
                         
                         }
                         */
                        
                    }
                }
            }
        }
    }
    
    func createPhysicsBarrier(type: String, pointA: CGPoint, pointB: CGPoint) {
        //Create the physics barrier
        
        let barrier = SKShapeNode()
        barrier.lineWidth = 1
        let aPath = CGMutablePath()
        aPath.addLines(between: [pointA, pointB])
        
        barrier.physicsBody = SKPhysicsBody(edgeChainFrom: aPath)
        barrier.physicsBody?.restitution = 0
        barrier.physicsBody?.isDynamic = false
        barrier.physicsBody?.categoryBitMask = PhysicsCategory.wallCategory
        barrier.physicsBody?.collisionBitMask = PhysicsCategory.playerCategory | PhysicsCategory.enemyCategory
        barrier.physicsBody?.contactTestBitMask = PhysicsCategory.playerCategory | PhysicsCategory.enemyCategory
        barrier.name = type
        addChild(barrier)
        
    }
    
    func initCamera() {
        //        print(self.frame.minX)
        //        print(self.frame.minY)
        //        print(self.frame.midX)
        //        print(self.frame.midY)
        //        print(self.frame.maxX)
        //        print(self.frame.maxY)
        //        print(self.frame.midX*SCALEVALUE)
        //        print(self.frame.midY*SCALEVALUE)
        spriteCam = SKCameraNode()
        spriteCam?.position = CGPoint(x: self.frame.midX*SCALEVALUEX , y: self.frame.midY*SCALEVALUEY)
        spriteCam?.xScale = SCALEVALUEX
        spriteCam?.yScale = SCALEVALUEY
        addChild(spriteCam!)
        camera = spriteCam
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
        
    }
    
    override func keyDown(with event: NSEvent) {
        //If goku sprite is taking damage, then do nothing
        if  goku.isTakingDamage || megaman.isTakingDamage || hasCamAction || goku.mmActions.contains(.transforming) {
            return
        }
        
        switch event.keyCode {
        case 35: //Press the 'showPhysics' button
            togglePhysics()
        case 38: //Press 'j' (Shoot Buster)
            
            if isMegaMan {
                if megaman.mmActions.contains(.shooting) {
                    megaman.shotTimer = 0
                }
                megamanShoot()
            } else {
                if goku.mmActions.contains(.shooting) {
                    goku.shotTimer = 0
                }
                gokuShoot()
            }
            
        case 11: //Press 'B'(Test Audio)
            openingMusic.run(SKAction.pause())
            do {
                try play(name: "Final Death", type: "mp3")
            }catch {
                print("Error")
            }
//            pitchControl.pitch -= 50
            
        case 16: //Large Buster
            gokuLargeBuster()
            
        case 0: //Press 'A' (Go Left)
            if goLeft == false {
                print("couldn't go left")
                return
            }
            if isMegaMan {
                keyDownMegaManLeftDashingState()
            } else {
                keyDownGokuLeftDashingState()
            }
            
        case 2: //Press 'D' (Go Right)
            if goRight == false {
                print("couldn't go right")
                return
            }
            if isMegaMan {
                keyDownMegaManRightDashingState()
            } else {
                keyDownGokuRightDashingState()
            }
        case 40: //Press 'K' (Jump)
            if downKeys.contains("k") {
                return
            }
            
            if isMegaMan {
                enterMegaManJumpState()
            } else {
                enterGokuJumpState()
            }
            
        case 37: //ULTRA INSTINCT
            if !isMegaMan {
                print("here press L")
                gokuUI()
            }
        case 8:
            if isMegaMan {
                goku.mmActions.insert(.transforming)
                let action = SKAction.animate(with: megaman.getSprites(nameOfSprite: "gokuTransformation", folder: "Goku", action: ""), timePerFrame: 0.1, resize: true, restore: false)
                megaman.run(action, completion: {self.setGoku()})
                
            } else {
                setMegaMan()
            }
        default:
            print(event.keyCode)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 38: //Shoot buster released
            
            if goku.mmActions.contains(.chargingLargeBuster) {
                fireLargeBuster()
                updateGokuShootingTexture()
                goku.mmActions.remove(.chargingLargeBuster)
            }
            downKeys.remove("j")
            
        case 0: //Left button released
            downKeys.remove("a")
            if isMegaMan {
                keyUpMegaManLeftDashingState()
            } else {
                keyUpGokuLeftDashingState()
            }
            
        case 2: //Right button released
            downKeys.remove("d")
            if isMegaMan {
                keyUpMegaManRightDashingState()
            } else {
                keyUpGokuRightDashingState()
            }
        case 40: //Jump button released
            downKeys.remove("k")
            if isMegaMan {
                megaman.stopJump()
            } else {
                goku.stopJump()
            }
            
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    func setGoku() {
        goku = Goku(texture: goku.jumpTexture)
        goku.position = CGPoint(x: megaman.position.x, y: megaman.position.y)//CGPoint(x: 2560, y: -1560)CGPoint(x: megaman.position.x, y: megaman.position.y)
        goku.zPosition = 1
        goku.meter = SKSpriteNode(texture: goku.meterTextures[goku.health])
        goku.meter.setScale(3.5)
        goku.meter.zPosition = 0
        goku.meter.position = CGPoint(x: -400, y: 200)
        self.camera?.removeAllChildren()
        self.camera?.addChild(goku.meter)
        removeChildren(in: [megaman])
        addChild(goku)
        isMegaMan = false
        goku.mmActions.remove(.transforming)
    }
    
    func setMegaMan() {
        megaman = MegaMan(texture: megaman.jumpTexture)
        megaman.position = CGPoint(x: goku.position.x, y: goku.position.y)
        megaman.meter = SKSpriteNode(texture: megaman.meterTextures[megaman.health])
        megaman.meter.setScale(3.5)
        megaman.meter.zPosition = 2
        megaman.meter.position = CGPoint(x: -400, y: 200)
        self.camera?.removeAllChildren()
        self.camera?.addChild(megaman.meter)
        removeChildren(in: [goku])
        addChild(megaman)
        isMegaMan = true
    }
    
    func gokuShoot() {
        if downKeys.contains("j") || goku.mmActions.contains(.charging) || self.childNode(withName: "LargeBuster") != nil {
            return
        }
        downKeys.insert("j")
        
        if goku.weapons.contains(.largeBuster) {
            addLargeBuster()
            goku.mmActions.insert(.chargingLargeBuster)
            updateGokuShootingBusterState()
            return
        } else {
            addGokuBuster()
        }
        
        //Determine which goku sprite state should be entered based on the currentstate after pressing 'j'
        updateGokuShootingBusterState()
    }
    
    func gokuLargeBuster() {
        if goku.mmActions.contains(.shooting) || goku.isTakingDamage || goku.stateMachine.currentState == goku.stateMachine.state(forClass: Charging.self){
            return
        }
        
        if goku.weapons.contains(.largeBuster) {
            goku.weapons.remove(.largeBuster)
        } else {
            goku.weapons.insert(.largeBuster)
        }
    }
    
    func megamanShoot() {
        if downKeys.contains("j") || megaman.mmActions.contains(.charging) {
            return
        }
        downKeys.insert("j")
        
        if megaman.weapons.contains(.largeBuster) {
            addLargeBuster()
            updateMegaManShootingBusterState()
            return
        } else {
            addMegaBuster()
            
        }
        
        updateMegaManShootingBusterState()
    }
    
    func drawLine(from: CGPoint, to: CGPoint){
        line.removeFromParent()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: from.x, y: to.y))
        path.addLine(to: CGPoint(x: to.x, y: to.y))
        line = SKShapeNode(path: path)
        line.strokeColor = .red
        self.addChild(line)
    }
    
    func drawLine(fromBarrierMaxY: SKNode, toYContact: CGPoint, playerMinY: CGFloat) {
        
        
        
        line.removeFromParent()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: toYContact.x, y: fromBarrierMaxY.frame.maxY))
        path.addLine(to: CGPoint(x: toYContact.x, y: playerMinY))
        line = SKShapeNode(path: path)
        line.strokeColor = .red
        line.zPosition = 1
        self.addChild(line)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if isMegaMan {
            megaman.stateMachine.update(deltaTime: currentTime)
            updateMegaMan()
            updateMegaManJump()
            updateMegaManTimes()
            updateMegaManCamera()
        } else {
            goku.stateMachine.update(deltaTime: currentTime)
            updateGoku()
            updateGokuJump()
            updateGokuTimes()
            updateGokuCamera()
        }
        
        updateMet()
        updateShotMan()
        
    }
    
    func updateMegaManCamera() {
        
        //        upperFloor: if megaman.position.y < 384 {
        //            if level == 0 {
        //                break upperFloor
        //            } else {
        //                print("Switch Floors")
        //                moveCamBetweenFloors(camYValue: -384)
        //                level = 0
        //            }
        //        } else if megaman.position.y < 700 && megaman.position.y >= 384 {
        //            if level == 1 {
        //                break upperFloor
        //            } else {
        //                print("Switch Floors")
        //                moveCamBetweenFloors(camYValue: 384)
        //                level = 1
        //            }
        //        }
        //
        //        if hasCamAction == true {
        //            return
        //        }
        
        if megaman.position.x >= self.frame.midX*SCALEVALUEX && megaman.position.x <= MAX_MAP_X-(self.frame.midX*SCALEVALUEY) {
            spriteCam?.position.x = megaman.position.x
        }
        
    }
    
    func updateGokuCamera() {
        
        
//        if level == -7 && goku.position.x >= 1665 && goku.position.x <= 2688 {
//            spriteCam?.position.x = goku.position.x
//        }
//        spriteCam?.position.y = (-7*(240)) + 120
//
//        return
        
        Floors: switch true {

        case goku.position.y < 0 && goku.position.y >= -240:
            if level == -1 {
                break Floors
            } else {
                print("Switch Floors")
                moveCamBetweenFloors(camYValue: -240)
                level = -1
            }
        case goku.position.y < -1*(240) && goku.position.y >= -2*(240):
            if level == -2 {
                break Floors
            } else {
                print("Switch Floors")
                moveCamBetweenFloors(camYValue: -240)
                level = -2
            }
        case goku.position.y < -2*(240) && goku.position.y >= -3*(240):
            if level == -3 {
                break Floors
            } else {
                print("Switch Floors")
                moveCamBetweenFloors(camYValue: -240)
                level = -3
            }
        case goku.position.y < -3*(240) && goku.position.y >= -4*(240):
            if level == -4 {
                break Floors
            } else {
                print("Switch Floors")
                moveCamBetweenFloors(camYValue: -240)
                level = -4
            }
        case goku.position.y < -4*(240) && goku.position.y >= -5*(240):
            if level == -5 {
                break Floors
            } else {
                print("Switch Floors")
                moveCamBetweenFloors(camYValue: -240)
                level = -5
            }
        case goku.position.y < -5*(240) && goku.position.y >= -6*(240):
            if level < -5 {
                break Floors
            } else {
                print("Switch Floors to -6")
                moveCamBetweenFloors(camYValue: -240)
                level = -6
            }
        case goku.position.y < -6*(240) && goku.position.y >= -7*(240):
            if level == -7 {
                break Floors
            } else {
                print("Switch Floors to -7")
                moveCamBetweenFloors(camYValue: -240)
                level = -7
            }
        case goku.position.y < -7*(240) && goku.position.y >= -8*(240):
            if level == -8 {
                break Floors
            } else {
                print("Switch Floors to -8")
                moveCamBetweenFloors(camYValue: -240)
                level = -8
            }
        case goku.position.y < -8*(240) && goku.position.y >= -9*(240):
            if level == -9 {
                break Floors
            } else {
                print("Switch Floors")
                moveCamBetweenFloors(camYValue: -240)
                level = -9
            }
        case goku.position.y < -9*(240) && goku.position.y >= -10*(240):
            if level == -10 {
                break Floors
            } else {
                print("Switch Floors")
                moveCamBetweenFloors(camYValue: -240)
                level = -10
            }
        case goku.position.y < -10*(240) && goku.position.y >= -11*(240):
            if level == -11 {
                break Floors
            } else {
                print("Switch Floors")
                moveCamBetweenFloors(camYValue: -240)
                level = -12
            }
        default:
            break
        }

        if hasCamAction == true {
            return
        }

        if level == 1 && goku.position.x >= self.frame.midX*SCALEVALUEX && goku.position.x <= MAX_MAP_X-(self.frame.midX*SCALEVALUEY) {
            spriteCam?.position.x = goku.position.x
        } else if level == -7 && goku.position.x >= 1665 && goku.position.x <= 2688 {
            spriteCam?.position.x = goku.position.x
        }
        
    }
    
    func updateMegaManJump() {

        Jump: if !megaman.jumpPressed{
            break Jump
        } else if megaman.jumpPressed {
            megaman.jumpTimer = megaman.jumpTimer + 1
            if megaman.jumpTimer >= 15 {
                megaman.stopJump()
            }
        }
    }
    
    func updateGokuJump() {

        Jump: if !goku.jumpPressed{
            break Jump
        } else if goku.jumpPressed {
            goku.jumpTimer = goku.jumpTimer + 1
            if goku.jumpTimer >= 15 {
                goku.stopJump()
            }
        }
    }
    
    func updateMegaMan() {
  
        if !downKeys.contains("a") && !downKeys.contains("d") {
            if megaman.action(forKey: "Move") != nil {
                megaman.removeAction(forKey: "Move")
                megaman.mmActions.remove(.running)
            }
        }
        
        if megaman.physicsBody?.allContactedBodies().count == 0 {
            megaman.isFalling = true
            if megaman.stateMachine.currentState == megaman.stateMachine.state(forClass: MegaManRunning.self) {
                megaman.stateMachine.enter(MegaManJumping.self)
            } else if megaman.stateMachine.currentState == megaman.stateMachine.state(forClass: MegaManRunning.self) {
                megaman.stateMachine.enter(MegaManRunningAndJumping.self)
            } else if megaman.stateMachine.currentState == megaman.stateMachine.state(forClass: Standing.self) {
                megaman.stateMachine.enter(MegaManJumping.self)
            }
            
        }
    }
    
    func updateGoku() {
        
        if  goku.UILight.isHidden {
            
            if goku.mmActions.contains(.faceRight) && (goku.mmActions.contains(.dashing)) {
                goku.physicsBody?.applyImpulse(CGVector(dx: 3, dy: 0))
            } else if goku.mmActions.contains(.faceLeft) && (goku.mmActions.contains(.dashing)) {
                goku.physicsBody?.applyImpulse(CGVector(dx: -3, dy: 0))
                
            }
        } else {
            goku.physicsBody?.velocity.dx = 0
        }
        
        if  goku.isTakingDamage {
            if goku.mmActions.contains(.faceRight) {
                goku.physicsBody?.applyImpulse(CGVector(dx: -5, dy: 0))
            } else {
                goku.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 0))
                
            }
        }
        
        if !downKeys.contains("a") && !downKeys.contains("d") {
            if goku.action(forKey: "Dash") != nil {
                goku.removeAction(forKey: "Dash")
                goku.mmActions.remove(.dashing)
            }
        }
        
        if goku.physicsBody?.allContactedBodies().count == 0 {
            goku.isFalling = true
            if goku.stateMachine.currentState == goku.stateMachine.state(forClass: DashingAndShooting.self) {
                goku.stateMachine.enter(DashingAndJumpingAndShooting.self)
            } else if goku.stateMachine.currentState == goku.stateMachine.state(forClass: Dashing.self) {
                goku.stateMachine.enter(DashingAndJumping.self)
            }  else if goku.stateMachine.currentState == goku.stateMachine.state(forClass: Standing.self) {
                goku.stateMachine.enter(Jumping.self)
            }
            
        } else {
            
        }
        
    }
    
    func updateMet() {
        
        for node in children {
            if node.name == "metBuster" && !node.hasActions() {
                node.removeFromParent()
            }
        }
        
        if isMegaMan {
            for aMet in mets {
                if aMet.physicsBody?.isDynamic == false {
                    return
                }
                if fabs(self.megaman.position.x - aMet.position.x) < 100 {
                    if aMet.action(forKey: "moveMet") != nil {
                        aMet.action(forKey: "moveMet")?.speed = 1
                    } else {
                        aMet.moveMet(gokuPosition: self.megaman.position, metPosition: aMet.position)
                    }
                } else {
                    aMet.action(forKey: "moveMet")?.speed = 0
                }
                if aMet.action(forKey: "moveMet")?.speed == 0 {
                    aMet.removeAction(forKey: "moveMet")
                    aMet.texture = aMet.hideTexture
                }
            }
        } else {
            for aMet in mets {
                if fabs(self.goku.position.x - aMet.position.x) < 100 && fabs(self.goku.position.y - aMet.position.y) < 30 {
                    if aMet.action(forKey: "moveMet") != nil {
                        aMet.action(forKey: "moveMet")?.speed = 1
                    } else {
                        aMet.moveMet(gokuPosition: self.goku.position, metPosition: aMet.position)
                    }
                } else {
                    aMet.action(forKey: "moveMet")?.speed = 0
                }
                if aMet.action(forKey: "moveMet")?.speed == 0 {
                    aMet.removeAction(forKey: "moveMet")
                    aMet.texture = aMet.hideTexture
                }
            }
        }
        
        for node in self.children {
            if node.name == "metBuster" && !node.hasActions() {
                node.removeFromParent()
            }
        }
    }
    
    func updateShotMan() {
        for node in children {
            if node.name == "shotManBuster" && !node.hasActions() {
                node.removeFromParent()
            }
        }
        
        for aShotMan in shotMen {
            if fabs(self.goku.position.x - aShotMan.position.x) < 200 && fabs(self.goku.position.y - aShotMan.position.y) < 150 {
                if aShotMan.action(forKey: "shotman") != nil {
                    aShotMan.action(forKey: "shotman")?.speed = 1
                } else {
                    aShotMan.shotman(gokuPosition: goku.position)
                }
            } else {
                aShotMan.action(forKey: "shotman")?.speed = 0
            }
        }
    }
    
    func updateGokuTimes() {
        
        Shoot: if !goku.mmActions.contains(.shooting) {
            break Shoot
        } else if goku.mmActions.contains(.shooting) && goku.weapons.contains(.largeBuster) {
            return
        } else if goku.mmActions.contains(.shooting) {
            goku.shotTimer = goku.shotTimer + 1
            if goku.shotTimer >= 20 {
                updateGokuShootingTexture()
                goku.mmActions.remove(.shooting)
                goku.shotTimer = 0
            }
        }
        
        Damage: if goku.isTakingDamage == false {
            break Damage
        } else if goku.isTakingDamage == true {
            if goku.mmActions.contains(.jumping) {
                return
            }
            goku.damageTimer = goku.damageTimer + 1
            if goku.damageTimer >= 30 {
                goku.stateMachine.enter(Standing.self)
                goku.isTakingDamage = false
                goku.damageTimer = 0
            }
        }
        
        ChargeShot: if goku.isShootingChargeShot == false {
            break ChargeShot
        } else if goku.isShootingChargeShot == true {
            if goku.mmActions.contains(.jumping) {
                return
            }
            goku.shotTimer = goku.shotTimer + 1
            if goku.shotTimer >= 70 {
                goku.stateMachine.enter(Standing.self)
                goku.isShootingChargeShot = false
                goku.shotTimer = 0
            }
        }
        
        UI: if !goku.isUI {
            break UI
        } else if goku.isUI {
            if goku.texture == goku.standTexture {
                goku.texture = goku.standAndShootTexture
                goku.action(forKey: "Stand")?.speed = 0
            }
            goku.UITimer = goku.UITimer + 1
            if goku.UITimer >= 5 {
                goku.isUI = false
                stopUIMovement()
                goku.UITimer = 0
                if goku.texture == goku.standAndShootTexture {
                    goku.texture = goku.standTexture
                    goku.action(forKey: "Stand")?.speed = 1
                }
            }
        }
        
    }
    
    func updateMegaManTimes() {
        
        Shoot: if !megaman.mmActions.contains(.shooting) {
            break Shoot
        } else if megaman.mmActions.contains(.shooting) && megaman.weapons.contains(.largeBuster) {
            return
        } else if megaman.mmActions.contains(.shooting) {
            megaman.shotTimer = megaman.shotTimer + 1
            
            if megaman.shotTimer >= 20 {
                megaman.mmActions.remove(.shooting)
                megaman.shotTimer = 0
   
            }
        }
        
        Damage: if megaman.isTakingDamage == false {
            break Damage
        } else if megaman.isTakingDamage == true {
            if megaman.mmActions.contains(.jumping) {
                return
            }
            megaman.damageTimer = megaman.damageTimer + 1
            if megaman.damageTimer >= 30 {
                megaman.stateMachine.enter(MegaManStanding.self)
                megaman.isTakingDamage = false
                megaman.damageTimer = 0
            }
        }
        
        ChargeShot: if megaman.isShootingChargeShot == false {
            break ChargeShot
        } else if megaman.isShootingChargeShot == true {
            if megaman.mmActions.contains(.jumping) {
                return
            }
            megaman.shotTimer = megaman.shotTimer + 1
            if megaman.shotTimer >= 70 {
                megaman.stateMachine.enter(MegaManStanding.self)
                megaman.isShootingChargeShot = false
                megaman.shotTimer = 0
            }
        }
    }
    
    func updateGokuShootingBusterState() {
        switch goku.stateMachine.currentState {
        case is Standing:
            goku.stateMachine.enter(StandingAndShooting.self)
        case is Dashing:
            goku.stateMachine.enter(DashingAndShooting.self)
        case is Jumping:
            goku.stateMachine.enter(JumpingAndShooting.self)
        case is DashingAndJumping:
            goku.stateMachine.enter(DashingAndJumpingAndShooting.self)
        case is TakingDamage: return
        default:
            print("weird buster shooting state...")
        }
    }
    
    func updateMegaManShootingBusterState() {
        
        switch megaman.stateMachine.currentState {
        case is MegaManStanding, is MegaManRunning, is MegaManJumping, is MegaManRunningAndJumping:
            megaman.mmActions.insert(.shooting)
        case is MegaManTakingDamage: return
        default:
            print("weird buster shooting state...")
        }
    }
    
    func updateMegaManShootingTexture() {
        megaman.mmActions.remove(.shooting)
    }
    
    func updateGokuShootingTexture() {
        
        switch goku.stateMachine.currentState {
        case is JumpingAndShooting: goku.stateMachine.enter(Jumping.self)
        case is DashingAndShooting: goku.stateMachine.enter(Dashing.self)
        case is StandingAndShooting: goku.stateMachine.enter(Standing.self)
        case is DashingAndJumpingAndShooting: goku.stateMachine.enter(DashingAndJumping.self)
        case is FloatingAndShooting: goku.stateMachine.enter(Floating.self)
        case is Charging:
            self.goku.removeAction(forKey: "Charging")
            self.goku.stateMachine.enter(Standing.self)
            
        default:
            ()
        }
    }
    
    func addGokuBuster() {
        //Create the default standing MM Sprite using SKTexture
        let busterTexture = SKTexture(image: #imageLiteral(resourceName: "buster"))
        let buster = SKSpriteNode(texture: busterTexture)
        
        buster.setScale(0.33)
        buster.name = "Buster"
    
        //Buster Position
        var busterPositionX: CGFloat = 15
        var busterPositionY: CGFloat = -12
        
        if goku.mmActions.contains(.dashing) {
            busterPositionX = busterPositionX + 5
            busterPositionY = busterPositionY - 5
        }
        
        if goku.mmActions.contains(.jumping) {
            busterPositionY = busterPositionY + 5
        }
        
        //Buster Attributes
        var busterSpeed: TimeInterval
        busterSpeed = 1.5
        
        //Set particle's physicsbody
        buster.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        buster.physicsBody?.categoryBitMask = Goku.PhysicsCategory.weaponCategory
        buster.physicsBody?.collisionBitMask = PhysicsCategory.enemyCategory
        buster.physicsBody?.contactTestBitMask = PhysicsCategory.enemyCategory
        buster.physicsBody?.linearDamping = 0
        buster.physicsBody?.affectedByGravity = false
        buster.physicsBody?.mass = 0.00001
        buster.zPosition = 1
        
        run(SKAction.playSoundFileNamed("Buster1.wav", waitForCompletion: false))
        if (goku.xScale >= 0.33) {
            buster.position = CGPoint(x: goku.position.x + busterPositionX, y: goku.position.y + busterPositionY)
            buster.run(SKAction.moveBy(x: 300, y: 0, duration: TimeInterval(busterSpeed)), completion: {self.removeChildren(in: [buster])})
            addChild(buster)
            
        } else if goku.xScale <= -0.33 {
            buster.position = CGPoint(x: goku.position.x - busterPositionX, y: goku.position.y + busterPositionY)
            buster.run(SKAction.moveBy(x: -300, y: 0, duration: TimeInterval(busterSpeed)), completion: {self.removeChildren(in: [buster])})
            addChild(buster)
            
        }
    }
    
    func addMegaBuster() {
        //Create the default standing MM Sprite using SKTexture
        let busterTexture = SKTexture(image: #imageLiteral(resourceName: "buster"))
        let buster = SKSpriteNode(texture: busterTexture)
        buster.setScale(0.33)
        
        //Buster Position
        let busterPositionX: CGFloat = 21
        let busterPositionY: CGFloat = -12
        
        buster.name = "Buster"
        
        //SSG Buster Attributes
        var busterSpeed: TimeInterval
        
        
        busterSpeed = 3
        //        busterSize = 1.3
        
        //Set particle's physicsbody
        buster.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        buster.physicsBody?.categoryBitMask = MegaMan.PhysicsCategory.weaponCategory
        buster.physicsBody?.collisionBitMask = PhysicsCategory.enemyCategory
        buster.physicsBody?.contactTestBitMask = PhysicsCategory.enemyCategory
        buster.physicsBody?.linearDamping = 0
        buster.physicsBody?.affectedByGravity = false
        buster.physicsBody?.mass = 0.00001
        //        buster.setScale(busterSize)
        buster.zPosition = 1
        
        run(SKAction.playSoundFileNamed("Buster1.wav", waitForCompletion: false))
        if (megaman.xScale >= 0.33) {
            buster.position = CGPoint(x: megaman.position.x + busterPositionX, y: megaman.position.y + busterPositionY)
            buster.run(SKAction.moveBy(x: 667, y: 0, duration: TimeInterval(busterSpeed)), completion: {self.removeChildren(in: [buster])})
            addChild(buster)
            
        } else if megaman.xScale <= -0.33 {
            buster.position = CGPoint(x: megaman.position.x - busterPositionX, y: megaman.position.y + busterPositionY)
            buster.run(SKAction.moveBy(x: -667, y: 0, duration: TimeInterval(busterSpeed)), completion: {self.removeChildren(in: [buster])})
            addChild(buster)
            
        }
    }
    
    func addLargeBuster() {
        goku.mmActions.insert(.chargingLargeBuster)
        
        let largeBuster = SKEmitterNode(fileNamed: "ChargeBuster.sks")
        //                largeBuster?.targetNode = self.scene
        
        //Large Buster Position
        var largePositionX: CGFloat = 35
        var largePositionY: CGFloat = -10
        
        if goku.mmActions.contains(.dashing) {
            largePositionX = largePositionX + 10
            largePositionY = largePositionY - 0
        }
        
        largeBuster?.name = "LargeBuster"
        
        //SSG Buster Attributes
        var largeBusterSize: CGFloat
        
        //        chargeSpeed = 2
        largeBusterSize = 0.75
        
        //Set particle's physicsbody
        largeBuster?.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        largeBuster?.physicsBody?.categoryBitMask = Goku.PhysicsCategory.weaponCategory
        largeBuster?.physicsBody?.collisionBitMask = PhysicsCategory.enemyCategory
        largeBuster?.physicsBody?.contactTestBitMask = PhysicsCategory.enemyCategory
        largeBuster?.physicsBody?.linearDamping = 0
        largeBuster?.physicsBody?.affectedByGravity = false
        largeBuster?.setScale(largeBusterSize)
        largeBuster?.zPosition = 1
        
        if (goku.xScale >= 0.33) {
            largeBuster?.position = CGPoint(x: goku.position.x + largePositionX, y: goku.position.y + largePositionY)
            addChild(largeBuster!)
        } else if goku.xScale <= -0.33 {
            largeBuster?.position = CGPoint(x: goku.position.x - largePositionX, y: goku.position.y + largePositionY)
            addChild(largeBuster!)
        }
    }
    
    func fireLargeBuster() {
        //Charge Buster Attributes
        var largeBusterSpeed: TimeInterval
        largeBusterSpeed = 0.3
        
        if (goku.xScale >= 0.33) {
            self.childNode(withName: "LargeBuster")?.run(SKAction.moveBy(x: 250, y: 0, duration: TimeInterval(largeBusterSpeed)), completion: {self.removeChildren(in: [self.childNode(withName: "LargeBuster")!])})
        } else if goku.xScale <= -0.33 {
            self.childNode(withName: "LargeBuster")?.run(SKAction.moveBy(x: -250, y: 0, duration: TimeInterval(largeBusterSpeed)), completion: {self.removeChildren(in: [self.childNode(withName: "LargeBuster")!])})
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let first = contact.bodyA
        let second = contact.bodyB
        
        if first.node == nil || second.node == nil {
            return
        }
        
        
        //Contact between goku and ground
        if (first.node?.name == "Goku") && (second.categoryBitMask == PhysicsCategory.wallCategory) {
            
            collisionPlayerBarrier(player: first.node!, barrier: second.node!, contact: contact)
        } else if (second.node?.name == "Goku") && (first.categoryBitMask == PhysicsCategory.wallCategory) {
            
            collisionPlayerBarrier(player: second.node!, barrier: first.node!, contact: contact)
        }
        
        //Contact between MM and ground
        if (first.node?.name == "MM") && (second.categoryBitMask == PhysicsCategory.wallCategory) {
            first.node?.physicsBody?.velocity.dy = 0
            collisionPlayerBarrier(player: first.node!, barrier: second.node!, contact: contact)
        } else if (second.node?.name == "MM") && (first.categoryBitMask == PhysicsCategory.wallCategory) {
            collisionPlayerBarrier(player: second.node!, barrier: first.node!, contact: contact)
        }
        
        //Contact between enemy and barrier
        if (first.categoryBitMask == PhysicsCategory.enemyCategory) && (second.categoryBitMask == PhysicsCategory.wallCategory) {
            collisionEnemyBarrier(enemy: first.node!, barrier: second.node!)
        } else if (second.categoryBitMask == PhysicsCategory.enemyCategory) && (first.categoryBitMask == PhysicsCategory.wallCategory) {
            collisionEnemyBarrier(enemy: second.node!, barrier: first.node!)
        }
        
        //Contact between weapon and enemy
        if (first.categoryBitMask == Goku.PhysicsCategory.weaponCategory) && (second.categoryBitMask == PhysicsCategory.enemyCategory) {
            collisionEnemyBuster(weapon: first.node!, enemy: second.node!)
        } else if (second.categoryBitMask == Goku.PhysicsCategory.weaponCategory) && (first.categoryBitMask == PhysicsCategory.enemyCategory) {
            collisionEnemyBuster(weapon: second.node!, enemy: first.node!)
        }
        
        //Contact between enemy weapon and goku
        if (first.categoryBitMask == PhysicsCategory.playerCategory) && (second.categoryBitMask == Met.PhysicsCategory.weaponCategory) {
            if goku.children.contains(goku.UILight) {
                UIMovement()
                goku.isUI = true
            } else {
                collisionEnemyBusterAndPlayer(player: first.node!, enemyWeapon: second.node!)
                
            }
        } else if (second.categoryBitMask == PhysicsCategory.playerCategory) && (first.categoryBitMask == Met.PhysicsCategory.weaponCategory) {
            if goku.children.contains(goku.UILight) {
                UIMovement()
                goku.isUI = true
            } else {
                collisionEnemyBusterAndPlayer(player: second.node!, enemyWeapon: first.node!)
                
            }
        }
        
        //Contact between player and enemy
        if (first.categoryBitMask == PhysicsCategory.playerCategory) && (second.categoryBitMask == PhysicsCategory.enemyCategory) {
            if goku.children.contains(goku.UILight) {
                UIMovement()
                goku.isUI = true
            } else {
                collisionPlayerEnemy(player: first.node!, enemy: second.node!)
                
            }
        } else if (second.categoryBitMask == PhysicsCategory.playerCategory) && (first.categoryBitMask == PhysicsCategory.enemyCategory) {
            if goku.children.contains(goku.UILight) {
                UIMovement()
                goku.isUI = true
            } else {
                collisionPlayerEnemy(player: second.node!, enemy: first.node!)
                
            }
        }
    }
    
    func collisionPlayerBarrier(player: SKNode, barrier: SKNode, contact: SKPhysicsContact) {
        var collisionArea = ""
        goku.barrier = barrier
        
        if barrier.name == "death" {
            die()
        }
        
        if barrier.name == "gate" {
            barrier.removeFromParent()
            runGateOpenAnimation(aGate: barrier as! SKSpriteNode)
            
        } else if barrier.name == "gate2" {
            barrier.removeFromParent()
            runGateOpenAnimation(aGate: barrier as! SKSpriteNode)
        }
        
        
//        playerFrame.removeFromParent()
        playerFrame = SKShapeNode(rect: CGRect(x: player.position.x-10, y: player.position.y-25, width: 21, height: 24))

        
        if player.frame.minY - barrier.frame.maxY > -5 {
            playerFrame.strokeColor = .green
//            self.addChild(playerFrame)
            collisionArea = "ground"
            run(SKAction.playSoundFileNamed("MM_Land.wav", waitForCompletion: false))
        } else if (barrier.frame.minY - playerFrame.frame.maxY > -5) {
            playerFrame.strokeColor = .red
//            self.addChild(playerFrame)
            collisionArea = "roof"
        } else if (barrier.frame.minX - playerFrame.frame.maxX > -6 || playerFrame.frame.minX - barrier.frame.maxX > -6) {
            playerFrame.strokeColor = .yellow
//            self.addChild(playerFrame)
            goku.currentContactPoint = contact.contactPoint
            goku.barrier = barrier
            goku.barrier.name = "wall"
            
        }
        

        if isMegaMan {
            handleMegaManBarrier(name: collisionArea)
        } else {
            goku.handleGokuBarrier(name: collisionArea)
        }
        
        
    }
    
    func collisionEnemyBarrier(enemy: SKNode, barrier: SKNode) {
        
        if barrier.name == "death" {
            enemy.removeFromParent()
        }
    }
    
    func collisionEnemyBusterAndPlayer(player: SKNode, enemyWeapon: SKNode) {
        
        if player.name == "Goku" {
            goku.isTakingDamage = true
            goku.physicsBody?.categoryBitMask = 0
            if enemyWeapon.name == "metBuster" {
                if goku.health - 2 <= 0 {
                    goku.meter.texture = goku.meterTextures[0]
                    die()
                } else {
                    var xForce: CGFloat = 0
                    
                    if goku.mmActions.contains(.faceRight) {
                        xForce = -15
                        print(xForce)
                    } else {
                        xForce = 15
                        print(xForce)
                    }
                    player.physicsBody?.velocity.dx = 20
                    goku.health = goku.health - 2
                    goku.meter.texture = goku.meterTextures[goku.health]
                    
                }
            }
            goku.stateMachine.enter(TakingDamage.self)
        } else if player.name == "MM" {
            megaman.isTakingDamage = true
            megaman.physicsBody?.categoryBitMask = 0
            if enemyWeapon.name == "metBuster" {
                if megaman.health - 7 <= 0 {
                    megaman.meter.texture = megaman.meterTextures[0]
                    die()
                } else {
                    megaman.health = megaman.health - 7
                    megaman.meter.texture = megaman.meterTextures[megaman.health]
                    
                }
            }
            megaman.stateMachine.enter(MegaManTakingDamage.self)
        }
        
        
    }
    
    func collisionPlayerEnemy(player: SKNode, enemy: SKNode) {
        
        goku.isTakingDamage = true
        goku.physicsBody?.categoryBitMask = 0
        if enemy.name == "Met" {
            if goku.health - 2 <= 0 {
                goku.meter.texture = goku.meterTextures[0]
                die()
            } else {
                goku.health = goku.health - 2
                goku.meter.texture = goku.meterTextures[goku.health]
            }
        }
        goku.stateMachine.enter(TakingDamage.self)
        
    }
    
    func collisionEnemyBuster(weapon: SKNode, enemy: SKNode) {
        
        if enemy.name == "Met" {
            processMet(weapon: weapon, enemy: enemy as! Met)
        } else if enemy.name == "ShotMan" {
            processShotMan(weapon: weapon, enemy: enemy as! ShotMan)
        }
    }
    
    func processShotMan(weapon: SKNode, enemy: ShotMan) {
        
        if weapon.name == "Buster" {
            enemy.health = enemy.health - 1
            enemy.Flash()
            weapon.removeFromParent()
            run(SKAction.playSoundFileNamed("MM_Enemy_Hit.mp3", waitForCompletion: true))
            
            if enemy.health == 0 {
                kill(enemy: enemy, weaponType: "Buster")
            }
            
        } else if weapon.name == "LargeBuster" {
            weapon.removeFromParent()
            kill(enemy: enemy, weaponType: "LargeBuster")
            updateGokuShootingTexture()
            goku.mmActions.remove(.chargingLargeBuster)
        } else if weapon.name == "ChargeBeam" {
            goku.removeChargeBeam()
            kill(enemy: enemy, weaponType: "ChargeBeam")
        }
    }
    
    func processMet(weapon: SKNode, enemy: Met) {
        //Determine direction of the met
        var direction = ""
        if weapon.position.x < enemy.position.x {
            direction = "left"
        } else {
            direction = "right"
        }
        
        if enemy.texture?.description.range(of: "met0") == nil && weapon.name == "Buster" {
            enemy.health = enemy.health - 1
            if enemy.health > 1 {
                enemy.Flash()
            }
            weapon.removeFromParent()
            run(SKAction.playSoundFileNamed("MM_Enemy_Hit.mp3", waitForCompletion: true))
            
            if enemy.health == 0 {
                
//                enemy.physicsBody?.affectedByGravity = false
//                enemy.physicsBody?.isDynamic = false
                kill(enemy: enemy, weaponType: "Buster")
            }
            
        } else {
            if weapon.name == "Buster" {
                deflectBuster(buster: weapon, direction: direction)
                run(SKAction.playSoundFileNamed("Deflect_Buster.wav", waitForCompletion: false))
            } else if weapon.name == "LargeBuster" {
                weapon.removeFromParent()
                kill(enemy: enemy, weaponType: "LargeBuster")
                updateGokuShootingTexture()
                goku.mmActions.remove(.chargingLargeBuster)
            } else if weapon.name == "ChargeBeam" {
                goku.removeChargeBeam()
                kill(enemy: enemy, weaponType: "ChargeBeam")
            }
        }
    }
    
    func kill(enemy: SKSpriteNode, weaponType: String) {
        
        var waitTime: CGFloat = 0
        
        if weaponType == "Buster" {
            if enemy.name == "ShotMan" {
                shotMen = shotMen.filter {$0 != (enemy as! ShotMan)}
                (enemy as! ShotMan).Explosion()
                
            } else if enemy.name == "Met" {
                mets = mets.filter {$0 != (enemy as! Met)}
                (enemy as! Met).Explosion()
                
            }
            
        } else if weaponType == "LargeBuster" {
            waitTime = 2
            let add = SKAction.run {self.addEmitter(weaponType: weaponType, position: CGPoint(x: enemy.position.x, y: enemy.position.y + 20), waitTime: waitTime)}
            let remove = SKAction.run {enemy.removeFromParent()}
            self.run(SKAction.sequence([add, remove]))
        } else if weaponType == "ChargeBeam" {
            waitTime = 3
            let add = SKAction.run {self.addEmitter(weaponType: weaponType, position: CGPoint(x: enemy.position.x, y: enemy.position.y + 20), waitTime: waitTime)}
            let remove = SKAction.run {enemy.removeFromParent()}
            self.run(SKAction.sequence([add, remove]))
        }
        
    }
    
    func deflectBuster(buster: SKNode, direction: String) {
        
        var xVal: CGFloat
        xVal = 0
        
        if direction == "right" {
            xVal = 50
        } else if direction == "left" {
            xVal = -50
        }
        //        print(xVal)
        
        var moveBuster = SKAction.moveBy(x: xVal, y: 35, duration: 0.07)
        moveBuster = SKAction.repeat(moveBuster, count: 10)
        let killBuster = (SKAction.run({
            //            print("Buster off screen")
            buster.removeFromParent()
        }))
        
        let busterDeflectAction = SKAction.sequence([moveBuster, killBuster])
        buster.removeAllActions()
        buster.run(busterDeflectAction)
    }
    
    func addEmitter(weaponType: String, position:CGPoint, waitTime: CGFloat){
        
        let effect = SKEmitterNode(fileNamed: "\(weaponType)Explosion.sks")!
        
        effect.position = position
        effect.position.y = (effect.position.y) - 30
        
        let addEmitterAction = SKAction.run({self.addChild(effect)})
        let wait = SKAction.wait(forDuration: TimeInterval(waitTime))
        let remove = SKAction.run({effect.removeFromParent()})
        let sequence = SKAction.sequence([addEmitterAction, wait, remove])
        
        self.run(sequence)
    }
    
    func moveOffWall() {
        ////        print("MOVE OFF!")
        //        var moveValue: CGFloat = 0
        //        if goku.mmActions.contains(.faceRight) {moveValue = -1} else if goku.mmActions.contains(.faceLeft) {moveValue = 1}
        ////        goku.run(SKAction.moveBy(x: moveValue, y:0, duration: 0.01))
        //        goku.physicsBody?.applyImpulse(CGVector(dx: moveValue, dy: 0))
    }
    
    func addUltraInstinct() {
        
        let fadeOut = SKAction.fadeAlpha(to: 0.1, duration: 0.1)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.5)
        let flashAction = SKAction.sequence([fadeOut, SKAction.wait(forDuration: 1), fadeIn])
        let flash = SKAction.repeat(flashAction, count: 1)
        
        let UITransform = SKEmitterNode(fileNamed: "TransformUI.sks")
        UITransform?.name = "UIEffect"
        UITransform?.zPosition = -1
        UITransform?.position = CGPoint(x: 0, y: -25)
        UITransform?.setScale(1.5)
        goku.addChild(UITransform!)
        UITransform?.run(SKAction.wait(forDuration: 5))
        goku.run(flash)
        
        goku.lightingBitMask = PhysicsCategory.playerCategory
        goku.shadowedBitMask = PhysicsCategory.playerCategory
        
        goku.UIAura?.setScale(3)
        goku.UIAura?.zPosition = -1
        goku.UIAura?.position = CGPoint(x: 0, y: -33)
        goku.addChild(goku.UIAura!)
        
        goku.UILight.categoryBitMask = PhysicsCategory.playerCategory
        goku.UILight.lightColor = NSColor.white
        goku.UILight.ambientColor = NSColor.white
        goku.UILight.shadowColor = NSColor.white
        goku.UILight.falloff = 0
        goku.UILight.zPosition = -1
        
        let light1 = SKAction.run {self.goku.UILight.lightColor = NSColor.white.withAlphaComponent(0.1)}
        let light2 = SKAction.run {self.goku.UILight.lightColor = NSColor.white.withAlphaComponent(0.6)}
        let light3 = SKAction.run {self.goku.UILight.lightColor = NSColor.white.withAlphaComponent(0.9)}
        let wait = SKAction.wait(forDuration: 0.07)
        
        let lightAction = SKAction.sequence([light1, wait, wait, light2, wait, wait, light3, wait, light2, wait, wait])
        let light = SKAction.repeatForever(lightAction)
        
        goku.UILight.run(light)
        goku.addChild(goku.UILight)
    }
    
    func removeUltraInstinct() {
        goku.removeChildren(in: [goku.UIAura!, goku.UILight, goku.childNode(withName: "UIEffect")!])
        
    }
    
    func UIMovement() {
        
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.0)
        let UIMove = SKEmitterNode(fileNamed: "UIMove.sks")
        UIMove?.setScale(0.33)
        
        UIMove?.name = "UIMove"
        UIMove?.zPosition = -1
        UIMove?.position = CGPoint(x: 0, y: -5)
        UIMove?.particleTexture = goku.texture
        
        if goku.mmActions.contains(.faceRight) {
            UIMove?.xScale = fabs((UIMove?.xScale)!) * 1
            
        } else {
            UIMove?.xScale = fabs((UIMove?.xScale)!) * -1
            
        }
        
        UIMove?.position = goku.position
        
        
        goku.run(fadeOut); addChild(UIMove!); goku.UILight.isHidden = true
        //        UIMove?.targetNode = self.scene
        goku.physicsBody?.categoryBitMask = 0

    }
    
    func stopUIMovement() {
        
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.1)
        goku.run(fadeIn, completion: {self.removeChildren(in: [self.childNode(withName: "UIMove")!])})
        goku.UILight.isHidden = false
        goku.physicsBody?.categoryBitMask = PhysicsCategory.playerCategory
        
        
    }
    
    func setActionCam() {
        
        for node in self.children {
            if let aCam: SKCameraNode = node as? SKCameraNode {
                camera = aCam
                camera?.position = (spriteCam?.position)! //CGPoint(x: self.frame.midX*SCALEVALUE , y: self.frame.midY*SCALEVALUE)
                camera?.xScale = SCALEVALUEX
                camera?.yScale = SCALEVALUEY
            }
        }
    }
    
    func moveCamBetweenFloors(camYValue: CGFloat) {
        //Freeze the sprite and set the main camera to the sprite camera
        print("ARE YOU GOING TO SWITCH?")
        if self.level == -7.0 {
            print("SHOULD NOT DO ANYTHING")
            return
        }
        let freeze = SKAction.run {
            self.downKeys.removeAll()
            if self.isMegaMan {
                self.megaman.physicsBody?.isDynamic = false
                self.megaman.physicsBody?.affectedByGravity = false
            } else {
                self.goku.physicsBody?.isDynamic = false
                self.goku.physicsBody?.affectedByGravity = false
                //            self.goku.isPaused = true
            }
            self.hasCamAction = true
            self.setActionCam()
            print(self.level)
        }
        
        var camActions = SKAction()
        
        camActions = SKAction.moveBy(x: 0, y: camYValue, duration: 1)
        camActions.timingMode = .easeInEaseOut
        
        let moveCamDown = SKAction.run {self.camera?.run(camActions)}
        
        //Unfreeze the sprite and set the main camera back to the sprite camera
        let unFreeze = SKAction.run {
            if self.isMegaMan {
                self.megaman.physicsBody?.isDynamic = true;
                self.megaman.physicsBody?.affectedByGravity = true
                self.megaman.isPaused = false
            } else {
                self.goku.physicsBody?.isDynamic = true;
                self.goku.physicsBody?.affectedByGravity = true
                self.goku.isPaused = false
            }
            self.hasCamAction = false
            self.spriteCam?.position = (self.camera?.position)!
            self.camera = self.spriteCam
            
            if camYValue > 0 {
                if self.isMegaMan {
                    self.megaman.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
                } else {
                    self.goku.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
                }
            }
        }
        
        run(SKAction.sequence([freeze, moveCamDown, SKAction.wait(forDuration: 1), unFreeze]))
        
        
    }
    
    func camShift() {
        
        let shiftCamAction = SKAction.moveTo(y: (camera?.position.y)!-384, duration: 1)
        camera?.run(shiftCamAction)
    }
    
    func die() {
        removeChildren(in: [openingMusic])
        run(SKAction.playSoundFileNamed("MegamanDefeat.wav", waitForCompletion: true))
        goku.removeFromParent()
        self.run(SKAction.sequence([SKAction.wait(forDuration: 5)]), completion: startLevel)
    }
    
    func startLevel() {
        let scene = SKScene(fileNamed: "GameScene")
        scene?.scaleMode = .aspectFill
        view?.presentScene(scene)
    }
    
    func startMusic() {
        openingMusic.run(SKAction.changeVolume(to: 0.5, duration: 0.01))
    }
    
    func pauseMusic() {
        openingMusic.run(SKAction.changeVolume(to: 0.0, duration: 0.01))
    }
    
    func togglePhysics() {
        if (view?.showsPhysics)! {
            view?.showsPhysics = false
        } else {
            view?.showsPhysics = true
        }
    }
    
    func keyDownGokuLeftDashingState() {
        
        //Check if you're already pressing 'a'
        if downKeys.contains("a") {
            return
        }
        //Since you're not pressing 'a', insert it into the currently pressed keys
        downKeys.insert("a")
        
        //If you are pressing 'a' to go left, however you're already pressing 'd' to go right, then do nothing
        if downKeys.contains("d") {
            return
        }
        //Have goku sprite face left
        goku.faceLeft()
        
        //Determine which goku sprite state should be entered based on the currentstate after pressing 'a'
        
        switch goku.stateMachine.currentState {
        case is Standing:
            goku.stateMachine.enter(Dashing.self)
        case is StandingAndShooting:
            goku.stateMachine.enter(DashingAndShooting.self)
        case is Jumping:
            goku.stateMachine.enter(DashingAndJumping.self)
        case is JumpingAndShooting:
            goku.stateMachine.enter(DashingAndJumpingAndShooting.self)
        case is TakingDamage: return
        default:
            
            print("weird keyDown 'aaaa'...")
        }
    }
    
    func keyDownMegaManLeftDashingState() {
        //Check if you're already pressing 'a'
        if downKeys.contains("a") {
            return
        }
        //Since you're not pressing 'a', insert it into the currently pressed keys
        downKeys.insert("a")
        
        //If you are pressing 'a' to go left, however you're already pressing 'd' to go right, then do nothing
        if downKeys.contains("d") {
            return
        }
        //Have goku sprite face left
        megaman.faceLeft()
        
        //Determine which goku sprite state should be entered based on the currentstate after pressing 'a'
        switch megaman.stateMachine.currentState {
        case is MegaManStanding:
            megaman.stateMachine.enter(MegaManRunning.self)
        case is MegaManJumping:
            megaman.stateMachine.enter(MegaManRunningAndJumping.self)
        case is MegaManTakingDamage: return
        default:
            print("weird keyDown 'a'...")
        }
    }
    
    func keyDownGokuRightDashingState() {
        
        if downKeys.contains("d") {
            return
        }
        downKeys.insert("d")
        
        if downKeys.contains("a") {
            return
        }
        goku.faceRight()
        
        
        switch goku.stateMachine.currentState {
        case is Standing:
            goku.stateMachine.enter(Dashing.self)
        case is StandingAndShooting:
            goku.stateMachine.enter(DashingAndShooting.self)
        case is Jumping:
            goku.stateMachine.enter(DashingAndJumping.self)
        case is JumpingAndShooting:
            goku.stateMachine.enter(DashingAndJumpingAndShooting.self)
        case is TakingDamage: return
        default:
            print("weird keyDown 'd'...")
        }
    }
    
    func keyDownMegaManRightDashingState() {
        
        if downKeys.contains("d") {
            return
        }
        downKeys.insert("d")
        
        if downKeys.contains("a") {
            return
        }
        megaman.faceRight()
        
        switch megaman.stateMachine.currentState {
        case is MegaManStanding:
            megaman.stateMachine.enter(MegaManRunning.self)
        case is MegaManJumping:
            megaman.stateMachine.enter(MegaManRunningAndJumping.self)
        case is MegaManTakingDamage: return
        default:
            print("weird keyDown 'd'...")
        }
    }
    
    func keyUpGokuLeftDashingState() {
        switch goku.stateMachine.currentState {
            
        case is Dashing:
            if downKeys.contains("d") {
                goku.faceRight()
                goku.stateMachine.enter(Dashing.self)
            } else {
                if goku.isFalling {
                    goku.stateMachine.enter(DashingAndJumping.self)
                } else {
                    goku.stateMachine.enter(Standing.self)
                }
            }
        case is DashingAndShooting:
            if downKeys.contains("d") {
                goku.faceRight()
                goku.stateMachine.enter(DashingAndShooting.self)
            } else {
                if goku.isFalling {
                    goku.stateMachine.enter(DashingAndJumpingAndShooting.self)
                } else {
                    goku.stateMachine.enter(StandingAndShooting.self)
                }
            }
        case is DashingAndJumping:
            if downKeys.contains("d") {
                goku.faceRight()
                goku.stateMachine.enter(DashingAndJumping.self)
            } else {
                goku.stateMachine.enter(Jumping.self)
            }
        case is DashingAndJumpingAndShooting:
            if downKeys.contains("d") {
                goku.faceRight()
                goku.stateMachine.enter(DashingAndJumpingAndShooting.self)
            } else {
                goku.stateMachine.enter(JumpingAndShooting.self)
            }
            
        case is TakingDamage: return
        default:
            print("weird keyDown 'a'...")
        }
    }
    
    func keyUpMegaManLeftDashingState() {
        switch megaman.stateMachine.currentState {
            
        case is MegaManRunning:
            if downKeys.contains("d") {
                megaman.faceRight()
                megaman.stateMachine.enter(MegaManRunning.self)
            } else {
                if megaman.isFalling {
                    
                    megaman.stateMachine.enter(MegaManJumping.self)
                } else {
                    megaman.stateMachine.enter(MegaManStanding.self)
                }
            }
        case is MegaManRunningAndJumping:
            if downKeys.contains("d") {
                megaman.faceRight()
                megaman.stateMachine.enter(MegaManRunningAndJumping.self)
            } else {
                megaman.stateMachine.enter(MegaManJumping.self)
            }
        case is MegaManTakingDamage: return
        default:
            print("weird keyDown 'a'...")
        }
    }
    
    func keyUpGokuRightDashingState() {
        switch goku.stateMachine.currentState {
            
        case is Dashing:
            if downKeys.contains("a") {
                goku.faceLeft()
                goku.stateMachine.enter(Dashing.self)
            } else {
                if goku.isFalling {
                    goku.stateMachine.enter(DashingAndJumping.self)
                } else {
                    goku.stateMachine.enter(Standing.self)
                }
            }
        case is DashingAndShooting:
            if downKeys.contains("a") {
                goku.faceLeft()
                goku.stateMachine.enter(DashingAndShooting.self)
            } else {
                if goku.isFalling {
                    goku.stateMachine.enter(DashingAndJumpingAndShooting.self)
                } else {
                    goku.stateMachine.enter(StandingAndShooting.self)
                }
            }
        case is DashingAndJumping:
            if downKeys.contains("a") {
                goku.faceLeft()
                goku.stateMachine.enter(DashingAndJumping.self)
            } else {
                goku.stateMachine.enter(Jumping.self)
            }
        case is DashingAndJumpingAndShooting:
            if downKeys.contains("a") {
                goku.faceLeft()
                goku.stateMachine.enter(DashingAndJumpingAndShooting.self)
            } else {
                goku.stateMachine.enter(JumpingAndShooting.self)
            }
            
        case is TakingDamage: return
        default:
            print("weird keyDown 'd'...")
        }
    }
    
    func keyUpMegaManRightDashingState() {
        switch megaman.stateMachine.currentState {
            
        case is MegaManRunning:
            if downKeys.contains("a") {
                megaman.faceLeft()
                megaman.stateMachine.enter(MegaManRunning.self)
            } else {
                if megaman.isFalling {
                    megaman.stateMachine.enter(MegaManJumping.self)
                } else {
                    megaman.stateMachine.enter(MegaManStanding.self)
                }
            }
        case is MegaManRunningAndJumping:
            if downKeys.contains("a") {
                megaman.faceLeft()
                megaman.stateMachine.enter(MegaManRunningAndJumping.self)
            } else {
                megaman.stateMachine.enter(MegaManJumping.self)
            }
        case is MegaManTakingDamage: return
        default:
            print("weird keyDown 'd'...")
        }
    }
    
    func enterGokuJumpState() {
        
        if downKeys.contains("k") || goku.mmActions.contains(.jumping) || goku.isFalling {
            return
        }
        
        downKeys.insert("k")
        
        switch goku.stateMachine.currentState {
        case is Standing:
            goku.stateMachine.enter(Jumping.self)
        case is StandingAndShooting:
            goku.stateMachine.enter(JumpingAndShooting.self)
        case is Dashing:
            goku.stateMachine.enter(DashingAndJumping.self)
        case is DashingAndShooting:
            goku.stateMachine.enter(DashingAndJumpingAndShooting.self)
        case is TakingDamage: return
        default:
            print("Should already be dashing...")
        }
    }
    
    func enterMegaManJumpState() {
        
        if downKeys.contains("k") || megaman.mmActions.contains(.jumping) || megaman.isFalling {
            return
        }
        
        downKeys.insert("k")
        
        switch megaman.stateMachine.currentState {
        case is MegaManStanding:
            megaman.stateMachine.enter(MegaManJumping.self)
        case is MegaManRunning:
            megaman.stateMachine.enter(MegaManRunningAndJumping.self)
        case is MegaManTakingDamage: return
        default:
            print("Should already be dashing...")
        }
    }
    
    func gokuUI() {
        if goku.childNode(withName: "UIEffect") != nil {
            if (goku.childNode(withName: "UIEffect")?.hasActions())! || goku.isShooting || inTransition || goku.isTakingDamage || goku.stateMachine.currentState == goku.stateMachine.state(forClass: Charging.self){
                return
            }
        }
        
        if goku.children.contains(goku.UILight) {
            removeUltraInstinct()
            return
        } else {
            addUltraInstinct()
            run(SKAction.sequence([SKAction.run(pauseMusic), SKAction.playSoundFileNamed("UITransform.mp3", waitForCompletion: true), SKAction.run(startMusic)]))
        }
    }
    
    func handleMegaManBarrier(name: String) {
        switch name {
        case "ground":
            megaman.isFalling = false
            
            switch self.megaman.stateMachine.currentState {

            case is MegaManJumping:
                megaman.physicsBody?.velocity.dy = 0
                self.megaman.stateMachine.enter(MegaManStanding.self)
                
            case is MegaManRunningAndJumping:
                self.megaman.stateMachine.enter(MegaManRunning.self)
                
            case is MegaManTakingDamage:
                print("Taking damage...")
            default:
                ()
                
            }
            
        case "roof":
            megaman.stopJump()
            switch self.goku.stateMachine.currentState {
            case is TakingDamage:
                print("wait")
            default:
                ()
                
            }

        case "death":
            die()
        default:
            ()
        }
    }
    
    func play(name: String, type: String) throws {
        // 1: load the file
        let test = Bundle.main.path(forResource: name, ofType: type)
        let file = try AVAudioFile(forReading: URL(fileURLWithPath: test!))
        
        // 2: create the audio player
        let audioPlayer = AVAudioPlayerNode()
        
        // 3: connect the components to our playback engine
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        engine.attach(speedControl)
        
        // 4: arrange the parts so that output from one is input to another
        engine.connect(audioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
        
        // 5: prepare the player to play its file from the beginning
        audioPlayer.scheduleFile(file, at: nil)
        
        // 6: start the engine and player
        try engine.start()
        audioPlayer.play()
        
        
    }
    
    func runGateOpenAnimation(aGate: SKSpriteNode) {
        
        if aGate.name == "gate" {
         gate = (self.childNode(withName: "//gateSprite") as? SKSpriteNode)!
        } else if aGate.name == "gate2" {
          gate = (self.childNode(withName: "//gateSprite2") as? SKSpriteNode)!
        }
        
        let textureAtlas = SKTextureAtlas(named: "Background")
        let gate1Texture = textureAtlas.textureNamed("BG1.png")
        let gate2Texture = textureAtlas.textureNamed("BG1.png")
        let gate3Texture = textureAtlas.textureNamed("BG3.png")
        let gate4Texture = textureAtlas.textureNamed("BG4.png")
        let gate5Texture = textureAtlas.textureNamed("BG5.png")
        
        gate1Texture.filteringMode = .nearest
        gate2Texture.filteringMode = .nearest
        gate3Texture.filteringMode = .nearest
        gate4Texture.filteringMode = .nearest
        
        gate.texture = gate1Texture


        let freeze = SKAction.run {
            self.downKeys.removeAll()
            if self.isMegaMan {
                self.megaman.physicsBody?.isDynamic = false
                self.megaman.physicsBody?.affectedByGravity = false
            } else {
                self.goku.physicsBody?.isDynamic = false
                self.goku.physicsBody?.affectedByGravity = false
                self.inTransition = true
            }
        }
        
        let unFreeze = SKAction.run {
            if self.isMegaMan {
                self.megaman.physicsBody?.isDynamic = true;
                self.megaman.physicsBody?.affectedByGravity = true
            } else {
                self.goku.physicsBody?.isDynamic = true;
                self.goku.physicsBody?.affectedByGravity = true
                self.inTransition = false
            }
        }
        
        let openGate = SKAction.run {
            self.gate.run(SKAction.animate(with: [gate1Texture, gate2Texture, gate3Texture, gate4Texture, gate5Texture], timePerFrame: 0.2))
        }
        let moveGokuInGate = SKAction.run {
            self.goku.run(SKAction.moveBy(x: 55, y: 0, duration: 1))
            
            var camActions = SKAction()
            
            camActions = SKAction.moveBy(x: 256, y: 0, duration: 1)
            camActions.timingMode = .linear
            
            let moveCamInGate = SKAction.run {self.camera?.run(camActions)}
            self.run(moveCamInGate)
            
        }
        let closeGate = SKAction.run {
            self.gate.run(SKAction.animate(with: [gate5Texture, gate4Texture, gate3Texture, gate2Texture, gate1Texture], timePerFrame: 0.2))
        }
        
        
        run(SKAction.sequence([freeze, openGate, SKAction.wait(forDuration: 1), moveGokuInGate, SKAction.wait(forDuration: 1), closeGate, SKAction.wait(forDuration: 1), unFreeze]))
    }
    
}


