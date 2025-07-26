//
//  TypingIndicatorCell.swift
//  irisOne
//
//  Created by Test User on 7/26/25.
//

import Foundation
import UIKit

class TypingIndicatorCell: UITableViewCell {
    
    private let avatarImageView = UIImageView()
    private let bubbleView = UIView()
    private let dotsStackView = UIStackView()
    private var dotViews: [UIView] = []
    
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
        bubbleView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.cornerCurve = .continuous
        contentView.addSubview(bubbleView)
        
        dotsStackView.translatesAutoresizingMaskIntoConstraints = false
        dotsStackView.axis = .horizontal
        dotsStackView.spacing = 4
        dotsStackView.alignment = .center
        bubbleView.addSubview(dotsStackView)
        
        // Create 3 animated dots
        for _ in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            dot.layer.cornerRadius = 3
            dot.translatesAutoresizingMaskIntoConstraints = false
            dotsStackView.addArrangedSubview(dot)
            dotViews.append(dot)
            
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 6),
                dot.heightAnchor.constraint(equalToConstant: 6)
            ])
        }
        
        setupConstraints()
        startAnimating()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),
            
            bubbleView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.widthAnchor.constraint(equalToConstant: 60),
            
            dotsStackView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            dotsStackView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            dotsStackView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            dotsStackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with categoryColor: UIColor) {
        avatarImageView.backgroundColor = categoryColor
    }
    
    private func startAnimating() {
        for (index, dot) in dotViews.enumerated() {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.3
            animation.toValue = 1.0
            animation.duration = 0.6
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.2
            dot.layer.add(animation, forKey: "opacity")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dotViews.forEach { $0.layer.removeAllAnimations() }
        startAnimating()
    }
}
