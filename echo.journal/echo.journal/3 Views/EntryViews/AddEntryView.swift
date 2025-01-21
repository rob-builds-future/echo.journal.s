import SwiftUI

struct AddEntryView: View {
    @ObservedObject var viewModel: EntryViewModel // ViewModel für die Einträge

    @Environment(\.dismiss) private var dismiss // Um das Sheet zu schließen
    
    @State private var content: String = "" // Inhalt des neuen Eintrags
    @State private var isSaving = false // Zustand zum Verhindern von Mehrfachklicks

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Neuen Eintrag erstellen")) {
                    TextField("Inhalt", text: $content)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .navigationTitle("Neuer Eintrag")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss() // Schließe das Sheet
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveEntry() // Speichere den Eintrag
                    }
                    .disabled(isSaving || content.isEmpty) // Deaktiviere Button während des Speicherns
                }
            }
        }
    }

    private func saveEntry() {
        guard !isSaving else { return }
        isSaving = true

        Task {
            do {
                _ = try await viewModel.createEntry(content: content) // Speichere den Eintrag
                dismiss() // Schließe das Sheet nach erfolgreichem Speichern
            } catch {
                print("Fehler beim Speichern des Eintrags: \(error.localizedDescription)")
                isSaving = false
            }
        }
    }
}


#Preview {
    AddEntryView(viewModel: EntryViewModel(entryStoreRepository: EntryStoreRepository(), userId: "testUser"))
}
