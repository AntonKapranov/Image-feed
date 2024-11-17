import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let service = OAuth2Service()
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?

    private init() {}

    private(set) var authToken: String? {
        get { storage.token }
        set { storage.token = newValue }
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
       //правка из 10 спринта
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.fetchOAuthToken(code, completion: completion)
            }
            return
        }

        assert(Thread.isMainThread)

        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        if let currentTask = task {
            currentTask.cancel()
            completion(.failure(AuthServiceError.invalidRequest))
        }

        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
                
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let responseBody):
                    self?.authToken = responseBody.accessToken
                    completion(.success(responseBody.accessToken))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else { return nil }

        let auth2Keys: [String: Any] = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: auth2Keys, options: [])
            return request
        } catch {
            return nil
        }
    }
}
