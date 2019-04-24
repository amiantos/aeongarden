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
    let titleLabel = UILabel()

    private var backgroundBottomAnchor = NSLayoutConstraint()

    let healthLabel = AeonTVDataView(name: "HEALTH", initialValue: "0")
    let feelingLabel = AeonTVDataView(name: "FEELING", initialValue: "NEWBORN")
    let ageLabel = AeonTVDataView(name: "AGE", initialValue: "0.0 MINUTES")
    private var stackView = UIStackView()

    private let settingsButton = AeonTVButton()
    private let saveButton = AeonTVButton()
    private let favoriteButton = AeonTVButton()
    private let renameButton = AeonTVButton()

    private func setupView() {
        isHidden = true
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        backgroundView.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 1.2).isActive = true
        backgroundView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor).isActive = true
        backgroundBottomAnchor = backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: slideOffset)
        backgroundBottomAnchor.isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -120).isActive = true

        backgroundView.backgroundColor = .aeonMediumRed
        backgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowRadius = 20
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        backgroundView.layer.shouldRasterize = true
        backgroundView.layer.rasterizationScale = UIScreen.main.scale

        titleLabel.centerYAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: -33).isActive = true

        titleLabel.textColor = .aeonBrightYellow
        titleLabel.font = UIFont.aeonTitleFontMedium
        titleLabel.text = "Bradley Robert Root".uppercased()

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
        backgroundView.addSubview(stackView)
        stackView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: 5).isActive = true
        stackView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        stackView.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor, constant: 90).isActive = true
        stackView.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -90).isActive = true
    }

    private func setupButtons() {
        saveButton.setTitle("SAVE", for: .normal)
        favoriteButton.setTitle("FAVORITE", for: .normal)
        renameButton.setTitle("RENAME", for: .normal)

        let buttons = [saveButton, favoriteButton, renameButton]
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.addSubview(button)
            button.centerYAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        }

        saveButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: 20).isActive = true
        renameButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -30).isActive = true
        favoriteButton.trailingAnchor.constraint(equalTo: renameButton.leadingAnchor, constant: -30).isActive = true
    }

    // MARK: - Animations

    private let slideOffset: CGFloat = 300

    var currentState: State = .closed
    var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress = [CGFloat]()

    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        guard runningAnimators.isEmpty else { return }

        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .open:
                self.isHidden = false
                self.backgroundBottomAnchor.constant = -120
            case .closed:
                self.backgroundBottomAnchor.constant = self.slideOffset
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
                self.backgroundBottomAnchor.constant = -120
            case .closed:
                self.backgroundBottomAnchor.constant = self.slideOffset
                self.isHidden = true
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
