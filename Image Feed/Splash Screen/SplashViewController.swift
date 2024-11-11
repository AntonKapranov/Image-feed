import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = SplashConstants.oauth2TokenStorage.token {
            print("Saved token: \(token)")
            switchToTabBarController()
        } else {
            print("No token found in UserDefaults")
            performSegue(withIdentifier: SplashConstants.segueIdentifier, sender: nil)
        }
    }
    
    // MARK: - Navigation
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    // MARK: - Segue Preparation
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

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            self?.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        SplashConstants.oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success(let accessToken):
                SplashConstants.oauth2TokenStorage.token = accessToken
                self?.switchToTabBarController()
            case .failure(let error):
                print("Error fetching OAuth token: \(error)")
            }
        }
    }
}

// MARK: - Constants
private enum SplashConstants {
    static let segueIdentifier = "ShowAuthenticationScreen"
    static let oauth2Service = OAuth2Service.service
    static let oauth2TokenStorage = OAuth2TokenStorage()
}
