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
        self.animationTimeInterval = 1.0

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.animationTimeInterval = 1.0
    }

    override var frame: NSRect {
        didSet
        {
            self.spriteView?.frame = frame
        }
    }

    override func startAnimation() {
        if self.spriteView == nil {
            let spriteView = GameView(frame: self.frame)
            spriteView.ignoresSiblingOrder = true;
            spriteView.showsFPS = false;
            spriteView.showsNodeCount = false;
            let scene = AeonTankScene(size: frame.size)
            self.spriteView = spriteView
            addSubview(spriteView)
            spriteView.presentScene(scene)
        }
        super.startAnimation()
    }

}
