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

    let mainMenu = AeonMainMenuView(frame: CGRect(x: 0, y: 0, width: 1920, height: 1080))

    override func viewDidLoad() {
        super.viewDidLoad()

        scene = AeonTankScene(size: view.bounds.size)
        scene?.tankDelegate = self

        // Present the scene
        skView = view as? SKView
        skView?.ignoresSiblingOrder = true
        skView?.presentScene(scene)

        setupTemporaryControls()

//        let button = UIButton(type: .system)
//        let button2 = UIButton(type: .system)
//        button.setTitle("Hello", for: .normal)
//        button2.setTitle("Goodbye", for: .normal)
//
//        view.addSubview(button)
//        view.addSubview(button2)
//
//        button.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(60)
//            make.left.equalToSuperview().offset(60)
//        }
//
//        button2.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(60)
//            make.left.equalTo(button.snp.right).offset(60)
//        }

        view.addSubview(mainMenu)

        self.setNeedsFocusUpdate()

//        for family in UIFont.familyNames {
//            print("\(family)")
//            for names in UIFont.fontNames(forFamilyName: family){
//                print("== \(names)")
//            }
//        }

    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        //if subview exists, return the subview or the button, whichever is focusable
        return [mainMenu]
        //otherwise use the default implementation of AVPlayerController
        return super.preferredFocusEnvironments
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        print("Updated Focus...")
    }

    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        print("Check to should update focus?")
        return super.shouldUpdateFocus(in: context)
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
        return
    }


}
