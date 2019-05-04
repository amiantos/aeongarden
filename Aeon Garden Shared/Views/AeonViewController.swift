//
//  AeonViewController.swift
//  Aeon Garden
//
//  Created by Bradley Root on 9/30/17.
//  Copyright © 2017 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit
import UIKit

class AeonViewController: UIViewController, AeonTankUIDelegate {
    var scene: AeonTankScene?
    var skView: SKView?

    // MARK: - Per-Platform UI Styling

    let uiSettings: UISettings = {
        #if os(tvOS)
        return UISettings(
            mainTopConstantHidden: -300,
            mainTopConstantDefault: 60,
            mainLeftOffset: 90,
            mainTitleFont: UIFont.aeonTitleFontLarge,
            mainBackgroundTopConstant: 86,
            mainBackgroundLeftConstant: 50,
            mainBackgroundBottomConstant: -30,
            mainBackgroundRightConstant: -33,
            mainHeight: 280,
            mainWidth: 1153,

            detailsBottomConstantHidden: 310,
            detailsBottomConstantDefault: -60,
            detailsRightOffset: -90,
            detailsTitleFont: UIFont.aeonTitleFontMedium,
            detailsBackgroundTopConstant: 58,
            detailsBackgroundLeftConstant: 33,
            detailsBackgroundBottomConstant: -30,
            detailsBackgroundRightConstant: -33,
            detailsHeight: 225,
            detailsWidth: 1000,
            detailsStackViewWidth: 700,
            detailsStackViewOffsets: 120
        )
        #elseif os(iOS)
        // TODO: These need refinement.
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad Layout
            return UISettings(
                mainTopConstantHidden: -270,
                mainTopConstantDefault: 30,
                mainLeftOffset: 60,
                mainTitleFont: UIFont.aeonTitleFontMedium,
                mainBackgroundTopConstant: 58,
                mainBackgroundLeftConstant: 33,
                mainBackgroundBottomConstant: -20,
                mainBackgroundRightConstant: -15,
                mainHeight: 190,
                mainWidth: 770,

                detailsBottomConstantHidden: 205,
                detailsBottomConstantDefault: -30,
                detailsRightOffset: -60,
                detailsTitleFont: UIFont.aeonTitleFontSmall,
                detailsBackgroundTopConstant: 35,
                detailsBackgroundLeftConstant: 20,
                detailsBackgroundBottomConstant: -20,
                detailsBackgroundRightConstant: -15,
                detailsHeight: 150,
                detailsWidth: 1000,
                detailsStackViewWidth: 500,
                detailsStackViewOffsets: 60
            )
        }
        // iPhone Layout
        return UISettings(
            mainTopConstantHidden: -270,
            mainTopConstantDefault: 30,
            mainLeftOffset: 60,
            mainTitleFont: UIFont.aeonTitleFontMedium,
            mainBackgroundTopConstant: 58,
            mainBackgroundLeftConstant: 33,
            mainBackgroundBottomConstant: -20,
            mainBackgroundRightConstant: -15,
            mainHeight: 190,
            mainWidth: 770,

            detailsBottomConstantHidden: 205,
            detailsBottomConstantDefault: -30,
            detailsRightOffset: -60,
            detailsTitleFont: UIFont.aeonTitleFontSmall,
            detailsBackgroundTopConstant: 35,
            detailsBackgroundLeftConstant: 20,
            detailsBackgroundBottomConstant: -20,
            detailsBackgroundRightConstant: -15,
            detailsHeight: 150,
            detailsWidth: 1000,
            detailsStackViewWidth: 500,
            detailsStackViewOffsets: 60
        )
        #endif
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true
        view = SKView(frame: UIScreen.main.bounds)
        scene = AeonTankScene(size: view.bounds.size)
        scene?.tankDelegate = self
        scene!.scaleMode = .aspectFill

        skView = view as? SKView
        skView?.ignoresSiblingOrder = true
        skView!.presentScene(scene)

        view.translatesAutoresizingMaskIntoConstraints = false
        setupMainMenuView()
        setupDetailsView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initialAnimation()

