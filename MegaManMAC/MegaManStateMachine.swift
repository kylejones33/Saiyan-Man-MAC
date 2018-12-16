//
//  MegaManStateMachine.swift
//  goku
//
//  Created by Kyle Jones on 1/24/18.
//  Copyright © 2018 AngelGenie. All rights reserved.
//

import GameplayKit

extension SKTexture
{
    var name : String
    {
        return self.description.slice(start: "'",to: "'")!
    }
}

extension String {
    func slice(start: String, to: String) -> String?
    {
        
        return (range(of: start)?.upperBound).flatMap
            {
                sInd in
                (range(of: to, range: sInd..<endIndex)?.lowerBound).map
                    {
                        eInd in
                        substring(with:sInd..<eInd)
                        
                }
        }
    }
}

class MegaManStateMachine: GKStateMachine {
    init(player: MegaMan) {
        super.init(states: [
            MegaManStanding(player: player),
            MegaManRunning(player: player),
            MegaManJumping(player: player),
            MegaManRunningAndJumping(player: player),
            MegaManTakingDamage(player: player)])
    }
    
}

class MegaManState: GKState {
    var megaman: MegaMan
    
    init(player: MegaMan) {
        megaman = player
    }
}

class MegaManStanding: MegaManState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == MegaManRunning.self || stateClass == MegaManJumping.self || stateClass == MegaManTakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        
        if previousState is MegaManRunning {
            
            megaman.removeAllActions()
            megaman.mmActions.remove(.running)
            megaman.stand()
            
        } else if previousState is MegaManJumping {
            megaman.mmActions.remove(.jumping)
            megaman.stand()
        
        } else if previousState is MegaManTakingDamage {
            megaman.removeAction(forKey: "Damage")
            megaman.mmActions.remove(.takeDamage)
            megaman.stand()
            
        }
    }

    override func update(deltaTime seconds: TimeInterval) {
        if megaman.mmActions.contains(.shooting) {
            megaman.removeAction(forKey: "Stand")
            megaman.texture = megaman.standAndShootTexture
        } else {
            if megaman.action(forKey: "Stand") == nil {
                megaman.stand()
            }
        }
        
    }
}

class MegaManRunning: MegaManState {
    
    var runCounter = 0
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == MegaManStanding.self || stateClass == MegaManRunning.self || stateClass == MegaManRunningAndJumping.self || stateClass == MegaManTakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        megaman.runFrame = "0"
        if previousState is MegaManStanding {
            runCounter = 5
            megaman.removeAction(forKey: "Stand")
            megaman.mmActions.remove(.standing)
            megaman.run()
            
        } else if previousState is MegaManRunning {
            runCounter = 5
            megaman.removeAllActions()
            megaman.mmActions.remove(.running)
            megaman.run()
            
        } else if previousState is MegaManRunningAndJumping {
            runCounter = 5
//            megaman.removeAllActions()
            megaman.mmActions.remove(.jumping)
            megaman.mmActions.remove(.running)
            megaman.run()
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if runCounter <= 5 {
            runCounter = runCounter + 1
            return
        } else {
            
            switch megaman.runFrame {
            case "0":
                megaman.run(megaman.run0())
                megaman.runFrame = "1"
            case "1":
                megaman.run(megaman.run1())
                megaman.runFrame = "2"
            case "2":
                megaman.run(megaman.run2())
                megaman.runFrame = "3"
            case "3":
                megaman.run(megaman.run1())
                megaman.runFrame = "0"
            default:
                print("Strange Run")
            }
            runCounter = 0
        }
        
        
        
    }
    
}

class MegaManJumping: MegaManState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == MegaManStanding.self || stateClass == MegaManRunningAndJumping.self || stateClass == MegaManTakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print(stateMachine?.currentState as Any)
        
        if previousState is MegaManStanding {
            
            megaman.removeAction(forKey: "Stand")
            megaman.mmActions.remove(.standing)
            megaman.jump()
            
        } else if previousState is MegaManRunningAndJumping {
            
            megaman.removeAllActions()
            megaman.jump()
            
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if megaman.mmActions.contains(.shooting) {
            megaman.texture = megaman.jumpAndShootTexture
        } else {
            megaman.texture = megaman.jumpTexture
        }
    }
}


class MegaManRunningAndJumping: MegaManState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if  stateClass == MegaManRunningAndJumping.self || stateClass == MegaManRunning.self || stateClass == MegaManJumping.self || stateClass == MegaManTakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        
         if previousState is MegaManRunningAndJumping {
            
            megaman.removeAllActions()
            megaman.run()
            
        } else if previousState is MegaManRunning {

//            megaman.removeAllActions()
            megaman.jump()
            
            
        } else if previousState is MegaManJumping {
            megaman.removeAllActions()
            megaman.run()
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if megaman.mmActions.contains(.shooting) {
            print("Running Jumping and Shooting")
            megaman.texture = megaman.jumpAndShootTexture
        } else {
            megaman.texture = megaman.jumpTexture
        }
    }
    
    
}

class MegaManTakingDamage: MegaManState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == MegaManStanding.self  {
            return true
            
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print(stateMachine?.currentState as Any)
        
        if previousState is MegaManStanding {
            
            megaman.removeAction(forKey: "Stand")
            megaman.mmActions.remove(.standing)
            megaman.mmActions.insert(.takeDamage)
            
            megaman.texture = megaman.damageTexture
            megaman.takeDamge()
            
            
        } else if previousState is MegaManRunning {
            
            megaman.mmActions.remove(.running)
            megaman.removeAllActions()
            
            
            
            megaman.mmActions.insert(.takeDamage)
            megaman.texture = megaman.damageTexture
            megaman.takeDamge()
            
        } else if previousState is MegaManJumping {
            
            megaman.mmActions.remove(.jumping)
            
            megaman.mmActions.insert(.takeDamage)
            megaman.texture = megaman.damageTexture
            megaman.takeDamge()
            
        } else if previousState is MegaManRunningAndJumping {
            
            megaman.mmActions.remove(.running)
            megaman.removeAllActions()
            megaman.mmActions.remove(.jumping)
            
            megaman.mmActions.insert(.takeDamage)
            megaman.texture = megaman.damageTexture
            megaman.takeDamge()
            
        }
        
//        else if previousState is Charging {
//
//            megaman.mmActions.insert(.takeDamage)
//
//            //print("\(goku.currentActions) Add standing")
//            megaman.texture = megaman.damageTexture
//            megaman.takeDamge()
//
//        }
    }
}

//class MegaManCharging: MegaManState {
//    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
//        if stateClass == TakingDamage.self || stateClass == ChargingAndShooting.self {
//            return true
//        }
//
//        return false
//    }
//
//    override func didEnter(from previousState: GKState?) {
//        print(stateMachine?.currentState as Any)
//
//        if previousState is Standing {
//            megaman.removeAction(forKey: "Stand")
//            megaman.mmActions.insert(.charging)
//
//            //print("\(goku.currentActions) Add shooting")
//            megaman.chargeUp()
//        }
//    }
//}
//
//class MegaManChargingAndShooting: MegaManState {
//    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
//        if stateClass == Standing.self {
//            return true
//        }
//
//        return false
//    }
//
//    override func didEnter(from previousState: GKState?) {
//        print(stateMachine?.currentState as Any)
//
//        if previousState is Charging {
//
//            //print("\(goku.currentActions) remove charging")
//            megaman.fireChargeBeam()
//        }
//    }
//}






/*
 
 */


