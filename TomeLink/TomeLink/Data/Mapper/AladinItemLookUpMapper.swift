//
//  AladinItemLookUpMapper.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/9/25.
//

import Foundation

extension AladinItemLookUpResponseDTO {
    
    func toDomain() -> AladinItemLookUp {
        return AladinItemLookUp(
            title: self.title,
            detailURL: URL(string: self.link),
            pageCount: self.item?.bookinfo?.itemPage ?? 0
        )
    }
}
