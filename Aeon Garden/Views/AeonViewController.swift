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
import SnapKit

class AeonViewController: UIViewController {
    var scene: AeonTank?
    var skView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        view = SKView(frame: UIScreen.main.bounds)
        createTank()

        let menuButton = MenuButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        menuButton.addTarget(self, action: #selector(myButtonAction), for: .touchUpInside)

        view.addSubview(menuButton)
        menuButton.snp.makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.topMargin.equalToSuperview().offset(18)
            make.rightMargin.equalToSuperview().offset(-18)
        }

        let populationPill = DataPillView(frame: CGRect(x: 0, y: 0, width: 121, height: 30))

        view.addSubview(populationPill)
        populationPill.snp.makeConstraints { (make) in
            make.width.equalTo(121)
            make.height.equalTo(30)
            make.right.equalTo(menuButton.snp.left).offset(-18)
            make.topMargin.equalToSuperview().offset(18)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

extension AeonViewController {
    fileprivate func createTank() {
        scene = AeonTank(size: view.bounds.size)
        skView = view as? SKView
        scene!.scaleMode = .aspectFill
        scene!.backgroundColor = UIColor(red: 0.0706, green: 0.1961, blue: 0.2471, alpha: 1.0) /* #12323f */
        skView!.presentScene(scene)
    }
}

extension AeonViewController {
    @objc func myButtonAction(sender: UIButton!) {
        print("My Button tapped")
    }
}

