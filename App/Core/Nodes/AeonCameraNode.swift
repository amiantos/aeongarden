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
    var zoomTimer: Timer?
    var currentZoomState: zoomState = .zoomOut
    weak var interfaceDelegate: AeonTankInterfaceDelegate?

    enum zoomState {
        case fullZoom
        case threeQuartersZoom
        case halfZoom
        case quarterZoom
        case zoomOut
    }

    // MARK: - Functions

    func selectedNode(_ node: SKNode) {
        if selectedNode == node {
            deselectNode()
        } else {
            Log.info("📷 Selected Node")
            if let currentCreature = selectedNode as? AeonCreatureNode, currentCreature != node {
                currentCreature.hideSelectionRing()

                if let cameraBody = node as? AeonCameraBodyNode {
                    // If previously selected node was a creature,
                    // and the new node is the camera body,
                    // move the camera body there for a soft transition
                    cameraBody.position = currentCreature.position
                }
            }

            selectedNode = node
            if let newCreature = selectedNode as? AeonCreatureNode {
                newCreature.displaySelectionRing(withColor: .aeonBrightYellow)
                interfaceDelegate?.creatureSelected(newCreature)
                zoom(.fullZoom)
            } else {
                changeCameraZoomLevel()
            }
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

    func zoom(_ state: zoomState, speed: TimeInterval = 1) {
        switch state {
        case .fullZoom:
            run(SKAction.scale(to: 0.4, duration: speed))
            currentZoomState = .fullZoom
        case .threeQuartersZoom:
            run(SKAction.scale(to: 0.55, duration: speed))
            currentZoomState = .halfZoom
        case .halfZoom:
            run(SKAction.scale(to: 0.7, duration: speed))
            currentZoomState = .halfZoom
        case .quarterZoom:
            run(SKAction.scale(to: 0.85, duration: speed))
            currentZoomState = .halfZoom
        case .zoomOut:
            guard let scene = scene else { fatalError("Camera is not in a scene.") }
            removeAllActions()
            let scaleAction = SKAction.scale(to: 1, duration: speed)
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
        Log.debug("📷 Auto camera started...")
        guard let body = body else { fatalError("No body for auto-camera to attach to.") }
        selectedNode(body)
        body.pickRandomTarget()
    }

    func stopAutoCamera() {
        Log.debug("📷 Auto camera stopped.")
    }

    @objc func changeCameraZoomLevel() {
        Log.debug("📷 Camera auto-zoom updated.")

        zoomTimer?.invalidate()

        zoomTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(changeCameraZoomLevel), userInfo: nil, repeats: false)

        let randomZoomLevels: [zoomState] = [.halfZoom, .quarterZoom, .threeQuartersZoom, .fullZoom]
        zoom(randomZoomLevels.randomElement()!, speed: 20)
    }
}
