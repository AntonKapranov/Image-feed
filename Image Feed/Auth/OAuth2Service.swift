import UIKit

enum AuthServiceError: Error {
    case invalidRequest
    case failedToCreateRequest
    case taskAlreadyExists
    case responseError(String)
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
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.fetchOAuthToken(code, completion: completion)
            }
            return
        }

        assert(Thread.isMainThread)
        
        // Проверяем, не был ли уже использован код
        guard lastCode != code else {
            print("[OAuth2Service]: Код уже использован: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        cancelCurrentTaskIfExists()

        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: Не удалось создать запрос с кодом \(code)")
            completion(.failure(AuthServiceError.failedToCreateRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
                
                switch result {
                case .failure(let error):
                    print("[OAuth2Service]: Ошибка при получении токена: \(error.localizedDescription)")
                    completion(.failure(error))
                case .success(let responseBody):
                    self?.authToken = responseBody.accessToken
                    print("[OAuth2Service]: Успешно получен токен: \(responseBody.accessToken)")
                    completion(.success(responseBody.accessToken))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("[OAuth2Service]: Некорректный URL для токена")
            return nil
        }

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
            print("[OAuth2Service]: Ошибка сериализации тела запроса: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func cancelCurrentTaskIfExists() {
        if let currentTask = task {
            print("[OAuth2Service]: Отменяем текущую задачу")
            currentTask.cancel()
            task = nil
        }
    }
}
