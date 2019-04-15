//
//  GameViewController.swift
//  Aeon Garden tvOS
//
//  Created by Bradley Root on 3/28/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import GameplayKit
import SpriteKit
import UIKit
import SnapKit

class GameViewController: UIViewController {
    var scene: AeonTankScene?
    var skView: SKView?

    let creatureDetailsView = AeonBlurredView()
    let creaturesDetailsViewSeparator = UIView()
    let creatureNameLabel = UILabel()
    let creatureHealthLabel = UILabel()
    let healthDataButton = AeonDataButton(title: "0", imageName: "healthIcon")
    let thoughtDataButton = AeonDataButton(title: "Newborn", imageName: "thoughtIcon")
    let lifespanDataButton = AeonDataButton(title: "Newborn", imageName: "lifespanIcon")

    override func viewDidLoad() {
        super.viewDidLoad()

        scene = AeonTankScene(size: view.bounds.size)
        scene?.tankDelegate = self

        // Present the scene
        skView = view as? SKView
        skView?.ignoresSiblingOrder = true
        skView?.presentScene(scene)

//        skView?.showsFPS = true
//        skView?.showsNodeCount = true

        setupTemporaryControls()

        view.addSubview(creatureDetailsView)
        creatureDetailsView.backgroundColor = .clear
        creatureDetailsView.layer.cornerRadius = 5
        creatureDetailsView.clipsToBounds = true
        creatureDetailsView.snp.makeConstraints { (make) in
            make.width.equalTo(700)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-60)
            make.leading.greaterThanOrEqualToSuperview().offset(90)
            make.trailing.lessThanOrEqualToSuperview().offset(-90)
        }

        creatureDetailsView.addSubview(creatureNameLabel)
        creatureNameLabel.textAlignment = .center
        creatureNameLabel.textColor = .white
        creatureNameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(60)
            make.trailing.equalToSuperview().offset(-60)
        }

        creatureDetailsView.addSubview(creaturesDetailsViewSeparator)
        creaturesDetailsViewSeparator.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 0.1)
        creaturesDetailsViewSeparator.layer.cornerRadius = 1
        creaturesDetailsViewSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(creatureNameLabel.snp.bottom).offset(20)
            make.height.equalTo(2)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        creatureDetailsView.isHidden = true

        creatureDetailsView.addSubview(healthDataButton)
        creatureDetailsView.addSubview(thoughtDataButton)
        creatureDetailsView.addSubview(lifespanDataButton)
        healthDataButton.isEnabled = false
        lifespanDataButton.isEnabled = false
        thoughtDataButton.isEnabled = false

        healthDataButton.snp.makeConstraints { (make) in
            make.top.equalTo(creaturesDetailsViewSeparator.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-30)
        }

        thoughtDataButton.snp.makeConstraints { (make) in
            make.top.equalTo(creaturesDetailsViewSeparator.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }

        lifespanDataButton.snp.makeConstraints { (make) in
            make.top.equalTo(creaturesDetailsViewSeparator.snp.bottom).offset(25)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-30)
        }

    }

    @objc func deselectCreature() {
        scene!.resetCamera()
    }

    fileprivate func setupTemporaryControls() {
        let selectCreatureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectRandomCreature))
        selectCreatureRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        view.addGestureRecognizer(selectCreatureRecognizer)

        let deselectCreatureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deselectCreature))
        deselectCreatureRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        view.addGestureRecognizer(deselectCreatureRecognizer)
    }

    @objc func selectRandomCreature() {
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

    fileprivate func setupDropShadow(_ view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 2
        view.layer.rasterizationScale = UIScreen.main.scale
        view.layer.shouldRasterize = true
        view.layer.masksToBounds = false
    }

}

extension GameViewController: AeonTankDelegate {
    func updatePopulation(_ population: Int) {
        return
    }

    func updateFood(_ food: Int) {
        return
    }

    func updateBirths(_ births: Int) {
        return
    }

    func updateDeaths(_ deaths: Int) {
        return
    }

    func updateSelectedCreatureDetails(_ creature: AeonCreatureNode?) {
        if let creature = creature {
            creatureDetailsView.isHidden = false
            creatureNameLabel.text = creature.name
            thoughtDataButton.title = creature.getCurrentState()
            lifespanDataButton.title = creature.lifeTimeFormattedAsString()
            healthDataButton.title = String(Int(creature.getCurrentHealth().rounded()))
        } else {
            creatureDetailsView.isHidden = true
        }

    }


}
