//
//  extensions.swift
//  gatewait
//
//  Created by Danil on 21.10.2019.
//  Copyright © 2019 Danil Chernyshev. All rights reserved.
//

import Foundation
import UIKit


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

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

extension UIView {
    func rotateView(duration: CFTimeInterval = 1) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
