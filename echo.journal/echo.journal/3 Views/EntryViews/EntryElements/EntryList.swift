import SwiftUI

struct EntryList: View {
    @ObservedObject var entryViewModel: EntryViewModel // ViewModel für die Liste
    @ObservedObject var colorManager: ColorManager
    
    @Environment(\.colorScheme) var colorScheme // Aktuelles Farbschema
    
    let filterFavorites: Bool
    
    var body: some View {
        List {
            ForEach(entryViewModel.entries
                .filter { !filterFavorites || $0.isFavorite }
                .sorted(by: { $0.createdAt > $1.createdAt })
            ) { entry in
                EntryRow(
                    entryViewModel: entryViewModel,
                    colorManager: colorManager,
                    colorScheme: _colorScheme,
                    entry: entry,
                    onToggleFavorite: {
                        Task {
                            await entryViewModel.toggleFavorite(entryId: entry.id)
                        }
                    },
                    onDelete: {
                        Task {
                            await entryViewModel.deleteEntry(entryId: entry.id) // Eintrag löschen
                        }
                    }
                )
                .background(
                    NavigationLink("", value: entry) // Unsichtbarer NavigationLink im Hintergrund
                        .opacity(0) // Komplett unsichtbar
                )
                .contentShape(RoundedRectangle(cornerRadius: 12)) // Klickbereich exakt auf RoundedRectangle begrenzen
                .listRowSeparator(.hidden) // Separator verbergen
            }
        }
        .listStyle(PlainListStyle())
        // Navigation für JournalEntry aktivieren
        .navigationDestination(for: JournalEntry.self) { entry in
            EntryDetailView(viewModel: entryViewModel, colorManager: colorManager, entry: entry)
        }
    }
}
