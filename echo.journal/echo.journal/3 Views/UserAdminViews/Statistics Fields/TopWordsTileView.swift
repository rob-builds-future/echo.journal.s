import SwiftUI

struct TopWordsTileView: View {
    @ObservedObject var statisticsViewModel: StatisticsViewModel
    @ObservedObject var translationViewModel: TranslationViewModel
    @ObservedObject var colorManager: ColorManager
    @Environment(\.colorScheme) var colorScheme

    private let pageSize = 10

    /// Unterteilt die Top-Words in Seiten zu je 10 Elementen.
    private var pages: [[(word: String, count: Int)]] {
        let topWords = statisticsViewModel.topWords
        var result: [[(word: String, count: Int)]] = []
        var index = 0
        while index < topWords.count {
            let endIndex = min(index + pageSize, topWords.count)
            result.append(Array(topWords[index..<endIndex]))
            index += pageSize
        }
        return result
    }
    
    // Ausgelagerter Header als eigene Computed Property
    private var headerOverlay: some View {
        HStack {
            Text("Deine Top-Worte")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    CustomCornerShape(topLeft: 12, topRight: 0, bottomLeft: 0, bottomRight: 12)
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                )
            Spacer()
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.2),
                        radius: 4, x: 0, y: 0)
            
            VStack {
                Spacer().frame(height: 30)
                TopWordsPagesView(pages: pages,
                                  translationViewModel: translationViewModel,
                                  colorManager: colorManager,
                                  pageSize: pageSize)
                    .frame(height: 400)
            }
        }
        .overlay(headerOverlay, alignment: .top)
        .onAppear {
            // Setze die Page-Control-Farben abhängig vom aktuellen ColorScheme:
            let pageControl = UIPageControl.appearance()
            if colorScheme == .dark {
                pageControl.currentPageIndicatorTintColor = .white
                pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
            } else {
                pageControl.currentPageIndicatorTintColor = .black
                pageControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
            }
        }
    }
}

/// Ausgelagerte View für den TabView-Content
private struct TopWordsPagesView: View {
    let pages: [[(word: String, count: Int)]]
    let translationViewModel: TranslationViewModel
    let colorManager: ColorManager
    let pageSize: Int
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView {
            ForEach(0..<pages.count, id: \.self) { pageIndex in
                VStack(spacing: 8) {
                    ForEach(Array(pages[pageIndex].enumerated()), id: \.element.word) { index, wordItem in
                        TopWordRowView(
                            translationViewModel: translationViewModel,
                            colorManager: colorManager,
                            rank: pageIndex * pageSize + index + 1,
                            word: wordItem.word,
                            count: wordItem.count
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}
