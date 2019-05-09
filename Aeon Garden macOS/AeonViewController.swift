//
//  AeonViewController.swift
//  Aeon Garden macOS
//
//  Created by Bradley Root on 3/28/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
    func updateClock(_: String) {
        return
    }

    func updateSelectedCreatureDetails(_: AeonCreatureNode) {
        return
    }

    func creatureDeselected() {
        return
    }

    func creatureSelected(_: AeonCreatureNode) {
        return
    }

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
