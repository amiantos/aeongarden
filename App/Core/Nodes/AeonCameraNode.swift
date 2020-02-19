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

    override init() {
        super.init()

        let body = SKSpriteNode(texture: circleTexture)
        body.color = .red
        body.colorBlendFactor = 1
        body.size = CGSize(width: 20, height: 20)
        body.zPosition = -3
        body.name = "AeonCameraBodySprite"
        addChild(body)

        let nameLabel = SKLabelNode(text: "Bradley Root")
        nameLabel.fontName = "HelveticaNeue-Bold"
        nameLabel.fontSize = 64
        nameLabel.zPosition = -3
        nameLabel.name = "label"
        nameLabel.fontColor = SKColor(hue: 0.5972, saturation: 0.54, brightness: 0.65, alpha: 1.0) /* #4c71a5 */
        nameLabel.alpha = 0.2

        let effectNode = SKEffectNode()
        effectNode.shouldEnableEffects = true
        effectNode.addChild(nameLabel)

        addChild(effectNode)
        effectNode.position = CGPoint(x: nameLabel.position.x, y: nameLabel.position.y - 40)

        let destinationPositions: [vector_float2] = [
            // bottom row: left, center, right
            vector_float2(-0.02, -0.02),
            vector_float2(0.5, 0.0),
            vector_float2(0.95, 0.02),

            // middle row: left, center, right
            vector_float2(0.0, 0.5),
            vector_float2(0.5, 0.5),
            vector_float2(1.0, 0.5),

            // top row: left, center, right
            vector_float2(0.0, 1.0),
            vector_float2(0.5, 1.0),
            vector_float2(1.0, 1.0)
        ]

        let destinationPositions2: [vector_float2] = [
            // bottom row: left, center, right
            vector_float2(0.02, 0.02),
            vector_float2(0.51, 0.01),
            vector_float2(1.01, 0.01),

            // middle row: left, center, right
            vector_float2(0.0, 0.5),
            vector_float2(0.52, 0.42),
            vector_float2(1.0, 0.5),

            // top row: left, center, right
            vector_float2(0.02, 1.02),
            vector_float2(0.51, 1.01),
            vector_float2(1.01, 1.01)
        ]

        var warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 2, rows: 2)
        warpGeometryGridNoWarp = warpGeometryGridNoWarp.replacingByDestinationPositions(positions: destinationPositions2)
        var warpGeometryGrid = SKWarpGeometryGrid(columns: 2, rows: 2)
        warpGeometryGrid = warpGeometryGrid.replacingByDestinationPositions(positions: destinationPositions)

        if let warpAction = SKAction.animate(withWarps:[warpGeometryGrid,
                   warpGeometryGridNoWarp],
                                             times: [1, 2]) {
            warpAction.timingMode = .easeInEaseOut
            effectNode.run(SKAction.repeatForever(warpAction))

        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Delegate Functions

    func resetCamera() {
        Log.debug("📷 Camera resetting.")
        disableAutoCamera()
        selectedNode = nil
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
        changeCameraZoomLevel()
    }

    func disableAutoCamera() {
        Log.debug("📷 Auto camera stopped.")
        zoomTimer?.invalidate()
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
        Log.debug("🤳 Camera auto-zoom updated.")

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
