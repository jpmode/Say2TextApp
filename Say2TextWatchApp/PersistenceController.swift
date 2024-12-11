//
//  PersistenceController.swift
//  Say2Text
//
//  Created by Modeline Jean Pierre on 12/10/24.
//
//
//
import CoreData
import CloudKit

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "Note")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No persistent store descriptions found.")
        }

        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.JeanPierre.SigninwithApple")
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true

        container.viewContext.automaticallyMergesChangesFromParent = true

        // Observe background context changes
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.container.viewContext.mergeChanges(fromContextDidSave: notification)
        }

        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func isICloudAvailable() -> Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }
}


//import CoreData
//import CloudKit
//
//struct PersistenceController {
//    static let shared = PersistenceController()
//
//    let container: NSPersistentCloudKitContainer
//
//    init() {
//        // Initialize the container with the correct name for your .xcdatamodeld file
//        container = NSPersistentCloudKitContainer(name: "Note")
//
//        // Load the persistent stores, which includes CloudKit syncing
//        container.loadPersistentStores { description, error in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//    }
//}
