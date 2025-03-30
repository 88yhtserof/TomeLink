//
//  KakaoNetworkErrorResponse.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/30/25.
//

import Foundation

struct KakaoNetworkErrorResponse: Decodable {
    let errorType: String
    let message: String
    
    enum CodingKeys: CodingKey {
        case errorType
        case message
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.errorType = try container.decodeIfPresent(String.self, forKey: .errorType) ?? ""
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
    }
}

/*
 401 Unautorized
 
 {
     "errorType": "AccessDeniedError",
     "message": "cannot find Authorization : KakaoAK header"
 }
 
 */
