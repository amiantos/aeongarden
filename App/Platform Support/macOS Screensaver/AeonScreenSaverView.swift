//
//  AeonScreenSaverView.swift
//  Aeon Garden Screensaver
//
//  Created by Bradley Root on 5/4/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Cocoa
import ScreenSaver
import SpriteKit

class AeonScreenSaverView: ScreenSaverView {
    var spriteView: GameView?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        animationTimeInterval = 1.0
    }

    override var frame: NSRect {
        didSet {
            self.spriteView?.frame = frame
        }
    }

    override func startAnimation() {
        if spriteView == nil {
            let tankSettings = TankSettings(
                foodMaxAmount: 30,
                foodHealthRestorationBaseValue: 120,
                foodSpawnRate: 2,
                creatureInitialAmount: 30,
                creatureMinimumAmount: 20,
                creatureSpawnRate: 5,
                creatureBirthSuccessRate: 1,
                backgroundParticleBirthrate: 120,
                backgroundParticleLifetime: 120
            )
            let spriteView = GameView(frame: frame)
            spriteView.ignoresSiblingOrder = false
            spriteView.showsFPS = false
            spriteView.showsNodeCount = false
            let scene = AeonTankScene(size: frame.size)
            scene.tankSettings = tankSettings
            self.spriteView = spriteView
            addSubview(spriteView)
            spriteView.presentScene(scene)
            scene.startAutoCamera()
            scene.createInitialCreatures()
            scene.createInitialBubbles()
        }
        super.startAnimation()
    }
}
