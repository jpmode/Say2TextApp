//
//  NoteManager.swift
//  SigninwithApple
//
//  Created by Modeline Jean Pierre on 12/9/24.
//


import CoreData
import WatchConnectivity

class NoteManager {
    static let shared = NoteManager()
    private let dbManager = DatabaseManager.shared

    // MARK: - Core Data Operations
    func createNote(content: String, type: String) {
        let context = dbManager.persistentContainer.viewContext
        let note = Note(context: context)
        
        note.id = UUID()
        note.content = content
        note.type = type
        note.createdAt = Date()
        note.updatedAt = Date()
        note.isSynced = false
        
        dbManager.saveContext()

        // Send to paired device
        sendNoteToPairedDevice(note: note)
    }

    func fetchNotes() -> [Note] {
        let context = dbManager.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch notes: \(error)")
            return []
        }
    }

    func updateNote(_ note: Note, newContent: String) {
        note.content = newContent
        note.updatedAt = Date()
        note.isSynced = false
        
        dbManager.saveContext()

        // Sync updated note
        sendNoteToPairedDevice(note: note)
    }

    func deleteNote(_ note: Note) {
        let context = dbManager.persistentContainer.viewContext
        context.delete(note)
        dbManager.saveContext()

        // Send delete request
        sendDeleteRequestToPairedDevice(noteId: note.id)
    }

    // MARK: - WatchConnectivity Sync
    private func sendNoteToPairedDevice(note: Note) {
        if WCSession.default.isReachable {
            let message: [String: Any] = [
                "action": "addOrUpdate",
                "id": note.id?.uuidString ?? "",
                "content": note.content ?? "",
                "type": note.type ?? "",
                "createdAt": note.createdAt ?? Date(),
                "updatedAt": note.updatedAt ?? Date(),
                "isSync": true
            ]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending note to paired device: \(error)")
            }
        }
    }

    private func sendDeleteRequestToPairedDevice(noteId: UUID?) {
        guard let noteId = noteId else { return }
        if WCSession.default.isReachable {
            let message: [String: Any] = [
                "action": "delete",
                "id": noteId.uuidString
            ]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending delete request to paired device: \(error)")
            }
        }
    }

    func handleIncomingMessage(_ message: [String: Any]) {
        guard let action = message["action"] as? String else { return }

        let context = dbManager.persistentContainer.viewContext

        switch action {
        case "addOrUpdate":
            guard let idString = message["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let content = message["content"] as? String,
                  let type = message["type"] as? String,
                  let createdAt = message["createdAt"] as? Date,
                  let updatedAt = message["updatedAt"] as? Date else { return }

            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            if let existingNote = try? context.fetch(fetchRequest).first {
                // Update existing note
                existingNote.content = content
                existingNote.type = type
                existingNote.createdAt = createdAt
                existingNote.updatedAt = updatedAt
                existingNote.isSynced = true
            } else {
                // Create new note
                let note = Note(context: context)
                note.id = id
                note.content = content
                note.type = type
                note.createdAt = createdAt
                note.updatedAt = updatedAt
                note.isSynced = true
            }

        case "delete":
            guard let idString = message["id"] as? String,
                  let id = UUID(uuidString: idString) else { return }

            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            if let noteToDelete = try? context.fetch(fetchRequest).first {
                context.delete(noteToDelete)
            }

        default:
            break
        }

        dbManager.saveContext()
    }
    
    func fetchNoteById(_ id: UUID) -> Note? {
        let context = dbManager.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch note by ID: \(error)")
            return nil
        }
    }

}
