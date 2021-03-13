//
//  EditProjectView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

class EditProjectViewModel: ObservableObject, SongRepositoryInjectable {
    func update(project: Project) {
        songRepository.update(project: project)
    }
}

struct EditProjectView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = EditProjectViewModel()
    @Binding var project: Project

    var saveAction: ((Project) -> Void)

    var body: some View {
        NavigationView {
            List {
                SwiftUI.Section(header: Text("Title")) {
                    TextField("Project title", text: $project.title)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("New Project")
            .navigationBarItems(trailing: Button(action: {
                viewModel.update(project: project)
                saveAction(project)
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Save")
            }))
        }
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: .constant(Project())) { _ in }
    }
}
