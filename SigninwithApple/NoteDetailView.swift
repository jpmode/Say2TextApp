//
//  NoteDetailView.swift
//  SigninwithApple
//
//  Created by Modeline Jean Pierre on 12/10/24.
//


import SwiftUI
import CoreData

struct NoteDetailView: View {
    @ObservedObject var note: Note
    @Environment(\.presentationMode) var presentationMode
    let context: NSManagedObjectContext

    var body: some View {
        VStack {
            TextEditor(text: Binding(
                get: { note.content ?? "" },
                set: { note.content = $0 }
            ))
            .padding()
            .navigationTitle("Edit Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                }
            }
        }
    }

    private func saveNote() {
        do {
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving note: \(error.localizedDescription)")
        }
    }
}
