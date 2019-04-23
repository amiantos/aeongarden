//
//  AeonTVMainMenuView.swift
//  Aeon Garden
//
//  Created by Bradley Root on 4/19/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

// MARK: - State
private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class AeonTVMainMenuView: UIView {
    let backgroundView = UIView()
    let titleLabel = UILabel()

    let populationLabel = AeonTVDataView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    let foodLabel = AeonTVDataView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    let birthsLabel = AeonTVDataView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    let deathsLabel = AeonTVDataView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    let clockLabel = AeonTVDataView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))

    let settingsButton = AeonTVButton()
    let newTankButton = AeonTVButton()
    let saveTankButton = AeonTVButton()
    let loadTankButton = AeonTVButton()
    var stackView = UIStackView()

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

    func showMenuIfNeeded() {
//        if showing == false {
//            showMenu()
//            showing = true
//        }
    }

    func hideMenuIfNeeded() {
//        if showing == true {
//            hideMenu()
//            showing = false
//        }
    }

    func showMenu() {
        isHidden = false
        newTankButton.snp.updateConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom)
        }
        saveTankButton.snp.updateConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom)
        }
        loadTankButton.snp.updateConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom)
        }
        settingsButton.snp.updateConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom)
        }
        titleLabel.snp.updateConstraints { make in
            make.centerY.equalTo(backgroundView.snp.top)
        }
        backgroundView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(120)
        }
        setNeedsUpdateConstraints()
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 1
            self.layoutIfNeeded()

        }) { _ in
            print("Finished")
        }
    }

    func hideMenu() {
        newTankButton.snp.updateConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom).offset(45)
        }
        loadTankButton.snp.updateConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom).offset(60)
        }
        saveTankButton.snp.updateConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom).offset(50)
        }
        settingsButton.snp.updateConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom).offset(35)
        }
        titleLabel.snp.updateConstraints { make in
            make.centerY.equalTo(backgroundView.snp.top).offset(-80)
        }
        backgroundView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(-400)
        }
        setNeedsUpdateConstraints()
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
            self.titleLabel.alpha = 0
            self.layoutIfNeeded()

        }) { finished in
            if finished {
                self.isHidden = true
            }
        }
    }
}

extension AeonTVMainMenuView {
    fileprivate func setupView() {

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        backgroundView.heightAnchor.constraint(equalTo: titleLabel.heightAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 120).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 120).isActive = true

        backgroundView.backgroundColor = .aeonMediumRed
        backgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowRadius = 20
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        backgroundView.layer.shouldRasterize = true
        backgroundView.layer.rasterizationScale = UIScreen.main.scale

        titleLabel.centerYAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: -50).isActive = true

        titleLabel.textColor = .aeonBrightYellow
        titleLabel.font = UIFont.aeonTitleFontLarge
        titleLabel.text = "AEON GARDEN"

        titleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowRadius = 4
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        titleLabel.layer.shouldRasterize = true
        titleLabel.layer.rasterizationScale = UIScreen.main.scale
    }

    fileprivate func setupDataLabels() {
        populationLabel.title = "POPULATION"
        populationLabel.data = "0"

        foodLabel.title = "FOOD"
        foodLabel.data = "0"

        birthsLabel.title = "BIRTHS"
        birthsLabel.data = "0"

        deathsLabel.title = "DEATHS"
        deathsLabel.data = "0"

        clockLabel.title = "CLOCK"
        clockLabel.data = "00:00:00"

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

    fileprivate func setupButtons() {
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
}

extension UIView {
    func resizeToFitSubviews() {
        let subviewsRect = subviews.reduce(CGRect.zero) {
            $0.union($1.frame)
        }

        let fix = subviewsRect.origin
        subviews.forEach {
            $0.frame.offsetBy(dx: -fix.x, dy: -fix.y)
        }

        frame.offsetBy(dx: fix.x, dy: fix.y)
        frame.size = subviewsRect.size
    }
}
