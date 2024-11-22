import UIKit

let photosName: [String] = Array(0..<20).map{ "mock-image\($0)" }

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Сигвей
//        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        
        cell.imageCell.layer.cornerRadius = 16
        cell.imageCell.image = image
        cell.labelCell.text = dateFormatter.string(from: Date())
//        cell.gradientCell.backgroundColor = .red
//        cell.gradientCell.layer.cornerRadius = 16

        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "Heart-active") : UIImage(named: "Heart-unactive")
        cell.buttonCell.setImage(likeImage, for: .normal)
    }
}

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }



