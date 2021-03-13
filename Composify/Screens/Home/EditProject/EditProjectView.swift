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

    func save(section: Section, to project: Project) {
        songRepository.save(section: section, to: project)
    }
}

struct EditProjectView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = EditProjectViewModel()
    @Binding var project: Project
    @State private var addedSections: [Section] = []
    @State private var editMode = EditMode.active

    var saveAction: ((Project) -> Void)

    var body: some View {
        NavigationView {
            List {
                SwiftUI.Section(header: Text("Title")) {
                    TextField("Project title", text: $project.title)
                }
                SwiftUI.Section(header: Text("Sections")) {
                    ForEach(addedSections.indices, id: \.self) { index in
                        TextField("Section title", text: $addedSections[index].title)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("New Project")
            .navigationBarItems(leading: Button(action: {
                addedSections.forEach {
                    viewModel.save(section: $0, to: project)
                }
                viewModel.update(project: project)
                saveAction(project)
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Save")
            }), trailing: Button(action: {
                addedSections.append(Section())
            }, label: {
                Image(systemName: "plus")
            }))
            .environment(\.editMode, $editMode)
        }
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: .constant(Project())) { _ in }
    }
}
