//
//  RoadmapView.swift
//  Roadmap
//
//  Created by Onur Bas on 27/02/2024.
//

import SwiftUI


struct RoadmapView: View {
    @State private var status: RoadmapSubject.Status = .planned
    @State private var tag: RoadmapSubject.Tag = .feature
    @State private var searchQuery = ""
    @State private var openNewRequest = false
    @Environment(\.horizontalSizeClass) var sizeClass
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
                LazyVGrid(columns: sizeClass == .compact ? compactColumns : regularColumns, spacing: 15) {
                    ForEach(RoadmapSubject.mockArray.filter {
                        searchQuery.isEmpty || $0.title.lowercased().contains(searchQuery.lowercased())
                    }) { subject in
                        NavigationLink(destination: SelectedRoadmapItemView(subject: subject)) {
                            RoadmapListItemView(subject: subject)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                        
                    }
                }
                .padding(.top)
            }
            
            .refreshable {
                print("Refreshed")
            }
            .sheet(isPresented: $openNewRequest) {
                NewRequestView()
            }
            .searchable(text: $searchQuery)
            .navigationTitle("Roadmap")
            .toolbar {
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
            }
        }
    }
}

#Preview {
    RoadmapView()
}
