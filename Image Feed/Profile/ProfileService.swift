import UIKit

final class ProfileService {
    static let shared = ProfileService()
    
    private var task: URLSessionTask?
    private var isLoading = false
    private(set) var profile: Profile?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        if let existingProfile = profile {
            print("[ProfileService.fetchProfile]: Успех — возвращён кешированный профиль")
            completion(.success(existingProfile))
            return
        }
        
        guard !isLoading else {
            print("[ProfileService.fetchProfile]: Инфо — загрузка профиля уже выполняется")
            return
        }
        
        guard let request = createProfileRequest(with: token) else {
            print("[ProfileService.fetchProfile]: Ошибка — не удалось создать запрос")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        isLoading = true
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResults, Error>) in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            switch result {
            case .failure(let error):
                print("[ProfileService.fetchProfile]: Ошибка — \(error.localizedDescription)")
                completion(.failure(error))
            case .success(let profileResult):
                let profile = Profile(profile: profileResult)
                self.profile = profile
                print("[ProfileService.fetchProfile]: Успех — профиль загружен: \(profile)")
                completion(.success(profile))
            }
        }
        
        task?.resume()
    }
    
    private func createProfileRequest(with token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("[ProfileService.createProfileRequest]: Ошибка — некорректный URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("[ProfileService.createProfileRequest]: — запрос успешно создан")
        return request
    }
}
