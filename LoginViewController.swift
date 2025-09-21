//
//  LoginViewController.swift
//  irisOne
//
//  Created by Test User on 9/20/25.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let containerView = UIView()
    
    private let welcomeBackLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let passwordToggleButton = UIButton()
    
    private let signInButton = UIButton()
    private let signUpPromptLabel = UILabel()
    
    private var isPasswordVisible = false
    
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
        containerView.layer.cornerRadius = 32
        containerView.layer.cornerCurve = .continuous
        containerView.clipsToBounds = true
        
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 32
        blurView.clipsToBounds = true
        containerView.addSubview(blurView)
        
        // Semi-transparent white overlay on blur
        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        overlayView.layer.cornerRadius = 32
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
        
        // Welcome Back Label
        welcomeBackLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeBackLabel.text = "Welcome Back!"
        welcomeBackLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        welcomeBackLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        welcomeBackLabel.textAlignment = .center
        contentContainer.addSubview(welcomeBackLabel)
        
        // Subtitle Label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Sign in to your account"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        contentContainer.addSubview(subtitleLabel)
        
        // Email Text Field
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "Email"
        emailTextField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        emailTextField.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        emailTextField.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 0.6)
        emailTextField.layer.cornerRadius = 28
        emailTextField.layer.borderWidth = 0
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        emailTextField.leftViewMode = .always
        emailTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        emailTextField.rightViewMode = .always
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        contentContainer.addSubview(emailTextField)
        
        // Password Text Field
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Password"
        passwordTextField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        passwordTextField.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        passwordTextField.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 0.6)
        passwordTextField.layer.cornerRadius = 28
        passwordTextField.layer.borderWidth = 0
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        passwordTextField.leftViewMode = .always
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        contentContainer.addSubview(passwordTextField)
        
        // Password Toggle Button (Eye icon)
        passwordToggleButton.translatesAutoresizingMaskIntoConstraints = false
        passwordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        passwordToggleButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        passwordToggleButton.contentMode = .scaleAspectFit
        contentContainer.addSubview(passwordToggleButton)
        
        // Sign In Button
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        signInButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.layer.cornerRadius = 28
        signInButton.layer.shadowColor = UIColor.black.cgColor
        signInButton.layer.shadowOpacity = 0.1
        signInButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        signInButton.layer.shadowRadius = 8
        contentContainer.addSubview(signInButton)
        
        // Sign Up Prompt Label
        signUpPromptLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpPromptLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        signUpPromptLabel.textAlignment = .center
        
        let fullText = "Don't have an account? Sign up"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Set default color for "Don't have an account?"
        let defaultRange = NSRange(location: 0, length: 23) // "Don't have an account? "
        attributedString.addAttribute(.foregroundColor,
                                    value: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0),
                                    range: defaultRange)
        
        // Set pink color for "Sign up"
        let signUpRange = NSRange(location: 23, length: 7) // "Sign up"
        attributedString.addAttribute(.foregroundColor,
                                    value: UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0),
                                    range: signUpRange)
        attributedString.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: signUpRange)
        
        signUpPromptLabel.attributedText = attributedString
        contentContainer.addSubview(signUpPromptLabel)
        
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
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background Image - fill entire view
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
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            
            // Container View - vertically centered
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Welcome Back Label
            welcomeBackLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            welcomeBackLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            welcomeBackLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: welcomeBackLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Email Text Field
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Password Text Field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Password Toggle Button (Eye icon)
            passwordToggleButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            passwordToggleButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -20),
            passwordToggleButton.widthAnchor.constraint(equalToConstant: 24),
            passwordToggleButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Sign In Button
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            signInButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            signInButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            signInButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Sign Up Prompt Label
            signUpPromptLabel.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 24),
            signUpPromptLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            signUpPromptLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            signUpPromptLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32)
        ])
    }
    
    private func setupActions() {
        passwordToggleButton.addTarget(self, action: #selector(passwordToggleTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to sign up prompt
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(signUpPromptTapped))
        signUpPromptLabel.isUserInteractionEnabled = true
        signUpPromptLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func passwordToggleTapped() {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        
        let imageName = isPasswordVisible ? "eye" : "eye.slash"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func signInButtonTapped() {
        // Get email and password
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Basic validation
        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter both email and password.")
            return
        }
        
        guard isValidEmail(email) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        
        // Check if user exists (for now, check UserDefaults)
        let savedEmail = UserDefaults.standard.string(forKey: "user_email")
        let savedPassword = UserDefaults.standard.string(forKey: "user_password")
        
        guard email == savedEmail, password == savedPassword else {
            showAlert(title: "Invalid Credentials", message: "Email or password is incorrect.")
            return
        }
        
        print("Signing in with email: \(email)")
        
        // Navigate to main app
        let customTabBarController = CustomTabBarController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = customTabBarController
            }, completion: nil)
        }
    }
    
    @objc private func signUpPromptTapped() {
        // Navigate to sign up screen
        let signUpVC = IrisWelcomeViewController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = signUpVC
            }, completion: nil)
        }
    }
    
    // MARK: - Helper Methods
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