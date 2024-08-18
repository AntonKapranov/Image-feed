import UIKit

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    @IBOutlet private var tableView: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Failure")
                return
            }
            
            viewController.image = UIImage(named: photosName[indexPath.row])
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.rowHeight = 200
            tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }
    }

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}
