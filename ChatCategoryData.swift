
//  ChatCategoryData.swift
 // irisOne

 // Created by Test User on 7/26/25.


import Foundation
import UIKit

// MARK: - Chat Category Data Model
struct ChatCategoryData {
    let title: String
    let subtitle: String
    let iconName: String
    let backgroundColor: UIColor
}

// MARK: - Chat Message Data Model
struct ChatMessage {
    let text: String
    let isFromIris: Bool
    let timestamp: String

    init(text: String, isFromIris: Bool) {
        self.text = text
        self.isFromIris = isFromIris

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.timestamp = formatter.string(from: Date())
    }
}

// MARK: - CategoryData Extension (Conversion Helper)
extension CategoryData {
    func toChatCategoryData() -> ChatCategoryData {
        return ChatCategoryData(
            title: self.title,
            subtitle: self.subtitle,
            iconName: self.iconName,
            backgroundColor: self.backgroundColor
        )
    }
}
