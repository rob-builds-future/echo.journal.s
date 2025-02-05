import SwiftUI

struct EntryListView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager
    @StateObject private var entryViewModel: EntryViewModel
    @StateObject private var inspirationViewModel = InspirationViewModel()
    //@StateObject private var statisticsViewModel: StatisticsViewModel
    
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
            // The list of entries
            EntryList(entryViewModel: entryViewModel,
                      colorManager: colorManager,
                      filterFavorites: showFavoritesOnly)
            .refreshable {
                await entryViewModel.loadEntries()
            }
            
            // Fade-out overlay at the bottom
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
            AddEntryView(viewModel: entryViewModel, colorManager: colorManager)
        }
        .toolbar {
            // Top Toolbar Items
            
            // Left: Statistics Button leading to the StatisticsView
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: StatisticsView()) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .frame(width: capsuleWidth, height: capsuleHeight)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3))
                        )
                }
            }
            
            // Center: Title
            ToolbarItem(placement: .principal) {
                Text("\(userViewModel.currentUser?.username ?? "")'s Tagebuch")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            
            // Right: User Settings
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView(viewModel: userViewModel, colorManager: colorManager)) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .frame(width: capsuleWidth, height: capsuleHeight)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3))
                        )
                }
            }
            
            /// BOTTOM TOOLBAR
            // Jeder Button ist ein eigenes ToolbarItem und bekommt eine fixe Breite,
            // hier ein Drittel der Bildschirmbreite.
            
            // Favoriten-Filter-Button (links)
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    showFavoritesOnly.toggle()
                }) {
                    Image(systemName: showFavoritesOnly ? "bookmark.slash.fill" : "bookmark.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: capsuleWidth, height: capsuleHeight)
                        .background(
                            Capsule().fill(Color(UIColor.systemGray4))
                        )
                }
                .padding(.leading, 16)
                .frame(width: buttonWidth, alignment: .leading)
            }
            
            // Plus-Button (in der Mitte)
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
            
            // Inspiration-Button (rechts)
            ToolbarItem(placement: .bottomBar) {
                if let dailyInsp = inspirationViewModel.dailyInspiration() {
                    Button(action: {
                        showInspirationPopover.toggle()
                    }) {
                        Text("e.")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(
                                Circle().fill(colorManager.currentColor.color)
                            )
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

#Preview {
    EntryListView(
        userViewModel: UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()),
        colorManager: ColorManager()
    )
}
