//
//  AeonUISettings.swift
//  Aeon Garden
//
//  Created by Bradley Root on 5/4/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import Foundation
import UIKit

class UISettings {
    static var styles: UIStyling = {
        #if os(tvOS)
            // MARK: - tvOS Layout
            return UIStyling(
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
                detailsTitleExtraWidth: 66,
                detailsBackgroundTopConstant: 58,
                detailsBackgroundLeftConstant: 33,
                detailsBackgroundBottomConstant: -30,
                detailsBackgroundRightConstant: -33,
                detailsHeight: 225,
                detailsWidth: 1000,
                detailsStackViewWidth: 700,
                detailsStackViewOffsets: 120,

                buttonSpacing: 30
            )
        #elseif os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                // MARK: - iPad Layout
                return UIStyling(
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
                    detailsTitleExtraWidth: 40,
                    detailsBackgroundTopConstant: 36,
                    detailsBackgroundLeftConstant: 20,
                    detailsBackgroundBottomConstant: -20,
                    detailsBackgroundRightConstant: -15,
                    detailsHeight: 150,
                    detailsWidth: 500,
                    detailsStackViewWidth: 450,
                    detailsStackViewOffsets: 70,

                    buttonSpacing: 15
                )
            }
            // MARK: - iPhone Layout
            return UIStyling(
                mainTopConstantHidden: -140,
                mainTopConstantDefault: 10,
                mainLeftOffset: 20,
                mainTitleFont: UIFont.aeonTitleFontSmall,
                mainBackgroundTopConstant: 36,
                mainBackgroundLeftConstant: 21,
                mainBackgroundBottomConstant: -20,
                mainBackgroundRightConstant: -15,
                mainHeight: 120,
                mainWidth: 485,

                detailsBottomConstantHidden: 125,
                detailsBottomConstantDefault: -20,
                detailsRightOffset: -20,
                detailsTitleFont: UIFont.aeonTitleFontExtraSmall,
                detailsTitleExtraWidth: 40,
                detailsBackgroundTopConstant: 22,
                detailsBackgroundLeftConstant: 12,
                detailsBackgroundBottomConstant: -20,
                detailsBackgroundRightConstant: -15,
                detailsHeight: 100,
                detailsWidth: 485,
                detailsStackViewWidth: 300,
                detailsStackViewOffsets: 60,

                buttonSpacing: 10
            )
        #endif
    }()
}

struct UIStyling {
    let mainTopConstantHidden: CGFloat
    let mainTopConstantDefault: CGFloat
    let mainLeftOffset: CGFloat
    let mainTitleFont: UIFont
    let mainBackgroundTopConstant: CGFloat
    let mainBackgroundLeftConstant: CGFloat
    let mainBackgroundBottomConstant: CGFloat
    let mainBackgroundRightConstant: CGFloat
    let mainHeight: CGFloat
    let mainWidth: CGFloat

    let detailsBottomConstantHidden: CGFloat
    let detailsBottomConstantDefault: CGFloat
    let detailsRightOffset: CGFloat
    let detailsTitleFont: UIFont
    let detailsTitleExtraWidth: CGFloat
    let detailsBackgroundTopConstant: CGFloat
    let detailsBackgroundLeftConstant: CGFloat
    let detailsBackgroundBottomConstant: CGFloat
    let detailsBackgroundRightConstant: CGFloat
    let detailsHeight: CGFloat
    let detailsWidth: CGFloat
    let detailsStackViewWidth: CGFloat
    let detailsStackViewOffsets: CGFloat

    let buttonSpacing: CGFloat
}
