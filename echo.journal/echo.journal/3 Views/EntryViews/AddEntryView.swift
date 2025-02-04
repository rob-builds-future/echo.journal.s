import SwiftUI

struct AddEntryView: View {
    @ObservedObject var viewModel: EntryViewModel
    @ObservedObject var colorManager: ColorManager
    @StateObject private var translationViewModel = TranslationViewModel(
        translationRepository: TranslationAPIRepository(),
        userAuthRepository: UserAuthRepository()
    )
    @StateObject private var inspirationViewModel = InspirationViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var content: String = ""
    @State private var entryDate: Date = Date()
    @State private var showDatePicker = false
    
    var wordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $content)
                            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .autocorrectionDisabled(true)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .onChange(of: content) { _, newValue in
                                viewModel.startTimer(content: newValue)
                                translationViewModel.handleTextChange(newValue: newValue, debounceTime: 0.3)
                            }
                        // Platzhalter: Nur anzeigen, wenn der Editor leer ist
                        if content.isEmpty, let currentInsp = inspirationViewModel.currentInspiration {
                            HStack (alignment: .top){
                                Text(currentInsp.text)
                                    .foregroundColor(.gray)
                                    .padding(8)
                                Spacer()
                                // Button zum Blättern
                                Button(action: {
                                    inspirationViewModel.nextInspiration()
                                }) {
                                    Text("e.")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(
                                            Circle()
                                                .fill(colorManager.currentColor.color)
                                        )
                                }
                                .padding(.trailing, 8)
                            }
                            .zIndex(1)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Text("\(wordCount) Worte")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text(translationViewModel.translatedText.isEmpty ? "Hier werde ich für Dich übersetzen. Ich warte ..." : translationViewModel.translatedText)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(translationViewModel.translatedText.isEmpty ? colorManager.currentColor.color.opacity(0.5) : colorManager.currentColor.color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal)
                .padding(.vertical, 4)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                // Abbrechen Button (Links)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "xmark")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 14)
                        .background(
                            Capsule()
                                .fill(Color(UIColor.systemGray2))
                        )
                    }
                }
                // Klickbares Datum (Mitte)
                ToolbarItem(placement: .principal) {
                    Button(action: { showDatePicker.toggle() }) {
                        Text(entryDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(colorManager.currentColor.color)
                    }
                }
                // Speichern Button (Rechts)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            try await viewModel.createEntry(content: content, date: entryDate)
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 14)
                        .background(
                            Capsule()
                                .fill(content.isEmpty ? Color(UIColor.systemGray4) : colorManager.currentColor.color)
                        )
                    }
                    .disabled(content.isEmpty)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .task {
                await translationViewModel.fetchUserPreferredLanguage()
            }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker("Datum wählen", selection: $entryDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                    
                    Button("Fertig") {
                        showDatePicker = false
                    }
                    .padding()
                }
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    AddEntryView(viewModel: EntryViewModel(entryStoreRepository: EntryStoreRepository(), userId: "testUser"), colorManager: ColorManager())
}
