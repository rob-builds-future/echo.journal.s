import SwiftUI

struct EntryList: View {
    @ObservedObject var entryViewModel: EntryViewModel
    @ObservedObject var colorManager: ColorManager
    @ObservedObject var translationViewModel: TranslationViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
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
            // Abstand für letzten Eintrag in Liste
            Rectangle()
                .fill(.clear)
                .frame(height: 100)
        }
        .listStyle(PlainListStyle())
        // Navigation für JournalEntry aktivieren
        .navigationDestination(for: JournalEntry.self) { entry in
            EntryDetailView(entryViewModel: entryViewModel, colorManager: colorManager, translationViewModel: translationViewModel, entryId: entry.id)
        }
    }
}
