//
//  AuthorizationManager.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/29/25.
//

import Foundation

enum AuthorizationManager: String {
    case kakao = "KAKAO"
    
    var apiKey: String? {
        return Bundle.main.infoDictionary?["\(self.rawValue)_API_KEY"] as? String
    }
    
    var url: String? {
        return Bundle.main.infoDictionary?["\(self.rawValue)_URL"] as? String
    }
}
