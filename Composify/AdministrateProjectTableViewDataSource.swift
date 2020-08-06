//
//  AdministrateProjectTableViewDataSource.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

class AdministrateProjectTableViewDataSource: NSObject, UITableViewDataSource {
    var administrateProjectViewController: AdministrateProjectViewController

    init(administrateProjectViewController: AdministrateProjectViewController) {
        self.administrateProjectViewController = administrateProjectViewController
    }

    var currentProject: Project? {
        administrateProjectViewController.project
    }

    func numberOfSections(in _: UITableView) -> Int {
        administrateProjectViewController.tableSections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = administrateProjectViewController.tableSections[section].values.count

        switch section {
        case 1, 2: return count + 1
        default: return count
        }
    }

    func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        fatalError("Subclass responsibility")
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        administrateProjectViewController.tableSections[section].header
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            administrateProjectViewController.insertNewSection {
                self.administrateProjectViewController
                    .administrateProjectDelegate?
                    .userDidAddSectionToProject($0)
            }

            guard let currentProject = currentProject else {
                return
            }

            updateDataBackend(currentProject)

            // It's important that we reload the previously last row after we
            // insert the new row so there's no problem with indexes.
            let newIndexPath = IndexPath(row: currentProject.sections.count, section: 1)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .delete:
            guard currentProject?.sections.hasElements ?? false else { return }
            guard let sectionToDelete = currentProject?.getSection(at: indexPath.row) else { return }

            if UserDefaults.standard.lastSection() == sectionToDelete {
                UserDefaults.standard.resetLastSection()
            }

            let confirmation = UIAlertController.createConfirmationAlert(
                title: R.Loc.deleteSectionConfirmationAlertTitle,
                message: R.Loc.deleteSectionConfirmationAlertMessage,
                completionHandler: { [weak self] _ in
                    self?.deleteSection(sectionToDelete, indexPath: indexPath)
                }
            )

            administrateProjectViewController.present(confirmation, animated: true)

        case .none:
            break
        @unknown default:
            break
        }
    }

    func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceRow = sourceIndexPath.row
        let destinationRow = destinationIndexPath.row
        guard let sourceSection = currentProject?.getSection(at: sourceRow) else { return }
        guard let destinationSection = currentProject?.getSection(at: destinationRow) else { return }

        RealmRepository().performOperation { _ in
            sourceSection.index = destinationRow
            destinationSection.index = sourceRow
        }

        administrateProjectViewController.tableSections[1].values[sourceRow] = sourceSection.title
        administrateProjectViewController.tableSections[1].values[destinationRow] = destinationSection.title

        administrateProjectViewController.administrateProjectDelegate?.userDidReorderSections()
    }

    func tableView(_: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Only the section that contains sections should contain movable cells
        // Also we don't want to be able to reorder the last row in that section,
        // because that's the green adding row. Also it doesn't make sense to show
        // the re-ordering controls if there is only a single section.
        let numberOfSections = currentProject?.sections.count ?? 0
        let projectSectionsSection = 1
        return indexPath.section == projectSectionsSection &&
            indexPath.row < numberOfSections &&
            numberOfSections > projectSectionsSection
    }
}

extension AdministrateProjectTableViewDataSource {
    func deleteProject() {
        let userDefaults = UserDefaults.standard
        if userDefaults.lastProject() == currentProject {
            userDefaults.resetLastProject()
            userDefaults.resetLastSection()
        }
        
        guard let currentProject = currentProject else {
            return
        }

        RealmRepository().delete(object: currentProject)
        administrateProjectViewController.administrateProjectDelegate?.userDidDeleteProject()
        administrateProjectViewController.dismiss(animated: true)
    }

    func configureCellTextField(textField: AdministrateProjectTextField, placeholder: String, delegate: UITextFieldDelegate?) {
        textField.placeholder = placeholder
        textField.delegate = delegate
    }

    func configureSectionsCell(indexPath: IndexPath, insertRowIndex: Int, cell: TextFieldTableViewCell) {
        if indexPath.row == insertRowIndex {
            cell.textField.isUserInteractionEnabled = false
            cell.textField.text = R.Loc.addSection
        } else {
            if let section = currentProject?.getSection(at: indexPath.row) {
                configureCellTextField(textField: cell.textField, placeholder: section.title, delegate: administrateProjectViewController)
            }
        }
    }
}

private extension AdministrateProjectTableViewDataSource {
    func updateDataBackend(_ currentProject: Project) {
        let existingValues = administrateProjectViewController.tableSections[1].values

        administrateProjectViewController.tableSections[1].values.removeAll()
        for (index, section) in currentProject.sections.enumerated() {
            // We're skipping the entries that have a title different
            // from the corresponding section title, because that means the
            // section was renamed. Without this check, if a section is renamed
            // and a section later added, the rename will be ignored.
            let existingTitle: String
            if index < existingValues.count {
                existingTitle = existingValues[index]
            } else {
                existingTitle = section.title
            }

            guard existingTitle == section.title else {
                continue
            }

            administrateProjectViewController.tableSections[1].values.append(section.title)
        }
    }

    func deleteSection(_ section: Section, indexPath: IndexPath) {
        administrateProjectViewController.deleteSection(section) { [weak self] in
            self?.administrateProjectViewController
                .administrateProjectDelegate?
                .userDidDeleteSectionFromProject()

            self?.administrateProjectViewController.tableSections[1].values.removeAll()
            self?.administrateProjectViewController.fillUnderlyingDataStorage()
            self?.administrateProjectViewController.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
