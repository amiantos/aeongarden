//
//  AeonViewController.swift
//  Aeon Garden tvOS
//
//  Created by Bradley Root on 3/28/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import GameplayKit
import SpriteKit
import UIKit

class AeonViewController: UIViewController {
    var scene: AeonTankScene?
    var skView: SKView?

    let mainMenu = AeonTVMainMenuView()
    let detailsView = AeonTVDetailsView(frame: CGRect(x: 0, y: 0, width: 1920, height: 1080))

    weak var selectedCreature: AeonCreatureNode? {
        didSet {
            if selectedCreature != nil && oldValue == nil {
                toggleMainMenu()
            } else if selectedCreature == nil && oldValue != nil {
                toggleMainMenu()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scene = AeonTankScene(size: view.bounds.size)
        scene?.tankDelegate = self

        // Present the scene
        skView = view as? SKView
        skView?.ignoresSiblingOrder = true
        skView?.presentScene(scene)

        setupTemporaryControls()

        //view.addSubview(mainMenu)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailsView)

        setNeedsFocusUpdate()
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if scene!.selectedCreature != nil {
            return [detailsView]
        } else {
            return [mainMenu]
        }
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
        if let selected = mateArray.randomElement() {
            selectedCreature = selected
            scene!.selectCreature(selected)
        }
    }

    @objc func deselectCreature() {
        selectedCreature = nil
        scene!.resetCamera()
    }

    func toggleMainMenu() {
        mainMenu.toggle()
        detailsView.toggle()
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
}

extension AeonViewController: AeonTankUIDelegate {
    func updateClock(_ clock: String) {
        mainMenu.clockLabel.data = clock
    }

    func updatePopulation(_ population: Int) {
        mainMenu.populationLabel.data = String(population)
    }

    func updateFood(_ food: Int) {
        mainMenu.foodLabel.data = String(food)
    }

    func updateBirths(_ births: Int) {
        mainMenu.birthsLabel.data = String(births)
    }

    func updateDeaths(_ deaths: Int) {
        mainMenu.deathsLabel.data = String(deaths)
    }

    func updateSelectedCreatureDetails(_ creature: AeonCreatureNode?) {
        if let creature = creature {
            detailsView.title = creature.name?.localizedUppercase
            detailsView.healthLabel.data = String(Int(creature.getCurrentHealth())).localizedUppercase
            detailsView.feelingLabel.data = creature.getCurrentState().localizedUppercase
            detailsView.ageLabel.data = creature.lifeTimeFormattedAsString().localizedUppercase
        }
    }
}
