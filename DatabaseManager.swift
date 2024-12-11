//
//  DatabaseManager.swift
//  SigninwithApple
//
//  Created by Modeline Jean Pierre on 12/9/24.
//

import CoreData
import CloudKit

class DatabaseManager {
    static let shared = DatabaseManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Note")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve store description")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.JeanPierre.SigninwithApple"
        )
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    // MARK: - Core Data Operations
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
