
//
//  AeonBlurredView.swift
//  Aeon Garden tvOS
//
//  Created by Bradley Root on 4/11/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class AeonBlurredView: UIView {

    let blurredEffectView: UIVisualEffectView

    override init(frame: CGRect) {
        let blurEffect: UIBlurEffect = UIBlurEffect(style: .dark)
        blurredEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(frame: frame)
        blurredEffectView.layer.cornerRadius = 5
        blurredEffectView.clipsToBounds = true
        blurredEffectView.frame = self.bounds
        self.insertSubview(blurredEffectView, at: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurredEffectView.frame = self.bounds

    }

}
