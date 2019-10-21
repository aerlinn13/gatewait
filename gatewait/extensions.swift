//
//  extensions.swift
//  gatewait
//
//  Created by Danil on 21.10.2019.
//  Copyright © 2019 Danil Chernyshev. All rights reserved.
//

import Foundation


extension Date {
    var day: Int { return Calendar.autoupdatingCurrent.component(.day, from: self) }
    var month: Int { return Calendar.autoupdatingCurrent.component(.month, from: self) }
    var year: Int { return Calendar.autoupdatingCurrent.component(.year, from: self) }
}

extension String {
    var letters: String {
        return String(unicodeScalars.filter(CharacterSet.letters.contains))
    }
    var digits: String {
        return String(unicodeScalars.filter(CharacterSet.decimalDigits.contains))
    }
}
