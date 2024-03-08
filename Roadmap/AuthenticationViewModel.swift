//
//  AuthenticationViewModel.swift
//  Roadmap
//
//  Created by Onur Bas on 08/03/2024.
//

import SwiftUI
import AuthenticationServices

@Observable
class AuthViewModel {
    var user: User?
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

            let result = try JSONDecoder().decode(User.self, from: data)

            user = result
            dump(user)
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
    struct User: Decodable {
        var appleUserId: String
        var authorizationToken: String
    }
    enum NetworkError: Error {
        case invalidURL

    }

    enum AuthError: Error {
        case appleLoginFailed
        case loginFailedVeritfication

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
