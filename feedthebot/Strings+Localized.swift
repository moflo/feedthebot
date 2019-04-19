//
//  Strings+Localized.swift
//  feedthebot
//
//  Created by d. nye on 4/19/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import Foundation

extension String {
    // MARK: Button titles
    static let TEXT = NSLocalizedString("TEXT", comment: "Text OCR title button")
    static let CLASSIFICATION = NSLocalizedString("CLASSIFICATION", comment: "image classification button")
    static let SENTIMENT = NSLocalizedString("SENTIMENT", comment: "text sentiment anlaysis button")
    static let BOUNDINGBOX = NSLocalizedString("BOUNDING BOX", comment: "bounding box anlaysis button")
    static let POLYGONLABEL = NSLocalizedString("POLYGON LABEL", comment: "polygon label box anlaysis button")
    
    // MARK: Prompts
    static let SELECT_SOMETHING = NSLocalizedString("Select Training Type", comment: "select type promprt")
    static let TYPE_SOMETHING = NSLocalizedString("Type some text!", comment: "type promprt")

    
}
