//
//  ManagedTank+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

extension ManagedTank {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedTank> {
        return NSFetchRequest<ManagedTank>(entityName: "ManagedTank")
    }

    @NSManaged public var birthCount: Int16
    @NSManaged public var deathCount: Int16
    @NSManaged public var tankTime: Float
    @NSManaged public var uuid: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var creatures: NSSet
    @NSManaged public var tankSettings: ManagedTankSettings
    @NSManaged public var bubbles: NSSet?
    @NSManaged public var food: NSSet?
}

extension ManagedTank {
    func toStruct() -> Tank {
        var creatures: [Creature] = []
        if let managedCreatures = self.creatures.allObjects as? [ManagedTankCreature] {
            for managedCreature in managedCreatures {
                creatures.append(managedCreature.toStruct())
            }
        }
        var foods: [Food] = []
        if let managedFoods = food?.allObjects as? [ManagedFood] {
            for managedFood in managedFoods {
                foods.append(managedFood.toStruct())
            }
        }
        var bubbles: [Bubble] = []
        if let managedBubbles = self.bubbles?.allObjects as? [ManagedBubble] {
            for managedBubble in managedBubbles {
                bubbles.append(managedBubble.toStruct())
            }
        }
        return Tank(
            uuid: uuid,
            tankTime: tankTime,
            deathCount: Int(deathCount),
            birthCount: Int(birthCount),
            tankSettings: tankSettings.toStruct(),
            creatures: creatures,
            food: foods,
            bubbles: bubbles
        )
    }
}

// MARK: Generated accessors for creatures

extension ManagedTank {
    @objc(addCreaturesObject:)
    @NSManaged public func addToCreatures(_ value: ManagedTankCreature)

    @objc(removeCreaturesObject:)
    @NSManaged public func removeFromCreatures(_ value: ManagedTankCreature)

    @objc(addCreatures:)
    @NSManaged public func addToCreatures(_ values: NSSet)

    @objc(removeCreatures:)
    @NSManaged public func removeFromCreatures(_ values: NSSet)
}

// MARK: Generated accessors for bubbles

extension ManagedTank {
    @objc(addBubblesObject:)
    @NSManaged public func addToBubbles(_ value: ManagedBubble)

    @objc(removeBubblesObject:)
    @NSManaged public func removeFromBubbles(_ value: ManagedBubble)

    @objc(addBubbles:)
    @NSManaged public func addToBubbles(_ values: NSSet)

    @objc(removeBubbles:)
    @NSManaged public func removeFromBubbles(_ values: NSSet)
}

// MARK: Generated accessors for food

extension ManagedTank {
    @objc(addFoodObject:)
    @NSManaged public func addToFood(_ value: ManagedFood)

    @objc(removeFoodObject:)
    @NSManaged public func removeFromFood(_ value: ManagedFood)

    @objc(addFood:)
    @NSManaged public func addToFood(_ values: NSSet)

    @objc(removeFood:)
    @NSManaged public func removeFromFood(_ values: NSSet)
}
