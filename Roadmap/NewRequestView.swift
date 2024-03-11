//
//  NewRequestView.swift
//  Roadmap
//
//  Created by Onur Bas on 28/02/2024.
//

import SwiftUI

@Observable class NewRequestVM {
    struct NewRequest: Encodable {
        var title: String
        var description: String
        var typeId: Int
    }
    let tags: [RoadmapSubject.Tag] = RoadmapSubject.Tag.allCases

    var selectedTag: RoadmapSubject.Tag = .feature
    var title: String = ""
    var description: String = ""

    @MainActor func submitRequest(_ dismiss: DismissAction) async {

        print("Submitting the request...")
        print("Title: \(title)")
        print("--------------------")
        print("Description: \(description)")
        print("--------------------")
        print("Tag: \(selectedTag.rawValue)")
        let newRequest = NewRequest(title: title, description: description, typeId: 1)

        await SessionViewModel.shared.post(endpoint: "requests", body: newRequest) { (result: Result<Data, Error>) in
            switch result {
            case .success(let request):
                print("Posted succesfully: \(request)")
            case .failure(let error):
                print(error)
            }
        }

        dismiss()
    }
}

extension NewRequestVM {
    var isSubmitButtonDisabled: Bool {
        title.isEmpty || description.isEmpty
    }
}

struct NewRequestView: View {
    @State private var requestVM = NewRequestVM()
    @FocusState private var focusedField: FocusField?
    private enum FocusField: Hashable {
        case title, description
    }
    @Environment(\.dismiss) var dismiss

    var body: some View {

        NavigationStack {
            Form {
                Section(footer: Text("Please provide a clear and concise title and description for your request.")) {
                    // Title TextField
                    TextField("Title", text: $requestVM.title)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .description // Switch focus to the description field when the return key is pressed
                        }

                    TextEditor(text: $requestVM.description)
                        .frame(height: 200)
                        .foregroundStyle(.secondary)

                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .description)

                    Picker("Tag", selection: $requestVM.selectedTag) {
                        ForEach(requestVM.tags, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .onChange(of: requestVM.selectedTag) {
                        focusedField = nil
                    }

                }
            }
            .navigationTitle("New Request")
            .onAppear {
                focusedField = .title
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                    Button("Submit") {
                        Task { await requestVM.submitRequest(dismiss) }
                    }
                    .disabled(requestVM.isSubmitButtonDisabled)

                }
            }
        }
    }
}

#Preview {
    NewRequestView()
}
