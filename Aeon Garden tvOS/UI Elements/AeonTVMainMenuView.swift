//
//  AeonTVMainMenuView.swift
//  Aeon Garden
//
//  Created by Bradley Root on 4/19/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SnapKit
import UIKit

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

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupButtons()
        setupDataLabels()
        sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupView()
        setupButtons()
        setupDataLabels()
        sizeToFit()
    }
}

extension AeonTVMainMenuView {
    fileprivate func setupView() {
        titleLabel.textColor = .aeonBrightYellow
        titleLabel.font = UIFont.aeonTitleFontLarge
        titleLabel.text = "AEON GARDEN"

        backgroundView.backgroundColor = .aeonMediumRed

        addSubview(backgroundView)
        backgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.50).cgColor
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowRadius = 20
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        backgroundView.layer.shouldRasterize = true
        backgroundView.layer.rasterizationScale = UIScreen.main.scale

        addSubview(titleLabel)
        titleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowRadius = 4
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        titleLabel.layer.shouldRasterize = true
        titleLabel.layer.rasterizationScale = UIScreen.main.scale

        backgroundView.snp.makeConstraints { make in
            make.height.equalTo(titleLabel.snp.height)
            make.width.equalTo(titleLabel.snp.width)
            make.top.equalToSuperview().offset(120)
            make.left.equalToSuperview().offset(120)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backgroundView.snp.top)
            make.left.equalTo(backgroundView.snp.left).offset(-50)
        }
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

        let stackView = UIStackView(arrangedSubviews: [populationLabel, foodLabel, birthsLabel, deathsLabel, clockLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 5

        backgroundView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(11)
            make.left.equalToSuperview().offset(90)
            make.right.equalToSuperview().offset(-90)
        }
    }

    fileprivate func setupButtons() {
        settingsButton.setTitle("SETTINGS", for: .normal)
        newTankButton.setTitle("NEW TANK", for: .normal)
        saveTankButton.setTitle("SAVE TANK", for: .normal)
        loadTankButton.setTitle("LOAD TANK", for: .normal)

        let buttons = [settingsButton, newTankButton, saveTankButton, loadTankButton]
        for button in buttons {
            backgroundView.addSubview(button)
        }

        newTankButton.snp.makeConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom)
            make.right.equalTo(backgroundView.snp.right).offset(20)
        }

        loadTankButton.snp.makeConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom)
            make.right.equalTo(newTankButton.snp.left).offset(-30)
        }

        saveTankButton.snp.makeConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom)
            make.right.equalTo(loadTankButton.snp.left).offset(-30)
        }

        settingsButton.snp.makeConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom)
            make.right.equalTo(saveTankButton.snp.left).offset(-30)
        }
    }
}
