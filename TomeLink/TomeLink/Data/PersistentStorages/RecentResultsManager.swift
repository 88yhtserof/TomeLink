//
//  RecentResultsManager.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/31/25.
//

import Foundation

import RxSwift
import RxCocoa

enum RecentResultsManager {
    
    @UserDefaultsWrapper(key: "recentResults", defaultValue: [:])
    private static var recentResults: [String: Date]
    
    static var elements: Observable<[String]> {
        return Observable.create { observer in
            RecentResultsManager.$recentResults
                .map{ $0 }
                .map{
                    $0.sorted(by: { (before, after) in
                        before.value > after.value
                    })
                    .map{ $0.key }
                }
                .subscribe(observer)
        }
    }
    
    
    static func save(_ element: String) {
        RecentResultsManager.recentResults.updateValue(Date(), forKey: element)
    }
    
    static func remove(of element: String) {
        let index = RecentResultsManager.recentResults.keys.firstIndex(of: element)!
        RecentResultsManager.recentResults.remove(at: index)
    }
    
    static func removeAll() {
        RecentResultsManager.recentResults = [:]
    }
}
