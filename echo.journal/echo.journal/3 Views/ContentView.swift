import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: UserViewModel
    
    init() {
        let authRepo = UserAuthRepository()
        let storeRepo = UserStoreRepository()
        _viewModel = StateObject(wrappedValue: UserViewModel(
            authRepository: authRepo,
            storeRepository: storeRepo
        ))
    }
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoggedIn {
                JournalEntryListView(viewModel: viewModel, user: viewModel.currentUser!)
            } else {
                LoginView(viewModel: viewModel)
            }
        }
    }
}


#Preview {
    ContentView()
}
