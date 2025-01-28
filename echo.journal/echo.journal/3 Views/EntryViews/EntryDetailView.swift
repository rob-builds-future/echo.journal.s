import SwiftUI

struct EntryDetailView: View {
    @ObservedObject var viewModel: EntryViewModel // ViewModel zur Verwaltung der Einträge
    let entry: JournalEntry // Der Eintrag, der angezeigt wird

    @State private var isEditing: Bool = false // Zustand für den Bearbeitungsmodus
    @State private var updatedContent: String = "" // Bearbeiteter Inhalt des Eintrags

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isEditing {
                    // Bearbeitungsmodus
                    editView
                } else {
                    // Anzeigemodus
                    detailView
                }
            }
            .padding()
        }
        .navigationTitle(isEditing ? "Bearbeiten" : "Details") // Dynamischer Navigationstitel
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isEditing {
                    // Button für Bearbeiten
                    Button("Bearbeiten") {
                        enterEditMode()
                    }
                }
            }
        }
    }

    // MARK: - Detailansicht
    private var detailView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Eintragsinhalt
            Text(entry.content)
                .font(.title2)
                .fontWeight(.medium)
                .padding(.bottom, 8)

            // Metadaten
            HStack {
                Image(systemName: "calendar")
                Text("Erstellt am: \(entry.createdAt.formatted(date: .abbreviated, time: .omitted))")
            }
            .font(.footnote)
            .foregroundColor(.gray)

            HStack {
                Image(systemName: "clock")
                Text("Aktualisiert am: \(entry.updatedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")")
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
    }

    // MARK: - Bearbeitungsansicht
    private var editView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // TextEditor für den bearbeitbaren Inhalt
            TextEditor(text: $updatedContent)
                .frame(minHeight: 200)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            // Buttons für Abbrechen und Speichern
            HStack {
                // Abbrechen-Button
                Button("Abbrechen") {
                    exitEditMode()
                }
                .foregroundColor(.red)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.2))
                )

                Spacer()

                // Speichern-Button
                Button("Speichern") {
                    Task {
                        await saveChanges()
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                )
            }
        }
    }

    // MARK: - Funktionen

    /// Wechselt in den Bearbeitungsmodus und lädt den aktuellen Inhalt.
    private func enterEditMode() {
        isEditing = true
        updatedContent = entry.content
    }

    /// Verwirft Änderungen und verlässt den Bearbeitungsmodus.
    private func exitEditMode() {
        isEditing = false
        updatedContent = entry.content // Setzt den ursprünglichen Inhalt zurück
    }

    /// Speichert die Änderungen über das ViewModel.
    private func saveChanges() async {
        await viewModel.updateEntry(entryId: entry.id, content: updatedContent)
        isEditing = false
    }
}
