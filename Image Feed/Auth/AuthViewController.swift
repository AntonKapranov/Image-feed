import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode: String)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let auth2 = OAuth2Service.service
    private let tabBArID = "TabBarViewController"
    private let storage = OAuth2TokenStorage()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard !UIBlockingProgressHUD.isActive else { return }
            
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                fatalError("Failed to prepare for \(showWebViewSegueIdentifier)")
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("No available window to set root view controller")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: tabBArID)
        window.rootViewController = tabBarController
    }
    
    private func presentFailureAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
            print("didAuthenticateWithCode has been called")
            print("check if code is empty")
            guard !code.isEmpty else {
                print("Code is empty, \(code), calling an Failure Alert")
                presentFailureAlert()
//                vc.dismiss(animated: true)
                return
            }
            
//            vc.dismiss(animated: true)
                print("code is \(code), calling delegate")
            delegate?.authViewController(self, didAuthenticateWithCode: code)
        }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("Delegate has been called")
        dismiss(animated: true)
    }
}
