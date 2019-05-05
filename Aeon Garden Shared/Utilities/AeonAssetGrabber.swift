//
//  AeonAssetGrabber.swift
//  Aeon Garden
//
//  Created by Bradley Root on 5/5/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SpriteKit

#if os(macOS)
    import Cocoa

    // Step 1: Typealias UIImage to NSImage
    typealias UIImage = NSImage
#endif

// For screensaver support, we need to manually grab files out of the bundle.
// This creates a lot of hassle that wouldn't be necessary otherwise.

class AeonFileGrabber {
    let bundle: Bundle

    static let shared: AeonFileGrabber = AeonFileGrabber()

    init() {
        guard let bundle = Bundle(identifier: "net.amiantos.Aeon-Garden") else { fatalError("Could not load main bundle.") }
        self.bundle = bundle
    }

    private func getFileContents(named: String, ofType type: String) -> Data? {
        guard let filePath = bundle.path(forResource: named, ofType: type) else { return nil }

        guard let fileContents = FileManager.default.contents(atPath: filePath) else { return nil }

        return fileContents
    }

    public func getSKEmitterNode(named: String) -> SKEmitterNode? {
        guard let fileContents = getFileContents(named: named, ofType: "sks") else { return nil }
        guard let decodedEmitter = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileContents) as? SKEmitterNode else { return nil }

        return decodedEmitter
    }

    public func getSKTexture(named: String) -> SKTexture? {
        #if os(macOS)
            guard let image = bundle.image(forResource: named) else { return nil }
        #else
            guard let image = UIImage(named: named, in: bundle, compatibleWith: nil) else { return nil }
        #endif
        return SKTexture(image: image)
    }
}
