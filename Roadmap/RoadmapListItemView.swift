//
//  SubjectItemView.swift
//  Roadmap
//
//  Created by Onur Bas on 27/02/2024.
//

import SwiftUI

struct RequestModel: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let stateId: Int
    let typeId: Int

    let createdAt: Date
    let lastActivityAt: Date
    var upvoteCount: Int
    var commentCount: Int
}
extension RequestModel {

    var state: RequestState? {
        return RequestState(rawValue: stateId)
    }

    var type: RequestType? {
        return RequestType(rawValue: typeId)
    }
    var stateString: String {
        return state?.description ?? "Unknown"
    }

    var typeString: String {
        return type?.description ?? "Unknown"
    }
    enum RequestState: Int, Codable {
        case pending = 1
        case approved = 2
        case rejected = 3
        case planned = 4
        case inProgress = 5
        case completed = 6

        var description: String {
            switch self {
            case .pending: return "Pending"
            case .approved: return "Approved"
            case .rejected: return "Rejected"
            case .planned: return "Planned"
            case .inProgress: return "In Progress"
            case .completed: return "Completed"
            }
        }
    }

    enum RequestType: Int, Codable, CaseIterable {
        case feature = 1
        case improvement = 2
        case bug = 3

        var description: String {
            switch self {
            case .feature: return "Feature"
            case .improvement: return "Improvement"
            case .bug: return "Bug"

            }
        }

        var color: Color {
            switch self {
            case .feature: return .blue
            case .improvement: return .green
            case .bug: return .red
            }
        }
    }

}

struct RoadmapSubject: Identifiable {
    let id: UUID = UUID()
    let title: String
    let description: String
    var totalUpvotes: Int
    let tag: Tag
    let status: Status
    let createdAt: Date = Date()
    let lastActivityAt: Date = Date()
    var didUpvote: Bool = false {
        didSet {
            if didUpvote == true {
                totalUpvotes += 1
            } else {
                totalUpvotes -= 1
            }
        }
    }
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
        RoadmapSubject(title: "Fix issue with image loading", description: "Images are not loading consistently on certain devices, need to investigate and resolve", totalUpvotes: 5, tag: .bug, status: .completed), RoadmapSubject(title: "Improve search functionality", description: "Enhance search capabilities to include filters and sorting options", totalUpvotes: 8, tag: .feature, status: .planned),
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
    let request: RequestModel
    var body: some View {

        HStack(spacing: 15) {

            VStack(spacing: 5) {
                Image(systemName: "chevron.up")

                Text("\(request.upvoteCount)")
            }
            .font(.title3)
            //            .foregroundStyle(Color(subject.didUpvote ? .tintColor : .label))
            VStack(spacing: 10) {

                VStack(alignment: .leading) {
                    Text(request.title)
                    Text(request.description)
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

// #Preview {
//    ScrollView {
//        RoadmapListItemView(subject: RoadmapSubject.mock)
//        RoadmapListItemView(subject: RoadmapSubject.mock)
//        RoadmapListItemView(subject: RoadmapSubject.mock)
//    }
//    .padding(.horizontal)
// }
