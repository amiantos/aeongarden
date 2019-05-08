//
//  AeonScreenSaverView.swift
//  Aeon Garden Screensaver
//
//  Created by Bradley Root on 5/4/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

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
            let tankSettings = AeonTankSettings(
                foodMaxAmount: 40,
                foodHealthRestorationBaseValue: 120,
                foodSpawnRate: 2,
                creatureInitialAmount: 50,
                creatureMinimumAmount: 5,
                creatureSpawnRate: 5,
                tankBackgroundColor: .aeonDarkBlue
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
        }
        super.startAnimation()
    }
}
