//
//  AeonViewController.swift
//  Aeon Garden tvOS
//
//  Created by Bradley Root on 3/28/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import GameplayKit
import SpriteKit
import UIKit

enum UIState {
    case main
    case details
}

extension UIState {
    var opposite: UIState {
        switch self {
        case .main: return .details
        case .details: return .main
        }
    }
}

class AeonViewController: UIViewController {
    var scene: AeonTankScene?
    var skView: SKView?

    // MARK: - Animations

    var currentState: UIState = .main
    var runningAnimators = [UIViewPropertyAnimator]()
    var runningNameAnimators = [UIViewPropertyAnimator]()
    private var animationProgress = [CGFloat]()

    private func animateTransitionIfNeeded(to state: UIState, duration: TimeInterval) {
        guard runningAnimators.isEmpty else { return }

        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .main:
                self.detailsBottomAnchorConstraint.constant = self.detailsHiddenOffset
                self.detailsTitleLabel.alpha = 0
                self.mainTopAnchorConstraint.constant = self.mainDefaultOffset
                self.mainTitleLabel.alpha = 1
            case .details:
                self.detailsBottomAnchorConstraint.constant = self.detailsDefaultOffset
                self.mainTopAnchorConstraint.constant = self.mainHiddenOffset
                self.mainTitleLabel.alpha = 0
            }
            self.view.layoutIfNeeded()
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
            case .main:
                self.detailsBottomAnchorConstraint.constant = self.detailsHiddenOffset
                self.detailsTitleLabel.alpha = 0
                self.mainTopAnchorConstraint.constant = self.mainDefaultOffset
                self.mainTitleLabel.alpha = 1
            case .details:
                self.detailsBottomAnchorConstraint.constant = self.detailsDefaultOffset
                self.mainTopAnchorConstraint.constant = self.mainHiddenOffset
                self.mainTitleLabel.alpha = 0
            }

            self.runningAnimators.removeAll()
            self.setNeedsFocusUpdate()
            self.updateFocusIfNeeded()
        }

        transitionAnimator.startAnimation()
        runningAnimators.append(transitionAnimator)
    }

    func showDetailsIfNeeded() {
        removeAnimationsIfNeeded()
        animateTransitionIfNeeded(to: .details, duration: 1)
    }

    func hideDetailsIfNeeded() {
        removeNameAnimationsIfNeeded()
        removeAnimationsIfNeeded()
        animateTransitionIfNeeded(to: .main, duration: 1)
    }

    private func removeAnimationsIfNeeded() {
        if !runningAnimators.isEmpty {
            runningAnimators.forEach { $0.pauseAnimation() }
            runningAnimators.forEach { $0.stopAnimation(true) }
            runningAnimators.removeAll()
        }
    }

    private func removeNameAnimationsIfNeeded() {
        if !runningNameAnimators.isEmpty {
            runningNameAnimators.forEach { $0.pauseAnimation() }
            runningNameAnimators.forEach { $0.stopAnimation(true) }
            runningNameAnimators.removeAll()
        }
    }

    func initialAnimation() {
        mainTopAnchorConstraint.constant = mainDefaultOffset
        mainTitleLabel.alpha = 1
        let transitionAnimator = UIViewPropertyAnimator(duration: 2, dampingRatio: 1) {
            self.view.layoutIfNeeded()
        }
        runningAnimators.append(transitionAnimator)
        transitionAnimator.startAnimation()
    }

    // MARK: - Main Menu View

    let mainContainerView = UIView()
    let mainBackgroundView = UIView()
    let mainTitleLabel = UILabel()

    var mainTopAnchorConstraint = NSLayoutConstraint()

    let mainPopulationLabel = AeonTVDataView(name: "POPULATION", initialValue: "0")
    let mainFoodLabel = AeonTVDataView(name: "FOOD", initialValue: "0")
    let mainBirthsLabel = AeonTVDataView(name: "BIRTHS", initialValue: "0")
    let mainDeathsLabel = AeonTVDataView(name: "DEATHS", initialValue: "0")
    let mainClockLabel = AeonTVDataView(name: "CLOCK", initialValue: "00:00:00")
    var mainStackView = UIStackView()

    private let mainSettingsButton = AeonTVButton()
    private let mainNewTankButton = AeonTVButton()
    private let mainSaveTankButton = AeonTVButton()
    private let mainLoadTankButton = AeonTVButton()

    let mainHiddenOffset: CGFloat = -300
    let mainDefaultOffset: CGFloat = 60

    func setupMainMenuView() {
        mainContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainContainerView)
        mainContainerView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        mainContainerView.widthAnchor.constraint(equalToConstant: 1153).isActive = true

        mainBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.addSubview(mainBackgroundView)
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        mainBackgroundView.addSubview(mainTitleLabel)

        mainBackgroundView.topAnchor.constraint(equalTo: mainContainerView.topAnchor, constant: 86).isActive = true
        mainBackgroundView.rightAnchor.constraint(equalTo: mainContainerView.rightAnchor, constant: -33).isActive = true
        mainBackgroundView.leftAnchor.constraint(equalTo: mainContainerView.leftAnchor, constant: 50).isActive = true
        mainBackgroundView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor, constant: -30).isActive = true

        mainBackgroundView.backgroundColor = .aeonMediumRed
        mainBackgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        mainBackgroundView.layer.shadowOpacity = 1
        mainBackgroundView.layer.shadowRadius = 20
        mainBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        mainBackgroundView.layer.shouldRasterize = true
        mainBackgroundView.layer.rasterizationScale = UIScreen.main.scale

        mainTitleLabel.topAnchor.constraint(equalTo: mainContainerView.topAnchor).isActive = true
        mainTitleLabel.leftAnchor.constraint(equalTo: mainContainerView.leftAnchor).isActive = true

        mainTitleLabel.clipsToBounds = false
        mainTitleLabel.contentMode = .left
        mainTitleLabel.text = "AEON GARDEN"
        mainTitleLabel.textColor = .aeonBrightYellow
        mainTitleLabel.font = UIFont.aeonTitleFontLarge

        mainTitleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        mainTitleLabel.layer.shadowOpacity = 1
        mainTitleLabel.layer.shadowRadius = 4
        mainTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        mainTitleLabel.layer.shouldRasterize = true
        mainTitleLabel.layer.rasterizationScale = UIScreen.main.scale

        mainTitleLabel.alpha = 0

        mainTopAnchorConstraint = mainContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: mainHiddenOffset)
        mainTopAnchorConstraint.isActive = true
        mainContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 90).isActive = true

        // MARK: Main Menu Data Labels

        mainStackView = UIStackView(arrangedSubviews: [
            mainPopulationLabel,
            mainFoodLabel,
            mainBirthsLabel,
            mainDeathsLabel,
            mainClockLabel
        ])
        mainStackView.axis = .horizontal
        mainStackView.distribution = .equalSpacing
        mainStackView.alignment = .fill
        mainStackView.spacing = 30

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainBackgroundView.addSubview(mainStackView)
        mainStackView.centerYAnchor.constraint(equalTo: mainBackgroundView.centerYAnchor, constant: 10).isActive = true
        mainStackView.centerXAnchor.constraint(equalTo: mainContainerView.centerXAnchor).isActive = true
        mainStackView.leadingAnchor.constraint(greaterThanOrEqualTo: mainContainerView.leadingAnchor, constant: 80).isActive = true
        mainStackView.trailingAnchor.constraint(lessThanOrEqualTo: mainContainerView.trailingAnchor, constant: -80).isActive = true

        // MARK: Main Menu Buttons

        mainSettingsButton.setTitle("SETTINGS", for: .normal)
        mainNewTankButton.setTitle("NEW TANK", for: .normal)
        mainSaveTankButton.setTitle("SAVE TANK", for: .normal)
        mainLoadTankButton.setTitle("LOAD TANK", for: .normal)

        let mainButtons = [mainSettingsButton, mainNewTankButton, mainSaveTankButton, mainLoadTankButton]
        for button in mainButtons {
            button.translatesAutoresizingMaskIntoConstraints = false
            mainContainerView.addSubview(button)
            button.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor).isActive = true
        }

        mainNewTankButton.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: 20).isActive = true
        mainLoadTankButton.trailingAnchor.constraint(equalTo: mainNewTankButton.leadingAnchor, constant: -30).isActive = true
        mainSaveTankButton.trailingAnchor.constraint(equalTo: mainLoadTankButton.leadingAnchor, constant: -30).isActive = true
        mainSettingsButton.trailingAnchor.constraint(equalTo: mainSaveTankButton.leadingAnchor, constant: -30).isActive = true
    }

    // MARK: - Details View

    var disableDetailUpdates: Bool = false
    let detailsContainerView = UIView()
    let detailsBackgroundView = UIView()
    let detailsTitleLabel = UILabel()
    var detailsTitle: String? = "BRADLEY ROBERT ROOT"
    var detailsBottomAnchorConstraint = NSLayoutConstraint()
    var detailsBackgroundWidthConstraint = NSLayoutConstraint()

    let detailsHealthLabel = AeonTVDataView(name: "HEALTH", initialValue: "0")
    let detailsFeelingLabel = AeonTVDataView(name: "FEELING", initialValue: "NEWBORN")
    let detailsAgeLabel = AeonTVDataView(name: "AGE", initialValue: "0.0 MINUTES")
    var detailsStackView = UIStackView()

    let detailsSaveButton = AeonTVButton()
    let detailsFavoriteButton = AeonTVButton()
    let detailsRenameButton = AeonTVButton()

    let detailsHiddenOffset: CGFloat = 310
    let detailsDefaultOffset: CGFloat = -60

    func setupDetailsView() {
        detailsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailsContainerView)
        detailsContainerView.heightAnchor.constraint(equalToConstant: 225).isActive = true

        detailsBackgroundWidthConstraint = detailsContainerView.widthAnchor.constraint(equalToConstant: 1000)
        detailsBackgroundWidthConstraint.priority = .defaultLow
        detailsBackgroundWidthConstraint.isActive = true

        detailsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        detailsContainerView.addSubview(detailsBackgroundView)
        detailsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsBackgroundView.addSubview(detailsTitleLabel)

        detailsBackgroundView.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 58).isActive = true
        detailsBackgroundView.rightAnchor.constraint(equalTo: detailsContainerView.rightAnchor, constant: -33).isActive = true
        detailsBackgroundView.leftAnchor.constraint(equalTo: detailsContainerView.leftAnchor, constant: 33).isActive = true
        detailsBackgroundView.bottomAnchor.constraint(equalTo: detailsContainerView.bottomAnchor, constant: -30).isActive = true

        detailsBackgroundView.backgroundColor = .aeonMediumRed
        detailsBackgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        detailsBackgroundView.layer.shadowOpacity = 1
        detailsBackgroundView.layer.shadowRadius = 20
        detailsBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        detailsBackgroundView.layer.shouldRasterize = true
        detailsBackgroundView.layer.rasterizationScale = UIScreen.main.scale

        detailsTitleLabel.topAnchor.constraint(equalTo: detailsContainerView.topAnchor).isActive = true
        detailsTitleLabel.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor).isActive = true

        detailsTitleLabel.clipsToBounds = false
        detailsTitleLabel.contentMode = .left
        detailsTitleLabel.text = "BRADLEY ROBERT ROOT"
        detailsTitleLabel.textColor = .aeonBrightYellow
        detailsTitleLabel.font = UIFont.aeonTitleFontMedium

        detailsTitleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        detailsTitleLabel.layer.shadowOpacity = 1
        detailsTitleLabel.layer.shadowRadius = 4
        detailsTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        detailsTitleLabel.layer.shouldRasterize = true
        detailsTitleLabel.layer.rasterizationScale = UIScreen.main.scale

        detailsTitleLabel.alpha = 1

        detailsBottomAnchorConstraint = detailsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: detailsHiddenOffset)
        detailsBottomAnchorConstraint.isActive = true
        detailsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -90).isActive = true

        // MARK: Details Data Labels

        detailsStackView = UIStackView(arrangedSubviews: [detailsHealthLabel, detailsFeelingLabel, detailsAgeLabel])
        detailsStackView.axis = .horizontal
        detailsStackView.distribution = .equalSpacing
        detailsStackView.alignment = .fill
        detailsStackView.spacing = 5

        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        detailsContainerView.addSubview(detailsStackView)
        detailsStackView.widthAnchor.constraint(equalToConstant: 700).isActive = true
        detailsStackView.centerYAnchor.constraint(equalTo: detailsBackgroundView.centerYAnchor).isActive = true
        detailsStackView.centerXAnchor.constraint(equalTo: detailsContainerView.centerXAnchor).isActive = true
        detailsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: detailsContainerView.leadingAnchor, constant: 120).isActive = true
        detailsStackView.trailingAnchor.constraint(lessThanOrEqualTo: detailsContainerView.trailingAnchor, constant: -120).isActive = true

        // MARK: Details Buttons

        detailsSaveButton.setTitle("SAVE", for: .normal)
        detailsFavoriteButton.setTitle("FAVORITE", for: .normal)
        detailsRenameButton.setTitle("RENAME", for: .normal)

        let detailsButtons = [detailsSaveButton, detailsFavoriteButton, detailsRenameButton]
        for button in detailsButtons {
            button.translatesAutoresizingMaskIntoConstraints = false
            detailsContainerView.addSubview(button)
            button.bottomAnchor.constraint(equalTo: detailsContainerView.bottomAnchor).isActive = true
        }

        detailsSaveButton.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: 0).isActive = true
        detailsRenameButton.trailingAnchor.constraint(equalTo: detailsSaveButton.leadingAnchor, constant: -30).isActive = true
        detailsFavoriteButton.trailingAnchor.constraint(equalTo: detailsRenameButton.leadingAnchor, constant: -30).isActive = true
    }

    func detailsTitleChanged() {
        removeNameAnimationsIfNeeded()
        let currentShadowPath = detailsBackgroundView.bounds
        let newShadowPath = detailsBackgroundView.bounds

        let animation = UIViewPropertyAnimator(duration: 1, curve: .easeInOut, animations: {
            self.detailsBackgroundWidthConstraint.constant = self.detailsTitleLabel.bounds.width + 66
            self.detailsTitleLabel.alpha = 1
            self.detailsHealthLabel.dataLabel.alpha = 1
            self.detailsFeelingLabel.dataLabel.alpha = 1
            self.detailsAgeLabel.dataLabel.alpha = 1
            self.view.layoutIfNeeded()
        })
        animation.addCompletion { _ in
            self.detailsTitleLabel.alpha = 1
            self.detailsHealthLabel.dataLabel.alpha = 1
            self.detailsFeelingLabel.dataLabel.alpha = 1
            self.detailsAgeLabel.dataLabel.alpha = 1
            self.detailsBackgroundWidthConstraint.constant = self.detailsTitleLabel.bounds.width + 66
        }

        let fadeOutAnimation = UIViewPropertyAnimator(duration: 0.2, curve: .linear, animations: {
            self.detailsTitleLabel.alpha = 0
            self.detailsHealthLabel.dataLabel.alpha = 0
            self.detailsFeelingLabel.dataLabel.alpha = 0
            self.detailsAgeLabel.dataLabel.alpha = 0
        })
        fadeOutAnimation.addCompletion { position in
            if position == .end {
                self.disableDetailUpdates = false
                self.detailsTitleLabel.text = self.detailsTitle?.localizedUppercase
                self.view.layoutIfNeeded()
                self.runningNameAnimators.append(animation)
                animation.startAnimation()

                let shadowAnimation = CABasicAnimation(keyPath: "shadowPath")
                shadowAnimation.fromValue = currentShadowPath
                shadowAnimation.toValue = newShadowPath
                shadowAnimation.duration = 1
                shadowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                shadowAnimation.isRemovedOnCompletion = true
                shadowAnimation.autoreverses = true
                self.detailsBackgroundView.layer.add(shadowAnimation, forKey: "shadowAnimation")
            }
        }
        runningNameAnimators.append(fadeOutAnimation)
        fadeOutAnimation.startAnimation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scene = AeonTankScene(size: view.bounds.size)
        scene?.tankDelegate = self

        // Present the scene
        skView = view as? SKView
        skView?.ignoresSiblingOrder = true
        skView?.presentScene(scene)

        setupTemporaryControls()

        view.translatesAutoresizingMaskIntoConstraints = false
        setupMainMenuView()
        setupDetailsView()

        setNeedsFocusUpdate()
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if currentState == .details {
            return [detailsContainerView]
        } else {
            return [mainContainerView]
        }
    }

    fileprivate func setupTemporaryControls() {
        let selectCreatureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectRandomCreature))
        selectCreatureRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        view.addGestureRecognizer(selectCreatureRecognizer)

        let deselectCreatureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deselectCreature))
        deselectCreatureRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        view.addGestureRecognizer(deselectCreatureRecognizer)
    }

    @objc func selectRandomCreature() {
        var mateArray: [AeonCreatureNode] = []
        let nodes = scene!.children
        for case let child as AeonCreatureNode in nodes {
            mateArray.append(child)
        }
        if !mateArray.isEmpty {
            var selected = mateArray.randomElement()!
            while selected == scene!.selectedCreature, mateArray.count > 1 {
                selected = mateArray.randomElement()!
            }
            scene!.selectCreature(selected)
            showDetailsIfNeeded()
        }
    }

    @objc func deselectCreature() {
        scene!.deselectCreature()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        mainBackgroundView.layer.shadowPath = UIBezierPath(rect: mainBackgroundView.bounds).cgPath
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initialAnimation()
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
}

extension AeonViewController: AeonTankUIDelegate {
    func creatureDeselected() {
        print("Received deselected message from tank.")
        hideDetailsIfNeeded()
    }

    func updateClock(_ clock: String) {
        mainClockLabel.data = clock
    }

    func updatePopulation(_ population: Int) {
        mainPopulationLabel.data = String(population)
    }

    func updateFood(_ food: Int) {
        mainFoodLabel.data = String(food)
    }

    func updateBirths(_ births: Int) {
        mainBirthsLabel.data = String(births)
    }

    func updateDeaths(_ deaths: Int) {
        mainDeathsLabel.data = String(deaths)
    }

    func updateSelectedCreatureDetails(_ creature: AeonCreatureNode?) {
        if let creature = creature, !disableDetailUpdates {
            if detailsTitle != creature.name {
                disableDetailUpdates = true
                detailsTitle = creature.name
                detailsTitleChanged()
                return
            }
            detailsHealthLabel.data = String(Int(creature.getCurrentHealth())).localizedUppercase
            detailsFeelingLabel.data = creature.getCurrentState().localizedUppercase
            detailsAgeLabel.data = creature.lifeTimeFormattedAsString().localizedUppercase
        }
    }
}
