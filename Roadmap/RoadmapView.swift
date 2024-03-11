//
//  RoadmapView.swift
//  Roadmap
//
//  Created by Onur Bas on 27/02/2024.
//

import SwiftUI

@Observable class RoadmapViewModel {
    var subjects: [RoadmapSubject] = RoadmapSubject.mockArray
    var requests: [RequestModel] = []
    var selectedSortCriteria: SortCriteria = .upvotes {
        didSet {
            sortSubjects(by: selectedSortCriteria)
        }
    }

    func upvote(subject: RoadmapSubject) {
        guard let index = subjects.firstIndex(where: { $0.id == subject.id }) else { return }

        subjects[index].didUpvote.toggle()

    }
    func fetchRequests() async {
        await SessionViewModel.shared.fetch(endpoint: "requests") { (result: Result<[RequestModel], Error>) in
            switch result {
            case .success(let requestData):
                print(requestData)
                self.requests = requestData
                self.sortSubjects(by: self.selectedSortCriteria)
            case .failure(let error):
                print(error)
            }
        }
    }
    func sortSubjects(by criteria: SortCriteria) {
        switch criteria {
        case .newest:
            requests.sort { $0.createdAt > $1.createdAt }
        case .upvotes:
            requests.sort { $0.upvoteCount > $1.upvoteCount }
        case .recentActivity:
            requests.sort { $0.lastActivityAt > $1.lastActivityAt }
        }

    }

    enum SortCriteria: String, CaseIterable {
        case newest = "Newest"
        case recentActivity = "Recent activity"
        case upvotes = "Most upvoted"
    }
}

struct RoadmapView: View {
    @State private var status: RoadmapSubject.Status = .planned
    @State private var tag: RoadmapSubject.Tag = .feature
    @State private var openNewRequest = false
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var roadmapVM = RoadmapViewModel()
    @State private var showLogin = false
    let compactColumns = [
        GridItem(.flexible())
    ]
    let regularColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        NavigationStack {

            ScrollView {
                sortMenu
                LazyVGrid(columns: sizeClass == .compact ? compactColumns : regularColumns, spacing: 15) {
                    ForEach(roadmapVM.requests) { request in
                        NavigationLink(destination: SelectedRoadmapItemView(request: request)) {
                            RoadmapListItemView(request: request)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    }
//                    ForEach(roadmapVM.subjects) { request in
//                        NavigationLink(destination: SelectedRoadmapItemView(subject: subject)) {
//                            RoadmapListItemView(subject: subject)
//                                .padding(.horizontal)
//                        }
//                        .buttonStyle(.plain)

//                    }

                }

            }
            .task {
                if roadmapVM.requests.isEmpty {
                    await roadmapVM.fetchRequests()
                }
            }
            .refreshable {
                print("Refreshed")
                await roadmapVM.fetchRequests()
            }
            .sheet(isPresented: $openNewRequest) {
                NewRequestView()
            }
            .navigationTitle("Roadmap")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        print("Login button tapped")
                        showLogin.toggle()
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                    .buttonStyle(.plain)
                }
                ToolbarItem(placement: .navigationBarTrailing) {

                    Button {
                        print("Add button tapped")
                        openNewRequest.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.pencil")

                            Text("Request")

                        }
                        .fontWeight(.semibold)
                        .padding(.horizontal, 2)

                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(Capsule())
                }

                //                ToolbarItem(placement: .navigationBarLeading) {
                //                    Picker("Sort by", selection: $roadmapVM.selectedSortCriteria) {
                //                        ForEach(RoadmapViewModel.SortCriteria.allCases, id: \.self) { criteria in
                //                            HStack(spacing: 5) {
                //                                Image(systemName: criteria.imageString())
                //                                Text(criteria.rawValue)
                //                            }
                ////                            Label(criteria.rawValue, systemImage: criteria.imageString())
                ////                            Text(criteria.rawValue)
                //                                .tag(criteria)
                //                        }
                //                    }
                //                    .pickerStyle(.menu)
                ////                    Menu {
                ////                        Text("Sort by")
                ////                        ForEach(RoadmapViewModel.SortCriteria.allCases, id: \.self) { criteria in
                ////                            Button {
                ////                                roadmapVM.sortSubjects(by: criteria)
                ////                            } label: {
                ////                                Label(criteria.rawValue, systemImage: criteria.imageString())
                ////                            }
                ////                        }
                ////                    } label: {
                ////                        Image(systemName: "arrow.up.arrow.down")
                ////
                ////                    }
                //                }
            }
        }
        .sheet(isPresented: $showLogin) {
            ContentView()
        }
        .environment(roadmapVM)
    }
}

extension RoadmapView {
    var sortMenu: some View {
        Picker("Sort by", selection: $roadmapVM.selectedSortCriteria) {
            ForEach(RoadmapViewModel.SortCriteria.allCases, id: \.self) { criteria in
                Text(criteria.rawValue)
                    .tag(criteria)

            }

        }
        .tint(.secondary)
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    RoadmapView()
}
