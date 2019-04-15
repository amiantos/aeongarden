//
//  AeonDataButton.swift
//  Aeon Garden
//
//  Created by Bradley Root on 4/14/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class AeonDataButton: UIButton {


    var title: String = "" {
        didSet {
            setTitle(title, for: .normal)
            sizeToFit()
        }
    }
    var imageName: String = "" {
        didSet {
            let image = UIImage(named: imageName)!
            setImage(image, for: .normal)
        }
    }

    init(title: String, imageName: String) {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        super.init(frame: frame)

        self.title = title
        self.imageName = imageName
//        backgroundColor = .red

        let image = UIImage(named: imageName)!
        setImage(image, for: .normal)
        setTitle(title, for: .normal)
        setTitleColor(.gray, for: .normal)
        setTitleColor(.white, for: .focused)
        titleEdgeInsets.left = 10

        guard let label = titleLabel, let icon = imageView else { fatalError() }

        label.font = label.font.withSize(22)
//        label.backgroundColor = .black

        label.snp.makeConstraints { (make) in
            //make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        icon.contentMode = .scaleAspectFit
        icon.snp.makeConstraints { (make) in
            make.size.equalTo(40)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        setupDropShadow(icon)

        layoutSubviews()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupDropShadow(_ view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 2
        view.layer.rasterizationScale = UIScreen.main.scale
        view.layer.shouldRasterize = true
        view.layer.masksToBounds = false
    }

    override var intrinsicContentSize: CGSize {
        let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
        let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: labelSize.height)
        return desiredButtonSize
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
