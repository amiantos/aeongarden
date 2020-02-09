//
//  AeonCameraNode.swift
//  Aeon Garden
//
//  Created by Brad Root on 2/9/20.
//  Copyright © 2020 Brad Root. All rights reserved.
//

import SpriteKit

class AeonCameraNode: SKCameraNode, Updatable {
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
                self.zoom(.zoomIn)
            }
        }
    }

    func deselectNode() {
        Log.info("Deselected Node")
        if let currentCreature = selectedNode as? AeonCreatureNode {
            currentCreature.hideSelectionRing()
            interfaceDelegate?.creatureDeselected()
        }
        selectedNode = nil
        self.zoom(.zoomOut)
    }

    func zoom(_ state: zoomState) {
        switch state {
        case .zoomIn:
            self.run(SKAction.scale(to: 0.4, duration: 1))
            currentZoomState = .zoomIn
        case .zoomOut:
            guard let scene = scene else { fatalError("Camera is not in a scene.") }
            self.removeAllActions()
            let scaleAction = SKAction.scale(to: 1, duration: 1)
            let moveAction = SKAction.move(
                to: CGPoint(x: scene.size.width / 2, y: scene.size.height / 2),
                duration: 1
            )
            self.run(SKAction.group([scaleAction, moveAction]))
            currentZoomState = .zoomOut
        }
    }


    func update(_ currentTime: TimeInterval) {
        if let selectedNode = self.selectedNode {
            let cameraAction = SKAction.move(to: selectedNode.position, duration: cameraMoveDuration)
            self.run(cameraAction)
        }
        lastUpdateTime = currentTime
    }


}
