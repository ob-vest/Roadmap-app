//
//  ContentView.swift
//  Roadmap
//
//  Created by Onur Bas on 27/02/2024.
//

import AuthenticationServices
import SwiftUI

@Observable
class authViewModel {
    var id = ""
    func configurationRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = []
    }

    func authResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            print("Authorization successful.")
            switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                print("User ID: \(appleIDCredential.user)")
//                print("Email: \(appleIDCredential.email ?? "Unknown")")
//                print("Full Name: \(appleIDCredential.fullName?.description ?? "Unknown")")
                dump("Real User Status: \(appleIDCredential.realUserStatus)")
                print("Authorization Code: \(appleIDCredential.authorizationCode?.base64EncodedString() ?? "Unknown")")
                print("JWT: \(String(data: appleIDCredential.identityToken!, encoding: .utf8) ?? "Unknown")")
                id = appleIDCredential.user
            default:
                break
            }
        case .failure(let error):
            print("Authorization failed: " + error.localizedDescription)
        }
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var authVM = authViewModel()

    var body: some View {
        VStack {
            if !authVM.id.isEmpty {
                Text("User ID: \(authVM.id)")
            }
            SignInWithAppleButton(onRequest: authVM.configurationRequest, onCompletion: authVM.authResult)
                .frame(height: 50)
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        }
        .padding()
        .onAppear {
//            getCredentialState(forUserID: authVM.id) { result, err in
//                <#code#>
//            }
        }
    }
}

#Preview {
    ContentView()
}
