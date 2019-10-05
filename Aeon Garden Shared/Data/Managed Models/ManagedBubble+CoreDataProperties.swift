//
//  ManagedBubble+CoreDataProperties.swift
//  Aeon Garden
//
//  Created by Brad Root on 10/5/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedBubble {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedBubble> {
        return NSFetchRequest<ManagedBubble>(entityName: "ManagedBubble")
    }


}
