import SwiftUI

struct EntryList: View {
    @ObservedObject var entryViewModel: EntryViewModel // ViewModel für die Liste
    
    @Environment(\.colorScheme) var colorScheme // Aktuelles Farbschema
    
    @State private var selectedEntry: JournalEntry?
    
    var body: some View {
        List {
            ForEach(entryViewModel.entries.sorted(by: { $0.createdAt > $1.createdAt })) { entry in
                ZStack {
                    // Unsichtbarer NavigationLink für die Navigation
                    NavigationLink(value: entry) {
                        EmptyView() // Unsichtbarer Inhalt
                    }
                    .buttonStyle(.plain)
                    .frame(width: 0, height: 0) // Unsichtbar machen
                    
                    // Sichtbare Kachel
                    EntryRow(
                        entry: entry,
                        colorScheme: colorScheme,
                        onEdit: {
                            entryViewModel.selectedEntry = entry
                        },
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
                    .contentShape(Rectangle()) // Klickbereich für die gesamte Kachel
                }
                .listRowSeparator(.hidden) // Separator verbergen
            }
        }
        .listStyle(PlainListStyle())
        // Navigation für JournalEntry aktivieren
        .navigationDestination(for: JournalEntry.self) { entry in
            EntryDetailView(viewModel: entryViewModel, entry: entry)
        }
    }
}
