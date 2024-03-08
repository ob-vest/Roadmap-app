//
//  ContentView.swift
//  Roadmap
//
//  Created by Onur Bas on 27/02/2024.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(AuthViewModel.self) var authVM

    var body: some View {
        VStack {
            if let user = authVM.user {
                Text("User ID: \(user.appleUserId)")
                Text("Token: \(user.authorizationToken)")
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
