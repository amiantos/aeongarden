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

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        layer.cornerRadius = 15
        clipsToBounds = true

        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = frame.size
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor(hue: 0.5861, saturation: 0.07, brightness: 0.93, alpha: 1.0).cgColor
        ]
        layer.addSublayer(gradientLayer)

        // MARK: - Number View
        let numberView = UIView(frame: CGRect(x: 0, y: 0, width: 39, height: 30))
        let numberGradientLayer: CAGradientLayer = CAGradientLayer()
        numberGradientLayer.frame.size = numberView.frame.size
        numberGradientLayer.colors = [
            UIColor(hue: 0, saturation: 0, brightness: 0.86, alpha: 1.0).cgColor,
            UIColor(hue: 0.5861, saturation: 0.24, brightness: 0.89, alpha: 1.0).cgColor
        ]
        numberView.layer.addSublayer(numberGradientLayer)
        addSubview(numberView)

        numberView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(39)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
