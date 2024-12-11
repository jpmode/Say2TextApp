//
//  SigninwithAppleApp.swift
//  SigninwithApple
//
//  Created by Modeline Jean Pierre on 12/7/24.
////
///
///
///
import SwiftUI
import CoreData

@main
struct SigninwithAppleApp: App {
    // Declare the shared model container
    var sharedModelContainer: NSPersistentCloudKitContainer

    // Initialize the app
    init() {
        // Initialize the container with your Core Data model
        sharedModelContainer = NSPersistentCloudKitContainer(name: "Note") // Replace with your actual model name

        // Configure the persistent store with CloudKit
        guard let description = sharedModelContainer.persistentStoreDescriptions.first else {
            fatalError("Failed to load persistent store description")
        }
        
        // Set the CloudKit container identifier
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.JeanPierre.SigninwithApple") // Use your actual CloudKit container ID
        
        // Load persistent stores
        sharedModelContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            PhoneContentView()
                .environment(\.managedObjectContext, sharedModelContainer.viewContext) // Pass the managed object context to the views
        }
    }
}
