import UIKit

class IrisWelcomeViewController: UIViewController {
    
    // MARK: - UI Components
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let containerView = UIView()
    
    private let welcomeLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let disclaimerLabel = UILabel()
    
    private let termsStackView = UIStackView()
    private let termsCheckbox = UIButton()
    private let termsLabel = UILabel()
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let startButton = UIButton()
    
    private var isTermsAgreed = false
    
    // MARK: - Class Methods
    static func presentModally(from presentingViewController: UIViewController) {
        let welcomeVC = IrisWelcomeViewController()
        welcomeVC.modalPresentationStyle = .fullScreen
        presentingViewController.present(welcomeVC, animated: true)
    }
    
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
        
        // Welcome Label
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.text = "Welcome to Iris"
        welcomeLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        welcomeLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        welcomeLabel.textAlignment = .center
        contentContainer.addSubview(welcomeLabel)
        
        // Subtitle Label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Your space to heal, reflect, and grow."
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        contentContainer.addSubview(subtitleLabel)
        
        // Disclaimer Label
        disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
        disclaimerLabel.text = "Iris is not a substitute for professional\nmedical, legal, or financial advice."
        disclaimerLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        disclaimerLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        disclaimerLabel.textAlignment = .center
        disclaimerLabel.numberOfLines = 0
        contentContainer.addSubview(disclaimerLabel)
        
        // Terms Stack View
        termsStackView.translatesAutoresizingMaskIntoConstraints = false
        termsStackView.axis = .horizontal
        termsStackView.alignment = .top
        termsStackView.spacing = 12
        contentContainer.addSubview(termsStackView)
        
        // Terms Checkbox
        termsCheckbox.translatesAutoresizingMaskIntoConstraints = false
        termsCheckbox.layer.cornerRadius = 4
        termsCheckbox.layer.borderWidth = 2
        termsCheckbox.layer.borderColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0).cgColor
        termsCheckbox.backgroundColor = UIColor.clear
        
        // Create custom images for checkbox states
        let uncheckedImage = createCheckboxImage(checked: false)
        let checkedImage = createCheckboxImage(checked: true)
        
        termsCheckbox.setImage(uncheckedImage, for: .normal)
        termsCheckbox.setImage(checkedImage, for: .selected)
        termsStackView.addArrangedSubview(termsCheckbox)
        
        // Terms Label
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.numberOfLines = 0
        termsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        let fullText = "I agree to the Terms of Use & Disclaimer"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Set default color
        attributedString.addAttribute(.foregroundColor,
                                    value: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0),
                                    range: NSRange(location: 0, length: fullText.count))
        
        // Set pink color for "Terms of Use & Disclaimer"
        if let range = fullText.range(of: "Terms of Use & Disclaimer") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor,
                                        value: UIColor(red: 0.94, green: 0.6, blue: 0.8, alpha: 1.0),
                                        range: nsRange)
            attributedString.addAttribute(.underlineStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                        range: nsRange)
        }
        
        termsLabel.attributedText = attributedString
        termsStackView.addArrangedSubview(termsLabel)
        
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
        passwordTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        passwordTextField.rightViewMode = .always
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        contentContainer.addSubview(passwordTextField)
        
        // Start Button
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Sign Up", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        startButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 28
        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowOpacity = 0.1
        startButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        startButton.layer.shadowRadius = 8
        contentContainer.addSubview(startButton)
        
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
        
        updateStartButtonState()
    }
    
    private func createCheckboxImage(checked: Bool) -> UIImage? {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            if checked {
                // Fill with pink color
                UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0).setFill()
                let path = UIBezierPath(roundedRect: rect, cornerRadius: 4)
                path.fill()
                
                // Draw checkmark
                UIColor.white.setStroke()
                let checkmarkPath = UIBezierPath()
                checkmarkPath.lineWidth = 2
                checkmarkPath.lineCapStyle = .round
                checkmarkPath.lineJoinStyle = .round
                
                checkmarkPath.move(to: CGPoint(x: 5, y: 10))
                checkmarkPath.addLine(to: CGPoint(x: 8, y: 13))
                checkmarkPath.addLine(to: CGPoint(x: 15, y: 6))
                checkmarkPath.stroke()
            } else {
                // Draw border only
                UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0).setStroke()
                let path = UIBezierPath(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: 4)
                path.lineWidth = 2
                path.stroke()
            }
        }
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
            
            // Container View - vertically centered, just tall enough for content
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Welcome Label
            welcomeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            welcomeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            welcomeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Disclaimer Label
            disclaimerLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            disclaimerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            disclaimerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Terms Stack View
            termsStackView.topAnchor.constraint(equalTo: disclaimerLabel.bottomAnchor, constant: 32),
            termsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            termsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Terms Checkbox
            termsCheckbox.widthAnchor.constraint(equalToConstant: 20),
            termsCheckbox.heightAnchor.constraint(equalToConstant: 20),
            
            // Email Text Field
            emailTextField.topAnchor.constraint(equalTo: termsStackView.bottomAnchor, constant: 24),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Password Text Field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Start Button
            startButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            startButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            startButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            startButton.heightAnchor.constraint(equalToConstant: 56),
            startButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32)
        ])
    }
    
    private func setupActions() {
        termsCheckbox.addTarget(self, action: #selector(termsCheckboxTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(termsLabelTapped))
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func termsCheckboxTapped() {
        isTermsAgreed.toggle()
        termsCheckbox.isSelected = isTermsAgreed
        updateStartButtonState()
    }
    
    @objc private func termsLabelTapped() {
        // Handle terms of use tap
        print("Terms of Use tapped")
    }
    
    @objc private func startButtonTapped() {
        guard isTermsAgreed else { return }
        
        // Get email and password (optional for now)
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Save user credentials if provided
        if !email.isEmpty && !password.isEmpty {
            saveUserCredentials(email: email, password: password)
            print("Signing up with email: \(email)")
        } else {
            // Mark as guest user for now
            UserDefaults.standard.set(true, forKey: "user_signed_up")
            UserDefaults.standard.set(Date(), forKey: "signup_date")
            UserDefaults.standard.synchronize()
            print("Signing up as guest user")
        }
        
        // Navigate to Create Profile screen
        let createProfileVC = CreateProfileViewController()
        
        // Get the window scene and replace the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            // Animate the transition
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = createProfileVC
            }, completion: nil)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func saveUserCredentials(email: String, password: String) {
        // Save to UserDefaults (will replace with Firebase later)
        UserDefaults.standard.set(email, forKey: "user_email")
        UserDefaults.standard.set(password, forKey: "user_password") // Note: In production, never save plain text passwords
        UserDefaults.standard.set(true, forKey: "user_signed_up")
        UserDefaults.standard.set(Date(), forKey: "signup_date")
        UserDefaults.standard.synchronize()
        
        print("✅ User credentials saved:")
        print("- Email: \(email)")
        print("- Password: [Protected]")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateStartButtonState() {
        startButton.isEnabled = isTermsAgreed
        startButton.alpha = isTermsAgreed ? 1.0 : 0.6
    }
}
