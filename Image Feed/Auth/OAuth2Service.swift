import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("bad baseURL")
            return nil
        }
        
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&client_secret=\(Constants.secretKey)"
            + "&redirect_uri=\(Constants.redirectURI)"
            + "&code=\(code)"
            + "&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("bad url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create request"])))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = responseBody.acessToken
                    completion(.success(responseBody.acessToken))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("Network error: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
