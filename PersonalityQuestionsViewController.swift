//
//  PersonalityQuestionsViewController.swift
//  irisOne
//
//  Created by Test User on 9/20/25.
//

import UIKit

class PersonalityQuestionsViewController: UIViewController {
    
    // MARK: - UI Components
    private let modalView = UIView()
    private let headerView = UIView()
    private let backButton = UIButton()
    private let closeButton = UIButton()
    private let titleLabel = UILabel()
    private let stepLabel = UILabel()
    private let progressBackgroundView = UIView()
    private let progressFillView = UIView()
    
    // Content
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let questionNumberLabel = UILabel()
    private let questionLabel = UILabel()
    private let optionsStackView = UIStackView()
    private let nextButton = UIButton()
    
    // Data
    private var currentQuestionIndex = 0
    private var selectedOptionIndex: Int?
    private let totalQuestions = 2
    private var progressWidthConstraint: NSLayoutConstraint!
    private var userResponses: [Int] = []
    
    private let questions = [
        QuestionData(
            title: "Get to Know You",
            description: "Answer a few questions so I can personalize your experience. This helps me become your perfect AI companion.",
            question: "When facing a challenging decision, what sounds most like you?",
            options: [
                OptionData(
                    text: "I research extensively and create a detailed plan",
                    subtitle: "I need all the facts before I can move forward confidently"
                ),
                OptionData(
                    text: "I trust my gut and take decisive action",
                    subtitle: "I prefer to move quickly and adapt as I go"
                ),
                OptionData(
                    text: "I seek advice from others and consider different perspectives",
                    subtitle: "Collaboration and input from others is important to me"
                )
            ]
        ),
        QuestionData(
            title: "Personality Insights",
            description: "Based on your responses, we're building a comprehensive understanding of your unique traits and preferences.",
            question: "How do you typically handle stress or pressure?",
            options: [
                OptionData(
                    text: "I create structured plans and break things down systematically",
                    subtitle: "Organization and clear steps help me feel in control"
                ),
                OptionData(
                    text: "I focus on the immediate solution and adapt quickly",
                    subtitle: "I work best when I can respond flexibly to challenges"
                ),
                OptionData(
                    text: "I talk through challenges with trusted friends or mentors",
                    subtitle: "External perspectives help me process and find clarity"
                )
            ]
        )
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadQuestion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)

        // Modal View
        modalView.translatesAutoresizingMaskIntoConstraints = false
        modalView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        modalView.layer.cornerRadius = 0
        view.addSubview(modalView)
        
        // Header View
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        modalView.addSubview(headerView)
        
        // Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        headerView.addSubview(backButton)
        
        // Close Button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        headerView.addSubview(closeButton)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Persona Detection"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        // Step Label
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.text = "Step 1 of 2"
        stepLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        stepLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        stepLabel.textAlignment = .center
        headerView.addSubview(stepLabel)
        
        // Progress Background
        progressBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        progressBackgroundView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        progressBackgroundView.layer.cornerRadius = 2
        headerView.addSubview(progressBackgroundView)
        
        // Progress Fill
        progressFillView.translatesAutoresizingMaskIntoConstraints = false
        progressFillView.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        progressFillView.layer.cornerRadius = 2
        headerView.addSubview(progressFillView)
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        modalView.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Main Title
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        mainTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        mainTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        mainTitleLabel.textAlignment = .center
        contentView.addSubview(mainTitleLabel)
        
        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        
        // Question Number
        questionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        questionNumberLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        questionNumberLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        contentView.addSubview(questionNumberLabel)
        
        // Question
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        questionLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        questionLabel.numberOfLines = 0
        contentView.addSubview(questionLabel)
        
        // Options Stack View
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 12
        contentView.addSubview(optionsStackView)
        
