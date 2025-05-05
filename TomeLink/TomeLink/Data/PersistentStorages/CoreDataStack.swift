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

extension CoreDataStack {
    
    func save() {
        
        guard persistentContainer.viewContext.hasChanges else {
            print("Failed to save: no changes")
            return
        }
        
        do {
            try persistentContainer.viewContext.save()
            print("Successfully saved the context.")
        } catch {
            print("Failed to save the context:", error.localizedDescription)
        }
    }
}
