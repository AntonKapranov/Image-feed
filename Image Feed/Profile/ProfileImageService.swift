import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let storage = OAuth2TokenStorage()
    
    private init() {}
    
    private(set) var avatarURL: String?
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")

    func fetchProfileImageURL(for username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = ProfileImageService.storage.token else { return }
        
        let url = URL(string: "https://api.unsplash.com/users/\(username)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let profileImageURLs = json["profile_image"] as? [String: String],
                let avatarURL = profileImageURLs["large"]
            else {
                completion(.failure(NSError(domain: "Invalid data", code: -1, userInfo: nil)))
                return
            }
            
            self.avatarURL = avatarURL
            NotificationCenter.default.post(
                name: ProfileImageService.didChangeNotification,
                object: self,
                userInfo: ["URL": avatarURL]
            )
            completion(.success(avatarURL))
        }
        task.resume()
    }
}
