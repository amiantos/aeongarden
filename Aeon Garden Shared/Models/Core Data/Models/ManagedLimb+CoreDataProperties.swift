//
//  ManagedLimb+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/6/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData


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
            shape: BodyPart(rawValue: self.shape) ?? .triangle,
            hue: self.hue,
            blend: self.blend,
            brightness: self.brightness,
            saturation: self.saturation,
            limbWidth: Int(self.limbWidth),
            wiggleFactor: self.wiggleFactor,
            wiggleMoveFactor: self.wiggleMoveFactor,
            wiggleMoveBackFactor: self.wiggleMoveBackFactor,
            wiggleActionDuration: self.wiggleActionDuration,
            wiggleActionBackDuration: self.wiggleActionBackDuration,
            wiggleActionMovementDuration: self.wiggleActionMovementDuration,
            wiggleActionMovementBackDuration: self.wiggleActionMovementBackDuration,
            limbzRotation: self.limbzRotation,
            positionX: self.positionX,
            positionY: self.positionY
        )
    }
}
