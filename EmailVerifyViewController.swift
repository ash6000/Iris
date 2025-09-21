//
//  PersonalizationViewController.swift
//  irisOne
//
//  Created by Test User on 9/20/25.
//

import UIKit

class EmailVerifyViewController: UIViewController {
    
    // MARK: - UI Components
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let containerView = UIView()
    
    // Header
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    
    // Email verification content
    private let emailIconView = UIView()
    private let emailImageView = UIImageView()
    private let mainTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let codeInfoLabel = UILabel()
    private let emailLabel = UILabel()
    
    // Verification code input
    private let codeInputLabel = UILabel()
    private let codeInputStackView = UIStackView()
    private var codeTextFields: [UITextField] = []
    
    // Action buttons
    private let verifyButton = UIButton()
    private let resendLabel = UILabel()
    private let resendButton = UIButton()
    private let resendTimerLabel = UILabel()
    private let changeEmailButton = UIButton()
    private let needHelpButton = UIButton()
    private let contactSupportButton = UIButton()
    
    // Timer for resend functionality
    private var resendTimer: Timer?
    private var resendCountdown = 45
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Background Image - full screen
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: "iris_rainbow_background")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        
        // Container View with blur effect
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.clear
        containerView.layer.cornerRadius = 20
        containerView.layer.cornerCurve = .continuous
        containerView.clipsToBounds = true
        
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 20
        blurView.clipsToBounds = true
        containerView.addSubview(blurView)
        
        // Semi-transparent white overlay on blur
        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        overlayView.layer.cornerRadius = 20
        overlayView.clipsToBounds = true
        containerView.addSubview(overlayView)
        
        // Content container on top of blur
        let contentContainer = UIView()
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.backgroundColor = UIColor.clear
        containerView.addSubview(contentContainer)
        
        // Shadow for container
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 20
        
        view.addSubview(containerView)
        
        // Setup content in the content container instead of containerView
        setupContentInContainer(contentContainer)
        
        // Blur view constraints
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: containerView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            contentContainer.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupContentInContainer(_ contentContainer: UIView) {
        
        // Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        backButton.contentMode = .scaleAspectFit
        contentContainer.addSubview(backButton)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Verify Email"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        contentContainer.addSubview(titleLabel)
        
        // Email Icon Container
        emailIconView.translatesAutoresizingMaskIntoConstraints = false
        emailIconView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        emailIconView.layer.cornerRadius = 30
        contentContainer.addSubview(emailIconView)
        
        // Email Icon
        emailImageView.translatesAutoresizingMaskIntoConstraints = false
        emailImageView.image = UIImage(systemName: "envelope.fill")
        emailImageView.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        emailImageView.contentMode = .scaleAspectFit
        emailIconView.addSubview(emailImageView)
        
        // Main Title
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        mainTitleLabel.text = "Check Your Email"
        mainTitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        mainTitleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        mainTitleLabel.textAlignment = .center
        contentContainer.addSubview(mainTitleLabel)
        
        // Description Label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "We've sent a 6-digit verification code to your email address. Enter the code below to activate your account."
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        contentContainer.addSubview(descriptionLabel)
        
        // Code Info Label
        codeInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        codeInfoLabel.text = "Code sent to:"
        codeInfoLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        codeInfoLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        codeInfoLabel.textAlignment = .center
        contentContainer.addSubview(codeInfoLabel)
        
        // Email Label
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.text = "sarah.johnson@email.com"
        emailLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        emailLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        emailLabel.textAlignment = .center
        contentContainer.addSubview(emailLabel)
        
        // Code Input Label
        codeInputLabel.translatesAutoresizingMaskIntoConstraints = false
        codeInputLabel.text = "Enter verification code"
        codeInputLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        codeInputLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        contentContainer.addSubview(codeInputLabel)
        
        // Code Input Stack View
        codeInputStackView.translatesAutoresizingMaskIntoConstraints = false
        codeInputStackView.axis = .horizontal
        codeInputStackView.distribution = .fillEqually
        codeInputStackView.spacing = 12
        contentContainer.addSubview(codeInputStackView)
        
        // Create 6 text fields for verification code
        for i in 0..<6 {
            let textField = UITextField()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
            textField.layer.cornerRadius = 8
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
            textField.textAlignment = .center
            textField.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            textField.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
            textField.keyboardType = .numberPad
            textField.tag = i
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            NSLayoutConstraint.activate([
                textField.heightAnchor.constraint(equalToConstant: 52),
                textField.widthAnchor.constraint(equalToConstant: 44)
            ])
            
            codeTextFields.append(textField)
            codeInputStackView.addArrangedSubview(textField)
        }
        
        // Verify Button
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        verifyButton.setTitle("Verify & Continue", for: .normal)
        verifyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        verifyButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 12
        contentContainer.addSubview(verifyButton)
        
        // Resend section
        resendLabel.translatesAutoresizingMaskIntoConstraints = false
        resendLabel.text = "Didn't receive the code?"
        resendLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        resendLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        resendLabel.textAlignment = .center
        contentContainer.addSubview(resendLabel)
        
        resendButton.translatesAutoresizingMaskIntoConstraints = false
        resendButton.setTitle("Resend code", for: .normal)
        resendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        resendButton.setTitleColor(UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0), for: .normal)
        resendButton.setTitleColor(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0), for: .disabled)
        contentContainer.addSubview(resendButton)
        
        resendTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        resendTimerLabel.text = "Resend available in 0:45"
        resendTimerLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        resendTimerLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        resendTimerLabel.textAlignment = .center
        contentContainer.addSubview(resendTimerLabel)
        
        // Change email button
        changeEmailButton.translatesAutoresizingMaskIntoConstraints = false
        changeEmailButton.setTitle("📧 Change email address", for: .normal)
        changeEmailButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        changeEmailButton.setTitleColor(UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0), for: .normal)
        contentContainer.addSubview(changeEmailButton)
        
        // Need help section
        needHelpButton.translatesAutoresizingMaskIntoConstraints = false
        needHelpButton.setTitle("Need help?", for: .normal)
        needHelpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        needHelpButton.setTitleColor(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0), for: .normal)
        contentContainer.addSubview(needHelpButton)
        
        contactSupportButton.translatesAutoresizingMaskIntoConstraints = false
        contactSupportButton.setTitle("Contact support", for: .normal)
        contactSupportButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        contactSupportButton.setTitleColor(UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0), for: .normal)
        contentContainer.addSubview(contactSupportButton)
        
        // Start resend timer
        startResendTimer()
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background Image
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Container View
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Back Button
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Email Icon Container
            emailIconView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            emailIconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emailIconView.widthAnchor.constraint(equalToConstant: 60),
            emailIconView.heightAnchor.constraint(equalToConstant: 60),
            
            // Email Icon
            emailImageView.centerXAnchor.constraint(equalTo: emailIconView.centerXAnchor),
            emailImageView.centerYAnchor.constraint(equalTo: emailIconView.centerYAnchor),
            emailImageView.widthAnchor.constraint(equalToConstant: 24),
            emailImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Main Title
            mainTitleLabel.topAnchor.constraint(equalTo: emailIconView.bottomAnchor, constant: 16),
            mainTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            mainTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Code Info
            codeInfoLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            codeInfoLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Email Label
            emailLabel.topAnchor.constraint(equalTo: codeInfoLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Code Input Label
            codeInputLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            codeInputLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            // Code Input Stack View
            codeInputStackView.topAnchor.constraint(equalTo: codeInputLabel.bottomAnchor, constant: 12),
            codeInputStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            codeInputStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Verify Button
            verifyButton.topAnchor.constraint(equalTo: codeInputStackView.bottomAnchor, constant: 20),
            verifyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            verifyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            verifyButton.heightAnchor.constraint(equalToConstant: 48),
            
            // Resend section
            resendLabel.topAnchor.constraint(equalTo: verifyButton.bottomAnchor, constant: 16),
            resendLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            resendButton.topAnchor.constraint(equalTo: resendLabel.bottomAnchor, constant: 4),
            resendButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            resendTimerLabel.topAnchor.constraint(equalTo: resendButton.bottomAnchor, constant: 4),
            resendTimerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Change email
            changeEmailButton.topAnchor.constraint(equalTo: resendTimerLabel.bottomAnchor, constant: 16),
            changeEmailButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Need help section
            needHelpButton.topAnchor.constraint(equalTo: changeEmailButton.bottomAnchor, constant: 16),
            needHelpButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            contactSupportButton.topAnchor.constraint(equalTo: needHelpButton.bottomAnchor, constant: 4),
            contactSupportButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            contactSupportButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
        changeEmailButton.addTarget(self, action: #selector(changeEmailButtonTapped), for: .touchUpInside)
        contactSupportButton.addTarget(self, action: #selector(contactSupportButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        // Navigate back to profile screen
        let profileVC = CreateProfileViewController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = profileVC
            }, completion: nil)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text.count <= 1 else {
            textField.text = String(textField.text?.prefix(1) ?? "")
            return
        }
        
        // Move to next field if text entered
        if text.count == 1 {
            let nextTag = textField.tag + 1
            if nextTag < codeTextFields.count {
                codeTextFields[nextTag].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
                checkVerificationCode()
            }
        }
    }
    
    @objc private func verifyButtonTapped() {
        let code = codeTextFields.compactMap { $0.text }.joined()
        
        if code.count == 6 {
            print("Verifying code: \(code)")
            // Simulate verification success
            navigateToMainApp()
        } else {
            showAlert(title: "Invalid Code", message: "Please enter the complete 6-digit verification code.")
        }
    }
    
    @objc private func resendButtonTapped() {
        print("Resending verification code...")
        resendCountdown = 45
        startResendTimer()
    }
    
    @objc private func changeEmailButtonTapped() {
        // Navigate back to profile screen to change email
        backButtonTapped()
    }
    
    @objc private func contactSupportButtonTapped() {
        print("Contacting support...")
        showAlert(title: "Contact Support", message: "Support feature coming soon!")
    }
    
    // MARK: - Helper Methods
    private func checkVerificationCode() {
        let code = codeTextFields.compactMap { $0.text }.joined()
        if code.count == 6 {
            verifyButtonTapped()
        }
    }
    
    private func startResendTimer() {
        resendButton.isEnabled = false
        resendTimer?.invalidate()
        
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.resendCountdown > 0 {
                let minutes = self.resendCountdown / 60
                let seconds = self.resendCountdown % 60
                self.resendTimerLabel.text = String(format: "Resend available in %d:%02d", minutes, seconds)
                self.resendCountdown -= 1
            } else {
                self.resendTimer?.invalidate()
                self.resendButton.isEnabled = true
                self.resendTimerLabel.text = ""
            }
        }
    }
    
    private func navigateToMainApp() {
        // Save verification completion
        UserDefaults.standard.set(true, forKey: "email_verified")
        UserDefaults.standard.set(Date(), forKey: "verification_date")
        UserDefaults.standard.synchronize()
        
        // Navigate to welcome screen
        let welcomeVC = WelcomeViewController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = welcomeVC
            }, completion: nil)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
