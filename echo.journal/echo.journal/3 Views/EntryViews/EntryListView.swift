import SwiftUI

struct EntryListView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager
    @StateObject private var entryViewModel: EntryViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingAddEntry = false
    @State private var showFavoritesOnly = false
    
    init(userViewModel: UserViewModel, colorManager: ColorManager) {
        self.userViewModel = userViewModel
        self.colorManager = colorManager
        _entryViewModel = StateObject(wrappedValue: EntryViewModel(entryStoreRepository: EntryStoreRepository(), userId: userViewModel.currentUser?.id ?? ""))
    }
    
    var body: some View {
        VStack {
            EntryList(entryViewModel: entryViewModel,
                      colorManager: colorManager,
                      filterFavorites: showFavoritesOnly) // Liste mit Einträgen
            .refreshable { // Lade die Entries mit Pull-to-Refresh
                await entryViewModel.loadEntries()
            }
            .padding(.top, 12) // etwas Abstand von der Toolbar
        }
        .sheet(isPresented: $showingAddEntry) { // AddEntry Sheet
            AddEntryView(viewModel: entryViewModel, colorManager: colorManager)
        }
        .toolbar {
            ToolbarItem(placement: .principal) { // Titel Toolbar Element
                HStack(spacing: 0) {
                    Text(userViewModel.currentUser?.username ?? "")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(colorManager.currentColor.color) // Nur der Benutzername in Farbe
                    
                    Text("'s Tagebuch")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : .black) // Standardfarbe für den Rest
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) { // User Settings Toolbar Element
                NavigationLink(destination: SettingsView(viewModel: userViewModel, colorManager: colorManager)) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3)) // **Adaptiver Hintergrund**
                        )
                }
            }
            
            ToolbarItem(placement: .bottomBar) { // Neuer Eintrag Toolbar Element
                HStack(alignment: .bottom) {
                    // Favoriten-Filter Button
                    Button(action: {
                        showFavoritesOnly.toggle()
                    }) {
                        Image(systemName: showFavoritesOnly ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 16)
                            .background(
                                Capsule()
                                    .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3))
                            )
                    }
                    
                    Spacer()
                    
                    // Plus-Button zum Hinzufügen eines neuen Eintrags
                    Button(action: {
                        showingAddEntry.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 35)
                            .background(
                                Capsule().fill(colorManager.currentColor.color)
                            )
                    }
                    
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline) // Beseitige Platzhalter für Navigationtitle
        .toolbarBackground(Color.clear, for: .bottomBar) // Mache bottom Toolbar transparent
        .onAppear { // Lade on view appear die entries
            Task {
                await entryViewModel.loadEntries()
            }
        }
    }
}

#Preview {
    EntryListView(userViewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()), colorManager: ColorManager())
}
