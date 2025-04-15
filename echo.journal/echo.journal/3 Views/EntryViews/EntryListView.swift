import SwiftUI

struct EntryListView: View {
    // Externe Abhängigkeiten
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager

    // Intern erzeugte ViewModels – einheitlich im init instanziiert
    @StateObject private var entryViewModel: EntryViewModel
    @StateObject private var statisticsViewModel: StatisticsViewModel
    @StateObject private var inspirationViewModel: InspirationViewModel
    @StateObject private var translationViewModel: TranslationViewModel
    @StateObject private var ttsViewModel = TtsViewModel()

    
    @Environment(\.colorScheme) var colorScheme
    
    // Lokale Zustände
    @State private var showingAddEntry: Bool = false
    @State private var showFavoritesOnly: Bool = false
    @State private var showInspirationPopover: Bool = false
    
    // Initialisierung – alle internen ViewModels werden hier erzeugt
    init(userViewModel: UserViewModel, colorManager: ColorManager) {
        self.userViewModel = userViewModel
        self.colorManager = colorManager
        
        let entryViewModelInstance = EntryViewModel(
            entryStoreRepository: EntryStoreRepository(),
            userId: userViewModel.currentUser?.id ?? ""
        )
        _entryViewModel = StateObject(wrappedValue: entryViewModelInstance)
        _statisticsViewModel = StateObject(wrappedValue: StatisticsViewModel(entryViewModel: entryViewModelInstance))
        _inspirationViewModel = StateObject(wrappedValue: InspirationViewModel())
        _translationViewModel = StateObject(wrappedValue: TranslationViewModel(
            translationRepository: TranslationAPIRepository(),
            userAuthRepository: UserAuthRepository()
        ))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                StatisticsHeaderView(
                    colorManager: colorManager,
                    totalWords: statisticsViewModel.totalWords,
                    totalTime: statisticsViewModel.totalDuration
                )
                .padding(.vertical, 4)
                
                // Eintragsliste
                EntryList(
                    entryViewModel: entryViewModel,
                    colorManager: colorManager,
                    translationViewModel: translationViewModel,
                    filterFavorites: showFavoritesOnly
                )
                .refreshable {
                    await entryViewModel.loadEntries()
                }
            }
            // Overlay: Fade-Effekt am unteren Rand
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color(UIColor.systemBackground)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 140)
                .allowsHitTesting(false),
                alignment: .bottom
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showingAddEntry) {
            AddEntryView(
                entryViewModel: entryViewModel,
                colorManager: colorManager,
                translationViewModel: translationViewModel,
                inspirationViewModel: inspirationViewModel
            )
        }
        .toolbar {
            /// OBERE TOOLBAR
            // Links: Statistik-Ansicht
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: StatisticsView(
                    userViewModel: userViewModel,
                    statisticsViewModel: statisticsViewModel,
                    translationViewModel: translationViewModel,
                    colorManager: colorManager
                )) {
                    Image(systemName: "calendar.and.person")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            // Mitte: Titel mit Benutzername
            ToolbarItem(placement: .principal) {
                let username = userViewModel.currentUser?.username ?? ""
                Text(String(format: NSLocalizedString("journalTitle", comment: "Titel des Tagebuchs eines Nutzers"), username))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            // Rechts: Einstellungen
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView(viewModel: userViewModel, colorManager: colorManager)) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            /// UNTERE TOOLBAR
            // Links: Favoriten-Filter
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    showFavoritesOnly.toggle()
                }) {
                    Image(systemName: showFavoritesOnly ? "bookmark.slash.fill" : "bookmark.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .frame(width: 60, height: 30)
                        .background(Capsule().fill(Color(colorScheme == .dark ? .white : .black)))
                }
                .padding(.leading, 16)
                .frame(width: UIScreen.main.bounds.width / 3, alignment: .leading)
            }
            // Mitte: Neuer Eintrag erstellen
            ToolbarItem(placement: .bottomBar) {
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
                .frame(width: UIScreen.main.bounds.width / 3, alignment: .center)
            }
            // Rechts: Inspiration anzeigen
            ToolbarItem(placement: .bottomBar) {
                if let dailyInspiration = inspirationViewModel.dailyInspiration() {
                    Button(action: {
                        showInspirationPopover.toggle()
                    }) {
                        Text("e.")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(Circle().fill(colorManager.currentColor.color))
                    }
                    .popover(isPresented: $showInspirationPopover, attachmentAnchor: .point(.topTrailing)) {
                        VStack(spacing: 12) {
                            Text(dailyInspiration.text)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)
                            Color.clear
                                .scaleEffect(2)
                        }
                        .padding()
                        .frame(height: 120)
                        .presentationCompactAdaptation(.popover)
                        .background(colorManager.currentColor.color)
                    }
                    .frame(width: UIScreen.main.bounds.width / 3, alignment: .center)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.clear, for: .bottomBar)
        .onAppear {
            Task { await entryViewModel.loadEntries() }
        }
    }
}
