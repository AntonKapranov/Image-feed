import UIKit

final class ProfileService {
    static let shared = ProfileService()
    
    private var task: URLSessionTask?
    private var isLoading = false
    private(set) var profile: Profile?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        print("Начинается загрузка профиля")
        
        DispatchQueue.main.async {
            if let existingProfile = self.profile {
                print("Профиль уже загружен, возвращаем кешированный профиль")
                completion(.success(existingProfile))
                return
            }
            
            self.task?.cancel()
            
            guard let request = self.makeRequest(with: token) else {
                print("[ProfileService.fetchProfile]: Ошибка создания запроса")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            self.isLoading = true
            
            self.task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResults, Error>) in
                guard let self = self else { return }
                
                defer { self.isLoading = false }
                
                switch result {
                case .failure(let error):
                    print("[ProfileService.fetchProfile]: Ошибка выполнения задачи - \(error.localizedDescription)")
                    completion(.failure(error))
                case .success(let profileResult):
                    let profile = Profile(profile: profileResult)
                    self.profile = profile
                    print("[ProfileService.fetchProfile]: Профиль успешно загружен - \(profile)")
                    completion(.success(profile))
                }
            }
            
            self.task?.resume()
        }
    }
    
    func makeRequest(with token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("[ProfileService.makeRequest]: Некорректный URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
