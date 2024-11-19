import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode: String)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let auth2 = OAuth2Service.service
    private let tabBarID = "TabBarViewController"
    private let storage = OAuth2TokenStorage()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard !UIBlockingProgressHUD.isActive else { return }
            
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                assertionFailure("[AuthViewController]: Ошибка подготовки к переходу \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("[AuthViewController]: Не удалось найти окно для установки корневого контроллера")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: tabBarID)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func presentFailureAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("[AuthViewController]: Метод didAuthenticateWithCode вызван")
        
        guard !code.isEmpty else {
            print("[AuthViewController]: Код пустой, вызываю алерт .presentFailureAlert()")
            vc.dismiss(animated: true) { [weak self] in
                self?.presentFailureAlert()
            }
            return
        }
        
        print("[AuthViewController]: Код получен: \(code), вызываю делегат .authViewController(self!, didAuthenticateWithCode: code)")
        vc.dismiss(animated: true) { [weak self] in
            self?.delegate?.authViewController(self!, didAuthenticateWithCode: code)
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("[AuthViewController]: Пользователь отменил авторизацию")
        dismiss(animated: true)
    }
}
