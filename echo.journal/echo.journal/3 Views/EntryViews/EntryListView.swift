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
    
    let buttonWidth = UIScreen.main.bounds.width / 3
    let capsuleWidth: CGFloat = 60
    let capsuleHeight: CGFloat = 30
    
    init(userViewModel: UserViewModel, colorManager: ColorManager) {
        self.userViewModel = userViewModel
        self.colorManager = colorManager
        _entryViewModel = StateObject(
            wrappedValue: EntryViewModel(
                entryStoreRepository: EntryStoreRepository(),
                userId: userViewModel.currentUser?.id ?? ""
            )
        )
    }
    
    var body: some View {
        ZStack {
            // Liste der Tagebucheinträge mit Favoriten-Filter
            EntryList(entryViewModel: entryViewModel,
                      colorManager: colorManager,
                      filterFavorites: showFavoritesOnly)
            .refreshable {
                await entryViewModel.loadEntries()
            }
            
            // Weicher Verlauf am unteren Bildschirmrand
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color(UIColor.systemBackground)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
                .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showingAddEntry) {
            AddEntryView(entryViewModel: entryViewModel, colorManager: colorManager)
        }
        .toolbar {
            /// **OBERE TOOLBAR**
            // Links: Statistik-Ansicht
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: StatisticsView(entryViewModel: entryViewModel)) {
                    Image(systemName: "calendar.and.person") // calendar.and.person, arrow.up.right.circle.fill, chart.xyaxis.line
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .frame(width: capsuleWidth, height: capsuleHeight)
                        .background(
                            Capsule().fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3))
                        )
                }
            }
            
            // Mitte: Titel mit Benutzername
            ToolbarItem(placement: .principal) {
                Text("\(userViewModel.currentUser?.username ?? "")'s Tagebuch")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            
            // Rechts: Einstellungen
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView(viewModel: userViewModel, colorManager: colorManager)) {
                    Image(systemName: "slider.horizontal.3") // person.fill, slider.horizontal3, person.crop.circle.fill
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .frame(width: capsuleWidth, height: capsuleHeight)
                        .background(
                            Capsule().fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3))
                        )
                }
            }
            
            /// **UNTERE TOOLBAR*
            // Links: Favoriten-Filter
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    showFavoritesOnly.toggle()
                }) {
                    Image(systemName: showFavoritesOnly ? "bookmark.slash.fill" : "bookmark.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: capsuleWidth, height: capsuleHeight)
                        .background(Capsule().fill(Color(UIColor.systemGray4)))
                }
                .padding(.leading, 16)
                .frame(width: buttonWidth, alignment: .leading)
            }
            
            // Mitte: Neuer Eintrag erstellen
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    showingAddEntry.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 35)
                        .background(
                            Capsule().fill(colorScheme == .dark ? .white : .black)
                        )
                }
                .frame(width: buttonWidth, alignment: .center)
            }
            
            // Rechts: Inspiration anzeigen
            ToolbarItem(placement: .bottomBar) {
                if let dailyInsp = inspirationViewModel.dailyInspiration() {
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
                            Text(dailyInsp.text)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .presentationCompactAdaptation(.popover)
                        .padding()
                        .background(colorManager.currentColor.color)
                    }
                    .frame(width: buttonWidth, alignment: .center)
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
