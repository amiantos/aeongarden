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

    var numberLabel: UILabel

    public var number: Int = 0 {
        didSet {
            numberLabel.text = String(number)
        }
    }
    public var title: String = "Population"

    override init(frame: CGRect) {
        let numberView = UIView(frame: CGRect(x: 0, y: 0, width: 39, height: 30))
        numberLabel = UILabel(frame: numberView.frame)

        super.init(frame: frame)

        backgroundColor = .clear
        layer.cornerRadius = 15
        clipsToBounds = true

        let gradientView: UIView = UIView(frame: frame)
        gradientView.isUserInteractionEnabled = false
        addSubview(gradientView)
        gradientView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = frame.size
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor(hue: 0.5861, saturation: 0.07, brightness: 0.93, alpha: 1.0).cgColor
        ]
        gradientView.layer.cornerRadius = 15
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.clipsToBounds = true

        // MARK: - Number View

        numberView.layer.cornerRadius = 15
        numberView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        let numberGradientLayer: CAGradientLayer = CAGradientLayer()
        numberGradientLayer.frame.size = numberView.frame.size
        numberGradientLayer.colors = [
            UIColor(hue: 0, saturation: 0, brightness: 0.86, alpha: 1.0).cgColor,
            UIColor(hue: 0.5861, saturation: 0.24, brightness: 0.89, alpha: 1.0).cgColor
        ]
        numberView.layer.addSublayer(numberGradientLayer)
        numberView.clipsToBounds = true
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
            make.edges.equalToSuperview()
        }

        let titleLabel = UILabel(frame: frame)
        titleLabel.textAlignment = .center
        titleLabel.text = String(title)
        titleLabel.font = titleLabel.font.withSize(14)
        titleLabel.textColor = UIColor(hue: 0.5778, saturation: 0.62, brightness: 0.49, alpha: 1.0)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalTo(numberView.snp.left)
        }

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 15).cgPath
        layer.masksToBounds = false

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
