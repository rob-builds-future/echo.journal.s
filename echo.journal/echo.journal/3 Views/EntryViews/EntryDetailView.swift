import SwiftUI

struct EntryDetailView: View {
    @ObservedObject var viewModel: EntryViewModel
    let entryId: String

    var body: some View {
        if let entry = viewModel.entries.first(where: { $0.id == entryId }) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Inhalt
                    Text(entry.content)
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.bottom, 8)

                    // Erstellungsdatum
                    HStack {
                        Image(systemName: "calendar")
                        Text("Erstellt am: \(entry.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)

                    // Aktualisierungsdatum
                    HStack {
                        Image(systemName: "clock")
                        Text("Aktualisiert am: \(entry.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Eintrag Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Bearbeiten") {
                        // Logik für Bearbeiten (z. B. Umschalten in den Bearbeitungsmodus)
                    }
                }
            }
        } else {
            // Fallback, wenn der Eintrag nicht gefunden wird
            Text("Eintrag nicht gefunden.")
                .font(.headline)
                .foregroundColor(.red)
        }
    }
}
