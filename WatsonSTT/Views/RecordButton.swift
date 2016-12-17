//
//  RecordButton.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/18/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import UIKit

class RecordButton: UIButton {

    enum RecordState {
        case recording
        case idle
    }

    var recordState: RecordState = .idle {

        didSet {
            switch recordState {
            case .idle:
                self.setImage(#imageLiteral(resourceName: "record-button-gray"), for: .normal)
            default:
                self.setImage(#imageLiteral(resourceName: "record-button-red"), for: .normal)
            }
        }
    }
}
