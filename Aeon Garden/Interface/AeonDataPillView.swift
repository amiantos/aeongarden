//
//  AeonDataPillView.swift
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

class AeonDataPillView: UIView {
    let numberLabel: UILabel
    let numberView: UIView
    public var number: Int = 0 {
        didSet {
            numberLabel.text = String(number)
        }
    }

    let titleLabel: UILabel
    let titleView: UIView
    public var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    override init(frame: CGRect) {
        titleLabel = UILabel(frame: frame)
        numberLabel = UILabel(frame: frame)
        numberView = UIView(frame: frame)
        titleView = UIView(frame: frame)

        super.init(frame: frame)

        backgroundColor = .clear
        layer.cornerRadius = 15

        setupNumberView()
        setupTitleView()
        setupDropShadow()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupNumberView() {
        numberView.layer.cornerRadius = 15
        numberView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        numberView.clipsToBounds = true
        numberView.backgroundColor = .aeonUIBackgroundDark
        addSubview(numberView)

        numberView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(39)
        }

        numberLabel.textAlignment = .center
        numberLabel.text = String(number)
        numberLabel.font = numberLabel.font.withSize(14)
        numberLabel.textColor = .aeonTintColor
        numberView.addSubview(numberLabel)

        numberLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-2)
            make.centerY.equalToSuperview()
        }
    }

    fileprivate func setupTitleView() {
        titleView.layer.cornerRadius = 15
        titleView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        titleView.clipsToBounds = true
        titleView.backgroundColor = .aeonUIBackgroundLight
        addSubview(titleView)

        titleView.snp.makeConstraints { make in
            make.right.equalTo(numberView.snp.left)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }

        titleLabel.textAlignment = .center
        titleLabel.text = String(title)
        titleLabel.font = titleLabel.font.withSize(14)
        titleLabel.textColor = .aeonTintColor
        titleView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-8)
        }
    }

    fileprivate func setupDropShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 4
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        layer.masksToBounds = false
    }
}
