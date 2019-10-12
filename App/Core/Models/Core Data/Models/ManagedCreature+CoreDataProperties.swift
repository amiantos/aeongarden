//
//  ManagedCreature+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

extension ManagedCreature {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedCreature> {
        return NSFetchRequest<ManagedCreature>(entityName: "ManagedCreature")
    }

    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var movementSpeed: Float
    @NSManaged public var primaryHue: Float
    @NSManaged public var sizeModifier: Float
    @NSManaged public var turnSpeed: Float
    @NSManaged public var uuid: UUID
    @NSManaged public var limbs: NSSet
}

// MARK: Generated accessors for limbs

extension ManagedCreature {
    @objc(addLimbsObject:)
    @NSManaged public func addToLimbs(_ value: ManagedLimb)

    @objc(removeLimbsObject:)
    @NSManaged public func removeFromLimbs(_ value: ManagedLimb)

    @objc(addLimbs:)
    @NSManaged public func addToLimbs(_ values: NSSet)

    @objc(removeLimbs:)
    @NSManaged public func removeFromLimbs(_ values: NSSet)
}
