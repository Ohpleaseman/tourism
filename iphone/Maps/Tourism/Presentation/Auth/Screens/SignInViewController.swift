import UIKit
import Combine

class SignInViewController: UIViewController {
  
  
  private var cancellables = Set<AnyCancellable>()
  private var authRepository = AuthRepositoryImpl(authService: AuthServiceImpl())
  
  private let backButton: BackButton = {
    let backButton = BackButton()
    backButton.translatesAutoresizingMaskIntoConstraints = false
    return backButton
  }()
  
  private let backgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "splash_background")
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 16
    return view
  }()
  
  private let blurView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: .light)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    blurView.layer.cornerRadius = 16
    blurView.clipsToBounds = true
    return blurView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = L("sign_in_title")
    label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    label.textColor = .white
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let emailTextField: AuthTextField = {
    let textField = AuthTextField()
    textField.placeholder = L("tourism_email")
    textField.keyboardType = .emailAddress
    textField.autocapitalizationType = .none
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
  }()
  
  private let passwordTextField: PasswordTextField = {
    let textField = PasswordTextField()
    textField.placeholder = L("tourism_password")
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
  }()
  
  private let signInButton: AppButton = {
    let button = AppButton(label: L("sign_in"), isPrimary: true, target: self, action: #selector(signInTapped))
    return button
  }()
  
  private let forgotPasswordButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle(L("tourism_forgot_password"), for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  private let developedByLabel: UILabel = {
    let label = UILabel()
    label.text = L("developed_by_label")
    label.textColor = .white
    UIKitFont.applyStyle(to: label, style: UIKitFont.h4)
    applyWrapContent(label: label)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  private func setupViews() {
    let gradientView = UIView(frame: CGRect(x: 0, y: view.height - 100, width: view.width, height: 100))
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(developedByLabelTapped))

    gradientView.addGestureRecognizer(tapGesture)
    gradientView.isUserInteractionEnabled = true
    
    let gradient = CAGradientLayer()
    gradient.frame = gradientView.bounds
    gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
    gradientView.layer.insertSublayer(gradient, at: 0)
    
    
    view.addSubview(backgroundImageView)
    view.addSubview(backButton)
    view.addSubview(containerView)
    view.addSubview(gradientView)
    view.addSubview(developedByLabel)
    
    containerView.addSubview(blurView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(emailTextField)
    containerView.addSubview(passwordTextField)
    containerView.addSubview(signInButton)
    containerView.addSubview(forgotPasswordButton)
    
    NSLayoutConstraint.activate([
      // Background Image
      backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      // Back Button
      backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      
      // Container View
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
      
      // Blur View
      blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
      blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      // Title Label
      titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
      titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
      titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
      
      // Email Text Field
      emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
      emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
      emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
      
      // Password Text Field
      passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 40),
      passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
      passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
      
      // Sign In Button
      signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 48),
      signInButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
      signInButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
      
      // Forgot Password Button
      forgotPasswordButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20),
      forgotPasswordButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
      forgotPasswordButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32),
      
      developedByLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      developedByLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32)
    ])
    
    backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
  }
  
  // MARK: -  buttons listeners
  @objc private func signInTapped() {
    signInButton.isLoading = true
    authRepository.signIn(body: SignInRequest(email: emailTextField.text ?? "", password: passwordTextField.text ?? ""))
      .sink(receiveCompletion: { [weak self] completion in
        switch completion {
        case .finished:
          self?.navigateToMain()
        case .failure(let error):
          self?.showError(message: error.errorDescription)
        }
      }, receiveValue: { response in
        UserPreferences.shared.setToken(value: response.token)
      }
      )
      .store(in: &cancellables)
  }
  
  @objc private func forgotPasswordTapped() {
    self.navigationController?.pushViewController(ForgotPasswordViewController(), animated: false)
  }
  
  @objc private func backButtonTapped() {
    self.navigationController?.popViewController(animated: false)
  }
  
  @objc func developedByLabelTapped() {
    print("developedByLabelTapped")
    if let url = URL(string: "https://rebus.tj") {
        UIApplication.shared.open(url)
    }
  }
  
  // MARK: - other functions
  private func showError(message: String) {
    signInButton.isLoading = false
    showAlert(title: L("error"), message: message)
  }
  
  private func navigateToMain() {
    signInButton.isLoading = false
    self.dismiss(animated: true)
    UserPreferences.shared.setShouldGoToTourismMain(value: true)
  }
}
