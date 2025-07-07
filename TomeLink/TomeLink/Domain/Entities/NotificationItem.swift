//
//  NotificationItem.swift
//  TomeLink
//
//  Created by 임윤휘 on 7/3/25.
//

import Foundation

struct NotificationItem: Hashable, Identifiable {
    let id: UUID
    let isbn: String
    let notifiedAt: Date
    let title: String
    let content: String
    let type: String
}
