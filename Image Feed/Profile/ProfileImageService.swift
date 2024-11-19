import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let storage = OAuth2TokenStorage()
    
    private init() {}
    
    private(set) var avatarURL: String?
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")

    func fetchProfileImageURL(for username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = ProfileImageService.storage.token else {
            print("[ProfileImageService]: Ошибка — токен не найден")
            return
        }
        
        let url = URL(string: "https://api.unsplash.com/users/\(username)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: Ошибка — не удалось загрузить изображение профиля: \(error.localizedDescription)")
                completion(.failure(error))
            case .success(let userResult):
                if let avatarURL = userResult.profileImage?.large {
                    self.avatarURL = avatarURL
                    print("[ProfileImageService.fetchProfileImageURL]: Успех — URL аватара получен: \(avatarURL)")
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                    completion(.success(avatarURL))
                } else {
                    print("[ProfileImageService.fetchProfileImageURL]: Ошибка — отсутствует URL аватара в ответе")
                    completion(.failure(NSError(domain: "Invalid data", code: -1, userInfo: nil)))
                }
            }
        }
        task.resume()
    }
}

