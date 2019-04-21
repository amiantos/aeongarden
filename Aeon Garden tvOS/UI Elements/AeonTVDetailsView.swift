//
//  AeonTVDetailsView.swift
//  Aeon Garden tvOS
//
//  Created by Bradley Root on 4/20/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import SnapKit
import UIKit

class AeonTVDetailsView: UIView {
    let backgroundView = UIView()
    let titleLabel = UILabel()

    let healthLabel = AeonTVDataView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    let feelingLabel = AeonTVDataView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    let ageLabel = AeonTVDataView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))

    let settingsButton = AeonTVButton()
    let saveButton = AeonTVButton()
    let favoriteButton = AeonTVButton()
    let renameButton = AeonTVButton()

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

extension AeonTVDetailsView {
    fileprivate func setupView() {
        titleLabel.textColor = .aeonBrightYellow
        titleLabel.font = UIFont.aeonTitleFontMedium

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
            make.height.equalTo(titleLabel.snp.height).multipliedBy(1.2)
            make.width.equalTo(titleLabel.snp.width)
            make.bottom.equalToSuperview().offset(-120)
            make.right.equalToSuperview().offset(-120)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backgroundView.snp.top)
            make.left.equalTo(backgroundView.snp.left).offset(-33)
        }
    }

    fileprivate func setupDataLabels() {
        healthLabel.title = "HEALTH"
        healthLabel.data = "0"

        feelingLabel.title = "FEELING"
        feelingLabel.data = "NEWBORN"

        ageLabel.title = "AGE"
        ageLabel.data = "0 SECONDS"

        let stackView = UIStackView(arrangedSubviews: [healthLabel, feelingLabel, ageLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 30

        backgroundView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(5)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(90)
            make.right.lessThanOrEqualToSuperview().offset(-90)
        }
    }

    fileprivate func setupButtons() {
        saveButton.setTitle("SAVE", for: .normal)
        favoriteButton.setTitle("FAVORITE", for: .normal)
        renameButton.setTitle("RENAME", for: .normal)

        let buttons = [saveButton, favoriteButton, renameButton]
        for button in buttons {
            backgroundView.addSubview(button)
        }

        saveButton.snp.makeConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom)
            make.right.equalTo(backgroundView.snp.right).offset(20)
        }

        renameButton.snp.makeConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom)
            make.right.equalTo(saveButton.snp.left).offset(-30)
        }

        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalTo(backgroundView.snp.bottom)
            make.right.equalTo(renameButton.snp.left).offset(-30)
        }

    }
}
