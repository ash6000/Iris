//
//  QuickStarterModels.swift
//  irisOne
//
//  Created by Claude Code
//

import Foundation

// MARK: - Quick Starters Response
struct QuickStartersResponse: Codable {
    let version: String
    let generatedAt: String
    let type: String
    let items: [QuickStarterItem]

    enum CodingKeys: String, CodingKey {
        case version
        case generatedAt = "generated_at"
        case type
        case items
    }
}

// MARK: - Quick Starter Item
struct QuickStarterItem: Codable {
    let id: String
    let title: String
    let subtitle: String
    let category: String
}

// MARK: - Quick Starter Manager
class QuickStarterManager {
    static let shared = QuickStarterManager()

    private var cachedStarters: [QuickStarterItem] = []

    private init() {}

    /// Load quick starters from JSON file
    func loadQuickStarters() -> [QuickStarterItem] {
        // Return cached starters if already loaded
        if !cachedStarters.isEmpty {
            return cachedStarters
        }

        guard let url = Bundle.main.url(forResource: "iris_quick_starters", withExtension: "json") else {
            print("❌ Error: Could not find iris_quick_starters.json in bundle")
            return defaultQuickStarters()
        }

        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(QuickStartersResponse.self, from: data)
            cachedStarters = response.items
            print("✅ Successfully loaded \(cachedStarters.count) quick starters from JSON")
            return cachedStarters
        } catch {
            print("❌ Error decoding quick starters JSON: \(error.localizedDescription)")
            return defaultQuickStarters()
        }
    }

    /// Get a random subset of quick starters
    func getRandomStarters(count: Int = 3) -> [QuickStarterItem] {
        let allStarters = loadQuickStarters()
        let shuffled = allStarters.shuffled()
        return Array(shuffled.prefix(count))
    }

    /// Get quick starters by category
    func getStartersByCategory(_ category: String) -> [QuickStarterItem] {
        return loadQuickStarters().filter { $0.category == category }
    }

    /// Default fallback quick starters if JSON fails to load
    private func defaultQuickStarters() -> [QuickStarterItem] {
        return [
            QuickStarterItem(
                id: "default-1",
                title: "I want to plan my career goals",
                subtitle: "Let's map out your professional journey",
                category: "quick_starter"
            ),
            QuickStarterItem(
                id: "default-2",
                title: "I'm facing a difficult decision",
                subtitle: "We can work through it together",
                category: "quick_starter"
            ),
            QuickStarterItem(
                id: "default-3",
                title: "I need help staying motivated",
                subtitle: "Let's find what drives you",
                category: "quick_starter"
            )
        ]
    }

    /// Clear cached starters (useful for testing or refreshing)
    func clearCache() {
        cachedStarters.removeAll()
    }
}
