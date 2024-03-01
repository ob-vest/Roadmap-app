//
//  SuccesfulPopupView.swift
//  Roadmap
//
//  Created by Onur Bas on 29/02/2024.
//

import SwiftUI

struct SuccesfulPopupView: View {
    @Binding var isPresented: Bool
    let content: SuccesfulType
    var body: some View {
        if isPresented {
            VStack(spacing: 20) {
                
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 70)
                    .foregroundStyle(Color(.tintColor))
                
                Text(content.title())
                    .font(.title3)
                    .fontWeight(.bold)
                
                
                Text(content.description())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(.secondaryLabel))
                
            }
            .frame(maxWidth: 400)
            .padding()
            .background(Color(.secondarySystemBackground).clipShape(RoundedRectangle(cornerRadius: 30)))
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color(.systemBackground)
                    .opacity(0.3)
            )
            
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isPresented = false
                    }
                }
            }
        }
    }
}

extension SuccesfulPopupView {
    enum SuccesfulType {
        case request
        case comment
        
        func title() -> String {
            switch self {
            case .request:
                return "Request submitted"
            case .comment:
                return "Comment submitted"
            }
        }
        
        func description() -> String {
            switch self {
            case .request:
                return "Your request has been submitted successfully. It will be reviewed and added to the roadmap if approved. Thank you for your contribution!"
            case .comment:
                return "Your comment has been submitted successfully. It will be reviewed and added to the roadmap if approved. Thank you for your contribution!"
            }
        }
    }
}

#Preview {
    SuccesfulPopupView(isPresented: .constant(true), content: .comment)
}
