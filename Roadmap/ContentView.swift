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
    @Environment(SessionViewModel.self) var sessionVM
    var body: some View {
        VStack {
            if let user = sessionVM.user {
                Text("User ID: \(user.appleUserId)")
                Text("Token: \(user.authorizationToken)")
            }
            SignInWithAppleButton(onRequest: authVM.configurationRequest, onCompletion: authVM.authResult)
                .frame(height: 50)
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)

            Text("Remove User")
                .onTapGesture {
                    sessionVM.logout()
                }
                .foregroundColor(.red)
                .padding()
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
