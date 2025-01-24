import SwiftUI

struct EntryListView: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var entryViewModel: EntryViewModel
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showingAddEntry = false
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        _entryViewModel = StateObject(wrappedValue: EntryViewModel(entryStoreRepository: EntryStoreRepository(), userId: userViewModel.currentUser?.id ?? ""))
    }
    
    var body: some View {
        VStack {
            EntryList(entryViewModel: entryViewModel) // Liste mit Einträgen
                .refreshable { // Lade die Entries mit Pull-to-Refresh
                    await entryViewModel.loadEntries()
                }
                .padding(.top, 12) // etwas Abstand von der Toolbar
        }
        .sheet(isPresented: $showingAddEntry) { // AddEntry Sheet
            AddEntryView(viewModel: entryViewModel)
        }
        .toolbar {
            ToolbarItem(placement: .principal) { // Titel Toolbar Element
                Text("\(userViewModel.currentUser?.username ?? "")'s Tagebuch")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            
            ToolbarItem(placement: .navigationBarTrailing) { // User Settings Toolbar Element
                NavigationLink(destination: SettingsView(viewModel: userViewModel)) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3))
                        )
                }
            }
            
            ToolbarItem(placement: .bottomBar) { // Neuer Eintrag Toolbar Element
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
    EntryListView(userViewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()))
}
