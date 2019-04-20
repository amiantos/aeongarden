//
//  AeonMainMenuView.swift
//  Aeon Garden
//
//  Created by Bradley Root on 4/19/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit
import SnapKit

class AeonMainMenuView: UIView {

    let backgroundView = UIView()
    let titleLabel = UILabel()

    let newTankButton = UIButton(type: .system)
    let saveTankButton = UIButton(type: .system)
    let tankSettingsButton = UIButton(type: .system)

    let populationTitleLabel = UILabel()
    let populationCountLabel = UILabel()
    let birthsTitleLabel = UILabel()
    let birthsCountLabel = UILabel()
    let deathsTitleLabel = UILabel()
    let deathsCountLabel = UILabel()
    let clockTitleLabel = UILabel()
    let clockCountLabel = UILabel()

    
    override init(frame: CGRect) {
        super.init(frame: frame)


        titleLabel.textColor = .aeonBrightYellow
        titleLabel.font = UIFont.aeonTitleFontLarge
        titleLabel.text = "AEON GARDEN"

        backgroundView.backgroundColor = .aeonMediumRed

        addSubview(backgroundView)
        backgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
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

        newTankButton.setTitle("NEW TANK", for: .normal)
        saveTankButton.setTitle("SAVE TANK", for: .normal)
        tankSettingsButton.setTitle("TANK SETTINGS", for: .normal)
        let buttons = [newTankButton, saveTankButton, tankSettingsButton]
        for button in buttons {
            backgroundView.addSubview(button)
            button.backgroundColor = .aeonDarkRed

            button.layer.cornerRadius = 15
            button.titleLabel?.font = UIFont.aeonButtonFont
            button.setTitleColor(.aeonBrightYellow, for: .normal)
//            button.titleLabel?.snp.makeConstraints({ (make) in
//                make.top.equalToSuperview().offset(15)
//                make.bottom.equalToSuperview().offset(-15)
//                make.left.equalToSuperview().offset(35)
//                make.right.equalToSuperview().offset(-35)
//            })
//                button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
//                button.layer.shadowOpacity = 1
//                button.layer.shadowRadius = 20
//                button.layer.shadowOffset = CGSize(width: 0, height: 4)
//                button.layer.shouldRasterize = true
//                button.layer.rasterizationScale = UIScreen.main.scale
        }

        populationTitleLabel.text = "POPULATION"
        birthsTitleLabel.text = "BIRTHS"
        deathsTitleLabel.text = "DEATHS"
        clockTitleLabel.text = "CLOCK"
        let dataTitleLabels = [populationTitleLabel, birthsTitleLabel, deathsTitleLabel, clockTitleLabel]
        for titleLabel in dataTitleLabels {
            titleLabel.font = UIFont.aeonDataFont
            titleLabel.textColor = .aeonBrightYellow
            backgroundView.addSubview(titleLabel)
            titleLabel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            titleLabel.layer.shadowOpacity = 1
            titleLabel.layer.shadowRadius = 4
            titleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
            titleLabel.layer.shouldRasterize = true
            titleLabel.layer.rasterizationScale = UIScreen.main.scale
        }

        populationCountLabel.text = "0"
        birthsCountLabel.text = "0"
        deathsCountLabel.text = "0"
        clockCountLabel.text = "0"
        let dataCountLabels = [populationCountLabel, birthsCountLabel, deathsCountLabel, clockCountLabel]
        for countLabel in dataCountLabels {
            countLabel.font = UIFont.aeonDataFont
            countLabel.textColor = .aeonBrightBrown
            backgroundView.addSubview(countLabel)
        }

        backgroundView.snp.makeConstraints { (make) in
            make.height.equalTo(titleLabel.snp.height)
            make.width.equalTo(titleLabel.snp.width)
            make.top.equalToSuperview().offset(120)
            make.left.equalToSuperview().offset(120)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.top)
            make.left.equalTo(backgroundView.snp.left).offset(-50)
        }

        newTankButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.bottom)
            make.right.equalTo(backgroundView.snp.right).offset(20)
        }

        saveTankButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.bottom)
            make.right.equalTo(newTankButton.snp.left).offset(-30)
        }

        tankSettingsButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.bottom)
            make.right.equalTo(saveTankButton.snp.left).offset(-30)
        }

        populationTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(10)
            make.centerX.equalToSuperview().multipliedBy(0.50)
        }
        populationCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(populationTitleLabel.snp.centerY)
            make.left.equalTo(populationTitleLabel.snp.right).offset(10)
        }

        deathsTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(10)
            make.centerX.equalToSuperview().multipliedBy(1.25)
        }
        deathsCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(deathsTitleLabel.snp.centerY)
            make.left.equalTo(deathsTitleLabel.snp.right).offset(10)
        }

        birthsTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(10)
            make.centerX.equalToSuperview().multipliedBy(0.75)
        }
        birthsCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(birthsTitleLabel.snp.centerY)
            make.left.equalTo(birthsTitleLabel.snp.right).offset(10)
        }

        clockTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(10)
            make.centerX.equalToSuperview().multipliedBy(1.5)
        }
        clockCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(clockTitleLabel.snp.centerY)
            make.left.equalTo(clockTitleLabel.snp.right).offset(10)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
