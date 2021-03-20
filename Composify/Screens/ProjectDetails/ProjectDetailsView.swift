//
//  ProjectDetailsView.swift
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

struct ProjectDetailsView: View {
    @EnvironmentObject var songState: SongState
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = EditProjectViewModel()
    @State private var project: Project
    @State private var visibleSections: [Section] = []
    @State private var removedSections: [Section] = []
    @State private var editMode = EditMode.active

    var saveAction: ((Project?) -> Void)

    init(project: Project, saveAction: @escaping ((Project?) -> Void)) {
        self._project = .init(initialValue: project)
        self.saveAction = saveAction

        self._visibleSections = .init(initialValue: Array(project.sections))
    }

    var body: some View {
        NavigationView {
            List {
                SwiftUI.Section(header: Text("Title")) {
                    TextField("Project title", text: $project.title)
                }
                SwiftUI.Section(header: Text("Sections")) {
                    ForEach(visibleSections.indices, id: \.self) { index in
                        TextField("Section title", text: $visibleSections[index].title)
                    }
                    .onDelete(perform: deleteSections)
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
        visibleSections.forEach {
            viewModel.delete(section: $0)
        }
        visibleSections = []

        let projectCopy = project
        project = Project()
        viewModel.delete(project: projectCopy)

        presentationMode.wrappedValue.dismiss()
    }

    private func deleteSections(indices: IndexSet) {
        let sectionsToDelete = indices.map {
            visibleSections.remove(at: $0)
        }
        removedSections.append(contentsOf: sectionsToDelete)
    }

    private func leadingNavigationBarItemAction() {
        visibleSections
            .filter { !project.sections.contains($0) }
            .forEach { viewModel.save(section: $0, to: project) }

        visibleSections
            .filter { project.sections.contains($0) }
            .forEach { viewModel.update(section: $0) }

        removedSections.forEach {
            viewModel.delete(section: $0)
        }

        viewModel.update(project: project)

        songState.select(
            currentProject: project,
            currentSection: visibleSections.first
        )

        saveAction(project)
        presentationMode.wrappedValue.dismiss()
    }

    private func trailingNavigationBarItemAction() {
        let nextSectionIndex = visibleSections.count
        let nextSectionTitle = "Section \(nextSectionIndex + 1)"
        let nextSection = Section(title: nextSectionTitle, project: project, index: nextSectionIndex)
        visibleSections.append(nextSection)
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectDetailsView(project: Project()) { _ in }
    }
}
