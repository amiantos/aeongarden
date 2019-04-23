//
//  AeonViewController.swift
//  Aeon Garden macOS
//
//  Created by Bradley Root on 3/28/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Cocoa
import GameplayKit
import SnapKit
import SpriteKit

class AeonViewController: NSViewController {
    let population = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 200))
    let populationLabel = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 200))

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = AeonTankScene(size: view.bounds.size)
        scene.tankDelegate = self

        // Present the scene
        let skView = view as! SKView
        skView.presentScene(scene)

        skView.ignoresSiblingOrder = true

        skView.showsDrawCount = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        population.setValue(NSColor.windowFrameColor, forKey: "backgroundColor")

        view.addSubview(population)
        population.snp.makeConstraints { make in
            make.width.equalTo(36)
            make.height.equalTo(36)
            make.topMargin.equalToSuperview().offset(36)
            make.rightMargin.equalToSuperview().offset(-18)
        }

        populationLabel.textColor = .windowFrameTextColor
        populationLabel.sizeToFit()
        populationLabel.isBezeled = false
        populationLabel.isEditable = false
        population.addSubview(populationLabel)
        populationLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        populationLabel.stringValue = "0"
    }
}

extension AeonViewController: AeonTankUIDelegate {
    func updatePopulation(_ population: Int) {
        populationLabel.stringValue = "\(population)"
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
