//
//  ChatMessageCell.swift
//  irisOne
//
//  Created by Test User on 7/26/25.
//

import Foundation
import UIKit

class ChatMessageCell: UITableViewCell {
    
    private let avatarImageView = UIImageView()
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timestampLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.image = UIImage(systemName: "heart.fill")
        avatarImageView.tintColor = .white
        avatarImageView.contentMode = .center
        contentView.addSubview(avatarImageView)
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.cornerCurve = .continuous
        contentView.addSubview(bubbleView)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        messageLabel.numberOfLines = 0
        bubbleView.addSubview(messageLabel)
        
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        timestampLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        contentView.addSubview(timestampLabel)
    }
    
    func configure(with message: ChatMessage, categoryColor: UIColor) {
        messageLabel.text = message.text
        timestampLabel.text = message.timestamp
        
        // Clean up previous constraints
        avatarImageView.removeFromSuperview()
        contentView.addSubview(avatarImageView)
        
        if message.isFromIris {
            // Iris message (left side)
            avatarImageView.isHidden = false
            avatarImageView.backgroundColor = categoryColor
            bubbleView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
            messageLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
            
            NSLayoutConstraint.activate([
                avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                avatarImageView.widthAnchor.constraint(equalToConstant: 32),
                avatarImageView.heightAnchor.constraint(equalToConstant: 32),
                
                bubbleView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -80),
                
                messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
                messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
                messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
                messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
                
                timestampLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                timestampLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 4),
                timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
            
        } else {
            // User message (right side)
            avatarImageView.isHidden = true
            bubbleView.backgroundColor = UIColor(red: 0.92, green: 0.88, blue: 0.75, alpha: 1.0)
            messageLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
            
            NSLayoutConstraint.activate([
                bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 80),
                
                messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
                messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
                messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
                messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
                
                timestampLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                timestampLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 4),
                timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
        }
    }
}
