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

    let creatureDetailsView = AeonTVBlurredView()
    let creaturesDetailsViewSeparator = UIView()
    var vibrancyEffectView: UIVisualEffectView?
    var blurredEffectView: UIVisualEffectView?
    let creatureNameLabel = UILabel()
    let creatureHealthLabel = UILabel()
    let creatureThoughtLabel = UILabel()
    let creatureLifespanLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        scene = AeonTankScene(size: view.bounds.size)
        scene?.tankDelegate = self

        // Present the scene
        skView = view as? SKView
        skView?.ignoresSiblingOrder = true
        skView?.presentScene(scene)

        skView?.showsFPS = true
        skView?.showsNodeCount = true

        setupTemporaryControls()

        view.addSubview(creatureDetailsView)
        creatureDetailsView.backgroundColor = .clear
        creatureDetailsView.layer.cornerRadius = 5
        creatureDetailsView.clipsToBounds = true
        creatureDetailsView.snp.makeConstraints { (make) in
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
        creaturesDetailsViewSeparator.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 0.2)
        creaturesDetailsViewSeparator.layer.cornerRadius = 1
        creaturesDetailsViewSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(creatureNameLabel.snp.bottom).offset(20)
            make.height.equalTo(2)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        creatureDetailsView.addSubview(creatureHealthLabel)
        creatureDetailsView.addSubview(creatureLifespanLabel)
        creatureDetailsView.addSubview(creatureThoughtLabel)

        creatureHealthLabel.textColor = .gray
        creatureHealthLabel.textAlignment = .left
        creatureHealthLabel.font = creatureHealthLabel.font.withSize(20)
        creatureHealthLabel.snp.makeConstraints { (make) in
            make.top.equalTo(creaturesDetailsViewSeparator.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(60)
            make.trailing.equalTo(creatureDetailsView.snp.centerX).offset(-10)
        }

        creatureLifespanLabel.textColor = .gray
        creatureLifespanLabel.textAlignment = .right
        creatureLifespanLabel.font = creatureLifespanLabel.font.withSize(20)
        creatureLifespanLabel.snp.makeConstraints { (make) in
            make.top.equalTo(creaturesDetailsViewSeparator.snp.bottom).offset(25)
            make.leading.equalTo(creatureDetailsView.snp.centerX).offset(10)
            make.trailing.equalToSuperview().offset(-60)
        }

        creatureThoughtLabel.textColor = .white
        creatureThoughtLabel.textAlignment = .center
        creatureThoughtLabel.font = creatureThoughtLabel.font.withSize(26)
        creatureThoughtLabel.snp.makeConstraints { (make) in
            make.top.equalTo(creatureLifespanLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(60)
            make.trailing.equalToSuperview().offset(-60)
            make.bottom.equalToSuperview().offset(-30)
        }


        let blurEffect: UIBlurEffect = UIBlurEffect(style: .dark)
        blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView?.layer.cornerRadius = 5
        blurredEffectView?.clipsToBounds = true
        blurredEffectView?.frame = creatureDetailsView.bounds
        view.insertSubview(blurredEffectView!, at: 0)

        creatureDetailsView.isHidden = true
        blurredEffectView?.isHidden = true

    }

    override func viewDidLayoutSubviews() {
        blurredEffectView?.frame = creatureDetailsView.frame
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
            blurredEffectView?.isHidden = false
            creatureNameLabel.text = creature.name
            creatureThoughtLabel.text = creature.getCurrentState()
            creatureLifespanLabel.text = creature.lifeTimeFormattedAsString()
            creatureHealthLabel.text = "Health: " + String(Int(creature.getCurrentHealth().rounded()))
        } else {
            creatureDetailsView.isHidden = true
            blurredEffectView?.isHidden = true
        }

    }


}
