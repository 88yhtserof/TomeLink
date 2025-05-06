//
//  ReadingRepositoryProtocol.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/11/25.
//

import Foundation

protocol ReadingRepositoryProtocol {
    
    func isBookReading(isbn: String) -> Bool
    func addReading(book: Book, currentPage: Int32, pageCount: Int32, startedAt: Date)
    func updateCurrentPage(isbn: String, currentPage: Int32, startedAt: Date)
    func fetchReading(isbn: String) -> Reading?
    func deleteReading(isbn: String)
    func fetchAllReadings() -> [Reading]
}
