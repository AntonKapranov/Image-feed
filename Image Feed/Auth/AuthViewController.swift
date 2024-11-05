import UIKit

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .systemPink
        
    }
    @IBAction func didTappedBack(_ sender: Any) {
        dismiss(animated: true)
    }
}
