import SwiftUI

struct EntryRow: View {
    @ObservedObject var entryViewModel: EntryViewModel // ViewModel for the list
    @ObservedObject var colorManager: ColorManager
    
    let entry: JournalEntry
    let colorScheme: ColorScheme
    let onEdit: () -> Void
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Entry background
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.15) : Color.white)
                .shadow(color: colorScheme == .dark ? Color.white : Color(UIColor.systemGray5), radius: 4, x: 0, y: 0)

            // Bookmark placed in the background so it doesn't affect layout
            if entry.isFavorite {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 32)) // Size control without affecting layout
                    .foregroundColor(Color(UIColor.systemGray4))
                    .background(Color.clear)
                    .offset(x: 300, y: -8) // Position above the date
                    .padding(0)
            }
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        // Datum mit bündigem Hintergrund oben links
                        ZStack {
                            CustomCornerShape(
                                topLeft: 12, topRight: 0,
                                bottomLeft: 0, bottomRight: 12
                            )
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 120, height: 28) // Gleiche Höhe wie die Texte
                            
                            Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 4)
                        }
                        .offset(x: -16, y: -16)
                        
                        Spacer()
                        
                        // 🔹 Wortanzahl in der Listenelement-Vorschau
                        Text("\(entry.content.split { $0.isWhitespace || $0.isNewline }.count) Worte")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                            .offset(y: -16)
                        
                        Text("\(entryViewModel.formattedDuration(entry.duration))")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                            .offset(y: -16)
                    }
                    // Entry content
                    Text(entry.content)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .lineLimit(4)
                        .truncationMode(.tail)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.9))
                        .frame(minHeight: 70, alignment: .top)
                }
                .padding()
                
                Spacer()
                
                VStack(spacing: 0) {
                    Spacer()
                    // Menu button on the right
                    Menu {
                        Button("Edit", action: onEdit)
                        Button("Favorite", action: onToggleFavorite)
                        Button("Delete", role: .destructive, action: onDelete)
                    } label: {
                        CustomCornerShape(
                            topLeft: 12, topRight: 0,
                            bottomLeft: 0, bottomRight: 12
                        )
                        .fill(colorManager.currentColor.color.opacity(0.2))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                        )
                    }
                }
            }
        }
        .frame(height: 120)
        .padding(.vertical, 8)
    }
}

// 📌 Eigene Shape für spezifische Ecken
struct CustomCornerShape: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                topLeft > 0 ? .topLeft : [],
                topRight > 0 ? .topRight : [],
                bottomLeft > 0 ? .bottomLeft : [],
                bottomRight > 0 ? .bottomRight : []
            ].reduce([]) { $0.union($1) },
            cornerRadii: CGSize(width: 12, height: 12)
        )
        return Path(path.cgPath)
    }
}
