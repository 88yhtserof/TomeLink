//
//  UISheetPresentationController+Detent.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/10/25.
//

import UIKit

extension UISheetPresentationController.Detent {
    
    /// Create a system detent for a sheet that's approximately a third of the screen height. Excetionally the iPhone SE has a detent of quarter.
    class func small() -> UISheetPresentationController.Detent {
        let deviceName = UIDevice.current.name
        return self.custom(identifier: .small) { context in
            if deviceName.contains("iPhone SE") {
                return 0.4 * context.maximumDetentValue
            } else {
                return 0.3 * context.maximumDetentValue
            }
        }
    }
}

extension UISheetPresentationController.Detent.Identifier {
    
    /// The identifier for the systems's small detent
    static let small = UISheetPresentationController.Detent.Identifier("small")
}
