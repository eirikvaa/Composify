//
//  AdministrateProjectTableViewDataSource.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

class AdministrateProjectTableViewDataSource: NSObject {
    let administrateProjectViewController: AdministrateProjectViewController

    init(administrateProjectViewController: AdministrateProjectViewController) {
        self.administrateProjectViewController = administrateProjectViewController
    }
}

extension AdministrateProjectTableViewDataSource: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return administrateProjectViewController.rowCount.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return (administrateProjectViewController.currentProject?.sectionIDs.count ?? 0) + 1 }
        return administrateProjectViewController.rowCount[section] ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.Cells.administrateSectionCell, for: indexPath) as? TextFieldTableViewCell else { return UITableViewCell() }

        cell.textField.returnKeyType = .done
        cell.tag = 1234
        cell.textField.addTarget(administrateProjectViewController, action: #selector(administrateProjectViewController.textFieldChange), for: .editingChanged)
        cell.textField.text = nil
        cell.textField.placeholder = nil
        cell.isUserInteractionEnabled = true
        let insertRowIndex = administrateProjectViewController.currentProject?.sectionIDs.count ?? 0

        switch (indexPath.section, indexPath.row) {
        case (0, _):
            cell.textField.placeholder = administrateProjectViewController.currentProject?.title
            cell.textField.autocapitalizationType = .words
            cell.textField.clearButtonMode = .whileEditing
            cell.textField.returnKeyType = .done
        case (1, _):
            if indexPath.row == insertRowIndex {
                cell.textField.isUserInteractionEnabled = false
                cell.textField.text = R.Loc.addSection
            } else {
                if let section = administrateProjectViewController.currentProject?.getSection(at: indexPath.row) {
                    cell.textField.placeholder = section.title
                    cell.textField.autocapitalizationType = .words
                    cell.textField.clearButtonMode = .whileEditing
                    cell.textField.returnKeyType = .done
                }
            }
        case (2, _):
            guard let deleteCell = tableView.dequeueReusableCell(withIdentifier: R.Cells.administrateDeleteCell, for: indexPath) as? ButtonTableViewCell else { return UITableViewCell() }
            deleteCell.buttonTitle = R.Loc.deleteProejct
            deleteCell.action = {
                guard let currentProject = self.administrateProjectViewController.currentProject else { return }

                let standard = UserDefaults.standard
                if standard.lastProject() == currentProject {
                    standard.resetLastProject()
                    standard.resetLastSection()
                }

                do {
                    try FileManager.default.delete(currentProject)
                } catch {
                    self.administrateProjectViewController.handleError(error)
                }

                self.administrateProjectViewController.databaseService.delete(currentProject)
                self.administrateProjectViewController.administrateProjectDelegate?.userDidDeleteProject()

                self.administrateProjectViewController.dismiss(animated: true)
            }
            return deleteCell
        default:
            break
        }

        return cell
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return administrateProjectViewController.headers[section]
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            guard let currentProject = administrateProjectViewController.currentProject else { return }

            administrateProjectViewController.insertNewSection {
                self.administrateProjectViewController.administrateProjectDelegate?.userDidAddSectionToProject($0)
            }

            administrateProjectViewController.newValues.removeAll()
            for (index, sectionID) in currentProject.sectionIDs.enumerated() {
                // We're skipping the entries that have a title different
                // from the corresponding section title, because that means the
                // section was renamed. Without this check, if a section is renamed
                // and a section later added, the rename will be ignored.
                guard let section: Section = sectionID.correspondingComposifyObject(),
                    let existingTitle = administrateProjectViewController.newValues[HashableTuple((1, index))], existingTitle == section.title else { continue }

                administrateProjectViewController.newValues[HashableTuple((1, index))] = section.title
            }

            // It's important that we reload the previously last row after we
            // insert the new row so there's no problem with indexes.
            let newIndexPath = IndexPath(row: currentProject.sectionIDs.count, section: 1)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .delete:
            guard let currentProject = administrateProjectViewController.currentProject,
                currentProject.sectionIDs.hasElements else { return }
            let sectionToDelete: Section? = currentProject.sectionIDs[indexPath.row].correspondingComposifyObject()

            if UserDefaults.standard.lastSection() == sectionToDelete {
                UserDefaults.standard.resetLastSection()
            }

            administrateProjectViewController.deleteSection(sectionToDelete) {
                self.administrateProjectViewController.administrateProjectDelegate?.userDidDeleteSectionFromProject()
            }

            administrateProjectViewController.newValues.removeAll()
            for (index, sectionID) in currentProject.sectionIDs.enumerated() {
                if let section: Section = sectionID.correspondingComposifyObject() {
                    administrateProjectViewController.newValues[HashableTuple((1, index))] = section.title
                }
            }

            administrateProjectViewController.tableView?.deleteRows(at: [indexPath], with: .automatic)
        case .none:
            break
        }
    }

    func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let currentProject = administrateProjectViewController.currentProject else { return }
        var databaseService = administrateProjectViewController.databaseService
        let sourceSection = currentProject.getSection(at: sourceIndexPath.row)
        let destinationSection = currentProject.getSection(at: destinationIndexPath.row)

        databaseService.performOperation {
            sourceSection?.index = destinationIndexPath.row
            destinationSection?.index = sourceIndexPath.row
        }

        administrateProjectViewController.administrateProjectDelegate?.userDidReorderSections()
    }

    func tableView(_: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Only the section that contains sections should contain movable cells
        // Also we don't want to be able to reorder the last row in that section,
        // because that's the green adding row. Also it doesn't make sense to show
        // the re-ordering controls if there is only a single section.
        let numberOfSections = administrateProjectViewController.currentProject?.sections.count ?? 0
        return indexPath.section == 1 && indexPath.row < numberOfSections && numberOfSections > 1
    }
}
