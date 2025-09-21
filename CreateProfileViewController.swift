//
//  CreateProfileViewController.swift
//  irisOne
//
//  Created by Test User on 9/20/25.
//

import UIKit

class CreateProfileViewController: UIViewController {
    
    // MARK: - UI Components
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let containerView = UIView()
    
    // Header
    private let closeButton = UIButton()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    // Form Fields
    private let fullNameTextField = UITextField()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    
    // Password Requirements
    private let passwordMatchLabel = UILabel()
    private let passwordRequirementsLabel = UILabel()
    private let requirement1Label = UILabel()
    private let requirement2Label = UILabel()
    private let requirement3Label = UILabel()
    
    // Action Buttons
    private let continueButton = UIButton()
    private let termsLabel = UILabel()
    
    // State
    private var isPasswordVisible = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        updateContinueButtonState()
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
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
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
        
        contentView.addSubview(containerView)
        
        // Close Button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        closeButton.contentMode = .scaleAspectFit
        contentContainer.addSubview(closeButton)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Create Your Profile"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        contentContainer.addSubview(titleLabel)
        
        // Subtitle Label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Let's get started by setting up your account\nwith some basic information."
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        contentContainer.addSubview(subtitleLabel)
        
        // Full Name Text Field
        setupTextField(fullNameTextField, placeholder: "Enter your full name", label: "Full Name")
        fullNameTextField.autocapitalizationType = .words
        contentContainer.addSubview(fullNameTextField)
        
        // Email Text Field
        setupTextField(emailTextField, placeholder: "Enter your email address", label: "Email Address")
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        contentContainer.addSubview(emailTextField)
        
        // Password Text Field
        setupTextField(passwordTextField, placeholder: "Create a password", label: "Password")
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        contentContainer.addSubview(passwordTextField)
        
        // Confirm Password Text Field
        setupTextField(confirmPasswordTextField, placeholder: "Confirm your password", label: "Confirm Password")
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.autocapitalizationType = .none
        contentContainer.addSubview(confirmPasswordTextField)
        
        // Password Match Label
        passwordMatchLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordMatchLabel.text = "🔵 Password must match the one entered above"
        passwordMatchLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        passwordMatchLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        contentContainer.addSubview(passwordMatchLabel)
        
        // Password Requirements Label
        passwordRequirementsLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordRequirementsLabel.text = "Password Requirements:"
        passwordRequirementsLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        passwordRequirementsLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        contentContainer.addSubview(passwordRequirementsLabel)
        
        // Requirement 1
        requirement1Label.translatesAutoresizingMaskIntoConstraints = false
        requirement1Label.text = "✓ At least 8 characters long"
        requirement1Label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        requirement1Label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        contentContainer.addSubview(requirement1Label)
        
        // Requirement 2
        requirement2Label.translatesAutoresizingMaskIntoConstraints = false
        requirement2Label.text = "✓ Contains uppercase and lowercase letters"
        requirement2Label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        requirement2Label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        contentContainer.addSubview(requirement2Label)
        
        // Requirement 3
        requirement3Label.translatesAutoresizingMaskIntoConstraints = false
        requirement3Label.text = "✓ Contains at least one number"
        requirement3Label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        requirement3Label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        contentContainer.addSubview(requirement3Label)
        
        // Continue Button
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        continueButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 12
        continueButton.layer.shadowColor = UIColor.black.cgColor
        continueButton.layer.shadowOpacity = 0.1
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        continueButton.layer.shadowRadius = 8
        contentContainer.addSubview(continueButton)
        
        // Terms Label
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        termsLabel.textAlignment = .center
        termsLabel.numberOfLines = 0
        
        let fullText = "By continuing, you agree to our Terms of Service and Privacy Policy"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Set default color
        attributedString.addAttribute(.foregroundColor,
                                    value: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
                                    range: NSRange(location: 0, length: fullText.count))
        
