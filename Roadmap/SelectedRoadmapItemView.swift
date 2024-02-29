//
//  SelectedRoadmapItemView.swift
//  Roadmap
//
//  Created by Onur Bas on 28/02/2024.
//

import SwiftUI
import Pow

fileprivate struct Comment: Identifiable {
    var id = UUID()
    var user: String
    var message: String
    var date: Date
}

extension Comment {
    static var mockArray: [Comment] = [
        Comment(user: "John Doe", message: "This is a great idea!", date: Date(timeIntervalSinceNow: -86400 * 2)), // 2 days ago
        Comment(user: "Jane Smith", message: "I agree! But have we considered the cost?", date: Date(timeIntervalSinceNow: -86400)), // 1 day ago
        Comment(user: "Alex Johnson", message: "Can someone clarify the last point?", date: Date()),
        Comment(user: "Casey Kim", message: "Absolutely brilliant! I'm all in.", date: Date(timeIntervalSinceNow: -3600 * 2)), // 2 hours ago
        Comment(user: "Jordan Lee", message: "I have some concerns about the timeline.", date: Date(timeIntervalSinceNow: -86400 * 5)), // 5 days ago
        Comment(user: "Chris Parker", message: "Looks good to me.", date: Date(timeIntervalSinceNow: -3600 * 48)), // 48 hours ago
        Comment(user: "Pat Taylor", message: "I'm unsure, can we discuss this in our next meeting?", date: Date(timeIntervalSinceNow: -86400 * 7)), // 1 week ago
        Comment(user: "Jamie Morgan", message: "Great initiative, let's make sure to allocate enough resources.", date: Date()),
        Comment(user: "Sam Rivera", message: "Has anyone looked into the potential risks?", date: Date(timeIntervalSinceNow: -86400 * 3)), // 3 days ago
        Comment(user: "Alexis Bailey", message: "I agree with Jane, the cost is a major factor to consider.", date: Date(timeIntervalSinceNow: -3600 * 5)), // 5 hours ago
        Comment(user: "Drew Jordan", message: "This could really set us apart from the competition!", date: Date(timeIntervalSinceNow: -86400 * 4)), // 4 days ago
        Comment(user: "Taylor Quinn", message: "I'll need more information before making a decision.", date: Date(timeIntervalSinceNow: -3600 * 72)), // 3 days in hours
        Comment(user: "Jordan Casey", message: "Can we ensure that this is sustainable in the long term?", date: Date()),
        Comment(user: "Morgan Pat", message: "Excited to see where this goes!", date: Date(timeIntervalSinceNow: -86400 * 6)), // 6 days ago
        Comment(user: "Rivera Sam", message: "Let's not rush into this without more research.", date: Date(timeIntervalSinceNow: -3600 * 24)), // 24 hours ago
        Comment(user: "Bailey Alexis", message: "I'm on board with the idea, pending budget review.", date: Date()),
        Comment(user: "Jordan Drew", message: "This initiative could really benefit from more diverse perspectives.", date: Date(timeIntervalSinceNow: -86400 * 1)), // 1 day ago
        Comment(user: "Quinn Taylor", message: "I'm excited, but let's plan carefully.", date: Date(timeIntervalSinceNow: -3600 * 12)), // 12 hours ago
    ]
}

@Observable class CommentVM {
    fileprivate var comments: [Comment] = []
    
    var message: String = ""
    
    func sendComment(completion: @escaping (Bool) -> Void) {
        guard isCommentValid() else { return completion(false) }
        comments.append(Comment(user: "You", message: message, date: Date()))
        message = ""
        completion(true)
    }
    func fetchComments() {
        comments = Comment.mockArray
    }
}

extension CommentVM {
    func isCommentValid() -> Bool {
        return message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}

struct SelectedRoadmapItemView: View {
    let subject: RoadmapSubject
    @State private var commentVM = CommentVM()
    @FocusState private var isFocused: Bool
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    
                    SubjectInfoView()
                        .padding(.top, 3)
                    DeveloperNoteView()
                        .padding(.vertical)
                    UpvoteButton(subject: subject)
                    
                    //            .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    //                RoundedRectangle(cornerRadius: 20)
                    //                    .fill(Color(.secondarySystemBackground))
                    //                    .frame(height: 3)
                    //                Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground).clipShape(RoundedRectangle(cornerRadius: 20)))
                
