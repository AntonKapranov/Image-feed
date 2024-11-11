import UIKit

final class OAuth2Service {
    static let service = OAuth2Service()
    private let storage = OAuth2TokenStorage()
    private init() {}
    
    private(set) var authToken: String? {
        get { storage.token }
        set { storage.token = newValue }
    }
    
    private func performRequest(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(NetworkError.urlRequestError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    completion(.failure(NetworkError.httpStatusCode((response as? HTTPURLResponse)?.statusCode ?? -1)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                completion(.success(data))
            }
        }
        task.resume()
    }

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create request"])
            DispatchQueue.main.async {
                completion(.failure(NetworkError.urlRequestError(error)))
            }
            return
        }

        performRequest(request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        
                        let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        self.authToken = responseBody.accessToken
                        completion(.success(responseBody.accessToken))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
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
