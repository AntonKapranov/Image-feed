import UIKit
import WebKit

final class WebViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite_1
        webView.backgroundColor = .ypWhite_1
    }
    @IBAction func didTappedBackButton(_ sender: Any) {
        dismiss(animated: true)
    }
}
