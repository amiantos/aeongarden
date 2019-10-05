//
//  ManagedTank+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/5/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedTank {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedTank> {
        return NSFetchRequest<ManagedTank>(entityName: "ManagedTank")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var tankTime: Float
    @NSManaged public var deathCount: Int16
    @NSManaged public var birthCount: Int16
    @NSManaged public var creatures: NSSet
    @NSManaged public var tankSettings: ManagedTankSettings?

}

// MARK: Generated accessors for creatures
extension ManagedTank {

    @objc(addCreaturesObject:)
    @NSManaged public func addToCreatures(_ value: ManagedCreature)

    @objc(removeCreaturesObject:)
    @NSManaged public func removeFromCreatures(_ value: ManagedCreature)

    @objc(addCreatures:)
    @NSManaged public func addToCreatures(_ values: NSSet)

    @objc(removeCreatures:)
    @NSManaged public func removeFromCreatures(_ values: NSSet)

}
