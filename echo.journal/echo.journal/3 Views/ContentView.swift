//
//  ContentView.swift
//  echo.journal
//
//  Created by Robin Bettinghausen on 09.01.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world, i am a journal!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
