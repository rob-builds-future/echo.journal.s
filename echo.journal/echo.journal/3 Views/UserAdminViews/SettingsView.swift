import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: UserViewModel
    @ObservedObject var colorManager: ColorManager

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    @State private var newUsername: String = ""
    @State private var selectedLanguage: Language = .en
    @State private var selectedColorScheme: EchoColor = .azulLuminoso
    @State private var isEditingUsername: Bool = false
    @State private var isEditingLanguage: Bool = false
    @State private var isEditingColor: Bool = false
    @State private var showDeleteConfirmation: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar mit zentralem Titel
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.3))
                        )
                }
                Spacer()
                Text("Profil")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Spacer() // Platzhalter für symmetrischen Abstand
            }
            .padding(.horizontal)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 20) {
                    // Abstand zwischen Toolbar und Liste
                    Spacer().frame(height: 20)

                    // Profildaten über die gesamte Breite
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mitglied seit: \(viewModel.currentUser?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "")")
                        Divider()
                        if isEditingUsername {
                            TextField("Neuer Benutzername", text: $newUsername)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 10)
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
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        } else {
                            HStack {
                                Text("Benutzername: \(viewModel.currentUser?.username ?? "")")
                                Spacer()
                                Button(action: {
                                    newUsername = viewModel.currentUser?.username ?? ""
                                    isEditingUsername = true
                                }) {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .black : .white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 10)
                                        .background(Capsule().fill(colorScheme == .dark ? .white : .black))
                                }
                            }
                        }
                        Divider()
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
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        } else {
                            HStack {
                                Text("Zielsprache: \(viewModel.currentUser?.preferredLanguage.rawValue ?? "")")
                                Spacer()
                                Button(action: {
                                    selectedLanguage = viewModel.currentUser?.preferredLanguage ?? .en
                                    isEditingLanguage = true
                                }) {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .black : .white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 10)
                                        .background(Capsule().fill(colorScheme == .dark ? .white : .black))
                                }
                            }
                        }
                        Divider()
                        if isEditingColor {
                            Picker("Farbe", selection: $selectedColorScheme) {
                                ForEach(EchoColor.allCases) { color in
                                    Text(color.displayName).tag(color)
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
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        } else {
                            HStack {
                                Text("Echo Farbe: \(colorManager.currentColor.displayName)")
                                Spacer()
                                Button(action: {
                                    selectedColorScheme = colorManager.currentColor
                                    isEditingColor = true
                                }) {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .black : .white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 10)
                                        .background(Capsule().fill(colorScheme == .dark ? .white : .black))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                    )
                    .padding(.horizontal)
                }
            }

            // Mehr Optionen Button unten
            VStack(spacing: 15) {
                Menu {
                    Button("Abmelden") {
                        Task {
                            viewModel.signOut()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Text("Konto löschen")
                    }
                } label: {
                    Text("Mehr Optionen")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.2))
                        )
                }
                .padding(.horizontal)
                .padding(.bottom, 20) // Abstand zum unteren Rand
            }
        }
        .navigationBarHidden(true)
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
