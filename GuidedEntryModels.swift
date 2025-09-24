import UIKit
import Foundation

// MARK: - Chat Message Model
struct GuidedJournalMessage {
    enum MessageType {
        case intro
        case moodSelection
        case aiMessage
        case userMessage
    }

    let type: MessageType
    let content: String
    let isUser: Bool
}

// MARK: - Custom Cells for Guided Entry
class IntroMessageCell: UITableViewCell {
    private let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        contentView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with message: String) {
        messageLabel.text = message
    }
}

class MoodSelectionCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let moodStackView = UIStackView()
    private var selectedMoodIndex = 1

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        contentView.addSubview(titleLabel)

        moodStackView.translatesAutoresizingMaskIntoConstraints = false
        moodStackView.axis = .horizontal
        moodStackView.distribution = .equalSpacing
        moodStackView.alignment = .center
        contentView.addSubview(moodStackView)

        let moods = ["😢", "😔", "😐", "😊", "😄"]

        for (index, mood) in moods.enumerated() {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(mood, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
            button.tag = index

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 44),
                button.heightAnchor.constraint(equalToConstant: 44)
            ])

            moodStackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            moodStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            moodStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            moodStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            moodStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with message: String) {
        titleLabel.text = message
    }
}

class AIMessageCell: UITableViewCell {
    private let avatarView = UIView()
    private let messageContainerView = UIView()
    private let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none

        // Avatar
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        avatarView.layer.cornerRadius = 16
        contentView.addSubview(avatarView)

        let avatarIcon = UIImageView()
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarIcon.image = UIImage(systemName: "sparkles")
        avatarIcon.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        avatarIcon.contentMode = .scaleAspectFit
        avatarView.addSubview(avatarIcon)

        // Message container
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        messageContainerView.layer.cornerRadius = 16
        messageContainerView.layer.cornerCurve = .continuous
        contentView.addSubview(messageContainerView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        messageLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        messageLabel.numberOfLines = 0
        messageContainerView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 32),
            avatarView.heightAnchor.constraint(equalToConstant: 32),

            avatarIcon.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarIcon.widthAnchor.constraint(equalToConstant: 16),
            avatarIcon.heightAnchor.constraint(equalToConstant: 16),

            messageContainerView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            messageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            messageContainerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -60),
            messageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with message: String) {
        messageLabel.text = message
    }
}

class UserMessageCell: UITableViewCell {
    private let messageContainerView = UIView()
    private let messageLabel = UILabel()
    private let avatarView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none

        // Message container
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        messageContainerView.layer.cornerRadius = 16
        messageContainerView.layer.cornerCurve = .continuous
        contentView.addSubview(messageContainerView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        messageLabel.textColor = UIColor.white
        messageLabel.numberOfLines = 0
        messageContainerView.addSubview(messageLabel)

        // Avatar
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        avatarView.layer.cornerRadius = 16
        contentView.addSubview(avatarView)

        let avatarIcon = UIImageView()
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarIcon.image = UIImage(systemName: "person.fill")
        avatarIcon.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        avatarIcon.contentMode = .scaleAspectFit
        avatarView.addSubview(avatarIcon)

        NSLayoutConstraint.activate([
            messageContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60),
            messageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            messageContainerView.trailingAnchor.constraint(equalTo: avatarView.leadingAnchor, constant: -12),
            messageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -12),

            avatarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 32),
            avatarView.heightAnchor.constraint(equalToConstant: 32),

            avatarIcon.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarIcon.widthAnchor.constraint(equalToConstant: 16),
            avatarIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func configure(with message: String) {
        messageLabel.text = message
    }
}