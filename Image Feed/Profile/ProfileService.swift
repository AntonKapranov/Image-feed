import UIKit
import ProgressHUD

final class ProfileService {
    static let shared = ProfileService()
    
    private var task: URLSessionTask?
    private var isLoading = false
    private(set) var profile: Profile?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        print("doing fetchProfile")
        assert(Thread.isMainThread)
        
        if let existingProfile = profile {
            completion(.success(existingProfile))
            return
        }
        
        task?.cancel()
        
        guard let request = makeRequest(with: token) else {
            print("[ProfileService.fetchProfile]: Invalid request")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        isLoading = true
        
        task = URLSession.shared.dataTask(with: request) { [weak self] result in
            defer { self?.isLoading = false }
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let profileResult = try decoder.decode(ProfileResults.self, from: data)
                    let profile = Profile(profile: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                } catch {
                    print("[ProfileService.fetchProfile]: Decoding error - \(error.localizedDescription)")
                    completion(.failure(NetworkError.decodingError))
                }
            case .failure(let error):
                print("[ProfileService.fetchProfile]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task?.resume()
    }

        
    func makeRequest(with token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("[ProfileService.makeRequest]: Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