        // Set pink color for "Terms of Service"
        if let termsRange = fullText.range(of: "Terms of Service") {
            let nsRange = NSRange(termsRange, in: fullText)
            attributedString.addAttribute(.foregroundColor,
                                        value: UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0),
                                        range: nsRange)
            attributedString.addAttribute(.underlineStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                        range: nsRange)
        }
        
        // Set pink color for "Privacy Policy"
        if let privacyRange = fullText.range(of: "Privacy Policy") {
            let nsRange = NSRange(privacyRange, in: fullText)
            attributedString.addAttribute(.foregroundColor,
                                        value: UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0),
                                        range: nsRange)
            attributedString.addAttribute(.underlineStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                        range: nsRange)
        }
        
        termsLabel.attributedText = attributedString
        contentContainer.addSubview(termsLabel)
        
        // Add field labels
        addFieldLabel("Full Name", above: fullNameTextField, in: contentContainer)
        addFieldLabel("Email Address", above: emailTextField, in: contentContainer)
        addFieldLabel("Password", above: passwordTextField, in: contentContainer)
        addFieldLabel("Confirm Password", above: confirmPasswordTextField, in: contentContainer)
        
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
    
    private func setupTextField(_ textField: UITextField, placeholder: String, label: String) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        textField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func addFieldLabel(_ text: String, above textField: UITextField, in container: UIView) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -8)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background Image
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            // Close Button
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Full Name Text Field
            fullNameTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            fullNameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            fullNameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            fullNameTextField.heightAnchor.constraint(equalToConstant: 48),
            
            // Email Text Field
            emailTextField.topAnchor.constraint(equalTo: fullNameTextField.bottomAnchor, constant: 32),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 48),
            
            // Password Text Field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 32),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            passwordTextField.heightAnchor.constraint(equalToConstant: 48),
            
            // Confirm Password Text Field
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 48),
            
            // Password Match Label
            passwordMatchLabel.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 8),
            passwordMatchLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            passwordMatchLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Password Requirements Label
            passwordRequirementsLabel.topAnchor.constraint(equalTo: passwordMatchLabel.bottomAnchor, constant: 16),
            passwordRequirementsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            // Requirement 1
            requirement1Label.topAnchor.constraint(equalTo: passwordRequirementsLabel.bottomAnchor, constant: 8),
            requirement1Label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            // Requirement 2
            requirement2Label.topAnchor.constraint(equalTo: requirement1Label.bottomAnchor, constant: 4),
            requirement2Label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            // Requirement 3
            requirement3Label.topAnchor.constraint(equalTo: requirement2Label.bottomAnchor, constant: 4),
            requirement3Label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            // Continue Button
            continueButton.topAnchor.constraint(equalTo: requirement3Label.bottomAnchor, constant: 32),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 48),
            
            // Terms Label
            termsLabel.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 16),
            termsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            termsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            termsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        // Navigate back to welcome screen
        let welcomeVC = IrisWelcomeViewController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = welcomeVC
            }, completion: nil)
        }
    }
    
    @objc private func textFieldDidChange() {
        updateContinueButtonState()
        updatePasswordRequirements()
    }
    
    @objc private func continueButtonTapped() {
        // Validate all fields
        guard validateAllFields() else { return }
        
        // Save profile data
        saveUserProfile()
        
        // Navigate to personalization screen
        let personalizationVC = EmailVerifyViewController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = personalizationVC
            }, completion: nil)
        }
    }
    
    // MARK: - Helper Methods
    private func validateAllFields() -> Bool {
        // For now, allow navigation without required fields
        return true
    }
    
    private func updateContinueButtonState() {
        // Always enable the continue button for now
        continueButton.isEnabled = true
        continueButton.alpha = 1.0
    }
    
    private func updatePasswordRequirements() {
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        
        // Update password match indicator
        if !confirmPassword.isEmpty {
            let matches = password == confirmPassword
            passwordMatchLabel.text = matches ? "✅ Password matches" : "❌ Password must match the one entered above"
            passwordMatchLabel.textColor = matches ? UIColor.systemGreen : UIColor.systemRed
        } else {
            passwordMatchLabel.text = "🔵 Password must match the one entered above"
            passwordMatchLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        }
        
        // Update requirement indicators
        let hasMinLength = password.count >= 8
        requirement1Label.text = hasMinLength ? "✅ At least 8 characters long" : "❌ At least 8 characters long"
        requirement1Label.textColor = hasMinLength ? UIColor.systemGreen : UIColor.systemRed
        
        let hasUpperAndLower = password.rangeOfCharacter(from: .uppercaseLetters) != nil && password.rangeOfCharacter(from: .lowercaseLetters) != nil
        requirement2Label.text = hasUpperAndLower ? "✅ Contains uppercase and lowercase letters" : "❌ Contains uppercase and lowercase letters"
        requirement2Label.textColor = hasUpperAndLower ? UIColor.systemGreen : UIColor.systemRed
        
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        requirement3Label.text = hasNumber ? "✅ Contains at least one number" : "❌ Contains at least one number"
        requirement3Label.textColor = hasNumber ? UIColor.systemGreen : UIColor.systemRed
    }
    
    private func saveUserProfile() {
        let fullName = fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        
        UserDefaults.standard.set(fullName, forKey: "user_full_name")
        UserDefaults.standard.set(email, forKey: "user_email")
        UserDefaults.standard.set(password, forKey: "user_password")
        UserDefaults.standard.set(true, forKey: "user_signed_up")
        UserDefaults.standard.set(true, forKey: "profile_completed")
        UserDefaults.standard.set(Date(), forKey: "signup_date")
        UserDefaults.standard.synchronize()
        
        print("✅ User profile saved:")
        print("- Full Name: \(fullName)")
        print("- Email: \(email)")
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
