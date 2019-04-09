//
//  GameViewController.swift
//  Aeon Garden macOS
//
//  Created by Bradley Root on 3/28/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Cocoa
import GameplayKit
import SpriteKit

class GameViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = AeonTankScene(size: view.bounds.size)

        // Present the scene
        let skView = view as! SKView
        skView.presentScene(scene)

        skView.ignoresSiblingOrder = true

        skView.showsDrawCount = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
}