                ChatView()
                ContentUnavailableView {
                    Label("No comments yet", systemImage: "bubble.left.and.bubble.right")
                } description: {
                    Text("Be the first to comment")
                }
            }
            .padding(.horizontal)
            .padding(.top)
            //            .navigationTitle("\(subject.totalUpvotes) upvotes")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(subject.status.rawValue)
                        .foregroundStyle(.secondary)
                }
                //                ToolbarItem(placement: .bottomBar) {
                //                    Button { isFocused = true } label: {
                //                        HStack {
                //                            Text("Add a comment")
                //                            Image(systemName: "bubble.left.and.bubble.right")
                //                        }
                //                    }
                //                    .foregroundStyle(.primary)
                //                    .padding(.vertical, 5)
                //                    .frame(maxWidth: .infinity)
                //                    .background(Color(.tintColor), in: .capsule)
                //                }
                //                ToolbarItem(placement: .keyboard) {
                //                    HStack {
                //                        TextField("Type a message...", text: $messageText)
                //                            .textFieldStyle(.roundedBorder)
                //                            .focused($isFocused)
                ////                            .padding()
                //
                //                        // Send button
                //                        Button {} label: {
                //                            Image(systemName: "paperplane.fill")
                //                                .padding()
                //                        }
                //                    }
                //                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .overlay(
            HStack {
                TextField("Type a comment...", text: $commentVM.message)
                    .submitLabel(.return)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color(.tertiarySystemFill), lineWidth: 1)
                    )
                    .focused($isFocused)
                
                Button {commentVM.sendComment(completion: { isFocused = !$0 } )} label: {
                    Image(systemName: "paperplane.fill")
                    
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .foregroundStyle(Color(.white))
                        .background(Color(commentVM.isCommentValid() ? .tintColor : .secondarySystemBackground), in: .capsule)
                        .disabled(!commentVM.isCommentValid())
                        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                        .animation(.smooth, value: commentVM.isCommentValid())
                }
                
            }
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color(.systemBackground).ignoresSafeArea(.container, edges: .all))
                .frame(maxHeight: .infinity, alignment: .bottom)
            
        )
    }
}
extension SelectedRoadmapItemView {
    struct UpvoteButton: View {
        let subject: RoadmapSubject
        @State private var isUpvoted = false
        var body: some View {
            Button { isUpvoted.toggle() } label: {
                //            HStack {
                //                Image(systemName: "arrowshape.up.fill")
                //
                //                Text("Upvote")
                //            }
                //            .bold()
                //            .padding()
                //            .background(Color(.tintColor)
                //                .cornerRadius(20))
                HStack {
                    Image(systemName: "arrowshape.up.fill")
                        .changeEffect(.spray{
                            Image(systemName: "arrowshape.up.fill")
                        }, value: isUpvoted, isEnabled: isUpvoted)
                    Text("\(subject.totalUpvotes)")
                }
                .bold()
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundStyle(Color(isUpvoted ? .tintColor : .gray))
                .background(Color(isUpvoted ? .tintColor : .gray)
                    .cornerRadius(20)
                    .opacity(0.2)
                )
                
                
            }
        }
    }
    struct SubjectInfoView: View {
        let subject: RoadmapSubject = .mock
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                
                VStack(alignment: .leading) {
                    Text(subject.title)
                        .font(.title2)
                    
                    Text(subject.tag.rawValue)
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(.systemGreen).opacity(0.2)
                            .overlay( RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGreen), lineWidth: 1)))
                        .cornerRadius(10)
                }
                Text("Roadmap item is planned to be implemented in the next sprint. We are currently working on the design and architecture of the feature. We will keep you updated on the progress. Roadmap item is planned to be implemented in the next sprint. We are currently working on the design and architecture of the feature. We will keep you updated on the progress.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    struct DeveloperNoteView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "pin.fill")
                    Text("Developer note")
                }
                .fontWeight(.semibold)
                Text("Roadmap item is planned to be implemented in the next sprint. We are currently working on the design and architecture of the feature. We will keep you updated on the progress.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemFill))
            .cornerRadius(20)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
}




fileprivate struct ChatView: View {
    
    var comments: [Comment] = Comment.mockArray
    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 3)
                Text("Comments")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 3)
            }
            .padding(.vertical)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(comments) { comment in
                        ChatBubble(comment: comment)
                    }
                }
            }
        }
    }
}

fileprivate struct ChatBubble: View {
    var comment: Comment
    
    var body: some View {
        
        
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(comment.user)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(comment.date.formatRelativeTime())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            
            Text(comment.message)
            
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

#Preview {
    
    NavigationStack {
        SelectedRoadmapItemView(subject: RoadmapSubject.mock)
            .navigationBarTitleDisplayMode(.inline)
    }
}

//HStack {
//    HStack {
//        HStack {
//            Image(systemName: "arrowshape.up")
//                .font(.title3)
//            Text("Upvote")
//        }
//        .foregroundStyle(Color(.systemBlue))        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 25)
//                .stroke(Color(.systemBlue), lineWidth: 1)
//        )
//        Spacer()
//        HStack {
//            HStack(spacing: 0) {
//                Image(systemName: "arrowshape.up")
//                    .font(.title3)
//                Image(systemName: "arrowshape.up")
//                    .font(.title3)
//
//            }
//            Text("Super Upvote")
//        }
//
//        .foregroundStyle(Color(.systemYellow))        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 25)
//                .stroke(Color(.systemYellow), lineWidth: 1)
//
//
//        )
//    }
//
//    //                    HStack {
//    //                        Image(systemName: "bubble.fill")
//    //                            .font(.title3)
//    //                        Text("\(subject.totalUpvotes)")
//    //                            .font(.title3)
//    //                    }
//}
