//
//  AeonNodeProtocols.swift
//  Aeon Garden
//
//  Created by Bradley Root on 3/24/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SpriteKit

protocol Updatable {
    func update(_ currentTime: TimeInterval)
    var lastUpdateTime: TimeInterval { get set }
}

protocol Selectable {
    var selectionRing: SKSpriteNode { get }
    func setupSelectionRing()
    func displaySelectionRing(withColor color: SKColor)
    func hideSelectionRing()
}
