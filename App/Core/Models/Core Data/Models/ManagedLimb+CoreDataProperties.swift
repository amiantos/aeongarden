//
//  ManagedLimb+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import CoreData
import Foundation

extension ManagedLimb {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedLimb> {
        return NSFetchRequest<ManagedLimb>(entityName: "ManagedLimb")
    }

    @NSManaged public var shape: String
    @NSManaged public var hue: Float
    @NSManaged public var blend: Float
    @NSManaged public var brightness: Float
    @NSManaged public var saturation: Float
    @NSManaged public var limbWidth: Int16
    @NSManaged public var wiggleFactor: Float
    @NSManaged public var wiggleMoveFactor: Float
    @NSManaged public var wiggleMoveBackFactor: Float
    @NSManaged public var wiggleActionDuration: Float
    @NSManaged public var wiggleActionBackDuration: Float
    @NSManaged public var wiggleActionMovementDuration: Float
    @NSManaged public var wiggleActionMovementBackDuration: Float
    @NSManaged public var limbzRotation: Float
    @NSManaged public var positionX: Float
    @NSManaged public var positionY: Float
    @NSManaged public var creature: ManagedCreature
}

extension ManagedLimb {
    func toStruct() -> Limb {
        return Limb(
            shape: BodyPart(rawValue: shape) ?? .triangle,
            hue: hue,
            blend: blend,
            brightness: brightness,
            saturation: saturation,
            limbWidth: Int(limbWidth),
            wiggleFactor: wiggleFactor,
            wiggleMoveFactor: wiggleMoveFactor,
            wiggleMoveBackFactor: wiggleMoveBackFactor,
            wiggleActionDuration: wiggleActionDuration,
            wiggleActionBackDuration: wiggleActionBackDuration,
            wiggleActionMovementDuration: wiggleActionMovementDuration,
            wiggleActionMovementBackDuration: wiggleActionMovementBackDuration,
            limbzRotation: limbzRotation,
            positionX: positionX,
            positionY: positionY
        )
    }
}
