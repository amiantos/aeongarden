//
//  AeonCameraNode.swift
//  Aeon Garden
//
//  Created by Brad Root on 2/9/20.
//  Copyright © 2020 Brad Root. All rights reserved.
//

import SpriteKit

protocol AeonCameraDelegate: AnyObject {
    func resetCamera()
    func enableAutoCamera()
    func disableAutoCamera()
    func creatureSelected(_ creature: AeonCreatureNode)
    func creatureDeselected()
}

class AeonCameraNode: SKCameraNode, Updatable, AeonCameraDelegate {
    var body: AeonCameraBodyNode = AeonCameraBodyNode()
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

    // MARK: - Delegate Functions

    func resetCamera() {
        Log.debug("📷 Camera resetting.")
        zoom(.zoomOut)
    }

    func enableAutoCamera() {
        Log.debug("📷 Auto camera started.")

        if let scene = scene, body.scene == nil {
            Log.debug("📷 Creating camera body in scene.")
            scene.addChild(body)
        }

        // Set body to current camera position for smooth transition
        body.position = position

        selectedNode(body)
        body.pickRandomTarget()
    }

    func disableAutoCamera() {
        Log.debug("📷 Auto camera stopped.")
    }

    func creatureSelected(_ creature: AeonCreatureNode) {
        selectedNode(creature)
    }

    func creatureDeselected() {
        deselectNode(animated: true)
    }

    // MARK: - Camera Controls

    func selectedNode(_ node: SKNode) {
        if selectedNode == node {
            deselectNode()
        } else {
            Log.info("📷 Selected Node")
            selectedNode = node
            if selectedNode is AeonCreatureNode {
                zoom(.fullZoom, speed: 1)
            } else {
                changeCameraZoomLevel()
            }
        }
    }

    func deselectNode(animated: Bool = true) {
        selectedNode = nil
        if animated {
            zoom(.zoomOut)
        }
    }

    func zoom(_ state: zoomState, speed: TimeInterval = 1) {
        removeAllActions()
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

    @objc func changeCameraZoomLevel() {
        Log.debug("📷 Camera auto-zoom updated.")

        zoomTimer?.invalidate()

        zoomTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(changeCameraZoomLevel), userInfo: nil, repeats: false)

        let randomZoomLevels: [zoomState] = [.halfZoom, .threeQuartersZoom, .fullZoom]
        zoom(randomZoomLevels.randomElement()!, speed: 20)
    }

    // MARK: - Lifecycle

    func update(_ currentTime: TimeInterval) {
        if let selectedNode = self.selectedNode {
            let cameraAction = SKAction.move(to: selectedNode.position, duration: cameraMoveDuration)
            run(cameraAction)
        }
        body.update(currentTime)
        lastUpdateTime = currentTime
    }
}
