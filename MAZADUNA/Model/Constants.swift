//
//  Constants.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 11/02/1443 AH.
//

import Foundation
import UIKit

struct Constants {
      struct  Storyboard {
        public static let homeviewcontroller = "HomeVC"
        public static let SignInViewController = "signIn"
        public static let SignUpViewController = "signUp"
    }
}

extension UIColor {
    func hex(_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
