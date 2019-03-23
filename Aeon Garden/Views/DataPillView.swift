//
//  DataPillView.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/22/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit
import SnapKit

class DataPillView: UIView {

    let numberLabel: UILabel
    let titleLabel: UILabel
    let numberView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let titleGradientLayer: CAGradientLayer = CAGradientLayer()
    let numberGradientLayer: CAGradientLayer = CAGradientLayer()

    public var number: Int = 0 {
        didSet {
            numberLabel.text = String(number)
        }
    }
    public var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    override init(frame: CGRect) {
        titleLabel = UILabel(frame: frame)
        numberLabel = UILabel(frame: numberView.frame)

        super.init(frame: frame)

        backgroundColor = .clear
        layer.cornerRadius = 15

        // MARK: - Number View

        numberView.layer.cornerRadius = 15
        numberView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        numberView.clipsToBounds = true
        numberView.backgroundColor = UIColor(hue: 0.5861, saturation: 0.24, brightness: 0.89, alpha: 1.0)
        addSubview(numberView)

        numberView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(39)
        }

        numberLabel.textAlignment = .center
        numberLabel.text = String(number)
        numberLabel.font = numberLabel.font.withSize(14)
        numberLabel.textColor = UIColor(hue: 0.5778, saturation: 0.62, brightness: 0.49, alpha: 1.0)
        numberView.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(-2)
            make.centerY.equalToSuperview()
        }

        // MARK: - Title View

        titleView.layer.cornerRadius = 15
        titleView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        titleView.clipsToBounds = true
        titleView.backgroundColor = UIColor(hue: 0.5861, saturation: 0.07, brightness: 0.93, alpha: 1.0)
        addSubview(titleView)

        titleView.snp.makeConstraints { (make) in
            make.right.equalTo(numberView.snp.left)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }

        titleLabel.textAlignment = .center
        titleLabel.text = String(title)
        titleLabel.font = titleLabel.font.withSize(14)
        titleLabel.textColor = UIColor(hue: 0.5778, saturation: 0.62, brightness: 0.49, alpha: 1.0)
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-8)
        }

        // MARK: - Effects

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 4
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        layer.masksToBounds = false

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleGradientLayer.frame = titleView.bounds
        numberGradientLayer.frame = numberView.bounds
    }

}
