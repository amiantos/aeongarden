//
//  AeonViewController.swift
//  Aeon Garden macOS
//
//  Created by Bradley Root on 3/28/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Cocoa
import GameplayKit
import SpriteKit

class AeonViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = AeonTankScene(size: view.bounds.size)
        scene.tankDelegate = self

        // Present the scene
        let skView = view as? SKView
        skView?.presentScene(scene)

        skView?.ignoresSiblingOrder = true

        skView?.showsDrawCount = true
        skView?.showsFPS = true
        skView?.showsNodeCount = true
    }
}

extension AeonViewController: AeonTankUIDelegate {
    func updatePopulation(_: Int) {
        return
    }

    func updateFood(_: Int) {
        return
    }

    func updateBirths(_: Int) {
        return
    }

    func updateDeaths(_: Int) {
        return
    }
}
