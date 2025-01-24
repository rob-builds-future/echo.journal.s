import SwiftUI

struct EntryList: View {
    @ObservedObject var entryViewModel: EntryViewModel // ViewModel für die Liste
    
    @Environment(\.colorScheme) var colorScheme // Aktuelles Farbschema
    
    @State private var selectedEntry: JournalEntry?
    
    var body: some View {
        List {
            ForEach(entryViewModel.entries) { entry in
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
                                await entryViewModel.deleteEntry(entryId: entry.id)
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
//        // Navigation bei Auswahl eines Eintrags programmgesteuert auslösen
//        .onChange(of: selectedEntry) { entry in
//            if let entry = entry {
//                entryViewModel.selectedEntry = entry
//            }
//        }
    }
}
