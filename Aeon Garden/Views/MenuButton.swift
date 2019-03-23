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

        backgroundColor = .white
        layer.cornerRadius = 15

        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = frame.size
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor(hue: 0.5861, saturation: 0.07, brightness: 0.93, alpha: 1.0).cgColor
        ]
        layer.addSublayer(gradientLayer)
        clipsToBounds = true

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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
