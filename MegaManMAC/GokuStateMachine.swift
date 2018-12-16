//
//  MegaManStateMachine.swift
//  goku
//
//  Created by Kyle Jones on 1/24/18.
//  Copyright © 2018 AngelGenie. All rights reserved.
//

import GameplayKit

class GokuStateMachine: GKStateMachine {
    init(player: Goku) {
        super.init(states: [
            Standing(player: player), //Running, Jumping, StandShoot
            StandingAndShooting(player: player), //Standing, RunShoot, JumpShoot
            Dashing(player: player), // Standing, RunJump, RunShoot
            DashingAndShooting(player: player), //Running, RunJumpShoot, StandShoot
            Jumping(player: player), //JumpShoot, RunJump, Standing
            JumpingAndShooting(player: player), //Jumping, RunShoot
            DashingAndJumping(player: player),
            DashingAndJumpingAndShooting(player: player),
            TakingDamage(player: player),
            Charging(player: player),
            ChargingAndShooting(player: player),
            Floating(player: player), //Running, Jumping, RunJumpShoot
            FloatingAndShooting(player: player)])
        
    }
    
}

class GokuState: GKState {
    var goku: Goku
    
    init(player: Goku) {
        goku = player
    }
}

class Standing: GokuState { //Running, Jumping, StandShoot
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == Dashing.self || stateClass == Jumping.self || stateClass == StandingAndShooting.self || stateClass == Floating.self || stateClass == TakingDamage.self || stateClass == Charging.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print(stateMachine?.currentState as Any)
        if previousState is Dashing {
            
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            goku.stand()
            
        } else if previousState is Jumping {
            goku.mmActions.remove(.jumping)
            goku.stand()
            
        } else if previousState is StandingAndShooting {
            
            goku.mmActions.remove(.shooting)
            goku.stand()
            
        } else if previousState is Floating {
           
            
        } else if previousState is TakingDamage {
            goku.removeAction(forKey: "Damage")
            goku.stand()
            
        } else if previousState is ChargingAndShooting {
            goku.removeAction(forKey: "Charging")
            goku.mmActions.remove(.charging)
            goku.stand()
            
        }
    }
}

class StandingAndShooting: GokuState { //Standing, RunShoot, JumpShoot
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == Standing.self || stateClass == DashingAndShooting.self || stateClass == JumpingAndShooting.self || stateClass == TakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print(stateMachine?.currentState as Any)
        if previousState is Standing {
            
            goku.removeAction(forKey: "Stand")
            goku.mmActions.remove(.standing)
            goku.mmActions.insert(.shooting)
            goku.texture = goku.standAndShootTexture
            
        } else if previousState is DashingAndShooting {
            
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            goku.stand()
            
        } else if previousState is JumpingAndShooting {
            
            goku.mmActions.remove(.jumping)
            goku.stand()
        }
    }
    
//    override func update(deltaTime seconds: TimeInterval) {
//
//    }
}

class Dashing: GokuState { // Standing, RunJump, RunShoot
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == Standing.self || stateClass == Dashing.self || stateClass == DashingAndShooting.self || stateClass == DashingAndJumping.self || stateClass == TakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print(stateMachine?.currentState as Any)
        if previousState is Standing {
            
            goku.removeAction(forKey: "Stand")
            goku.mmActions.remove(.standing)
            goku.dash()
            
        } else if previousState is Dashing {
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            goku.dash()
            
        } else if previousState is DashingAndShooting {
            
            goku.mmActions.remove(.shooting)
            goku.texture = goku.dashTexture
            
            
        } else if previousState is DashingAndJumping {
            
            goku.mmActions.remove(.jumping)
            goku.texture = goku.dashTexture
//            print("Should be dashing from dashing and jumping.")

        }
    }

}

class DashingAndShooting: GokuState { //Running, RunJumpShoot, StandShoot
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == StandingAndShooting.self || stateClass == DashingAndShooting.self || stateClass == Dashing.self || stateClass == DashingAndJumpingAndShooting.self || stateClass == TakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print(stateMachine?.currentState as Any)
        
        if previousState is Dashing {
            
            goku.mmActions.insert(.shooting)
            goku.texture = goku.dashShootTexture
    
        } else if previousState is StandingAndShooting {
            
            goku.removeAction(forKey: "Stand")
            goku.mmActions.remove(.standing)
            goku.dash()
            
            
        } else if previousState is DashingAndShooting {
            
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            goku.dash()
            
        } else if previousState is DashingAndJumpingAndShooting {
            
            goku.mmActions.remove(.jumping)
            goku.texture = goku.dashShootTexture
//            print("Should be dashing and shooting from dashing, jumping and shooting.")

            
        }
    }
}


