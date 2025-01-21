import SwiftUI

struct EntryDetailView: View {
    var entry: JournalEntry
    @ObservedObject var viewModel: EntryViewModel

    var body: some View {
        VStack {
            Text(entry.content)
                .font(.title)
                .padding()

            // Hier kannst du weitere Details und Bearbeitungsoptionen hinzufügen
            Button("Mark as Favorite") {
                Task {
                    await viewModel.toggleFavorite(entryId: entry.id)
                }
            }
            .padding()
        }
        .navigationTitle("Entry Details")
    }
}

#Preview {
    EntryDetailView(entry: JournalEntry(userId: "testUser", content: "Test Entry"), viewModel: EntryViewModel(entryStoreRepository: EntryStoreRepository(), userId: "testUser"))
}