        // Next Button
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next Question", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nextButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 12
        nextButton.alpha = 0.5
        nextButton.isEnabled = false
        modalView.addSubview(nextButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Modal View
            modalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalView.topAnchor.constraint(equalTo: view.topAnchor),
            modalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Header View
            headerView.topAnchor.constraint(equalTo: modalView.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: modalView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: modalView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Close Button
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            
            // Step Label
            stepLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            stepLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Progress Background
            progressBackgroundView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            progressBackgroundView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            progressBackgroundView.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 16),
            progressBackgroundView.heightAnchor.constraint(equalToConstant: 4),
            
            // Progress Fill
            progressFillView.leadingAnchor.constraint(equalTo: progressBackgroundView.leadingAnchor),
            progressFillView.topAnchor.constraint(equalTo: progressBackgroundView.topAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressBackgroundView.bottomAnchor),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: modalView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: modalView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -12),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Main Title
            mainTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            mainTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Question Number
            questionNumberLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            questionNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            // Question
            questionLabel.topAnchor.constraint(equalTo: questionNumberLabel.bottomAnchor, constant: 8),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Options Stack View
            optionsStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            optionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Next Button
            nextButton.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -24),
            nextButton.bottomAnchor.constraint(equalTo: modalView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        // Set up progress width constraint separately
        progressWidthConstraint = progressFillView.widthAnchor.constraint(equalTo: progressBackgroundView.widthAnchor, multiplier: 0)
        progressWidthConstraint.isActive = true
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func loadQuestion() {
        let question = questions[currentQuestionIndex]
        
        // Update header
        stepLabel.text = "Step \(currentQuestionIndex + 1) of \(totalQuestions)"
        
        // Update progress
        let progress = CGFloat(currentQuestionIndex + 1) / CGFloat(totalQuestions)
        progressWidthConstraint.isActive = false
        progressWidthConstraint = progressFillView.widthAnchor.constraint(equalTo: progressBackgroundView.widthAnchor, multiplier: progress)
        progressWidthConstraint.isActive = true

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        // Update content
        mainTitleLabel.text = question.title
        descriptionLabel.text = question.description
        questionNumberLabel.text = "Question \(currentQuestionIndex + 1) of \(totalQuestions)"
        questionLabel.text = question.question
        
        // Clear previous options
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new options
        for (index, option) in question.options.enumerated() {
            let optionView = createOptionView(option: option, index: index)
            optionsStackView.addArrangedSubview(optionView)
        }
        
        // Reset selection
        selectedOptionIndex = nil
        updateNextButton()
    }
    
    private func createOptionView(option: OptionData, index: Int) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        
        let radioButton = UIView()
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.backgroundColor = UIColor.white
        radioButton.layer.cornerRadius = 12
        radioButton.layer.borderWidth = 2
        radioButton.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        containerView.addSubview(radioButton)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = option.text
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = option.subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        subtitleLabel.numberOfLines = 0
        containerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            radioButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            radioButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            radioButton.widthAnchor.constraint(equalToConstant: 24),
            radioButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.tag = index
        
        return containerView
    }
    
    @objc private func optionTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }
        
        selectedOptionIndex = tappedView.tag
        
        // Update all option views
        for (index, optionView) in optionsStackView.arrangedSubviews.enumerated() {
            let isSelected = index == selectedOptionIndex
            
            optionView.layer.borderColor = isSelected ? UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0).cgColor : UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
            
            // Update radio button
            if let radioButton = optionView.subviews.first(where: { $0 is UIView && $0.layer.cornerRadius == 12 }) {
                radioButton.backgroundColor = isSelected ? UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0) : UIColor.white
                
                // Add checkmark for selected
                if isSelected {
                    let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
                    checkmark.translatesAutoresizingMaskIntoConstraints = false
                    checkmark.tintColor = .white
                    radioButton.addSubview(checkmark)
                    
                    NSLayoutConstraint.activate([
                        checkmark.centerXAnchor.constraint(equalTo: radioButton.centerXAnchor),
                        checkmark.centerYAnchor.constraint(equalTo: radioButton.centerYAnchor),
                        checkmark.widthAnchor.constraint(equalToConstant: 12),
                        checkmark.heightAnchor.constraint(equalToConstant: 12)
                    ])
                } else {
                    radioButton.subviews.forEach { $0.removeFromSuperview() }
                }
            }
        }
        
        updateNextButton()
    }
    
    private func updateNextButton() {
        let hasSelection = selectedOptionIndex != nil
        nextButton.alpha = hasSelection ? 1.0 : 0.5
        nextButton.isEnabled = hasSelection
        
        if currentQuestionIndex == totalQuestions - 1 {
            nextButton.setTitle("Complete Assessment", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            loadQuestion()
        } else {
            // Navigate back to welcome screen
            let welcomeVC = WelcomeViewController()

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {

                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = welcomeVC
                }, completion: nil)
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        // Navigate back to welcome screen
        let welcomeVC = WelcomeViewController()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {

            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = welcomeVC
            }, completion: nil)
        }
    }
    
    @objc private func nextButtonTapped() {
        guard let selectedIndex = selectedOptionIndex else { return }

        // Store the user's response
        userResponses.append(selectedIndex)

        if currentQuestionIndex < totalQuestions - 1 {
            currentQuestionIndex += 1
            loadQuestion()
        } else {
            // Complete assessment
            completeAssessment()
        }
    }
    
    private func completeAssessment() {
        // Save completion and responses
        UserDefaults.standard.set(true, forKey: "personality_assessment_completed")
        UserDefaults.standard.set(Date(), forKey: "assessment_completion_date")
        UserDefaults.standard.set(userResponses, forKey: "personality_responses")
        UserDefaults.standard.synchronize()

        // Generate personalized message based on responses
        let personalizedMessage = generatePersonalizedMessage()

        // Navigate back to welcome screen with personalized content
        let welcomeVC = WelcomeViewController()
        welcomeVC.setPersonalizedContent(personalizedMessage)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {

            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = welcomeVC
            }, completion: nil)
        }
    }

    private func generatePersonalizedMessage() -> String {
        guard userResponses.count == 2 else {
            return "You seem like a thoughtful person who values meaningful connections. I'm excited to get to know you better and provide guidance tailored to your unique journey."
        }

        let decisionStyle = userResponses[0]
        let stressStyle = userResponses[1]

        var personalityType = ""

        // Generate personality type based on responses
        switch (decisionStyle, stressStyle) {
        case (0, 0): // Research + Structured
            personalityType = "methodical planner"
        case (0, 1): // Research + Adaptive
            personalityType = "strategic adapter"
        case (0, 2): // Research + Social
            personalityType = "collaborative analyst"
        case (1, 0): // Gut + Structured
            personalityType = "intuitive organizer"
        case (1, 1): // Gut + Adaptive
            personalityType = "spontaneous leader"
        case (1, 2): // Gut + Social
            personalityType = "empathetic decision-maker"
        case (2, 0): // Advice + Structured
            personalityType = "systematic collaborator"
        case (2, 1): // Advice + Adaptive
            personalityType = "flexible team player"
        case (2, 2): // Advice + Social
            personalityType = "natural networker"
        default:
            personalityType = "thoughtful individual"
        }

        return "You seem like a \(personalityType) type of person who brings unique strengths to every situation. I'm excited to learn more about your goals and support you in meaningful ways."
    }
}

// MARK: - Data Models
struct QuestionData {
    let title: String
    let description: String
    let question: String
    let options: [OptionData]
}

struct OptionData {
    let text: String
    let subtitle: String
}