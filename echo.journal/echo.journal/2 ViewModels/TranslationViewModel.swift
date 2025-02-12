import Foundation
import Combine // Wird benötigt, um ObservableObject und @Published für SwiftUI-Updates zu verwenden.

@MainActor
class TranslationViewModel: ObservableObject {
    // Abhängigkeiten für Übersetzungs- und Authentifizierungs-APIs.
    private let translationRepository: TranslationAPIRepository
    private let userAuthRepository: UserAuthRepository
    
    // Properties, die SwiftUI automatisch aktualisiert, wenn sie sich ändern.
    @Published var translatedText: String = ""
    @Published var userPreferredLanguage: Language = .en
    
    // Timer zur Verzögerung des Translate Aufrufs bei Texteingaben.
    private var translationDebounceTimer: Timer?
    
    // Cache für bereits übersetzte Top-Words, um wiederholte API-Aufrufe zu vermeiden.
    private var topWordTranslationCache: [String: TopWordTranslation] = [:]
    
    // Initialisierung mit Dependency Injection.
    init(translationRepository: TranslationAPIRepository, userAuthRepository: UserAuthRepository) {
        self.translationRepository = translationRepository
        self.userAuthRepository = userAuthRepository
        
        // Asynchrones Abrufen der bevorzugten Sprache des Benutzers.
        Task {
            await fetchUserPreferredLanguage()
        }
    }
    
    // Holt die bevorzugte Sprache des aktuellen Benutzers.
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
    
    // Übersetzt den eingegebenen Text.
    // - Parameter text: Der zu übersetzende Text.
    // - Parameter sourceLanguage: Die Quellsprache (Standard: "auto").
    func translateText(_ text: String, sourceLanguage: String = "auto") async {
        print("Text to Translate: \(text)")
        print("Target Language: \(userPreferredLanguage.code), Source Language: \(sourceLanguage)")
        do {
            let translation = try await translationRepository.translate(
                text: text,
                targetLanguage: userPreferredLanguage.code,
                sourceLanguage: sourceLanguage
            )
            // Aktualisieren der UI auf dem Hauptthread.
            DispatchQueue.main.async {
                self.objectWillChange.send()
                self.translatedText = translation
            }
        } catch {
            print("Translation Error: \(error.localizedDescription)")
        }
    }
    
    // Verzögert den Start der Übersetzung bei Texteingabe, um zu häufige Übersetzungsaufrufe zu vermeiden.
    // - Parameter newValue: Der aktuelle Texteingabewert.
    // - Parameter debounceTime: Zeitintervall für die Verzögerung.
    func handleTextChange(newValue: String, debounceTime: TimeInterval) {
        translationDebounceTimer?.invalidate() // Falls ein vorheriger Timer existiert, wird dieser gestoppt, um Mehrfachauslösungen zu vermeiden.
        translationDebounceTimer = Timer.scheduledTimer(withTimeInterval: debounceTime, repeats: false) { _ in   // Es wird ein neuer Timer erstellt, der nach 'debounceTime' Sekunden auslöst.
            Task { // Sobald der Timer auslöst, wird ein asynchroner Task gestartet.
                await self.translateText(newValue) // Dieser Task ruft die Funktion translateText mit dem aktuellen Text (newValue) auf.
            }
        }
    }
}

extension TranslationViewModel {

    // Zunächst wird geprüft, ob das Wort bereits im Cache vorhanden ist.
    // Andernfalls wird die Übersetzung (mit explizit Deutsch als Quellsprache) abgerufen.
    // Bei einem Fehler wird ein Fallback (Originalwort mit großem Anfangsbuchstaben) zurückgegeben.
    //
    // - Parameter text: Das zu übersetzende Wort.
    // - Returns: Ein `TopWordTranslation`-Objekt mit Hauptübersetzung und alternativen Übersetzungen.
    func translationForTopWord(_ text: String) async -> TopWordTranslation {
        // Rückgabe des Caches, falls vorhanden.
        if let cached = topWordTranslationCache[text.lowercased()] {
            return cached
        }
        
        do {
            // Anfrage an das Translation Repository; Quellsprache ist explizit Deutsch ("de").
            let result = try await translationRepository.translateForTopWord(
                text: text,
                targetLanguage: userPreferredLanguage.code,
                sourceLanguage: "de",   // Quellsprache: Deutsch
                alternatives: 3         // Anzahl der gewünschten Alternativübersetzungen
            )
            
            // Formatierung: Erstes Zeichen der Hauptübersetzung großschreiben.
            let mainResult = result.main.prefix(1).uppercased() + result.main.dropFirst()
            let finalTranslation = TopWordTranslation(main: mainResult, alternatives: result.alternatives)
            
            // Speichern im Cache.
            topWordTranslationCache[text.lowercased()] = finalTranslation
            
            return finalTranslation
        } catch {
            print("Translation Error: \(error.localizedDescription)")
            // Fallback: Originalwort mit großem Anfangsbuchstaben und ohne Alternativen.
            let fallbackTranslation = TopWordTranslation(
                main: text.prefix(1).uppercased() + text.dropFirst(),
                alternatives: []
            )
            topWordTranslationCache[text.lowercased()] = fallbackTranslation
            
            return fallbackTranslation
        }
    }
}
