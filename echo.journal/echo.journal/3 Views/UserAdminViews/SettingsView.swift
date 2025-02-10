import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    // Lokale Zustände für Profiländerungen
    @State private var newUsername: String = ""
    @State private var selectedLanguage: Language = .en
    @State private var selectedColorScheme: EchoColor = .lichtblau
    @State private var isEditingUsername: Bool = false
    @State private var isEditingLanguage: Bool = false
    @State private var isEditingColor: Bool = false
    @State private var showDeleteConfirmation: Bool = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Kachel "Erinnerungen"
                    CardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Erinnerungen")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Text("Hier kannst Du Erinnerungen (Push-Benachrichtigungen) einstellen. (Demnächst verfügbar)")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    .padding(.top, 16)
                    
                    // Kachel "Vorlagen"
                    CardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vorlagen")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Text("Wähle Vorlagen für Deine Tagebucheinträge aus. (Demnächst verfügbar)")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    
                    // Kachel "Profil‑Einstellungen"
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Profil‑Einstellungen")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            // Mitglied seit…
                            if let createdAt = viewModel.currentUser?.createdAt {
                                Text("Mitglied seit: \(createdAt.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            
                            Divider()
                            
                            // Bearbeiten des Benutzernamens
                            if isEditingUsername {
                                TextField("Neuer Benutzername", text: $newUsername)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button(action: {
                                    Task {
                                        await viewModel.updateProfile(username: newUsername, preferredLanguage: selectedLanguage)
                                        isEditingUsername = false
                                    }
                                }) {
                                    Text("Speichern")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.black)
                                        .cornerRadius(8)
                                }
                            } else {
                                HStack {
                                    Text("Benutzername: \(viewModel.currentUser?.username ?? "")")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    Spacer()
                                    Button(action: {
                                        newUsername = viewModel.currentUser?.username ?? ""
                                        isEditingUsername = true
                                    }) {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(colorScheme == .dark ? .black : .white)
                                            .padding(8)
                                            .background(Capsule().fill(colorScheme == .dark ? .white : .black))
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Bearbeiten der Zielsprache
                            if isEditingLanguage {
                                Picker("Zielsprache", selection: $selectedLanguage) {
                                    ForEach(Language.allCases) { language in
                                        Text(language.rawValue).tag(language)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                Button(action: {
                                    Task {
                                        await viewModel.updateProfile(username: newUsername, preferredLanguage: selectedLanguage)
                                        isEditingLanguage = false
                                    }
                                }) {
                                    Text("Speichern")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.black)
                                        .cornerRadius(8)
                                }
                            } else {
                                HStack {
                                    Text("Zielsprache: \(viewModel.currentUser?.preferredLanguage.rawValue ?? "")")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    Spacer()
                                    Button(action: {
                                        selectedLanguage = viewModel.currentUser?.preferredLanguage ?? .en
                                        isEditingLanguage = true
                                    }) {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(colorScheme == .dark ? .black : .white)
                                            .padding(8)
                                            .background(Capsule().fill(colorScheme == .dark ? .white : .black))
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Bearbeiten der Echo-Farbe
                            if isEditingColor {
                                Picker("Farbe", selection: $selectedColorScheme) {
                                    ForEach(EchoColor.allCases) { color in
                                        HStack {
                                            Circle()
                                                .fill(color.color)
                                                .frame(width: 20, height: 20)
                                            Text(color.displayName)
                                        }
                                        .tag(color)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                Button(action: {
                                    Task {
                                        colorManager.updateColor(to: selectedColorScheme)
                                        isEditingColor = false
                                    }
                                }) {
                                    Text("Speichern")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.black)
                                        .cornerRadius(8)
                                }
                            } else {
                                HStack {
                                    Text("Echo Farbe: \(colorManager.currentColor.displayName)")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    Spacer()
                                    Button(action: {
                                        selectedColorScheme = colorManager.currentColor
                                        isEditingColor = true
                                    }) {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(colorScheme == .dark ? .black : .white)
                                            .padding(8)
                                            .background(Capsule().fill(colorScheme == .dark ? .white : .black))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            
            // "Mehr Optionen" Button unten
            VStack(spacing: 15) {
                Menu {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Text("Konto löschen")
                    }
                    Button("Abmelden") {
                        Task {
                            viewModel.signOut()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    Text("Mehr Optionen")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2))
                        )
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Abbrechen-Button (links)
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            // Titel in der Mitte
            ToolbarItem(placement: .principal) {
                Text("Deine Einstellungen")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Konto löschen"),
                message: Text("Bist du sicher, dass du dein Konto löschen möchtest? Diese Aktion kann nicht rückgängig gemacht werden."),
                primaryButton: .destructive(Text("Löschen")) {
                    Task {
                        await viewModel.deleteAccount()
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                secondaryButton: .cancel(Text("Abbrechen"))
            )
        }
    }
}

/// Diese Hilfs-View kapselt den Standard-Hintergrund und Padding für alle „Kacheln“
struct CardView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding(16) // Einheitliches Padding
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.2),
                        radius: 4, x: 0, y: 0)
        )
    }
}
