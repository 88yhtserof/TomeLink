//
//  ImageResizingManager.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/20/25.
//

import Foundation

enum ImageResizingManager {
    static func resizingImage(for urlString: String) -> String {
        urlString.replacingOccurrences(of: "R120x174.q85", with: "R160x232.q90")
    }
}
