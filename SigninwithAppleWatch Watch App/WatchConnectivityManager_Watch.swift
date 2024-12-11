//
//  WatchConnectivityManager_Watch.swift
//  SigninwithApple
//
//  Created by Modeline Jean Pierre on 12/9/24.
//
import WatchConnectivity
import Combine

class WatchConnectivityManager_Watch: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectivityManager_Watch()

    @Published var isAuthenticated: Bool = false

    private override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    // Send authentication state to the iPhone
    func sendAuthStateToPhone(isAuthenticated: Bool) {
        if WCSession.default.isReachable {
            let message = ["isAuthenticated": isAuthenticated]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending message to iPhone: \(error)")
            })
        }
    }

    // Handle receiving messages from the iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let notesData = message["notes"] as? [[String: Any]] {
            for noteDict in notesData {
                if let id = UUID(uuidString: noteDict["id"] as? String ?? ""),
                   let content = noteDict["content"] as? String {
                    // Fetch or create a note and update its content
                    if let note = NoteManager.shared.fetchNoteById(id) {
                        NoteManager.shared.updateNote(note, newContent: content)
                    } else {
                        NoteManager.shared.createNote(content: content, type: "default")
                    }
                }
            }
        } else if let isAuthenticated = message["isAuthenticated"] as? Bool {
            print("Received authentication state from iPhone: \(isAuthenticated)")
            self.isAuthenticated = isAuthenticated
            NotificationCenter.default.post(name: .authStateChanged, object: isAuthenticated)
        }
    }

    // Send updated notes to the iPhone
    func sendUpdatedNotesToPhone(notes: [Note]) {
        guard WCSession.default.isReachable else {
            print("iPhone is not reachable")
            return
        }
        
        guard !notes.isEmpty else {
            print("No updated notes to send")
            return
        }
        
        let notesData = notes.map { note in
            [
                "id": note.id?.uuidString ?? "",
                "content": note.content ?? "",
                "type": note.type ?? "",
                "createdAt": note.createdAt ?? Date(),
                "updatedAt": note.updatedAt ?? Date(),
                "isSync": note.isSynced
            ] as [String: Any]
        }
        
        let message = ["updatedNotes": notesData]
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending updated notes to iPhone: \(error.localizedDescription)")
        }
    }

    // Handle session activation for Watch
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated successfully")
        }
    }
}
