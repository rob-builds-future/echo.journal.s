import SwiftUI

struct EntryList: View {
    @ObservedObject var entryViewModel: EntryViewModel
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        List {
            ForEach(entryViewModel.entries) { entry in
                EntryRow(
                    entry: entry,
                    colorScheme: colorScheme,
                    onEdit: { /* Bearbeiten-Aktion */ },
                    onToggleFavorite: {
                        Task { await entryViewModel.toggleFavorite(entryId: entry.id) }
                    },
                    onDelete: {
                        Task { await entryViewModel.deleteEntry(entryId: entry.id) }
                    }
                )
            }
            .onDelete(perform: deleteEntry)
            .listRowSeparator(.hidden)
        }
        .listStyle(PlainListStyle())
    }

    private func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            let entry = entryViewModel.entries[index]
            Task {
                await entryViewModel.deleteEntry(entryId: entry.id) // Lösche den Eintrag über das ViewModel
            }
        }
    }
}
