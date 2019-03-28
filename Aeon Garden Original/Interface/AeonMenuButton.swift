//
//  AeonMenuButton.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/22/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnapKit
import UIKit

class AeonMenuButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .aeonUIBackgroundLight
        layer.cornerRadius = 18
        clipsToBounds = true

        let buttonIcon = UIImageView()
        buttonIcon.frame = frame
        buttonIcon.clipsToBounds = true
        buttonIcon.image = UIImage(named: "menuIcon")
        buttonIcon.tintColor = .aeonTintColor
        addSubview(buttonIcon)

        buttonIcon.snp.makeConstraints { make in
            make.width.equalTo(25)
            make.height.equalTo(25)
            make.center.equalToSuperview()
        }

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 4
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        layer.masksToBounds = false
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
