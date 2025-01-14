//
//  SettingsView.swift
//  echo.journal
//
//  Created by Robin Bettinghausen on 14.01.25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // State-Variablen für die Eingabefelder
    @State private var newUsername: String = ""
    @State private var selectedLanguage: Language = .en // Standardwert
    @State private var isEditing: Bool = false // Zustand für das Bearbeiten
    
    var body: some View {
        VStack {
            // Aktuelle Profildaten anzeigen
            if let currentUser = viewModel.currentUser {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Benutzername: \(currentUser.username)")
                        Text("Zielsprache: \(currentUser.preferredLanguage.rawValue)")
                        Text("Mitglied seit: \(currentUser.formattedCreatedAt)")
                    }
                    Spacer()
                    Button(action: {
                        // Setze die Eingabewerte auf die aktuellen Werte
                        newUsername = currentUser.username
                        selectedLanguage = currentUser.preferredLanguage
                        isEditing.toggle() // Toggle den Bearbeitungszustand
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                // Zeige die Eingabefelder und den Picker nur, wenn isEditing true ist
                if isEditing {
                    TextField("Neuer Benutzername", text: $newUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Picker("Zielsprache", selection: $selectedLanguage) {
                        ForEach(Language.allCases) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    
                    Button("Profil aktualisieren") {
                        Task {
                            await viewModel.updateProfile(username: newUsername, preferredLanguage: selectedLanguage)
                            presentationMode.wrappedValue.dismiss() // Schließe die SettingsView
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            
            Button("Logout") {
                Task {
                    viewModel.signOut() // Logout-Logik aufrufen
                    presentationMode.wrappedValue.dismiss() // SettingsView schließen
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            Button("Konto löschen") {
                Task {
                    await viewModel.deleteAccount() // Konto löschen
                    presentationMode.wrappedValue.dismiss() // SettingsView schließen
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Einstellungen")
    }
}

#Preview {
    SettingsView(viewModel:
                    UserViewModel(authRepository: UserAuthRepository(), storeRepository: UserStoreRepository()))
}
