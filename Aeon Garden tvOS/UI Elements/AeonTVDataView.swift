//
//  AeonTVDataView.swift
//  Aeon Garden tvOS
//
//  Created by Bradley Root on 4/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SnapKit
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(titleLabel)
        addSubview(dataLabel)

        dataLabel.font = UIFont.aeonDataFont
        dataLabel.textColor = .aeonBrightBrown

        titleLabel.font = UIFont.aeonDataTitleFont
        titleLabel.textColor = .aeonBrightYellow
        titleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowRadius = 4
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        titleLabel.layer.shouldRasterize = true
        titleLabel.layer.rasterizationScale = UIScreen.main.scale

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalTo(dataLabel.snp.left).offset(-10)
        }

        dataLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        sizeToFit()
    }
}
