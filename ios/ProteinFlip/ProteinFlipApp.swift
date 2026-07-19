import SwiftUI

@main
struct ProteinFlipApp: App {
    @StateObject private var store = ProteinStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .onAppear { store.handleRolloverIfNeeded() }
                .environmentObject(store)
        }
    }
}

