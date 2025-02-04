import SwiftUI

struct EntryListView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager
    @StateObject private var entryViewModel: EntryViewModel
    @StateObject private var inspirationViewModel = InspirationViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingAddEntry = false
    @State private var showFavoritesOnly = false
    @State private var showInspirationPopover = false
    
    init(userViewModel: UserViewModel, colorManager: ColorManager) {
        self.userViewModel = userViewModel
        self.colorManager = colorManager
        _entryViewModel = StateObject(wrappedValue: EntryViewModel(entryStoreRepository: EntryStoreRepository(), userId: userViewModel.currentUser?.id ?? ""))
    }
    
    var body: some View {
        ZStack {
            // Liste mit Einträgen
            EntryList(entryViewModel: entryViewModel,
                      colorManager: colorManager,
                      filterFavorites: showFavoritesOnly)
            .refreshable {
                await entryViewModel.loadEntries()
            }
            // Fade-Out-Overlay am unteren Bildschirmrand
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color(UIColor.systemBackground)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80) // Passe die Höhe nach Bedarf an
                .allowsHitTesting(false) // Damit blockiert der Gradient keine Interaktionen
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showingAddEntry) { // AddEntry Sheet
            AddEntryView(viewModel: entryViewModel, colorManager: colorManager)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { // echo Inspiration Toolbar Element
                VStack {
                    if let dailyInsp = inspirationViewModel.dailyInspiration() {
                        Button(action: { showInspirationPopover.toggle() }) {
                            Text("e.")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(colorManager.currentColor.color)
                                )
                        }
                        .popover(isPresented: $showInspirationPopover) {
                            VStack(spacing: 12) {
                                Text(dailyInsp.text)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                //                                if let author = dailyInsp.author {
                                //                                    Text("– \(author)")
                                //                                        .font(.footnote)
                                //                                        .foregroundColor(.secondary)
                                //                                }
                            }
                            .presentationCompactAdaptation(.popover)
                            .padding()
                            .background(colorManager.currentColor.color)
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .principal) { // Titel Toolbar Element
                Text("\(userViewModel.currentUser?.username ?? "")'s Tagebuch")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black) // Standardfarbe für den Rest
            }
            
            ToolbarItem(placement: .navigationBarTrailing) { // User Settings Toolbar Element
                NavigationLink(destination: SettingsView(viewModel: userViewModel, colorManager: colorManager)) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
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
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 16)
                            .background(
                                Capsule()
                                    .fill(Color(UIColor.systemGray4))
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
            Task { await entryViewModel.loadEntries() }
        }
    }
}

#Preview {
    EntryListView(userViewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()), colorManager: ColorManager())
}
