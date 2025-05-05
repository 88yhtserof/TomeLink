//
//  ArchiveRepositoryProtocol.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/19/25.
//

import Foundation

protocol ArchiveRepositoryProtocol {
    
    func addArchive(book: Book, note: String?, archivedAt: Date)
    func updateArchive(at id: UUID, with value: Archive)
    func fetchArchive(for id: UUID) -> Archive?
    func fetchAllArchives() -> [Archive]
    func deleteArchive(at id: UUID)
}
