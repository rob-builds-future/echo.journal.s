import SwiftUI

struct EntryListView: View {
    @ObservedObject var userViewModel: UserViewModel // UserViewModel für den aktuellen Benutzer
    @StateObject private var entryViewModel: EntryViewModel // EntryViewModel für die Einträge
    @State private var showingAddEntry = false // Zustand für das Anzeigen des Hinzufügen-Dialogs
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        // Initialisiere das EntryViewModel mit der Benutzer-ID des aktuellen Benutzers
        _entryViewModel = StateObject(wrappedValue: EntryViewModel(entryStoreRepository: EntryStoreRepository(), userId: userViewModel.currentUser?.id ?? ""))
    }
    
    var body: some View {
        VStack {
            // Liste der Tagebucheinträge
            List {
                ForEach(entryViewModel.entries) { entry in
                    NavigationLink(destination: EntryDetailView(entry: entry, viewModel: entryViewModel)) {
                        HStack {
                            Text(entry.content)
                            Spacer()
                            if entry.isFavorite {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteEntry) // Ermöglicht das Löschen von Einträgen
            }
            .navigationTitle("\(userViewModel.currentUser?.username ?? "")'s Tagebuch") // Setze den Titel der Navigation
        }
        .sheet(isPresented: $showingAddEntry) {
            AddEntryView(viewModel: entryViewModel)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Navigiere zur SettingsView
                NavigationLink(destination: SettingsView(viewModel: userViewModel)) {
                    Image(systemName: "gear")
                        .imageScale(.large) // Größeres Zahnrad-Icon
                }
            }
            ToolbarItem(placement: .bottomBar) {
                // Zeige das Hinzufügen-Sheet an
                Button(action: {
                    showingAddEntry.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
        }
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
