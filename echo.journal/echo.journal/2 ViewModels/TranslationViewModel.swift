import Foundation

@MainActor
class TranslationViewModel: ObservableObject {
    private let translationRepository: TranslationAPIRepository
    private let userAuthRepository: UserAuthRepository
    
    @Published var translatedText: String = ""
    @Published var userPreferredLanguage: Language = .en
    
    private var translationDebounceTimer: Timer?

    
    init(translationRepository: TranslationAPIRepository, userAuthRepository: UserAuthRepository) {
        self.translationRepository = translationRepository
        self.userAuthRepository = userAuthRepository
    }
    
    func fetchUserPreferredLanguage() async {
        do {
            if let user = try await userAuthRepository.getCurrentUser() {
                self.userPreferredLanguage = user.preferredLanguage
                print("Preferred Language: \(self.userPreferredLanguage.rawValue)")
            }
        } catch {
            print("Error fetching preferred language: \(error.localizedDescription)")
        }
    }
    
    func translateText(_ text: String) async {
        print("Text to Translate: \(text)")
        print("Target Language: \(userPreferredLanguage.code)")
        
        do {
            let translation = try await translationRepository.translate(
                text: text,
                targetLanguage: userPreferredLanguage.code
            )
            print("Translation Result: \(translation)")
            self.translatedText = translation
        } catch {
            print("Translation Error: \(error.localizedDescription)")
        }
    }
    
    func handleTextChange(newValue: String) {
        translationDebounceTimer?.invalidate()
        translationDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            Task {
                await self.translateText(newValue)
            }
        }
    }
}
