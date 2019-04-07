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

import SnapKit
import SpriteKit
import UIKit

class AeonViewController: UIViewController {
    var scene: AeonTankScene?
    var skView: SKView?

    let menuButton = AeonMenuButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let populationDataPill = AeonDataPillView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let deathsDataPill = AeonDataPillView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let birthsDataPill = AeonDataPillView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let foodDataPill = AeonDataPillView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let menuView = AeonMenuView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        view = SKView(frame: UIScreen.main.bounds)
        createTank()

        menuButton.addTarget(self, action: #selector(myButtonAction), for: .touchUpInside)

        view.addSubview(menuButton)
        menuButton.snp.makeConstraints { make in
            make.width.equalTo(36)
            make.height.equalTo(36)
            make.topMargin.equalToSuperview().offset(36)
            make.rightMargin.equalToSuperview().offset(-18)
        }

        view.addSubview(foodDataPill)
        foodDataPill.title = "Food"
        foodDataPill.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(30)
            make.rightMargin.equalToSuperview().offset(-18)
            make.bottomMargin.equalToSuperview().offset(-36)
        }

        view.addSubview(deathsDataPill)
        deathsDataPill.title = "Deaths"
        deathsDataPill.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(30)
            make.rightMargin.equalToSuperview().offset(-18)
            make.bottom.equalTo(foodDataPill.snp.top).offset(-36)
        }

        view.addSubview(birthsDataPill)
        birthsDataPill.title = "Births"
        birthsDataPill.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(30)
            make.rightMargin.equalToSuperview().offset(-18)
            make.bottom.equalTo(deathsDataPill.snp.top).offset(-18)
        }

        view.addSubview(populationDataPill)
        populationDataPill.title = "Population"
        populationDataPill.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(30)
            make.rightMargin.equalToSuperview().offset(-18)
            make.bottom.equalTo(birthsDataPill.snp.top).offset(-18)
        }

        view.addSubview(menuView)
        menuView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(300)
        }
        menuView.isHidden = true
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
    func updateBirths(_ births: Int) {
        birthsDataPill.number = births
    }

    func updateDeaths(_ deaths: Int) {
        deathsDataPill.number = deaths
    }

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
        skView!.presentScene(scene)
    }
}

extension AeonViewController {
    @objc func myButtonAction(sender _: UIButton!) {
        menuView.isHidden.toggle()
    }
}
