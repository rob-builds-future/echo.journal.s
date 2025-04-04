//import SwiftUI
//
//struct AddEntryView: View {
//    @ObservedObject var entryViewModel: EntryViewModel
//    @ObservedObject var colorManager: ColorManager
//    @ObservedObject var translationViewModel: TranslationViewModel
//    @ObservedObject var inspirationViewModel: InspirationViewModel
//    
//    @Environment(\.dismiss) private var dismiss
//    @Environment(\.colorScheme) var colorScheme
//    
//    @State private var content: String = "" // Inhalt des neuen Eintrags
//    @State private var entryDate: Date = Date() // Datum des Eintrags
//    @State private var showDatePicker = false // Steuert die Sichtbarkeit des DatePickers
//    @State private var showAlert = false // Zeigt das Bestätigungs-Popup für das Verwerfen der Änderungen
//    
//    @State private var isTextEditorFocused: Bool = false
//    @FocusState private var textEditorFocused: Bool // Steuerung des Fokus auf das Textfeld
//    
//    // Berechnet die Wortanzahl des Eintrags
//    var wordCount: Int {
//        content.split { $0.isWhitespace || $0.isNewline }.count // Zerlegt text in einzelne Worte durch überprüfen der whitespaces und umbrüche und zählt diese dann
//    }
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                VStack(alignment: .leading) {
//                    ZStack(alignment: .topLeading) {
//                        // TextEditor für den Tagebucheintrag
//                        TextEditor(text: $content)
//                            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
//                            .padding(4)
//                            .background(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .fill(Color(UIColor.systemBackground))
//                            )
//                            .autocorrectionDisabled(true)
//                            .font(.system(size: 16, weight: .regular, design: .rounded))
//                            .focused($textEditorFocused) // Aktiviert den Fokus beim Öffnen
//                            .onAppear {
//                                textEditorFocused = true // Cursor direkt setzen
//                            }
//                            .onChange(of: content) { _, newValue in
//                                entryViewModel.startTimer(content: newValue) // Timer für die Schreibzeit
//                                translationViewModel.handleTextChange(newValue: newValue, debounceTime: 0.3) // Übersetzungen auslösen nach 0.3 Sek ohne Change
//                            }
//                        
//                        // Platzhalter mit Inspirationstext, falls das Feld leer ist
//                        if content.isEmpty, let currentInsp = inspirationViewModel.currentInspiration {
//                            HStack(alignment: .top) {
//                                Text(" \(currentInsp.text)")
//                                    .font(.system(size: 16, weight: .regular, design: .rounded))
//                                    .foregroundColor(colorManager.currentColor.color.opacity(0.5))
//                                    .padding(8)
//                                    .padding(.top, 4)
//                                Spacer()
//                                
//                                // Button zum Wechseln der Inspiration
//                                Button(action: {
//                                    inspirationViewModel.nextInspiration()
//                                }) {
//                                    Text("e.")
//                                        .font(.system(size: 16, weight: .bold, design: .rounded))
//                                        .foregroundColor(.white)
//                                        .padding(8)
//                                        .background(
//                                            Circle().fill(colorManager.currentColor.color)
//                                        )
//                                }
//                                .padding(.trailing, 8)
//                                .padding(.top, 8)
//                            }
//                            .zIndex(1) // Stellt sicher, dass der Platzhalter über dem TextEditor liegt
//                        }
//                    }
//                    
//                    Divider()
//                    
//                    // Wort-Zähler
//                    HStack {
//                        Spacer()
//                        Text("\(wordCount) Worte")
//                            .font(.system(size: 12, weight: .regular, design: .rounded))
//                            .foregroundColor(.gray)
//                            .padding(.horizontal, 4)
//                    }
//                }
//                .padding(.horizontal)
//                
//                // Bereich für die automatische Übersetzung
//                VStack(alignment: .leading) {
//                    Text(translationViewModel.translatedText.isEmpty
//                         ? "Hier werde ich für Dich übersetzen. Ich warte ..."
//                         : translationViewModel.translatedText)
//                    .font(.system(size: 16, weight: .regular, design: .rounded))
//                    .foregroundColor(translationViewModel.translatedText.isEmpty
//                                     ? colorManager.currentColor.color.opacity(0.5)
//                                     : colorManager.currentColor.color)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                .padding(.horizontal)
//                .padding(.vertical, 4)
//                
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            
//            .toolbar {
//                // Abbrechen-Button (links)
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: { showAlert = true }) {
//                        Image(systemName: "xmark")
//                            .font(.system(size: 14, weight: .bold, design: .rounded))
//                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
//                    }
//                }
//                
//                // Klickbares Datum (Mitte)
//                ToolbarItem(placement: .principal) {
//                    Button(action: { showDatePicker.toggle() }) {
//                        Text(entryDate.formatted(date: .abbreviated, time: .omitted))
//                            .font(.system(size: 16, weight: .bold, design: .rounded))
//                            .foregroundColor(colorManager.currentColor.color)
//                    }
//                }
//                
//                // Speichern-Button (rechts)
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        Task {
//                            try await entryViewModel.createEntry(content: content, date: entryDate)
//                            dismiss() // Schließt die Ansicht nach dem Speichern
//                        }
//                    }) {
//                        Image(systemName: "checkmark")
//                            .font(.system(size: 14, weight: .bold, design: .rounded))
//                            .foregroundColor(.white)
//                            .frame(width: 60, height: 30)
//                            .background(
//                                Capsule().fill(content.isEmpty ? Color(UIColor.systemGray4) : colorManager.currentColor.color)
//                            )
//                    }
//                    .disabled(content.isEmpty) // Deaktiviert Speichern, wenn das Feld leer ist
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            
//            // Tipp auf den Bildschirm schließt die Tastatur
//            .contentShape(Rectangle())
//            .onTapGesture {
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//            }
//            
//            // Lädt die bevorzugte Sprache beim Öffnen
//            .task {
//                await translationViewModel.fetchUserPreferredLanguage()
//            }
//            .onAppear {
//                UITextView.appearance().tintColor = UIColor.gray // Setzt die Cursor-Farbe
//            }
//            
//            // Datumsauswahl als Sheet
//            .sheet(isPresented: $showDatePicker) {
//                VStack {
//                    DatePicker("selectDate", selection: $entryDate, in: ...Date(), displayedComponents: .date)
//                        .datePickerStyle(GraphicalDatePickerStyle())
//                        .padding()
//                    
//                    Button("Fertig") {
//                        showDatePicker = false
//                    }
//                    .padding()
//                }
//                .presentationDetents([.medium])
//            }
//            
//            // Bestätigungsdialog für Abbrechen
//            .alert("Änderungen verwerfen?", isPresented: $showAlert) {
//                Button("Abbrechen", role: .cancel) {}
//                Button("Verwerfen", role: .destructive) { dismiss() }
//            } message: {
//                Text("Möchtest du die Änderungen wirklich verwerfen?")
//            }
//        }
//    }
//}
