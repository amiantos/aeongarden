//
//  AeonButton.swift
//  Aeon Garden tvOS
//
//  Created by Bradley Root on 4/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class AeonButton: UIButton {
    let style: UIStyle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .aeonDarkRed
        layer.borderColor = UIColor.aeonBrightYellow.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        if style == .tvos {
            titleLabel?.font = UIFont.aeonButtonFontTV
        } else {
            titleLabel?.font = UIFont.aeonButtonFontiOS
        }
        titleLabel?.backgroundColor = .aeonDarkRed
        setTitleColor(.aeonBrightYellow, for: .normal)

        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 35).isActive = true
        titleLabel?.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true

        sizeToFit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch")
        super.touchesBegan(touches, with: event)
    }

    override func didUpdateFocus(in _: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            let duration = UIView.inheritedAnimationDuration
            if self.isFocused {
                UIView.animate(withDuration: 0.2 * duration, delay: 0, options: .curveEaseInOut, animations: {
                    self.liftButton()
                }, completion: nil)
                let animation = CABasicAnimation(keyPath: "shadowOpacity")
                animation.fromValue = self.layer.shadowOpacity
                animation.toValue = 0.4
                animation.duration = 0.2 * duration
                self.layer.add(animation, forKey: animation.keyPath)
                let animation2 = CABasicAnimation(keyPath: "borderWidth")
                animation2.fromValue = self.layer.borderWidth
                animation2.toValue = 5
                animation2.duration = 0.2 * duration
                self.layer.add(animation2, forKey: animation2.keyPath)
                self.layer.borderWidth = 5
            } else {
                UIView.animate(withDuration: 1 * duration, animations: {
                    self.restButton()
                }, completion: nil)
                let animation = CABasicAnimation(keyPath: "shadowOpacity")
                animation.fromValue = self.layer.shadowOpacity
                animation.toValue = 0.25
                animation.duration = 1.0
                self.layer.add(animation, forKey: animation.keyPath)
                self.layer.shadowOpacity = 0.25
                let animation2 = CABasicAnimation(keyPath: "borderWidth")
                animation2.fromValue = self.layer.borderWidth
                animation2.toValue = 0
                animation2.duration = 0.2
                self.layer.add(animation2, forKey: animation2.keyPath)
                self.layer.borderWidth = 0
            }
        }, completion: nil)
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        if presses.count > 1 {
            return
        }
        for press in presses where press.type == .select {
            UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
                self.restButton()
                let animation = CABasicAnimation(keyPath: "shadowOpacity")
                animation.fromValue = self.layer.shadowOpacity
                animation.toValue = 0.25
                animation.duration = 0.2
                self.layer.add(animation, forKey: animation.keyPath)
                self.layer.shadowOpacity = 0.25
            }, completion: nil)
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)

        for press in presses where press.type == .select {
            UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
                self.liftButton()
                let animation = CABasicAnimation(keyPath: "shadowOpacity")
                animation.fromValue = self.layer.shadowOpacity
                animation.toValue = 0.4
                animation.duration = 0.3
                self.layer.add(animation, forKey: animation.keyPath)
                self.layer.shadowOpacity = 0.4
            }, completion: nil)
        }
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesCancelled(presses, with: event)
        for press in presses where press.type == .select {
            UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
                self.liftButton()
                let animation = CABasicAnimation(keyPath: "shadowOpacity")
                animation.fromValue = self.layer.shadowOpacity
                animation.toValue = 0.4
                animation.duration = 0.3
                self.layer.add(animation, forKey: animation.keyPath)
                self.layer.shadowOpacity = 0.4
            }, completion: nil)
        }
    }

    private func liftButton() {
        transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }

    private func restButton() {
        transform = .identity
    }
}