class Jumping: GokuState { //JumpShoot, RunJump, Standing
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == Standing.self || stateClass == Floating.self || stateClass == JumpingAndShooting.self || stateClass == DashingAndJumping.self || stateClass == TakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print(stateMachine?.currentState as Any)
        
        
        if previousState is Standing {
            
            goku.removeAction(forKey: "Stand")
            goku.mmActions.remove(.standing)
            goku.jump()
            
        } else if previousState is JumpingAndShooting {
            goku.mmActions.remove(.shooting)
            goku.texture = goku.jumpTexture
            
        } else if previousState is DashingAndJumping {
            
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            
        } else if previousState is Floating {
            
            goku.removeAction(forKey: "Float")
            goku.mmActions.remove(.floating)
            goku.mmActions.insert(.jumping)
            goku.texture = goku.jumpTexture
            goku.physicsBody?.affectedByGravity = true
        }
    }

    override func update(deltaTime seconds: TimeInterval) {


        if !(goku.physicsBody?.allContactedBodies().isEmpty)! {
            if goku.barrier.name == "wall" {
                if goku.frame.minY - goku.barrier.frame.maxY > -2 {
                    goku.handleGokuBarrier(name: "ground")
                    goku.barrier.name = "barrier"
                }
            }
        }
    }

}

class JumpingAndShooting: GokuState { //Jumping, RunShoot
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == Jumping.self || stateClass == DashingAndJumpingAndShooting.self || stateClass == StandingAndShooting.self || stateClass == TakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print(stateMachine?.currentState as Any)
        
        if previousState is DashingAndJumpingAndShooting {
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            
        } else if previousState is StandingAndShooting {
            goku.removeAction(forKey: "Stand")
            goku.mmActions.remove(.standing)
            goku.jump()

        } else if previousState is Jumping {
            goku.mmActions.insert(.shooting)
            goku.texture = goku.jumpAndShootTexture
            
        }
        
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if !(goku.physicsBody?.allContactedBodies().isEmpty)! {
            if goku.barrier.name == "wall" {
                
                if goku.frame.minY - goku.barrier.frame.maxY > -2 {
                    goku.handleGokuBarrier(name: "ground")
                    goku.barrier.name = "barrier"
                }
            }
        }
    }


}

class DashingAndJumping: GokuState { //Jumping, RunShoot
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == DashingAndJumpingAndShooting.self || stateClass == DashingAndJumping.self || stateClass == Dashing.self || stateClass == Jumping.self || stateClass == TakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print(stateMachine?.currentState as Any)
        
        if previousState is DashingAndJumpingAndShooting {
            
            goku.mmActions.remove(.shooting)
            goku.texture = goku.jumpTexture
            
        } else if previousState is DashingAndJumping {
            
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            goku.dash()
            
        }else if previousState is Dashing {
            
            goku.jump()
            
        } else if previousState is Jumping {
            
            goku.dash()
            
            
            
            
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if !(goku.physicsBody?.allContactedBodies().isEmpty)! {
            if goku.barrier.name == "wall" {
                if goku.frame.minY - goku.barrier.frame.maxY > -2 {
                    goku.handleGokuBarrier(name: "ground")
                    goku.barrier.name = "barrier"
                }
            }
        }
    }
    
}

class DashingAndJumpingAndShooting: GokuState { //Jumping, RunShoot
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == DashingAndShooting.self || stateClass == DashingAndJumpingAndShooting.self || stateClass == DashingAndJumping.self || stateClass == JumpingAndShooting.self || stateClass == TakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print(stateMachine?.currentState as Any)
        
        if previousState is DashingAndShooting {
            
            goku.jump()
            
            
        } else if previousState is DashingAndJumping {
            
            goku.mmActions.insert(.shooting)
            goku.texture = goku.jumpAndShootTexture
            
        } else if previousState is DashingAndJumpingAndShooting {
            
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            goku.dash()
            
        } else if previousState is JumpingAndShooting {
            
            goku.dash()
 
        }
    }
  
    override func update(deltaTime seconds: TimeInterval) {
        if !(goku.physicsBody?.allContactedBodies().isEmpty)! {
            if goku.barrier.name == "wall" {
                if goku.frame.minY - goku.barrier.frame.maxY > -2 {
                    goku.handleGokuBarrier(name: "ground")
                    goku.barrier.name = "barrier"
                }
            }
        }
    }



}

class TakingDamage: GokuState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == Standing.self  {
            return true
            
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        print(stateMachine?.currentState as Any)
        
