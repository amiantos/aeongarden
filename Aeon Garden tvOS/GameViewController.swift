//
//  GameViewController.swift
//  Aeon Garden tvOS
//
//  Created by Bradley Root on 3/28/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var scene: AeonTankScene?
    var skView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = AeonTankScene(size: view.bounds.size)
        
        // Present the scene
        skView = self.view as? SKView
        skView?.presentScene(scene)
        
        skView?.showsFPS = true
        skView?.showsNodeCount = true

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)];
        self.view.addGestureRecognizer(tapRecognizer)

    }

    @objc func tapped() {
        var mateArray: [AeonCreatureNode] = []
        let nodes = scene!.children
        for case let child as AeonCreatureNode in nodes {
            mateArray.append(child)
        }
        let selected = mateArray.randomElement()!
        if selected == scene!.selectedCreature {
            scene!.resetCamera()
        } else {
            scene!.selectCreature(selected)
        }
    }

}
