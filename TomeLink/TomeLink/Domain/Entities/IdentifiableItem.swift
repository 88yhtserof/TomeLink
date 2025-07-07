//
//  IdentifiableItem.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/1/25.
//

import Foundation

struct IdentifiableItem<Item: Hashable>: Hashable, Identifiable {
    let id = UUID()
    let item: Item
}
