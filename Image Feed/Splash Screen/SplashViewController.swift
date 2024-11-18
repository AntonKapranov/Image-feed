import UIKit

private enum SplashConstants {
    static let oauth2Service = OAuth2Service.service
    static let oauth2TokenStorage = OAuth2TokenStorage()
}

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    
    private let splashImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "splash_screen_logo")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = SplashConstants.oauth2TokenStorage.token {
            print("Saved token: \(token)")
            fetchProfile(token: token)
        } else {
            print("No token found in UserDefaults")
            switchToAuthViewController()
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    print("Profile data loaded successfully:")
                    self?.fetchProfileImageURL(username: profile.username)
                    self?.switchToTabBarController()
                case .failure(let error):
                    self?.showErrorAndRetry(error)
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    }

    private func fetchProfileImageURL(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(for: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageURL):
                    print("Profile image URL has been fetched successfully: \(imageURL)")
//                    self?.switchToTabBarController()
                case .failure(let error):
                    print("Error fetching profile image URL: \(error)")
                    self?.showErrorAndRetry(error)
                }
            }
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    
    
    private func showErrorAndRetry(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load profile: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            if let token = SplashConstants.oauth2TokenStorage.token {
                self?.fetchProfile(token: token)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    private func switchToAuthViewController() {
        guard let authViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            fatalError("Invalid Configuration")
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            self?.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        print("Doing fetchOAuthToken")
        SplashConstants.oauth2Service.fetchOAuthToken(code) { [weak self] result in
            switch result {
            case .success(let accessToken):
                SplashConstants.oauth2TokenStorage.token = accessToken
                self?.fetchProfile(token: accessToken)
            case .failure(let error):
                print("Error fetching OAuth token: \(error)")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
}

// MARK: UI and Constraints
extension SplashViewController {
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(splashImageView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashImageView.heightAnchor.constraint(equalToConstant: 60),
            splashImageView.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}
