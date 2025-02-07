import Foundation
import Combine

@MainActor
class TranslationViewModel: ObservableObject {
    private let translationRepository: TranslationAPIRepository
    private let userAuthRepository: UserAuthRepository
    
    @Published var translatedText: String = ""
    @Published var userPreferredLanguage: Language = .en
    
    private var translationDebounceTimer: Timer?
    
    // Cache (optional)
    private var topWordTranslationCache: [String: TopWordTranslation] = [:]
    
    init(translationRepository: TranslationAPIRepository, userAuthRepository: UserAuthRepository) {
        self.translationRepository = translationRepository
        self.userAuthRepository = userAuthRepository
        
        Task {
            await fetchUserPreferredLanguage()
        }
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
    
    func translateText(_ text: String, sourceLanguage: String = "auto") async {
        print("Text to Translate: \(text)")
        print("Target Language: \(userPreferredLanguage.code), Source Language: \(sourceLanguage)")
        do {
            let translation = try await translationRepository.translate(
                text: text,
                targetLanguage: userPreferredLanguage.code,
                sourceLanguage: sourceLanguage
            )
            DispatchQueue.main.async {
                self.objectWillChange.send()
                self.translatedText = translation
            }
        } catch {
            print("Translation Error: \(error.localizedDescription)")
        }
    }
    
    func handleTextChange(newValue: String, debounceTime: TimeInterval) {
        translationDebounceTimer?.invalidate()
        translationDebounceTimer = Timer.scheduledTimer(withTimeInterval: debounceTime, repeats: false) { _ in
            Task {
                await self.translateText(newValue)
            }
        }
    }
}

extension TranslationViewModel {
    /// Allgemeine Übersetzungsmethode (ohne explizite Quellsprache)
    func translation(for text: String) async -> String {
        do {
            let result = try await translationRepository.translate(
                text: text,
                targetLanguage: userPreferredLanguage.code,
                sourceLanguage: "auto"
            )
            let capitalizedResult = result.prefix(1).uppercased() + result.dropFirst()
            if capitalizedResult.lowercased() == text.lowercased() {
                return text.prefix(1).uppercased() + text.dropFirst()
            }
            return capitalizedResult
        } catch {
            print("Translation Error: \(error.localizedDescription)")
            return text.prefix(1).uppercased() + text.dropFirst()
        }
    }
    
    /// Übersetzt Top‑Words: Es wird explizit "de" als Eingabesprache genutzt.
    /// Die Methode enthält einen Retry-Mechanismus (bis zu 2 Versuche) und nutzt optional einen Cache.
    func translationForTopWord(_ text: String) async -> TopWordTranslation {
        // Cache-Prüfung:
        if let cached = topWordTranslationCache[text.lowercased()] {
            return cached
        }
        
        let maxRetries = 2
        var currentAttempt = 0
        
        while currentAttempt < maxRetries {
            do {
                let result = try await translationRepository.translateForTopWord(
                    text: text,
                    targetLanguage: userPreferredLanguage.code,
                    sourceLanguage: "de",   // explizit Deutsch
                    alternatives: 3         // Anzahl der gewünschten Alternativen
                )
                let mainResult = result.main.prefix(1).uppercased() + result.main.dropFirst()
                let final = TopWordTranslation(main: mainResult, alternatives: result.alternatives)
                topWordTranslationCache[text.lowercased()] = final
                return final
            } catch let error as URLError where error.code == .timedOut {
                print("Timeout while translating '\(text)', attempt \(currentAttempt + 1)")
                currentAttempt += 1
            } catch {
                print("Translation Error: \(error.localizedDescription)")
                break
            }
        }
        let fallback = TopWordTranslation(main: text.prefix(1).uppercased() + text.dropFirst(), alternatives: [])
        topWordTranslationCache[text.lowercased()] = fallback
        return fallback
    }
}
