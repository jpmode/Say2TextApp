//
//  Say2TextWatchView.swift
//  Say2Text
//
//  Created by Modeline Jean Pierre on 12/10/24.
//


import SwiftUI

struct Say2TextWView: View {
    @State private var isRecording = false
    @State private var transcription = "Waiting for speech..." // Default text while waiting
    @State private var currentText = "" // Holds the transcribed text
    
    var body: some View {
        VStack {
            Text(transcription)
                .padding()

            Button(action: {
                // Start transcription
                isRecording.toggle()
                startTranscription() // Replace with actual transcription logic
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
            }
            
            Button(action: {
                // Test transcription save
                let testText = "This is a sample transcription for testing."
                saveTranscriptionToCoreData(testText)
            }) {
                Text("Test Save Transcription")
                    .foregroundColor(.blue)
            }
        }
        .onAppear {
            // Test saving transcription immediately on view appear (for debugging)
            testSaveTranscription()
        }
    }
    
    func startTranscription() {
        // This function will start the transcription process
        // For testing, we'll simulate transcription and save it
        Task {
            // Simulate transcription (replace with your actual transcription logic)
            try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate waiting for transcription
            
            // After transcription is done, update the text and save it to Core Data
            transcription = "Transcription completed successfully!"
            saveTranscriptionToCoreData(transcription)
        }
    }

    func testSaveTranscription() {
        let sampleTranscription = "This is a test transcription"
        saveTranscriptionToCoreData(sampleTranscription)
    }

    func saveTranscriptionToCoreData(_ transcription: String) {
        guard !transcription.isEmpty else { return }
        
        // Get the context from the shared PersistenceController
        let context = PersistenceController.shared.container.viewContext
        
        // Create a new Note object (matching your Core Data model)
        let newNote = Note(context: context)
        newNote.content = transcription      // Set the transcription text
        newNote.timestamp = Date()          // Set the timestamp
        
        // Save the context (which saves the data to Core Data and CloudKit if configured)
        do {
            try context.save()
            print("Transcription saved successfully!")
        } catch {
            print("Failed to save transcription: \(error.localizedDescription)")
        }
    }
}

#Preview {
    Say2TextWView()
}
