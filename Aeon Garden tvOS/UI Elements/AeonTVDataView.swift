//
//  AeonTVDataView.swift
//  Aeon Garden tvOS
//
//  Created by Bradley Root on 4/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class AeonTVDataView: UIView {
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
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dataLabel)
        dataLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        dataLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        dataLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        dataLabel.font = UIFont.aeonDataFont
        dataLabel.backgroundColor = .aeonMediumRed
        dataLabel.textColor = .aeonBrightBrown

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: dataLabel.leadingAnchor, constant: -10).isActive = true

        titleLabel.font = UIFont.aeonDataTitleFont
        titleLabel.textColor = .aeonBrightYellow
        titleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowRadius = 4
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        titleLabel.layer.shouldRasterize = true
        titleLabel.layer.rasterizationScale = UIScreen.main.scale
    }
}
