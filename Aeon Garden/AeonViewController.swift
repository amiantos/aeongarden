//
//  AeonViewController.swift
//  Aeon Garden
//
//  Created by Bradley Root on 9/30/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit
import UIKit

class AeonViewController: UIViewController {
    var scene: AeonTank?
    var skView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        scene = AeonTank(size: view.bounds.size)
        skView = view as? SKView
        // skView!.showsFPS = true
        // skView!.showsNodeCount = true
        // skView!.ignoresSiblingOrder = false
        // skView!.showsPhysics = true
        scene!.scaleMode = .aspectFill
        scene!.backgroundColor = UIColor(red: 0.0706, green: 0.1961, blue: 0.2471, alpha: 1.0) /* #12323f */
        skView!.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
