import SwiftUI

struct AddEntryView: View {
    @ObservedObject var entryViewModel: EntryViewModel
    @ObservedObject var colorManager: ColorManager
    @ObservedObject var translationViewModel: TranslationViewModel
    @ObservedObject var inspirationViewModel: InspirationViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var content: String = ""
    @State private var entryDate: Date = Date()
    @State private var showDatePicker = false
    @State private var showAlert = false
    @State private var isReversed: Bool = false
    
    @FocusState private var textEditorFocused: Bool
    
    var wordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isReversed {
                    TranslationSectionView(translationViewModel: translationViewModel, colorManager: colorManager)
                    ZStack {
                        Divider()
                            .padding(.vertical, 4)
                        Button(action: { isReversed.toggle() }) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .padding(6)
                                .background(Circle().fill(Color(.systemBackground)))
                        }
                    }
                    EntrySectionView(content: $content, wordCount: wordCount, textEditorFocused: $textEditorFocused, entryViewModel: entryViewModel, translationViewModel: translationViewModel, inspirationViewModel: inspirationViewModel, colorManager: colorManager)
                } else {
                    EntrySectionView(content: $content, wordCount: wordCount, textEditorFocused: $textEditorFocused, entryViewModel: entryViewModel, translationViewModel: translationViewModel, inspirationViewModel: inspirationViewModel, colorManager: colorManager)
                    ZStack {
                        Divider()
                            .padding(.vertical, 4)
                        Button(action: { isReversed.toggle() }) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .padding(6)
                                .background(Circle().fill(Color(.systemBackground)))
                        }
                    }
                    TranslationSectionView(translationViewModel: translationViewModel, colorManager: colorManager)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showAlert = true }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Button(action: { showDatePicker.toggle() }) {
                        Text(entryDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(colorManager.currentColor.color)
                    }
                }
                //                ToolbarItem(placement: .navigationBarTrailing) {
                //                    Button(action: { isReversed.toggle() }) {
                //                        Image(systemName: "arrow.up.arrow.down")
                //                            .font(.system(size: 14, weight: .bold, design: .rounded))
                //                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                //                    }
                //                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            try await entryViewModel.createEntry(content: content, date: entryDate)
                            dismiss()
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 30)
                            .background(
                                Capsule().fill(content.isEmpty ? Color(UIColor.systemGray4) : colorManager.currentColor.color)
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
            .onAppear {
                UITextView.appearance().tintColor = UIColor.gray
            }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker("selectDate", selection: $entryDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                    Button("Fertig") {
                        showDatePicker = false
                    }
                    .padding()
                }
                .presentationDetents([.medium])
            }
            .alert("Änderungen verwerfen?", isPresented: $showAlert) {
                Button("cancel", role: .cancel) {}
                Button("Verwerfen", role: .destructive) { dismiss() }
            } message: {
                Text("Möchtest du die Änderungen wirklich verwerfen?")
            }
        }
    }
}
