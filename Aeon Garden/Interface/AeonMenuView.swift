//
//  AeonMenuView.swift
//  Aeon Garden
//
//  Created by Bradley Root on 3/23/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class AeonMenuView: UIView {

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    private let titleLabel: UILabel
    private let menuTableView: UITableView = UITableView()
    private let menuContents: [UITableViewCell] = []

    override init(frame: CGRect) {
        titleLabel = UILabel(frame: frame)
        super.init(frame: frame)

        backgroundColor = .aeonUIBackgroundLight
        layer.cornerRadius = 15

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 15
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        layer.masksToBounds = false
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
