//
//  MainView.swift
//  SigninwithApple
//
//  Created by Modeline Jean Pierre on 12/7/24.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Binding var isAuthenticated: Bool // Binding to track the authentication state
    @State private var items: [Note] = [] // Core Data notes
    @State private var selectedNote: Note? // The note currently being edited

    let context = DatabaseManager.shared.persistentContainer.viewContext
    let cloudContainer = DatabaseManager.shared.persistentContainer

    var body: some View {
        NavigationView {
            VStack {
                List(items, id: \.objectID) { item in
                    NavigationLink(destination: NoteDetailView(note: item, context: context)) {
                        Text(item.content ?? "Untitled")
                    }
                }
                .navigationTitle("Your Notes")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: addItem) {
                                Label("Add Note", systemImage: "plus")
                            }
                            Button(action: forceCloudSync) {
                                Label("Sync", systemImage: "arrow.clockwise")
                            }
                        }
                    }

                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: logOut) {
                            Label("Log Out", systemImage: "person.fill.xmark")
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchNotes() // Fetch notes when the view appears
        }
    }

    private func addItem() {
        // Create a new note and save it
        let newNote = Note(context: context)
        newNote.content = "New Item at \(Date())"
        newNote.createdAt = Date()
        saveContext()
        fetchNotes()
    }

    private func saveContext() {
        // Save changes to Core Data
        DatabaseManager.shared.saveContext()
    }

    private func fetchNotes() {
        // Fetch all notes from Core Data
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        do {
            items = try context.fetch(fetchRequest)
        } catch {
            print("Error fetching notes: \(error.localizedDescription)")
        }
    }

    private func logOut() {
        // Clear Keychain and update authentication state
        do {
            try KeychainHelper.shared.delete(for: "userIdentifierKey")
            self.isAuthenticated = false
        } catch {
            print("Error signing out: \(error)")
        }
    }

    private func forceCloudSync() {
        // Post a persistent store remote change notification
        NotificationCenter.default.post(name: .NSPersistentStoreRemoteChange, object: nil)
        print("Cloud sync triggered.")
    }
}
