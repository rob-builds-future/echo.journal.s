import SwiftUI

struct EntryRow: View {
    let entry: JournalEntry
    let colorScheme: ColorScheme
    let onEdit: () -> Void
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.15) : Color.white)
                .shadow(color: colorScheme == .dark ? .black.opacity(0.2) : .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            
            HStack(spacing: 12) {
                // Eintragsinhalt
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(entry.content)
                        .font(.body)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                
                Spacer()
                
                // Menü mit Optionen
                Menu {
                    Button("Bearbeiten", action: onEdit)
                    Button("Favorit", action: onToggleFavorite)
                    Button("Löschen", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Capsule().fill(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.3)))
                }
            }
            .padding(16) // Innenabstand der Kachel
        }
        .padding(.vertical, 8)
    }
}
