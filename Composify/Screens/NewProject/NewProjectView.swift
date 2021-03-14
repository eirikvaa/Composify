//
//  NewProjectView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

class NewProjectViewModel: ObservableObject, SongRepositoryInjectable {
    func save(project: Project) {
        songRepository.save(project: project)
        songRepository.set(currentProject: project, currentSection: nil)
    }
}

struct NewProjectView: View {
    @EnvironmentObject var songState: SongState
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = NewProjectViewModel()
    @State private var project = Project()

    var tapAction: (() -> Void)

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
                viewModel.save(project: project)
                tapAction()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Save")
            }))
        }
    }
}

struct NewProjectView_Previews: PreviewProvider {
    static var previews: some View {
        NewProjectView {}
    }
}
