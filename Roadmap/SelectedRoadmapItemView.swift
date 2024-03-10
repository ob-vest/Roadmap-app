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
struct SendComment: Encodable {
    let requestId: Int
    let comment: String
}
struct RequestComment: Decodable, Identifiable {
    let id: Int
    let userId: Int
    let text: String
    let createdAt: Date
    let isDeveloper: Bool
}
// private struct RequestComment: Identifiable {
//    var id = UUID()
//    var user: User
//    var text: String
//    var createdAt: Date
// }
// extension RequestComment {
//    static var mockArray: [RequestComment] = [
//        RequestComment(user: User(name: "John Doe", isDeveloper: false), text: "This is a great idea!", createdAt: Date(timeIntervalSinceNow: -86400 * 2)),
//        RequestComment(user: User(name: "Jane Smith", isDeveloper: false), text: "I agree! But have we considered the cost?", createdAt: Date(timeIntervalSinceNow: -86400)),
//        RequestComment(user: User(name: "Onur Bas", isDeveloper: true), text: "Looks good to me", createdAt: Date(timeIntervalSinceNow: -3600 * 12)),
//        RequestComment(user: User(name: "Alex Johnson", isDeveloper: false), text: "Can someone clarify the last point?", createdAt: Date()),
//        RequestComment(user: User(name: "Casey Kim", isDeveloper: false), text: "Absolutely brilliant! I'm all in.", createdAt: Date(timeIntervalSinceNow: -3600 * 2)),
//        RequestComment(user: User(name: "Jordan Lee", isDeveloper: false), text: "I have some concerns about the timeline.", createdAt: Date(timeIntervalSinceNow: -86400 * 5)),
//        RequestComment(user: User(name: "Chris Parker", isDeveloper: false), text: "Looks good to me.", createdAt: Date(timeIntervalSinceNow: -3600 * 48)),
//        RequestComment(user: User(name: "Pat Taylor", isDeveloper: false), text: "I'm unsure, can we discuss this in our next meeting?", createdAt: Date(timeIntervalSinceNow: -86400 * 7)),
//        RequestComment(user: User(name: "Jamie Morgan", isDeveloper: false), text: "Great initiative, let's make sure to allocate enough resources.", createdAt: Date()),
//        RequestComment(user: User(name: "Sam Rivera", isDeveloper: false), text: "Has anyone looked into the potential risks?", createdAt: Date(timeIntervalSinceNow: -86400 * 3)),
//        RequestComment(user: User(name: "Alexis Bailey", isDeveloper: false), text: "I agree with Jane, the cost is a major factor to consider.", createdAt: Date(timeIntervalSinceNow: -3600 * 5)),
//        RequestComment(user: User(name: "Drew Jordan", isDeveloper: false), text: "This could really set us apart from the competition!", createdAt: Date(timeIntervalSinceNow: -86400 * 4)),
//        RequestComment(user: User(name: "Taylor Quinn", isDeveloper: false), text: "I'll need more information before making a decision.", createdAt: Date(timeIntervalSinceNow: -3600 * 72)),
//        RequestComment(user: User(name: "Jordan Casey", isDeveloper: false), text: "Can we ensure that this is sustainable in the long term?", createdAt: Date()),
//        RequestComment(user: User(name: "Morgan Pat", isDeveloper: false), text: "Excited to see where this goes!", createdAt: Date(timeIntervalSinceNow: -86400 * 6)),
//        RequestComment(user: User(name: "Rivera Sam", isDeveloper: false), text: "Let's not rush into this without more research.", createdAt: Date(timeIntervalSinceNow: -3600 * 24)),
//        RequestComment(user: User(name: "Bailey Alexis", isDeveloper: false), text: "I'm on board with the idea, pending budget review.", createdAt: Date()),
//        RequestComment(user: User(name: "Jordan Drew", isDeveloper: false), text: "This initiative could really benefit from more diverse perspectives.", createdAt: Date(timeIntervalSinceNow: -86400 * 1)),
//        RequestComment(user: User(name: "Quinn Taylor", isDeveloper: false), text: "I'm excited, but let's plan carefully.", createdAt: Date(timeIntervalSinceNow: -3600 * 12))
//    ]
// }

@Observable class CommentViewModel {
    fileprivate var comments: [RequestComment] = []

    private(set) var commentError: NetworkError?
    var isLoading: Bool = true
    let requestId: Int

    var showError: Bool = false

    var message: String = ""

    init(requestId: Int) {
        self.requestId = requestId
    }
    @MainActor func sendComment(completion: @escaping (Bool) -> Void) async {
        guard isCommentValid() else { return completion(false) }
        let body = SendComment(requestId: requestId, comment: message)
        await SessionViewModel.shared.post(endpoint: "requests/\(requestId)/comments", body: body) { (result: Result<Data, Error>) in
            switch result {
            case .success:
                Task { await self.fetchComments() } // Fetch comments after sending
            case .failure(let error):
                print(error)
                self.showError(.invalidData)
            }
        }
        //        comments.append(RequestComment(user: User(name: "You", isDeveloper: false), text: message, createdAt: Date()))
        message = ""
        completion(true)
    }
    @MainActor func fetchComments() async {

        //        comments = RequestComment.mockArray
        await SessionViewModel.shared.fetch(endpoint: "requests/\(requestId)/comments") { (result: Result<[RequestComment], Error>) in
            switch result {
            case .success(let comments):
                self.comments = comments
            case .failure(let error):
                print(error)
                self.showError(.invalidData)
            }
        }
        isLoading = false
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
    @State var commentVM: CommentViewModel

    init(request: RequestModel) {
        self.request = request
        self._commentVM = State(wrappedValue: CommentViewModel(requestId: request.id))
    }
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
            await commentVM.fetchComments()
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

            Button { Task { await commentVM.sendComment(completion: { isFocused = !$0 })} } label: {
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

        if commentVM.isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .padding(.bottom, 90) // bottom padding for keyboard overlay
        } else if commentVM.comments.isEmpty {
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
    var comment: RequestComment

    var body: some View {

        VStack(alignment: .leading, spacing: 5) {
            HStack {
                HStack {
                    Text("UserID: \(comment.userId)")
                    if comment.isDeveloper {
                        Text("DEVELOPER")
                            .fontDesign(.monospaced)
                            .font(.system(size: 8))
                            .fontWeight(.bold)
                    }
                }
                .font(.caption2)
                .foregroundStyle( comment.isDeveloper ? .blue : .secondary)
                Spacer()
                Text(comment.createdAt.formatRelativeTime())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Text(comment.text)

                .frame(maxWidth: .infinity, alignment: .leading)

        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(
            Color(.secondarySystemBackground)
                .overlay(
                    Group {
                        if comment.isDeveloper {
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
