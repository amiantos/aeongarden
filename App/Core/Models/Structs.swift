//
//  Structs.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/4/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import SpriteKit

protocol DataStoreProtocol {
    func saveTank(_ tank: Tank)
    func getTanks(completion: @escaping ([Tank]) -> Void)

    func saveCreature(_ creature: Creature)
    func deleteCreature(_ creature: Creature)
    func getCreatures(completion: @escaping ([Creature]) -> Void)
}

struct TankSettings: Codable {
    let foodMaxAmount: Int
    let foodHealthRestorationBaseValue: Float
    let foodSpawnRate: Int

    let creatureInitialAmount: Int
    let creatureMinimumAmount: Int
    let creatureSpawnRate: Int
    let creatureBirthSuccessRate: Float

    let backgroundParticleBirthrate: Int
    let backgroundParticleLifetime: Int
}

struct Tank: Codable {
    let uuid: UUID
    let tankTime: Float
    let deathCount: Int
    let birthCount: Int
    let tankSettings: TankSettings

    let creatures: [Creature]
    let food: [Food]
    let bubbles: [Bubble]

    static func from(_ scene: AeonTankScene) -> Tank {
        guard let tankSettings = scene.tankSettings else { fatalError("Tank cannot lack TankSettings.") }
        var creatures: [Creature] = []
        for creatureNode in scene.creatureNodes {
            creatures.append(Creature.from(creatureNode))
        }

        var food: [Food] = []
        for foodNode in scene.foodNodes {
            food.append(Food.from(foodNode))
        }

        var bubbles: [Bubble] = []
        for bubbleNode in scene.bubbleNodes {
            bubbles.append(Bubble.from(bubbleNode))
        }

        return Tank(
            uuid: scene.uuid,
            tankTime: Float(scene.tankTime),
            deathCount: scene.deathCount,
            birthCount: scene.birthCount,
            tankSettings: tankSettings,
            creatures: creatures,
            food: food,
            bubbles: bubbles
        )
    }

    func restore(to scene: AeonTankScene) {
        scene.tankSettings = tankSettings
        scene.tankTime = TimeInterval(tankTime)
        scene.deathCount = deathCount
        scene.birthCount = birthCount
        scene.uuid = uuid

        for creature in creatures {
            creature.put(in: scene)
        }

        for food in food {
            food.put(in: scene)
        }

        for bubble in bubbles {
            bubble.put(in: scene)
        }
    }

    func save() {
        #if os(iOS) || os(tvOS)
            CoreDataStore.standard.saveTank(self)
        #endif
    }

    static func getAll(completion: @escaping ([Tank]) -> Void) {
        #if os(iOS) || os(tvOS)
            CoreDataStore.standard.getTanks { tanks in
                completion(tanks)
            }
        #else
            completion([])
        #endif
    }
}

struct Creature: Codable {
    let uuid: UUID

    let firstName: String
    let lastName: String
    let ancestors: [UUID]

    let limbs: [Limb]

    let movementSpeed: Float
    let turnSpeed: Float
    let sizeModifier: Float
    let primaryHue: Float

    var isFavorite: Bool

    var lifeTime: Float
    var currentHealth: Float

    let positionX: Float
    let positionY: Float

    static func from(_ node: AeonCreatureNode) -> Creature {
        var limbs: [Limb] = []
        let limbNodes: [AeonLimbNode] = [node.limbOne, node.limbTwo, node.limbThree, node.limbFour]
        for limbNode in limbNodes {
            limbs.append(Limb.from(limbNode))
        }
        return Creature(
            uuid: node.uuid,
            firstName: node.firstName,
            lastName: node.lastName,
            ancestors: node.ancestors,
            limbs: limbs,
            movementSpeed: Float(node.movementSpeed),
            turnSpeed: Float(node.turnSpeed),
            sizeModifier: Float(node.sizeModififer),
            primaryHue: Float(node.primaryHue),
            isFavorite: node.isFavorite,
            lifeTime: Float(node.lifeTime),
            currentHealth: Float(node.currentHealth),
            positionX: Float(node.position.x),
            positionY: Float(node.position.y)
        )
    }

    func toNode() -> AeonCreatureNode {
        let creatureNode = AeonCreatureNode(with: self)
        return creatureNode
    }

    func put(in scene: AeonTankScene) {
        let creatureNode = AeonCreatureNode(with: self)
        scene.addChild(creatureNode)
        creatureNode.position = CGPoint(
            x: CGFloat(positionX),
            y: CGFloat(positionY)
        )
        creatureNode.scaleAnimation()
        creatureNode.born()
    }

    func save() {
        #if os(iOS) || os(tvOS)
            CoreDataStore.standard.saveCreature(self)
        #endif
    }

    func delete() {
        #if os(iOS) || os(tvOS)
            CoreDataStore.standard.deleteCreature(self)
        #endif
    }
}

struct Limb: Codable {
    let shape: BodyPart
    let hue: Float
    let blend: Float
    let brightness: Float
    let saturation: Float
    let limbWidth: Int

    let wiggleFactor: Float
    let wiggleMoveFactor: Float
    let wiggleMoveBackFactor: Float
    let wiggleActionDuration: Float
    let wiggleActionBackDuration: Float
    let wiggleActionMovementDuration: Float
    let wiggleActionMovementBackDuration: Float

    let limbzRotation: Float

    let positionX: Float
    let positionY: Float

    static func from(_ node: AeonLimbNode) -> Limb {
        return Limb(
            shape: node.shape,
            hue: Float(node.hue),
            blend: Float(node.blend),
            brightness: Float(node.brightness),
            saturation: Float(node.saturation),
            limbWidth: node.limbWidth,
            wiggleFactor: Float(node.wiggleFactor),
            wiggleMoveFactor: Float(node.wiggleMoveFactor),
            wiggleMoveBackFactor: Float(node.wiggleMoveBackFactor),
            wiggleActionDuration: Float(node.wiggleActionDuration),
            wiggleActionBackDuration: Float(node.wiggleActionBackDuration),
            wiggleActionMovementDuration: Float(node.wiggleActionMovementDuration),
            wiggleActionMovementBackDuration: Float(node.wiggleActionMovementBackDuration),
            limbzRotation: Float(node.limbzRotation),
            positionX: Float(node.position.x),
            positionY: Float(node.position.y)
        )
    }
}

struct Food: Codable {
    let positionX: Float
    let positionY: Float

    static func from(_ node: AeonFoodNode) -> Food {
        return Food(
            positionX: Float(node.position.x),
            positionY: Float(node.position.y)
        )
    }

    func put(in scene: AeonTankScene) {
        let foodNode = AeonFoodNode()
        scene.addChild(foodNode)
        foodNode.position = CGPoint(
            x: CGFloat(positionX),
            y: CGFloat(positionY)
        )
        foodNode.born()
    }
}

struct Bubble: Codable {
    let positionX: Float
    let positionY: Float

    static func from(_ node: AeonBubbleNode) -> Bubble {
        return Bubble(
            positionX: Float(node.position.x),
            positionY: Float(node.position.y)
        )
    }

    func put(in scene: AeonTankScene) {
        let bubbleNode = AeonBubbleNode()
        scene.addChild(bubbleNode)
        bubbleNode.position = CGPoint(
            x: CGFloat(positionX),
            y: CGFloat(positionY)
        )
    }
}
