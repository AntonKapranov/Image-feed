import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case decodingError
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder: JSONDecoder = {
            let result = JSONDecoder()
            result.keyDecodingStrategy = .convertFromSnakeCase
            return result
        }()
        
        let fulfillCompletionOnTheMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                if 200 ..< 300 ~= statusCode {
                    do {
                        let decodedObject = try decoder.decode(T.self, from: data)
                        fulfillCompletionOnTheMainThread(.success(decodedObject))
                    } catch {
                        print("[objectTask]: DecodingError - \(error.localizedDescription), данные: \(String(data: data, encoding: .utf8) ?? "N/A")")
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.decodingError))
                    }
                } else {
                    print("[objectTask]: HTTPError - статус код \(statusCode), URL: \(request.url?.absoluteString ?? "N/A")")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("[objectTask]: URLRequestError - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "N/A")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[objectTask]: URLSessionError - неизвестная ошибка, URL: \(request.url?.absoluteString ?? "N/A")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        }
        
        task.resume()
        return task
    }
}