        #if os(tvOS)
        setupTemporaryControls()
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
        #endif
    }

    #if os(iOS)
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    #endif

    // MARK: tvOS Controls

    #if os(tvOS)
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if currentState == .details {
            return [detailsContainerView]
        }
        return [mainContainerView]
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
        }
    }

    @objc func deselectCreature() {
        scene!.deselectCreature()
    }
    #endif

    // MARK: - Tank Delegate

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

    func creatureSelected(_ creature: AeonCreatureNode) {
        DispatchQueue.main.async {
            self.updateSelectedCreatureDetails(creature)
            self.showDetailsIfNeeded()
        }
    }

    func creatureDeselected() {
        DispatchQueue.main.async {
            self.hideDetailsIfNeeded()
        }
    }

    func updateSelectedCreatureDetails(_ creature: AeonCreatureNode) {
        if detailsTitle != creature.name {
            disableDetailUpdates = true
            detailsTitle = creature.name
            detailsTitleChanged()
        }
        if !disableDetailUpdates {
            detailsHealthLabel.data = String(Int(creature.getCurrentHealth())).localizedUppercase
            detailsFeelingLabel.data = creature.getCurrentState().localizedUppercase
            detailsAgeLabel.data = creature.lifeTimeFormattedAsString().localizedUppercase
        }
    }

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
                self.mainTopAnchorConstraint.constant = self.mainTopConstantDefault
                self.mainTitleLabel.alpha = 1
                self.mainTitleLabelTopAnchorConstraint.constant = self.mainTitleLabelDefaultOffset
            case .details:
                self.detailsBottomAnchorConstraint.constant = self.detailsDefaultOffset
                self.mainTopAnchorConstraint.constant = self.mainTopConstantHidden
                self.mainTitleLabel.alpha = 0
                self.mainTitleLabelTopAnchorConstraint.constant = self.mainTitleLabelHiddenOffset
                if self.runningNameAnimators.isEmpty { self.detailsTitleLabel.alpha = 1 }
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
                self.mainTopAnchorConstraint.constant = self.mainTopConstantDefault
                self.mainTitleLabel.alpha = 1
                self.mainTitleLabelTopAnchorConstraint.constant = self.mainTitleLabelDefaultOffset
            case .details:
                self.detailsBottomAnchorConstraint.constant = self.detailsDefaultOffset
                self.mainTopAnchorConstraint.constant = self.mainTopConstantHidden
                self.mainTitleLabel.alpha = 0
                self.mainTitleLabelTopAnchorConstraint.constant = self.mainTitleLabelHiddenOffset
                if self.runningNameAnimators.isEmpty { self.detailsTitleLabel.alpha = 1 }
            }

            self.runningAnimators.removeAll()
            self.setNeedsFocusUpdate()
            self.updateFocusIfNeeded()
        }

        transitionAnimator.startAnimation()
        runningAnimators.append(transitionAnimator)
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
                if let creature = self.scene?.selectedCreature {
                    // sloppy kludge to get around 1 second UI updates on creature data
                    self.updateSelectedCreatureDetails(creature)
                }
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
        mainTopAnchorConstraint.constant = mainTopConstantDefault
        mainTitleLabelTopAnchorConstraint.constant = mainTitleLabelDefaultOffset
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
    var mainTitleLabelTopAnchorConstraint = NSLayoutConstraint()

    let mainPopulationLabel = AeonDataView(name: "POPULATION", initialValue: "0")
    let mainFoodLabel = AeonDataView(name: "FOOD", initialValue: "0")
    let mainBirthsLabel = AeonDataView(name: "BIRTHS", initialValue: "0")
    let mainDeathsLabel = AeonDataView(name: "DEATHS", initialValue: "0")
    let mainClockLabel = AeonDataView(name: "CLOCK", initialValue: "00:00:00")
    var mainStackView = UIStackView()

    private let mainSettingsButton = AeonButton()
    private let mainNewTankButton = AeonButton()
    private let mainSaveTankButton = AeonButton()
    private let mainLoadTankButton = AeonButton()

    var mainTopConstantHidden: CGFloat { return self.uiSettings.mainTopConstantHidden }
    var mainTopConstantDefault: CGFloat { return self.uiSettings.mainTopConstantDefault }
    let mainTitleLabelDefaultOffset: CGFloat = 0
    let mainTitleLabelHiddenOffset: CGFloat = -60

    func setupMainMenuView() {
        mainContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainContainerView)
        mainContainerView.heightAnchor.constraint(equalToConstant: uiSettings.mainHeight).isActive = true
        mainContainerView.widthAnchor.constraint(equalToConstant: uiSettings.mainWidth).isActive = true

        mainTopAnchorConstraint = mainContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: mainTopConstantHidden)
        mainTopAnchorConstraint.isActive = true
        mainContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: uiSettings.mainLeftOffset).isActive = true

        // Red Rectangle & Title

        mainBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.addSubview(mainBackgroundView)
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        mainBackgroundView.addSubview(mainTitleLabel)

        mainBackgroundView.topAnchor.constraint(equalTo: mainContainerView.topAnchor, constant: uiSettings.mainBackgroundTopConstant).isActive = true
        mainBackgroundView.rightAnchor.constraint(equalTo: mainContainerView.rightAnchor, constant: uiSettings.mainBackgroundRightConstant).isActive = true
        mainBackgroundView.leftAnchor.constraint(equalTo: mainContainerView.leftAnchor, constant: uiSettings.mainBackgroundLeftConstant).isActive = true
        mainBackgroundView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor, constant: uiSettings.mainBackgroundBottomConstant).isActive = true

        mainBackgroundView.backgroundColor = .aeonMediumRed
        mainBackgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        mainBackgroundView.layer.shadowOpacity = 1
        mainBackgroundView.layer.shadowRadius = 20
        mainBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        mainBackgroundView.layer.shouldRasterize = true
        mainBackgroundView.layer.rasterizationScale = UIScreen.main.scale

        mainTitleLabelTopAnchorConstraint = mainTitleLabel.topAnchor.constraint(
            equalTo: mainContainerView.topAnchor, constant: mainTitleLabelHiddenOffset)
        mainTitleLabelTopAnchorConstraint.isActive = true
        mainTitleLabel.leftAnchor.constraint(equalTo: mainContainerView.leftAnchor).isActive = true

        mainTitleLabel.clipsToBounds = false
        mainTitleLabel.contentMode = .left
        mainTitleLabel.text = "AEON GARDEN"
        mainTitleLabel.textColor = .aeonBrightYellow
        mainTitleLabel.font = uiSettings.mainTitleFont

        mainTitleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        mainTitleLabel.layer.shadowOpacity = 1
        mainTitleLabel.layer.shadowRadius = 4
        mainTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        mainTitleLabel.layer.shouldRasterize = true
        mainTitleLabel.layer.rasterizationScale = UIScreen.main.scale

        mainTitleLabel.alpha = 0

        // MARK: Main Menu Data Labels

        mainStackView = UIStackView(arrangedSubviews: [
            mainPopulationLabel,
            mainFoodLabel,
            mainBirthsLabel,
            mainDeathsLabel,
            mainClockLabel,
            ])
        mainStackView.axis = .horizontal
        mainStackView.distribution = .equalSpacing
        mainStackView.alignment = .fill
        mainStackView.spacing = 20

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

    let detailsHealthLabel = AeonDataView(name: "HEALTH", initialValue: "0")
    let detailsFeelingLabel = AeonDataView(name: "FEELING", initialValue: "NEWBORN")
    let detailsAgeLabel = AeonDataView(name: "AGE", initialValue: "0.0 MINUTES")
    var detailsStackView = UIStackView()

    let detailsSaveButton = AeonButton()
    let detailsFavoriteButton = AeonButton()
    let detailsRenameButton = AeonButton()

    var detailsHiddenOffset: CGFloat { return uiSettings.detailsBottomConstantHidden }
    var detailsDefaultOffset: CGFloat { return uiSettings.detailsBottomConstantDefault }

    func setupDetailsView() {
        detailsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailsContainerView)
        detailsContainerView.heightAnchor.constraint(equalToConstant: uiSettings.detailsHeight).isActive = true

        detailsBottomAnchorConstraint = detailsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: detailsHiddenOffset)
        detailsBottomAnchorConstraint.isActive = true
        detailsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: uiSettings.detailsRightOffset).isActive = true

        // Red Rectangle

        detailsBackgroundWidthConstraint = detailsContainerView.widthAnchor.constraint(equalToConstant: uiSettings.detailsWidth)
        detailsBackgroundWidthConstraint.priority = .defaultLow
        detailsBackgroundWidthConstraint.isActive = true

        detailsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        detailsContainerView.addSubview(detailsBackgroundView)
        detailsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsBackgroundView.addSubview(detailsTitleLabel)

        detailsBackgroundView.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: uiSettings.detailsBackgroundTopConstant).isActive = true
        detailsBackgroundView.rightAnchor.constraint(equalTo: detailsContainerView.rightAnchor, constant: uiSettings.detailsBackgroundRightConstant).isActive = true
        detailsBackgroundView.leftAnchor.constraint(equalTo: detailsContainerView.leftAnchor, constant: uiSettings.detailsBackgroundLeftConstant).isActive = true
        detailsBackgroundView.bottomAnchor.constraint(equalTo: detailsContainerView.bottomAnchor, constant: uiSettings.detailsBackgroundBottomConstant).isActive = true

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
        detailsTitleLabel.font = uiSettings.detailsTitleFont

        detailsTitleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        detailsTitleLabel.layer.shadowOpacity = 1
        detailsTitleLabel.layer.shadowRadius = 4
        detailsTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        detailsTitleLabel.layer.shouldRasterize = true
        detailsTitleLabel.layer.rasterizationScale = UIScreen.main.scale

        detailsTitleLabel.alpha = 0

        // MARK: Details Data Labels

        let detailsStackViews = [detailsHealthLabel, detailsFeelingLabel, detailsAgeLabel]
        detailsStackViews.forEach { $0.dataLabel.alpha = 0 }
        detailsStackView = UIStackView(arrangedSubviews: detailsStackViews)
        detailsStackView.axis = .horizontal
        detailsStackView.distribution = .equalSpacing
        detailsStackView.alignment = .fill
        detailsStackView.spacing = 15

        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        detailsContainerView.addSubview(detailsStackView)
        detailsStackView.widthAnchor.constraint(equalToConstant: uiSettings.detailsStackViewWidth).isActive = true
        detailsStackView.centerYAnchor.constraint(equalTo: detailsBackgroundView.centerYAnchor).isActive = true
        detailsStackView.centerXAnchor.constraint(equalTo: detailsContainerView.centerXAnchor).isActive = true
        detailsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: detailsContainerView.leadingAnchor, constant: uiSettings.detailsStackViewOffsets).isActive = true
        detailsStackView.trailingAnchor.constraint(lessThanOrEqualTo: detailsContainerView.trailingAnchor, constant: -uiSettings.detailsStackViewOffsets).isActive = true

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
}
