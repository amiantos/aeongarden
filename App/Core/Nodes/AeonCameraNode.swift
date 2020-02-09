//
//  AeonCameraNode.swift
//  Aeon Garden
//
//  Created by Brad Root on 2/9/20.
//  Copyright © 2020 Brad Root. All rights reserved.
//

import SpriteKit

class AeonCameraNode: SKCameraNode, Updatable {
    var body: AeonCameraBodyNode?
    var selectedNode: SKNode?
    var autoCameraIsEnabled: Bool = false
    let cameraMoveDuration: TimeInterval = 0.25
    var lastUpdateTime: TimeInterval = 0
    var currentZoomState: zoomState = .zoomOut
    weak var interfaceDelegate: AeonTankInterfaceDelegate?

    enum zoomState {
        case zoomIn
        case zoomOut
    }

    // MARK: - Functions

    func selectedNode(_ node: SKNode) {
        if selectedNode == node {
            deselectNode()
        } else {
            Log.info("Selected Node")
            if let currentCreature = selectedNode as? AeonCreatureNode, currentCreature != node {
                currentCreature.hideSelectionRing()
            }

            selectedNode = node
            if let newCreature = selectedNode as? AeonCreatureNode {
                newCreature.displaySelectionRing(withColor: .aeonBrightYellow)
                interfaceDelegate?.creatureSelected(newCreature)
            }

            zoom(.zoomIn)
        }
    }

    func deselectNode(animated: Bool = true) {
        Log.info("Deselected Node")
        if let currentCreature = selectedNode as? AeonCreatureNode {
            currentCreature.hideSelectionRing()
            if animated {
                interfaceDelegate?.creatureDeselected()
            }
        }
        selectedNode = nil
        if animated {
            zoom(.zoomOut)
        }
    }

    func zoom(_ state: zoomState) {
        switch state {
        case .zoomIn:
            run(SKAction.scale(to: 0.4, duration: 1))
            currentZoomState = .zoomIn
        case .zoomOut:
            guard let scene = scene else { fatalError("Camera is not in a scene.") }
            removeAllActions()
            let scaleAction = SKAction.scale(to: 1, duration: 1)
            let moveAction = SKAction.move(
                to: CGPoint(x: scene.size.width / 2, y: scene.size.height / 2),
                duration: 1
            )
            run(SKAction.group([scaleAction, moveAction]))
            currentZoomState = .zoomOut
        }
    }

    func update(_ currentTime: TimeInterval) {
        if let selectedNode = self.selectedNode {
            let cameraAction = SKAction.move(to: selectedNode.position, duration: cameraMoveDuration)
            run(cameraAction)
        }
        lastUpdateTime = currentTime
    }

    func startAutoCamera() {
        Log.debug("Auto camera started...")
//            deselectNode(animated: false)
        guard let body = body else { fatalError("No body for auto-camera to attach to.") }
        selectedNode(body)
        body.pickRandomTarget()
        //        selectedCreature?.hideSelectionRing()
        //        selectedCreature = nil
        //
        //        camera?.removeAllActions()
        //        autoCameraIsEnabled = true
    }

    func stopAutoCamera() {
        Log.debug("Auto camera stopped.")

        //        camera?.removeAllActions()
        //        autoCameraIsEnabled = false
        //        if let zoomTimer = zoomTimer {
        //            zoomTimer.invalidate()
        //        }
        //        zoomTimer = nil
        //        if let moveTimer = moveTimer {
        //            moveTimer.invalidate()
        //        }
        //        moveTimer = nil
    }

    //    var zoomTimer: Timer?
    //    @objc func changeCameraZoomLevel() {
    //        Log.debug("Camera auto-zoom triggered.")
    //
    //        if let zoomTimer = zoomTimer {
    //            zoomTimer.invalidate()
    //        }
    //
    //        zoomTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(changeCameraZoomLevel), userInfo: nil, repeats: false)
    //
    //        let randomZoomLevel = randomCGFloat(min: 0.4, max: 0.8)
    //        let action = SKAction.scale(to: randomZoomLevel, duration: 20)
    //        action.timingMode = .easeInEaseOut
    //        camera?.run(action)
    //    }
    //
    //    var moveTimer: Timer?
    //    @objc func changeCameraPosition() {
    //        Log.debug("Camera auto-move triggered.")
    //
    //        if let moveTimer = moveTimer {
    //            moveTimer.invalidate()
    //        }
    //
    //        moveTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(changeCameraPosition), userInfo: nil, repeats: false)
    //
    //        let randomPosition = creatureNodes.randomElement()?.position ?? CGPoint(x: size.width / 2, y: size.height / 2)
    //        let action = SKAction.move(to: randomPosition, duration: 45)
    //        action.timingMode = .easeInEaseOut
    //        camera?.run(action)
    //    }
}
