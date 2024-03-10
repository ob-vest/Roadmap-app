//
//  AuthenticationViewModel.swift
//  Roadmap
//
//  Created by Onur Bas on 08/03/2024.
//

import SwiftUI
import AuthenticationServices

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case invalidUser

    var errorDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid Response"
        case .invalidData:
            return "Invalid Data"
        case .invalidUser:
            return "Invalid User"
        }
    }
}

@Observable
class SessionViewModel {
    struct User: Decodable {
        var appleUserId: String
        var authorizationToken: String
    }
    static let shared = SessionViewModel() // Singleton instance for global access
    var user: User? = KeychainStorage.loadUser() {
        didSet {
            if let user = user {
                if KeychainStorage.loadUser() == nil {
                    KeychainStorage.save(user.appleUserId, forKey: .appleUserId)
                    KeychainStorage.save(user.authorizationToken, forKey: .authorizationToken)
                }
            }
        }
    }
    let host = "https://roadmap-apiservice-production.up.railway.app/api/"

    func fetch<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) async {

        guard let url = URL(string: "\(host)\(endpoint)") else { return }
        do {
            var request = URLRequest(url: url)

            if let user = user {
                request.setValue("Bearer " + user.authorizationToken, forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await URLSession.shared.data(for: request)

            getAuthorizationHeader(response: response)

            dump(data)
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)

            let result = try decoder.decode(T.self, from: data)
            completion(.success(result))
        } catch {
            completion(.failure(error))
        }

    }

    func post<T: Encodable>(endpoint: String, body: T, completion: @escaping (Result<Data, Error>) -> Void) async {
        guard let url = URL(string: "\(host)\(endpoint)") else { return completion(.failure(NetworkError.invalidURL)) }
        guard let user = user else { return completion(.failure(NetworkError.invalidUser))}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + user.authorizationToken, forHTTPHeaderField: "Authorization")
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(body)
            request.httpBody = data
            let (responseData, response) = try await URLSession.shared.data(for: request)

            getAuthorizationHeader(response: response)

            completion(.success(responseData))
        } catch {
            completion(.failure(error))
        }
    }

}

extension SessionViewModel {
    func getAuthorizationHeader(response: URLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        // Check for a new authorization token in the response headers
        if let newToken = httpResponse.allHeaderFields["Authorization"] as? String {
            // Optional: You might want to do some formatting or validation on the newToken before using it

            // Update the user's authorization token with the new value
            self.user?.authorizationToken = newToken

            // Note: Depending on your token format, you might need to remove any prefix (e.g., "Bearer ")
        }
    }
}

@Observable
class AuthViewModel {
//    var user: User?
    let host = "https://roadmap-apiservice-production.up.railway.app"

    func configurationRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = []

    }

    func confirmLogin(authCode: String) async {
        guard let url = URL(string: host + "/api/auth/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyData = "code=\(authCode)".data(using: .utf8)
        request.httpBody = bodyData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            let result = try JSONDecoder().decode(SessionViewModel.User.self, from: data)
            print("Fetching user successful.")
            SessionViewModel.shared.user = result
            dump(SessionViewModel.shared.user)
//            user = result
//            dump(user)
        } catch {
            print("FAILED")
        }
    }

    func authResult(_ result: Result<ASAuthorization, Error>) {

        Task {
            switch result {
            case .success(let authResults):
                print("Authorization successful.")
                switch authResults.credential {
                case let appleIDCredential as ASAuthorizationAppleIDCredential:

                    print("User ID: \(appleIDCredential.user)")
                    //                print("Email: \(appleIDCredential.email ?? "Unknown")")
                    //                print("Full Name: \(appleIDCredential.fullName?.description ?? "Unknown")")
                    print("State: \(appleIDCredential.state ?? "Unknown")")
                    dump("Real User Status: \(appleIDCredential.realUserStatus)")

                    print("id_token: \(String(data: appleIDCredential.identityToken!, encoding: .utf8) ?? "Unknown")")

                    if let authorizationCode = appleIDCredential.authorizationCode {
                        let authCode = String(data: authorizationCode, encoding: .utf8)!
                        print("Authorization Code 2: \(authCode ?? "Unknown")")
                        await confirmLogin(authCode: authCode)
                    }

                default:
                    break
                }
            case .failure(let error):
                print("Authorization failed: " + error.localizedDescription)
            }
        }
    }
}

extension AuthViewModel {

    enum AuthError: Error {
        case appleLoginFailed
        case loginFailedVerification

        //            var localizedDescription: String {
        //                switch self {
        //                case .requestFailed:
        //                    return "Failed to get comments. Please try again later."
        //                case .invalidData:
        //                    return "Invalid comment data"
        //                }
        //            }
    }
}
