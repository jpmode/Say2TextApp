//
//  ReviewTranscriptionView.swift
//  Say2Text
//
//  Created by Modeline Jean Pierre on 12/10/24.
//

//
//import SwiftUI
//
//struct ReviewTranscriptionView: View {
//    @State var transcribedText: String
//    @State private var isSaving = false
//
//    var body: some View {
//        VStack {
//            Text("Review Transcription")
//                .font(.title)
//                .padding()
//
//            TextEditor(text: $transcribedText)
//                .frame(height: 200)
//                .padding()
//                .border(Color.gray, width: 1)
//            
//            if isSaving {
//                ProgressView("Saving...")
//            } else {
//                HStack {
//                    Button("Save Locally") {
//                        saveLocally()
//                    }
//                    .padding()
//
//                    Button("Save & Sync to Cloud") {
//                        saveAndSyncToCloud()
//                    }
//                    .padding()
//                }
//            }
//        }
//        .navigationBarTitle("Review", displayMode: .inline)
//    }
//
//    private func saveLocally() {
//        isSaving = true
//        // Save transcribedText locally (e.g., in Core Data or UserDefaults)
//        let newNote = Note(content: transcribedText)
//        NoteManager.shared.save(note: newNote)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            isSaving = false
//        }
//    }
//
//    private func saveAndSyncToCloud() {
//        isSaving = true
//        // Save and sync the transcribed text to the cloud or to iPhone via WatchConnectivity
//        WatchConnectivityManager_Watch.shared.sendUpdatedNotesToPhone(notes: [Note(content: transcribedText)])
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            isSaving = false
//        }
//    }
//}
