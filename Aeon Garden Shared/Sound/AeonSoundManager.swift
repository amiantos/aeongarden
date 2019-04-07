//
//  AeonSoundManager.swift
//  Aeon Garden iOS
//
//  Created by Bradley Root on 3/30/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SpriteKit

enum AeonSound: String {
    case bubblePop = "pop.wav"
    case creatureEat = "pop_drip.wav"
    case creatureMate = "click_04.wav"
    case creatureBorn = "pad_confirm.wav"
}

class AeonSoundManager {
    static let shared = AeonSoundManager()

    func play(_ sound: AeonSound, onNode node: SKNode) {
        node.run(SKAction.playSoundFileNamed(sound.rawValue, waitForCompletion: false))
    }

}
