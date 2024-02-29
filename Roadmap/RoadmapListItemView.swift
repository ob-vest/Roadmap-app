//
//  SubjectItemView.swift
//  Roadmap
//
//  Created by Onur Bas on 27/02/2024.
//

import SwiftUI

struct RoadmapSubject: Identifiable {
    let id: UUID = UUID()
    let title: String
    let description: String
    let totalUpvotes: Int
    let tag: Tag
    let status: Status
    
    enum Status: String {
        case planned = "Planned"
        case inProgress = "In Progress"
        case completed = "Completed"
    }
    
    enum Tag: String, CaseIterable {
        case feature = "Feature"
        case bug = "Bug"
        case enhancement = "Enhancement"
    }
}
extension RoadmapSubject {
    static let mock = RoadmapSubject(title: "There should be an add button", description: "I have long thought of this interesting idea that doesnt exist", totalUpvotes: 10, tag: .enhancement, status: .planned)
    static let mockArray = [
        RoadmapSubject(title: "There should be an add button", description: "I have long thought of this interesting idea that doesnt exist yet, but i want is that i should be able to create a new template without relying on pre-existing templates", totalUpvotes: 10, tag: .enhancement, status: .planned),
        RoadmapSubject(title: "Implement dark mode feature", description: "Adding a dark mode option for better user experience in low light environments", totalUpvotes: 15, tag: .feature, status: .inProgress),
        RoadmapSubject(title: "Fix issue with image loading", description: "Images are not loading consistently on certain devices, need to investigate and resolve", totalUpvotes: 5, tag: .bug, status: .completed),    RoadmapSubject(title: "Improve search functionality", description: "Enhance search capabilities to include filters and sorting options", totalUpvotes: 8, tag: .feature, status: .planned),
        RoadmapSubject(title: "Optimize app performance", description: "Identify and address performance bottlenecks for smoother user experience", totalUpvotes: 12, tag: .enhancement, status: .inProgress),
        RoadmapSubject(title: "Update user interface design", description: "Redesign UI elements for a modern and intuitive look", totalUpvotes: 6, tag: .feature, status: .planned),
        RoadmapSubject(title: "Resolve security vulnerability", description: "Address security loophole to safeguard user data", totalUpvotes: 9, tag: .bug, status: .inProgress),
        RoadmapSubject(title: "Integrate third-party API", description: "Connect with external API for additional functionalities", totalUpvotes: 11, tag: .feature, status: .planned),
        RoadmapSubject(title: "Enhance error handling", description: "Improve error messages and handling for better user guidance", totalUpvotes: 7, tag: .enhancement, status: .inProgress),
        RoadmapSubject(title: "Implement offline mode", description: "Enable users to access app features without internet connectivity", totalUpvotes: 13, tag: .feature, status: .planned),
        RoadmapSubject(title: "Fix login authentication issue", description: "Investigate and fix login problems for seamless user access", totalUpvotes: 4, tag: .bug, status: .inProgress),
        RoadmapSubject(title: "Add data synchronization feature", description: "Sync user data across devices for consistent information access", totalUpvotes: 10, tag: .feature, status: .planned),
        RoadmapSubject(title: "Enhance onboarding process", description: "Optimize user onboarding steps for a smoother user experience", totalUpvotes: 5, tag: .enhancement, status: .inProgress)
    ]
    
}
struct RoadmapListItemView: View {
    let subject: RoadmapSubject
    var body: some View {
        
        HStack(spacing: 15) {
            
            VStack(spacing: 5) {
                Image(systemName: "chevron.up")
                
                Text("\(subject.totalUpvotes)")
            }
            .font(.title3)
            VStack(spacing: 10) {
                
                VStack(alignment: .leading) {
                    Text(subject.title)
                    Text(subject.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 60)
        .padding()
        .background(Color(.secondarySystemBackground) .cornerRadius(20))
    }
}

#Preview {
    ScrollView {
        RoadmapListItemView(subject: RoadmapSubject.mock)
        RoadmapListItemView(subject: RoadmapSubject.mock)
        RoadmapListItemView(subject: RoadmapSubject.mock)
    }
    .padding(.horizontal)
}
