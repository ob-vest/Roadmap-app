//
//  SelectedRoadmapItemView.swift
//  Roadmap
//
//  Created by Onur Bas on 28/02/2024.
//

import SwiftUI
import Pow

struct User: Identifiable {
    let id = UUID()
    let name: String
    let isDeveloper: Bool
}

private struct Comment: Identifiable {
    var id = UUID()
    var user: User
    var message: String
    var date: Date
}
extension Comment {
    static var mockArray: [Comment] = [
        Comment(user: User(name: "John Doe", isDeveloper: false), message: "This is a great idea!", date: Date(timeIntervalSinceNow: -86400 * 2)),
        Comment(user: User(name: "Jane Smith", isDeveloper: false), message: "I agree! But have we considered the cost?", date: Date(timeIntervalSinceNow: -86400)),
        Comment(user: User(name: "Onur Bas", isDeveloper: true), message: "Looks good to me", date: Date(timeIntervalSinceNow: -3600 * 12)),
        Comment(user: User(name: "Alex Johnson", isDeveloper: false), message: "Can someone clarify the last point?", date: Date()),
        Comment(user: User(name: "Casey Kim", isDeveloper: false), message: "Absolutely brilliant! I'm all in.", date: Date(timeIntervalSinceNow: -3600 * 2)),
        Comment(user: User(name: "Jordan Lee", isDeveloper: false), message: "I have some concerns about the timeline.", date: Date(timeIntervalSinceNow: -86400 * 5)),
        Comment(user: User(name: "Chris Parker", isDeveloper: false), message: "Looks good to me.", date: Date(timeIntervalSinceNow: -3600 * 48)),
        Comment(user: User(name: "Pat Taylor", isDeveloper: false), message: "I'm unsure, can we discuss this in our next meeting?", date: Date(timeIntervalSinceNow: -86400 * 7)),
        Comment(user: User(name: "Jamie Morgan", isDeveloper: false), message: "Great initiative, let's make sure to allocate enough resources.", date: Date()),
        Comment(user: User(name: "Sam Rivera", isDeveloper: false), message: "Has anyone looked into the potential risks?", date: Date(timeIntervalSinceNow: -86400 * 3)),
        Comment(user: User(name: "Alexis Bailey", isDeveloper: false), message: "I agree with Jane, the cost is a major factor to consider.", date: Date(timeIntervalSinceNow: -3600 * 5)),
        Comment(user: User(name: "Drew Jordan", isDeveloper: false), message: "This could really set us apart from the competition!", date: Date(timeIntervalSinceNow: -86400 * 4)),
        Comment(user: User(name: "Taylor Quinn", isDeveloper: false), message: "I'll need more information before making a decision.", date: Date(timeIntervalSinceNow: -3600 * 72)),
        Comment(user: User(name: "Jordan Casey", isDeveloper: false), message: "Can we ensure that this is sustainable in the long term?", date: Date()),
        Comment(user: User(name: "Morgan Pat", isDeveloper: false), message: "Excited to see where this goes!", date: Date(timeIntervalSinceNow: -86400 * 6)),
        Comment(user: User(name: "Rivera Sam", isDeveloper: false), message: "Let's not rush into this without more research.", date: Date(timeIntervalSinceNow: -3600 * 24)),
        Comment(user: User(name: "Bailey Alexis", isDeveloper: false), message: "I'm on board with the idea, pending budget review.", date: Date()),
        Comment(user: User(name: "Jordan Drew", isDeveloper: false), message: "This initiative could really benefit from more diverse perspectives.", date: Date(timeIntervalSinceNow: -86400 * 1)),
        Comment(user: User(name: "Quinn Taylor", isDeveloper: false), message: "I'm excited, but let's plan carefully.", date: Date(timeIntervalSinceNow: -3600 * 12))
    ]
}

@Observable class CommentViewModel {
    fileprivate var comments: [Comment] = []

    private(set) var commentError: NetworkError?

    var showError: Bool = false

    var message: String = ""
    func sendComment(completion: @escaping (Bool) -> Void) {
        guard isCommentValid() else { return completion(false) }
        comments.append(Comment(user: User(name: "You", isDeveloper: false), message: message, date: Date()))
        message = ""
        completion(true)
    }
    func fetchComments() {
        comments = Comment.mockArray
        //        showError(.invalidData)
    }
    func showError(_ error: NetworkError) {
        commentError = error
        showError = true
    }
}

