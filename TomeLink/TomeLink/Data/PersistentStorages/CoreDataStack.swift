//
//  CoreDataStack.swift
//  TomeLink
//
//  Created by 임윤휘 on 4/8/25.
//

import Foundation
import CoreData

final class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "TomeLink")
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
        
    private init() { }
}
