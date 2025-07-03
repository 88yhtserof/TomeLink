//
//  AladinNetworkErrorResponse.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/9/25.
//

import Foundation

struct AladinNetworkErrorResponse: Decodable {
    let errorCode: Int
    let errorMessage: String

    enum CodingKeys: String, CodingKey {
        case errorCode
        case errorMessage
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.errorCode = try container.decodeIfPresent(Int.self, forKey: .errorCode) ?? 0
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage) ?? ""
    }
}
