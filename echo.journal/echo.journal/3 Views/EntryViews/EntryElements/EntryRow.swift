import SwiftUI

struct EntryRow: View {
    @ObservedObject var entryViewModel: EntryViewModel // ViewModel for the list
    @ObservedObject var colorManager: ColorManager
    
    @Environment(\.colorScheme) var colorScheme
    
    let entry: JournalEntry
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack (alignment: .topTrailing) {
            // Entry background – Dark Mode: schwarz, Light Mode: weiß
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.2),
                        radius: 4, x: 0, y: 0)
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    // Entry-Inhalt
                    Text(entry.content)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .lineLimit(5)
                        .truncationMode(.tail)
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.9))
                        .frame(minHeight: 70, alignment: .top)
                }
                .padding()
                
                Spacer()
                // Menü-Button auf der rechten Seite
                VStack(spacing: 0) {
                    Spacer()
                    Menu {
                        NavigationLink(value: entry) {
                            Label {
                                Text("showEntry")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            } icon: {
                                Image(systemName: "eye")
                            }
                        }
                        
                        Button(action: onToggleFavorite) {
                            Label {
                                Text(entry.isFavorite ? "unfavorite" : "favorite")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            } icon: {
                                Image(systemName: entry.isFavorite ? "bookmark.slash.fill" : "bookmark.fill")
                            }
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label {
                                Text("delete")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            } icon: {
                                Image(systemName: "trash")
                            }
                        }
                    } label: {
                        CustomCornerShape(topLeft: 12, topRight: 0, bottomLeft: 0, bottomRight: 12)
                            .fill(colorManager.currentColor.color.opacity(0.5))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            )
                    }
                }
            }
            .padding(.top, 20)
        }
        // Alle Elemente (Datum, Wortanzahl, Dauer) werden rechts positioniert
        .overlay(
            HStack {
                // Datumsbadge
                Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        CustomCornerShape(topLeft: 12, topRight: 0, bottomLeft: 0, bottomRight: 12)
                            .fill(colorScheme == .dark ? Color.white : Color.black)
                    )
                Spacer()
                
                // Bookmark, falls favorisiert
                if entry.isFavorite {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    Divider()
                        .frame(height: 14)
                }
                // HStack für Wortanzahl
                HStack(spacing: 4) {
                    Image(systemName: "quote.closing")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    Text("\(entry.content.split { $0.isWhitespace || $0.isNewline }.count)")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
                Divider()
                    .frame(height: 14)
                // HStack für Dauer
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    Text("\(entryViewModel.formattedDuration(entry.duration)) min")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
                .padding(.trailing)
            },
            alignment: .topTrailing
        )
        .alert("entryDeleteTitle", isPresented: $showDeleteAlert) {
            Button("cancel", role: .cancel) {}
            Button("delete", role: .destructive, action: onDelete)
        } message: {
            Text("entryDeleteMessage")
        }
        .padding(.vertical, 4)
    }
}
