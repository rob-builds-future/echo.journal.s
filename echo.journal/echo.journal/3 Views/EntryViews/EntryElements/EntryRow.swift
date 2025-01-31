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
                .shadow(color: colorManager.currentColor.color.opacity(0.2), radius: 6, x: 0, y: 3)
            
            // Bookmark placed in the background so it doesn't affect layout
            if entry.isFavorite {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 32)) // Size control without affecting layout
                    .foregroundColor(colorManager.currentColor.color)
                    .background(Color.clear)
                    .offset(x: 300, y: -8) // Position above the date
            }
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // 🔹 Wortanzahl in der Listenelement-Vorschau
                        Text("\(entry.content.split { $0.isWhitespace || $0.isNewline }.count) Wörter")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("⏱ \(calculateWritingDuration(from: entry.createdAt)) min")
                                .font(.caption)
                                .foregroundColor(.gray)
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
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorManager.currentColor.color.opacity(0.2))
                            .frame(width: 56, height: 56) // Fixed size for menu area
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

// 📌 Funktion zur Berechnung der Schreibdauer in Minuten
func calculateWritingDuration(from startDate: Date) -> Int {
    let durationInMinutes = Int(Date().timeIntervalSince(startDate) / 60)
    return max(durationInMinutes, 1) // Mindestens 1 Minute anzeigen
}
