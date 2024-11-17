import UIKit

private enum SplashConstants {
    static let segueIdentifier = "ShowAuthenticationScreen"
    static let oauth2Service = OAuth2Service.service
    static let oauth2TokenStorage = OAuth2TokenStorage()
}

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = SplashConstants.oauth2TokenStorage.token {
            print("Saved token: \(token)")
            fetchProfile(token: token)
        } else {
            print("No token found in UserDefaults")
            performSegue(withIdentifier: SplashConstants.segueIdentifier, sender: nil)
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
                    print("Profile image URL hs been fetched successfully: \(imageURL)")
                    self?.switchToTabBarController()
                case .failure(let error):
                    print("Error fetching profile image URL: \(error)")
                    self?.showErrorAndRetry(error)
                }
            }
        }
    }
    
    private func switchToTabBarController() {
        print("Switching to tab bar controller")
        guard let windowScene = view.window?.windowScene else {
            fatalError("Invalid Configuration: no window scene available")
        }
        
        guard let window = windowScene.windows.first else {
            fatalError("Invalid Configuration: no window found")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SplashConstants.segueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController else {
                fatalError("Failed to prepare for \(SplashConstants.segueIdentifier)")
            }
            if let viewController = navigationController.viewControllers.first as? AuthViewController {
                viewController.delegate = self
            }
        }
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
}
