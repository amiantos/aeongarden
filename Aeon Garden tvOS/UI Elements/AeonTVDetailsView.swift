//
//  AeonTVDetailsView.swift
//  Aeon Garden tvOS
//
//  Created by Bradley Root on 4/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class AeonTVDetailsView: UIView {
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 1250, height: 300))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    func sharedInit() {
        setupView()
        setupButtons()
        setupDataLabels()
    }

    // MARK: - View Setup

    private let backgroundView = UIView()
    private let titleLabel = UILabel()

    var title: String? = "BRADLEY ROBERT ROOT" {
        didSet {
            if self.title != oldValue {
                let currentShadowPath = self.backgroundView.bounds
                let newShadowPath = self.backgroundView.bounds
                let animation = UIViewPropertyAnimator(duration: 1, curve: .easeInOut, animations: {
                    self.backgroundWidthConstraint.constant = self.titleLabel.bounds.width + 66
                    self.titleLabel.alpha = 1
                    self.layoutIfNeeded()
                })
                animation.addCompletion { (position) in
                    self.titleLabel.alpha = 1
                    self.backgroundWidthConstraint.constant = self.titleLabel.bounds.width + 66
                }

                let fadeOutAnimation = UIViewPropertyAnimator(duration: 0.2, curve: .linear, animations: {
                    self.titleLabel.alpha = 0
                })
                fadeOutAnimation.addCompletion { (position) in
                    if position == .end {
                        self.titleLabel.text = self.title
                        self.layoutIfNeeded()
                        animation.startAnimation()

                        let shadowAnimation = CABasicAnimation(keyPath: "shadowPath")
                        shadowAnimation.fromValue = currentShadowPath
                        shadowAnimation.toValue = newShadowPath
                        shadowAnimation.duration = 1
                        shadowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                        shadowAnimation.isRemovedOnCompletion = true
                        shadowAnimation.autoreverses = true
                        self.backgroundView.layer.add(shadowAnimation, forKey: "shadowAnimation")
                    }
                }

                fadeOutAnimation.startAnimation()
            }
        }
    }

    private var rightAnchorConstraint = NSLayoutConstraint()
    private var backgroundWidthConstraint = NSLayoutConstraint()
    private var titleCenterYAnchor = NSLayoutConstraint()

    let healthLabel = AeonTVDataView(name: "HEALTH", initialValue: "0")
    let feelingLabel = AeonTVDataView(name: "FEELING", initialValue: "NEWBORN")
    let ageLabel = AeonTVDataView(name: "AGE", initialValue: "0.0 MINUTES")
    private var stackView = UIStackView()

    private let settingsButton = AeonTVButton()
    private let saveButton = AeonTVButton()
    private let favoriteButton = AeonTVButton()
    private let renameButton = AeonTVButton()

    var parentConstraintsCreated: Bool = false

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
//        clipsToBounds = true
//        backgroundColor = .white
        contentMode = .right

        heightAnchor.constraint(equalToConstant: 250).isActive = true
        backgroundWidthConstraint = widthAnchor.constraint(greaterThanOrEqualToConstant: 1000)
        backgroundWidthConstraint.isActive = true

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(titleLabel)

        backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 55).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: rightAnchor, constant: -33).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: leftAnchor, constant: 33).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true

        backgroundView.backgroundColor = .aeonMediumRed
        backgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowRadius = 20
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        backgroundView.layer.shouldRasterize = true
        backgroundView.layer.rasterizationScale = UIScreen.main.scale

        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true

        titleLabel.clipsToBounds = false
        titleLabel.contentMode = .left
        titleLabel.text = "BRADLEY ROBERT ROOT"
        titleLabel.textColor = .aeonBrightYellow
        titleLabel.font = UIFont.aeonTitleFontMedium

        titleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowRadius = 4
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        titleLabel.layer.shouldRasterize = true
        titleLabel.layer.rasterizationScale = UIScreen.main.scale
    }

    private func setupDataLabels() {
        stackView = UIStackView(arrangedSubviews: [healthLabel, feelingLabel, ageLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 30

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 700).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 12).isActive = true
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 90).isActive = true
        stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -90).isActive = true
    }

    private func setupButtons() {
        saveButton.setTitle("SAVE", for: .normal)
        favoriteButton.setTitle("FAVORITE", for: .normal)
        renameButton.setTitle("RENAME", for: .normal)

        let buttons = [saveButton, favoriteButton, renameButton]
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }

        saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        renameButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -30).isActive = true
        favoriteButton.trailingAnchor.constraint(equalTo: renameButton.leadingAnchor, constant: -30).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //backgroundView.layer.shadowPath = UIBezierPath(rect: backgroundView.bounds).cgPath

        if let parent = superview, parentConstraintsCreated == false {
            print("Creating Parent Constraints")
            bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -60).isActive = true
//            rightAnchorConstraint = rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -90)
//            rightAnchorConstraint.priority = .required
//            rightAnchorConstraint.isActive = true
            centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
            leftAnchor.constraint(greaterThanOrEqualTo: parent.leftAnchor, constant: 90).isActive = true
            parentConstraintsCreated = true
        }
    }

    // MARK: - Animations

    private let slideOffset: CGFloat = 20

    var currentState: State = .closed
    var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress = [CGFloat]()

    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        guard runningAnimators.isEmpty else { return }

        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .open:
                //self.bottomAnchorConstraint.constant = -120
                self.titleCenterYAnchor.constant = 0
            case .closed:
                //self.bottomAnchorConstraint.constant = self.slideOffset
                self.titleCenterYAnchor.constant = self.slideOffset
            }
            self.layoutIfNeeded()
        }

        transitionAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            @unknown default:
                fatalError()
            }

            switch self.currentState {
            case .open:
                //self.bottomAnchorConstraint.constant = -120
                self.titleCenterYAnchor.constant = 0
            case .closed:
                //self.bottomAnchorConstraint.constant = self.slideOffset
                self.titleCenterYAnchor.constant = self.slideOffset
            }

            self.runningAnimators.removeAll()
        }

        transitionAnimator.startAnimation()
        runningAnimators.append(transitionAnimator)
    }

    func toggle() {
        if !runningAnimators.isEmpty {
            runningAnimators.forEach { $0.pauseAnimation() }
            runningAnimators.forEach { $0.isReversed = !$0.isReversed }
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        } else {
            switch currentState {
            case .open:
                animateTransitionIfNeeded(to: .closed, duration: 1)
            case .closed:
                animateTransitionIfNeeded(to: .open, duration: 1)
            }
        }
    }
}
