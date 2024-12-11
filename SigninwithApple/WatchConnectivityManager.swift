//
//  WatchConnectivityManager.swift
//  SigninwithApple
//
//  Created by Modeline Jean Pierre on 12/9/24.
//

import WatchConnectivity

class WatchConnectivityManager_iPhone: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager_iPhone()
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // Send authentication state to the Watch
    func sendAuthStateToWatch(isAuthenticated: Bool) {
        if WCSession.default.isReachable {
            let message = ["isAuthenticated": isAuthenticated]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending message to watch: \(error)")
            })
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let notesData = message["updatedNotes"] as? [[String: Any]] {
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
            print("Received authentication state from watch: \(isAuthenticated)")
        }
    }


    // Handle session activation
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated successfully")
        }
    }
    
    func sendNotesToWatch(notes: [Note]) {
        guard WCSession.default.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        let notesData = notes.map { note -> [String: Any] in
            [
                "id": note.id?.uuidString ?? "",  // Safely unwrap optional
                "content": note.content,          // `String` is not optional, no change needed
                "type": note.type,                // `String` is not optional, no change needed
                "createdAt": note.createdAt ?? Date(), // Safely provide a default value
                "updatedAt": note.updatedAt ?? Date(), // Safely provide a default value
                "isSync": note.isSynced             // `Bool` is not optional, no change needed
            ]
        }
        
        let message = ["notes": notesData]
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending notes to Watch: \(error.localizedDescription)")
        }
    }


    // Handle session lifecycle for iPhone (watch will not have these)
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }
}
