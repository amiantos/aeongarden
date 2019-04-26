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
    case creatureBorn = "aeonBirthSound.wav"
}

class AeonSoundManager {
    static let shared = AeonSoundManager()

    func play(_ sound: AeonSound, onNode node: SKNode) {
        var soundPath: String = ""
        if sound == .creatureBorn {
            let sounds = ["aeonBirthSound-C4.wav", "aeonBirthSound-E4.wav", "aeonBirthSound-G4.wav"]
            soundPath = sounds.randomElement()!
        } else if sound == .creatureMate {
            let sounds = ["aeonMateSound-C3.wav", "aeonMateSound-E3.wav", "aeonMateSound-G3.wav"]
            soundPath = sounds.randomElement()!
        } else {
            soundPath = sound.rawValue
        }
        node.run(SKAction.playSoundFileNamed(soundPath, waitForCompletion: false))
    }
}
