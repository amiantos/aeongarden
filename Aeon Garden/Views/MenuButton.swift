//
//  MenuButton.swift
//  Aeon Garden
//
//  Created by Brad Root on 3/22/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit
import SnapKit

class MenuButton: UIButton {

    override init(frame: CGRect) {
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

        let buttonIcon = UIImageView()
        buttonIcon.frame = frame
        buttonIcon.clipsToBounds = true
        buttonIcon.image = UIImage(named: "menuIcon")
        buttonIcon.tintColor = UIColor(hue: 0.5778, saturation: 0.62, brightness: 0.49, alpha: 1.0)
        addSubview(buttonIcon)

        buttonIcon.snp.makeConstraints { (make) in
            make.width.equalTo(25)
            make.height.equalTo(25)
            make.center.equalToSuperview()
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
