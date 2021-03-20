//
//  ProjectDetailsView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct ProjectDetailsView: View {
    @EnvironmentObject var songState: SongState
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ProjectDetailsViewModel()
    @State private var project: Project?
    @State private var visibleSections: [Section] = []
    @State private var removedSections: [Section] = []
    @State private var sectionTitles: [String] = []
    @State private var editMode = EditMode.active
    @State private var projectTitle = ""

    var saveAction: () -> Void

    init(project: Project?, saveAction: @escaping (() -> Void)) {
        self._project = .init(initialValue: project)
        self.saveAction = saveAction

        self._visibleSections = .init(initialValue: Array(project?.sections ?? .init()))
        self._sectionTitles = .init(initialValue: project?.sections.map { $0.title } ?? .init())
    }

    var body: some View {
        NavigationView {
            List {
                SwiftUI.Section(header: Text("Title")) {
                    TextField("Project title", text: $projectTitle)
                }
                SwiftUI.Section(header: Text("Sections")) {
                    ForEach(Array(sectionTitles.indices), id: \.self) { index in
                        TextField("Section title", text: $sectionTitles[index])
                    }
                    .onDelete(perform: deleteSections)
                }
                SwiftUI.Section(header: Text("Danger Zone")) {
                    DeleteProjectButton(deleteAction: deleteProject)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Edit \(project?.title ?? "")")
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
        defer {
            presentationMode.wrappedValue.dismiss()
        }

        songState.select(currentProject: nil, currentSection: nil)

        guard let project = project else {
            return
        }

        viewModel.delete(project: project)
    }

    private func deleteSections(indices: IndexSet) {
        let sectionsToDelete = indices.map {
            visibleSections.remove(at: $0)
        }

        indices.forEach {
            sectionTitles.remove(at: $0)
        }

        removedSections.append(contentsOf: sectionsToDelete)
    }

    private func leadingNavigationBarItemAction() {
        defer {
            presentationMode.wrappedValue.dismiss()
        }

        guard let project = project else {
            return
        }

        songState.select(
            currentProject: project,
            currentSection: visibleSections.first
        )

        for (var section, newTitle) in zip(visibleSections, sectionTitles) {
            viewModel.update(section: &section, keyPath: \.title, value: newTitle)
        }

        let newSections = visibleSections.filter {
            !project.sections.contains($0)
        }

        newSections.forEach {
            viewModel.save(section: $0, to: project)
        }

        removedSections.forEach {
            viewModel.delete(section: $0)
        }

        viewModel.save(project: project)

        saveAction()
    }

    private func trailingNavigationBarItemAction() {
        let nextSectionIndex = visibleSections.count
        let nextSectionTitle = "Section \(nextSectionIndex + 1)"
        let nextSection = Section(title: nextSectionTitle, index: nextSectionIndex)
        visibleSections.append(nextSection)
        sectionTitles.append(nextSectionTitle)
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectDetailsView(project: Project()) {}
    }
}
