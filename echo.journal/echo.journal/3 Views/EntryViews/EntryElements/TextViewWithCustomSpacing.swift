import SwiftUI

struct TextViewWithCustomSpacing: UIViewRepresentable {
    @Binding var text: String
    var wordCount: Int
    var onTextChange: (String) -> Void
    @FocusState.Binding var isFocused: Bool

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewWithCustomSpacing

        init(parent: TextViewWithCustomSpacing) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.onTextChange(textView.text)
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 14, weight: .regular) // Setze die Schriftgröße explizit
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.backgroundColor = UIColor.clear

        // Set custom line spacing and paragraph spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.paragraphSpacing = 6  // Abstand zwischen Absätzen

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 14, weight: .regular) // Sicherstellen, dass die Schriftgröße 16 bleibt
        ]

        let attributedText = NSAttributedString(string: text, attributes: attributes)
        textView.attributedText = attributedText
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.paragraphSpacing = 6

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 14, weight: .regular) // Auch hier sicherstellen, dass die Schriftgröße beibehalten wird
        ]

        let attributedText = NSAttributedString(string: text, attributes: attributes)
        uiView.attributedText = attributedText
    }
}