extension CommentViewModel {
    func isCommentValid() -> Bool {
        return message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
    enum NetworkError: Error {
        case requestFailed
        case invalidData

        var localizedDescription: String {
            switch self {
            case .requestFailed:
                return "Failed to get comments. Please try again later."
            case .invalidData:
                return "Invalid comment data"
            }
        }
    }
}

struct SelectedRoadmapItemView: View {
    let request: RequestModel
    @FocusState private var isFocused: Bool
    @Environment(\.horizontalSizeClass) var sizeClass
    @State var commentVM = CommentViewModel()
    var body: some View {
        Group {
            switch sizeClass {

            case .compact: compactLayout
            default: regularLayout

            }
        }
        .navigationBarTitleDisplayMode(.inline)

        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(request.stateString)
                    .foregroundStyle(.secondary)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .task {
            commentVM.fetchComments()
        }
        .alert("Error", isPresented: $commentVM.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(commentVM.commentError?.localizedDescription ?? "")
        }

    }
}

extension SelectedRoadmapItemView {

    var compactLayout: some View {
        ScrollView {
            VStack {

                mainView
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
                    ChatView(commentVM: commentVM)
                }

            }
            .padding(.horizontal)
            .padding(.top, 5)

        }
        .overlay(
            keyboardOverlay
        )
    }

    var regularLayout: some View {
        HStack(alignment: .top) {
            mainView

            ChatView(commentVM: commentVM)
                .overlay(
                    keyboardOverlay
                )

        }
        .padding(.horizontal)
    }
}
extension SelectedRoadmapItemView {
    var mainView: some View {
        VStack(alignment: .leading) {

            SubjectInfoView(request: request)
                .padding(.top, 3)
            DeveloperNoteView()
                .padding(.vertical)
            UpvoteButton(request: request)

            //            .frame(maxWidth: .infinity, alignment: .trailing)

            //                RoundedRectangle(cornerRadius: 20)
            //                    .fill(Color(.secondarySystemBackground))
            //                    .frame(height: 3)
            //                Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground).clipShape(RoundedRectangle(cornerRadius: 20)))
    }

    var keyboardOverlay: some View {

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

            Button {commentVM.sendComment(completion: { isFocused = !$0 })} label: {
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

    }
}
extension SelectedRoadmapItemView {
    struct UpvoteButton: View {
        let request: RequestModel
        @Environment(RoadmapViewModel.self) var roadmapVM
        var body: some View {
            Button { /*roadmapVM.upvote(subject: subject)*/ } label: {
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
                    //                        .changeEffect(.spray {
                    //                            Image(systemName: "arrowshape.up.fill")
                    //                        }, value: request.didUpvote, isEnabled: !request.didUpvote)
                    //                        .changeEffect(.spray {
                    //                            Text("\(request.upvoteCount)")
                    //                        }, value: request.didUpvote, isEnabled: !request.didUpvote)

                    Text("\(request.upvoteCount)")
                }
                .bold()
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundStyle(Color(.gray))
                .background(Color(.gray)
                    .cornerRadius(20)
                    .opacity(0.2)
                )
                //                .foregroundStyle(Color(request.didUpvote ? .tintColor : .gray))
                //                .background(Color(request.didUpvote ? .tintColor : .gray)
                //                    .cornerRadius(20)
                //                    .opacity(0.2)
                //                )

            }
        }
    }
    struct SubjectInfoView: View {
        let request: RequestModel
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {

                VStack(alignment: .leading) {
                    Text(request.title)
                        .font(.title2)

                    Text(request.typeString)
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(.systemGreen).opacity(0.2)
                            .overlay( RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGreen), lineWidth: 1)))
                        .cornerRadius(10)
                }
                Text(request.description)
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

private struct ChatView: View {

    @Bindable var commentVM: CommentViewModel
    var body: some View {
        if commentVM.comments.isEmpty {
            ContentUnavailableView {
                Label("No comments yet", systemImage: "bubble.left.and.bubble.right")
            } description: {
                Text("Be the first to comment")
            }
            .padding(.bottom, 90) // bottom padding for keyboard overlay
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(commentVM.comments) { comment in
                        ChatBubble(comment: comment)
                    }
                }
                .padding(.bottom, 90) // bottom padding for keyboard overlay
            }
        }
    }
}

private struct ChatBubble: View {
    var comment: Comment

    var body: some View {

        VStack(alignment: .leading, spacing: 5) {
            HStack {
                HStack {
                    Text(comment.user.name)
                    if comment.user.isDeveloper {
                        Text("DEVELOPER")
                            .fontDesign(.monospaced)
                            .font(.system(size: 8))
                            .fontWeight(.bold)
                    }
                }
                .font(.caption2)
                .foregroundStyle( comment.user.isDeveloper ? .blue : .secondary)
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
        .background(
            Color(.secondarySystemBackground)
                .overlay(
                    Group {
                        if comment.user.isDeveloper {
                            RoundedRectangle(cornerRadius: 15)
                                .strokeBorder(Color(.tintColor), lineWidth: 2)
                        }
                    }
                )
        )
        .cornerRadius(15)
    }
}

// #Preview {
//
//    NavigationStack {
//        SelectedRoadmapItemView(subject: RoadmapSubject.mock)
//            .navigationBarTitleDisplayMode(.inline)
//    }
//    .environment(RoadmapViewModel())
// }
