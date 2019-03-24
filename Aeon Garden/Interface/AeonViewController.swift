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
    var scene: AeonTankScene?
    var skView: SKView?

    let menuButton = AeonMenuButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    let populationDataPill = AeonDataPillView(frame: CGRect(x: 0, y: 0, width: 121, height: 30))
    let foodDataPill = AeonDataPillView(frame: CGRect(x: 0, y: 0, width: 121, height: 30))
    let menuView = AeonMenuView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        view = SKView(frame: UIScreen.main.bounds)
        createTank()

        menuButton.addTarget(self, action: #selector(myButtonAction), for: .touchUpInside)

        view.addSubview(menuButton)
        menuButton.snp.makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.topMargin.equalToSuperview().offset(36)
            make.rightMargin.equalToSuperview().offset(-18)
        }

        view.addSubview(foodDataPill)
        foodDataPill.title = "Food"
        foodDataPill.snp.makeConstraints { (make) in
            make.height.greaterThanOrEqualTo(30)
            make.right.equalTo(menuButton.snp.left).offset(-16)
            make.topMargin.equalToSuperview().offset(36)
        }

        view.addSubview(populationDataPill)
        populationDataPill.title = "Population"
        populationDataPill.snp.makeConstraints { (make) in
            make.height.greaterThanOrEqualTo(30)
            make.right.equalTo(foodDataPill.snp.left).offset(-16)
            make.topMargin.equalToSuperview().offset(36)
        }

        view.addSubview(menuView)
        menuView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(300)
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

extension AeonViewController: AeonTankDelegate {
    func updateFood(_ food: Int) {
        foodDataPill.number = food
    }

    func updatePopulation(_ population: Int) {
        populationDataPill.number = population
    }
}

extension AeonViewController {
    fileprivate func createTank() {
        scene = AeonTankScene(size: view.bounds.size)
        scene?.tankDelegate = self
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