        if previousState is Standing {
            
            goku.removeAction(forKey: "Stand")
            goku.mmActions.remove(.standing)
//            goku.mmActions.insert(.takeDamage)
            
            goku.texture = goku.damageTexture
            
            goku.takeDamge()
            
            
        } else if previousState is StandingAndShooting {
            
            goku.removeAction(forKey: "Stand")
            goku.mmActions.remove(.standing)
            goku.mmActions.remove(.shooting)
            
            //print("\(goku.currentActions) Remove shooting")
            
            
            //print("\(goku.currentActions) Add standing")
            goku.texture = goku.damageTexture
            goku.takeDamge()
            
        } else if previousState is Dashing {
            
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            
            //print("\(goku.currentActions) Remove dashing")
            
            
            
            //print("\(goku.currentActions) Add standing")
            goku.texture = goku.damageTexture
            goku.takeDamge()
            
        } else if previousState is DashingAndShooting {
            
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            goku.mmActions.remove(.shooting)
            
            //print("\(goku.currentActions) Remove dashing")
            
            
            
            //print("\(goku.currentActions) Add standing")
            goku.texture = goku.damageTexture
            goku.takeDamge()
            
        } else if previousState is Jumping {
            
            goku.mmActions.remove(.jumping)
            
            goku.texture = goku.damageTexture
            goku.takeDamge()
            
        } else if previousState is JumpingAndShooting {
            
            goku.mmActions.remove(.jumping)
            goku.mmActions.remove(.shooting)
            
            //print("\(goku.currentActions) Remove jumping")
            
            
            
            //print("\(goku.currentActions) Add standing")
            goku.texture = goku.damageTexture
            goku.takeDamge()
            
        } else if previousState is DashingAndJumping {
            
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            goku.mmActions.remove(.jumping)
            
            //print("\(goku.currentActions) Remove jumping")
            
            
            
            //print("\(goku.currentActions) Add standing")
            goku.texture = goku.damageTexture
            goku.takeDamge()
            
        } else if previousState is DashingAndJumpingAndShooting {
            goku.removeAction(forKey: "Dash")
            goku.mmActions.remove(.dashing)
            goku.mmActions.remove(.jumping)
            goku.mmActions.remove(.shooting)
            
            //print("\(goku.currentActions) Remove jumping")
            
            
            
            //print("\(goku.currentActions) Add standing")
            goku.texture = goku.damageTexture
            goku.takeDamge()
            
        } else if previousState is Floating {
            
            
            
            //print("\(goku.currentActions) Add standing")
            goku.texture = goku.damageTexture
            goku.takeDamge()
            
        } else if previousState is FloatingAndShooting {
            
            
            
            //print("\(goku.currentActions) Add standing")
            goku.texture = goku.damageTexture
            goku.takeDamge()
            
        } else if previousState is Charging {
            
            
            //print("\(goku.currentActions) Add standing")
            goku.texture = goku.damageTexture
            goku.takeDamge()
            
        }
    }

    override func update(deltaTime seconds: TimeInterval) {
       
    }


}

class Charging: GokuState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == TakingDamage.self || stateClass == ChargingAndShooting.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
//        print(stateMachine?.currentState as Any)
        
        if previousState is Standing {
            goku.removeAction(forKey: "Stand")
            goku.mmActions.insert(.charging)
            
            //print("\(goku.currentActions) Add shooting")
            goku.chargeUp()
        }
    }
}

class ChargingAndShooting: GokuState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == Standing.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
//        print(stateMachine?.currentState as Any)
        
        if previousState is Charging {
            
            //print("\(goku.currentActions) remove charging")
            goku.fireChargeBeam()
        }
    }
}

class Floating: GokuState { //Running, Jumping, RunJumpShoot
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == Jumping.self || stateClass == FloatingAndShooting.self || stateClass == TakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
//        print(stateMachine?.currentState as Any)
        if previousState is Standing {
            goku.removeAction(forKey: "Stand")
            goku.mmActions.remove(.standing)
            
            //print("\(goku.currentActions) Remove standing")
            
            goku.mmActions.insert(.floating)
            
            //print("\(goku.currentActions) Add floating")
            
            goku.float()
            
        } else if previousState is FloatingAndShooting {
            goku.action(forKey: "Float")?.speed = 1
            goku.mmActions.remove(.shooting)
            
            //print("\(goku.currentActions) Remove shooting")
            
            goku.texture = goku.floatTexture
            
        }
    }
    
}

class FloatingAndShooting: GokuState { //RunJump, RunShoot, JumpShoot
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == Floating.self || stateClass == TakingDamage.self {
            return true
        }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
//        print(stateMachine?.currentState as Any)
        if previousState is Floating {
            
            goku.action(forKey: "Float")?.speed = 0
            goku.mmActions.insert(.shooting)
            
            //print("\(goku.currentActions) Add floating and shooting")
            goku.texture = goku.floatAndShootTexture
            
        }
    }
    
}



/*
 
 */
