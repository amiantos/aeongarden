//
//  GameViewController.swift
//  Aeon Garden
//
//  Created by Bradley Root on 9/30/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//

import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
    var scene: GameScene?
    var skView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        scene = GameScene(size: view.bounds.size)
        skView = view as? SKView
        //skView!.showsFPS = true
        //skView!.showsNodeCount = true
        skView!.ignoresSiblingOrder = false
        // skView!.showsPhysics = true
        scene!.scaleMode = .aspectFill
        scene!.backgroundColor = UIColor(red: 0.102, green: 0.2824, blue: 0.3569, alpha: 1.0) /* #1a485b */
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
