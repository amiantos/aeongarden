//
//  AeonTankSettings.swift
//  Aeon Garden
//
//  Created by Brad Root on 4/9/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SpriteKit

struct AeonTankSettings {
    let foodMaxAmount: Int
    let foodHealthRestorationBaseValue: Int
    let foodSpawnRate: Int

    let creatureInitialAmount: Int
    let creatureMinimumAmount: Int
    let creatureSpawnRate: Int

    let backgroundColor: SKColor
    let backgroundParticleBirthrate: Int
    let backgroundParticleLifetime: Int
}
