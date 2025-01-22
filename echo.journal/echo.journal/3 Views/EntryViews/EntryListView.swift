import SwiftUI

struct EntryListView: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var entryViewModel: EntryViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingAddEntry = false // Zustand für das Anzeigen des Hinzufügen-Dialogs
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        // Initialisiere das EntryViewModel mit der Benutzer-ID des aktuellen Benutzers
        _entryViewModel = StateObject(wrappedValue: EntryViewModel(entryStoreRepository: EntryStoreRepository(), userId: userViewModel.currentUser?.id ?? ""))
    }
    
    var body: some View {
        VStack {
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
        .sheet(isPresented: $showingAddEntry) {
            AddEntryView(viewModel: entryViewModel)
        }
        .toolbar {
            ToolbarItem(placement: .principal) { // Benutzerdefinierter Titel
                Text("\(userViewModel.currentUser?.username ?? "")'s Tagebuch")
                    .font(.system(size: 20, weight: .bold, design: .rounded)) // SF Pro Rounded
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                // Navigiere zur SettingsView
                NavigationLink(destination: SettingsView(viewModel: userViewModel)) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded)) // SF Pro Rounded
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // Adaptive Farbe
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3)) // Dezenter Hintergrund
                        )
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                // Zeige das Hinzufügen-Sheet an
                Button(action: {
                    showingAddEntry.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 35)
                        .background(Capsule().fill(colorScheme == .dark ? .white : .black))
                }
            }
        }
        .toolbarBackground(Color.clear, for: .bottomBar)
        .onAppear {
            Task {
                await entryViewModel.loadEntries() // Lade die Einträge, wenn die Ansicht erscheint
            }
        }
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

#Preview {
    EntryListView(userViewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()))
}
