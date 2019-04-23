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
    var showing: Bool = true
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

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupButtons()
        setupDataLabels()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupView()
        setupButtons()
        setupDataLabels()
    }

    func showMenuIfNeeded() {
        if self.showing == false {
            showMenu()
            self.showing = true
        }
    }

    func hideMenuIfNeeded() {
        if self.showing == true {
            hideMenu()
            self.showing = false
        }
    }

    func showMenu() {
        self.isHidden = false
        self.newTankButton.snp.updateConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.bottom)
        }
        self.saveTankButton.snp.updateConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.bottom)
        }
        self.loadTankButton.snp.updateConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.bottom)
        }
        self.settingsButton.snp.updateConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.bottom)
        }
        self.titleLabel.snp.updateConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.top)
        }
        self.backgroundView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(120)
        }
        self.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 1
            self.layoutIfNeeded()

        }) { (finished) in
            print("Finished")
        }
    }

    func hideMenu() {
        self.newTankButton.snp.updateConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.bottom).offset(45)
        }
        self.loadTankButton.snp.updateConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.bottom).offset(60)
        }
        self.saveTankButton.snp.updateConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.bottom).offset(50)
        }
        self.settingsButton.snp.updateConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.bottom).offset(35)
        }
        self.titleLabel.snp.updateConstraints { (make) in
            make.centerY.equalTo(backgroundView.snp.top).offset(-80)
        }
        self.backgroundView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(-400)
        }
        self.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
            self.titleLabel.alpha = 0
            self.layoutIfNeeded()

        }) { (finished) in
            if finished {
                self.isHidden = true
            }
        }
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

        stackView = UIStackView(arrangedSubviews: [populationLabel, foodLabel, birthsLabel, deathsLabel, clockLabel])
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
