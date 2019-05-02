//
//  AeonDataView.swift
//  Aeon Garden tvOS
//
//  Created by Bradley Root on 4/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class AeonDataView: UIView {
    let style: UIStyle
    let titleLabel = UILabel()
    let dataLabel = UILabel()

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var data: String? {
        didSet {
            dataLabel.text = self.data
        }
    }

    convenience init(name: String, initialValue value: String) {
        self.init(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        titleLabel.text = name
        dataLabel.text = value
    }

    override init(frame: CGRect) {
        #if os(iOS)
        style = .ios
        #elseif os(tvOS)
        style = .tvos
        #endif
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        #if os(iOS)
        style = .ios
        #elseif os(tvOS)
        style = .tvos
        #endif
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dataLabel)

        // MARK: - Constraints

        dataLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        dataLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dataLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: dataLabel.leadingAnchor, constant: -10).isActive = true

        // MARK: - Appearance

        if style == .tvos {
            dataLabel.font = UIFont.aeonDataFontTV
            titleLabel.font = UIFont.aeonDataTitleFontTV
        } else {
            dataLabel.font = UIFont.aeonDataFontiOS
            titleLabel.font = UIFont.aeonDataTitleFontiOS
        }

        dataLabel.backgroundColor = .aeonMediumRed
        dataLabel.textColor = .aeonBrightBrown
        titleLabel.textColor = .aeonBrightYellow
        titleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowRadius = 4
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        titleLabel.layer.shouldRasterize = true
        titleLabel.layer.rasterizationScale = UIScreen.main.scale
    }
}
