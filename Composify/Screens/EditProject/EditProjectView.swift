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

    func update(section: Section) {
        songRepository.update(section: section)
    }

    func delete(section: Section) {
        songRepository.delete(section: section)
    }

    func delete(project: Project) {
        songRepository.delete(project: project)
    }
}

struct EditProjectView: View {
    @EnvironmentObject var songState: SongState
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = EditProjectViewModel()
    @State private var project: Project
    @State private var addedSections: [Section] = []
    @State private var deletedSections: [Section] = []
    @State private var editMode = EditMode.active

    var saveAction: ((Project) -> Void)

    init(project: Project, saveAction: @escaping ((Project) -> Void)) {
        self._project = .init(initialValue: project)
        self.saveAction = saveAction

        self._addedSections = .init(initialValue: Array(project.sections))
    }

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
                    .onDelete(perform: deleteSection)
                }
                SwiftUI.Section(header: Text("Danger Zone")) {
                    DeleteProjectButton(deleteAction: deleteProject)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Edit \(project.title)")
            .navigationBarItems(
                leading: leadingNavigationBarItem,
                trailing: trailingNavigationBarItem
            )
            .environment(\.editMode, $editMode)
        }
    }

    private var leadingNavigationBarItem: some View {
        Button(
            action: leadingNavigationBarItemAction,
            label: { Text("Save") }
        )
    }

    private var trailingNavigationBarItem: some View {
        Button(
            action: trailingNavigationBarItemAction,
            label: { Image(systemName: "plus") }
        )
    }

    private func deleteProject() {
        songState.select(currentProject: nil, currentSection: nil)

        // Reset state variables, but preserve the original project
        // so we can safely delete it.
        addedSections.forEach {
            viewModel.delete(section: $0)
        }
        addedSections = []

        let projectCopy = project
        project = Project()
        viewModel.delete(project: projectCopy)

        presentationMode.wrappedValue.dismiss()
    }

    private func deleteSection(indices: IndexSet) {
        indices.forEach {
            deletedSections.append(
                addedSections.remove(at: $0)
            )
        }
    }

    private func leadingNavigationBarItemAction() {
        addedSections
            .filter { !project.sections.contains($0) }
            .forEach { viewModel.save(section: $0, to: project) }
        addedSections
            .filter { project.sections.contains($0) }
            .forEach { viewModel.update(section: $0) }
        deletedSections
            .forEach { viewModel.delete(section: $0) }
        viewModel.update(project: project)
        songState.select(
            currentProject: project,
            currentSection: addedSections.first
        )
        saveAction(project)
        project = Project()
        presentationMode.wrappedValue.dismiss()
    }

    private func trailingNavigationBarItemAction() {
        addedSections.append(
            Section(
                title: "Section \(addedSections.count + 1)",
                project: project
            )
        )
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project()) { _ in }
    }
}
