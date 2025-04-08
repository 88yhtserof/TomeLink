//
//  FavoriteRepositoryProtocol.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/8/25.
//

import Foundation

protocol FavoriteRepositoryProtocol {
    
    func like(book: Book)
    func unlike(isbn: String)
    func isBookLiked(for isbn: String) -> Bool
    func fetchFavorites() -> [Book]
}

