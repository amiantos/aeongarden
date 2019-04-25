//
//  AeonTVMainMenuView.swift
//  Aeon Garden
//
//  Created by Bradley Root on 4/19/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class AeonTVMainMenuView: UIView {
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

    private func sharedInit() {
        setupView()
        setupButtons()
        setupDataLabels()
    }

    // MARK: - View Setup

    private let backgroundView = UIView()
    private let titleLabel = UILabel()

    private var backgroundTopAnchor = NSLayoutConstraint()
    private var titleCenterYAnchor = NSLayoutConstraint()

    let populationLabel = AeonTVDataView(name: "POPULATION", initialValue: "0")
    let foodLabel = AeonTVDataView(name: "FOOD", initialValue: "0")
    let birthsLabel = AeonTVDataView(name: "BIRTHS", initialValue: "0")
    let deathsLabel = AeonTVDataView(name: "DEATHS", initialValue: "0")
    let clockLabel = AeonTVDataView(name: "CLOCK", initialValue: "00:00:00")
    private var stackView = UIStackView()

    private let settingsButton = AeonTVButton()
    private let newTankButton = AeonTVButton()
    private let saveTankButton = AeonTVButton()
    private let loadTankButton = AeonTVButton()

    private func setupView() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        backgroundView.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 0.95).isActive = true
        backgroundView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor).isActive = true
        backgroundTopAnchor = backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 120)
        backgroundTopAnchor.isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 120).isActive = true

        backgroundView.isOpaque = true
        backgroundView.layer.masksToBounds = false
        backgroundView.backgroundColor = .aeonMediumRed
        backgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowRadius = 20
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        backgroundView.layer.shouldRasterize = true
        backgroundView.layer.rasterizationScale = UIScreen.main.scale

        titleCenterYAnchor = titleLabel.centerYAnchor.constraint(equalTo: backgroundView.topAnchor)
        titleCenterYAnchor.isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: -50).isActive = true

        titleLabel.textColor = .aeonBrightYellow
        titleLabel.font = UIFont.aeonTitleFontLarge
        titleLabel.text = "AEON GARDEN"

        titleLabel.isOpaque = true
        titleLabel.layer.masksToBounds = false
        //titleLabel.layer.shadowPath = UIBezierPath(rect: titleLabel.bounds).cgPath
        titleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowRadius = 4
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        titleLabel.layer.shouldRasterize = true
        titleLabel.layer.rasterizationScale = UIScreen.main.scale
    }

    private func setupDataLabels() {
        stackView = UIStackView(arrangedSubviews: [populationLabel, foodLabel, birthsLabel, deathsLabel, clockLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 5

        stackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stackView)
        stackView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: 11).isActive = true
        stackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 90).isActive = true
        stackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -90).isActive = true
    }

    private func setupButtons() {
        settingsButton.setTitle("SETTINGS", for: .normal)
        newTankButton.setTitle("NEW TANK", for: .normal)
        saveTankButton.setTitle("SAVE TANK", for: .normal)
        loadTankButton.setTitle("LOAD TANK", for: .normal)

        let buttons = [settingsButton, newTankButton, saveTankButton, loadTankButton]
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.addSubview(button)
            button.centerYAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        }
        newTankButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: 20).isActive = true
        loadTankButton.trailingAnchor.constraint(equalTo: newTankButton.leadingAnchor, constant: -30).isActive = true
        saveTankButton.trailingAnchor.constraint(equalTo: loadTankButton.leadingAnchor, constant: -30).isActive = true
        settingsButton.trailingAnchor.constraint(equalTo: saveTankButton.leadingAnchor, constant: -30).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //titleLabel.layer.shadowPath = UIBezierPath(rect: titleLabel.bounds).cgPath
        backgroundView.layer.shadowPath = UIBezierPath(rect: backgroundView.bounds).cgPath
    }

    // MARK: - Animations

    private let slideOffset: CGFloat = -300

    var currentState: State = .open
    var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress = [CGFloat]()

    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        guard runningAnimators.isEmpty else { return }

        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .open:
                self.backgroundTopAnchor.constant = 120
                self.titleCenterYAnchor.constant = 0
            case .closed:
                self.backgroundTopAnchor.constant = self.slideOffset
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
                self.backgroundTopAnchor.constant = 120
                self.titleCenterYAnchor.constant = 0
            case .closed:
                self.backgroundTopAnchor.constant = self.slideOffset
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
