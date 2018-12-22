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

    var currentProject: Project {
        return administrateProjectViewController.project
    }

    var tableSection: AdministrateProjectViewController.TableSection.Type {
        return AdministrateProjectViewController.TableSection.self
    }
}

extension AdministrateProjectTableViewDataSource: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return administrateProjectViewController.tableRowCount.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let projectSectionsSection = AdministrateProjectViewController.TableSection.projectSections.rawValue
        if section == projectSectionsSection { return currentProject.sections.count + 1 }
        return administrateProjectViewController.tableRowCount[section] ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.Cells.administrateSectionCell, for: indexPath) as? TextFieldTableViewCell else { return UITableViewCell() }

        cell.textField.returnKeyType = .done
        cell.tag = 1234
        cell.textField.addTarget(administrateProjectViewController, action: #selector(administrateProjectViewController.textFieldChange), for: .editingChanged)
        cell.textField.text = nil
        cell.textField.placeholder = nil
        cell.isUserInteractionEnabled = true
        let insertRowIndex = currentProject.sectionIDs.count

        switch (indexPath.section, indexPath.row) {
        case (tableSection.metInformation.rawValue, _):
            cell.textField.placeholder = currentProject.title
            cell.textField.autocapitalizationType = .words
            cell.textField.clearButtonMode = .whileEditing
            cell.textField.returnKeyType = .done
            cell.textField.delegate = administrateProjectViewController
        case (tableSection.projectSections.rawValue, _):
            if indexPath.row == insertRowIndex {
                cell.textField.isUserInteractionEnabled = false
                cell.textField.text = R.Loc.addSection
            } else {
                if let section = currentProject.getSection(at: indexPath.row) {
                    cell.textField.placeholder = section.title
                    cell.textField.autocapitalizationType = .words
                    cell.textField.clearButtonMode = .whileEditing
                    cell.textField.returnKeyType = .done
                    cell.textField.delegate = administrateProjectViewController
                }
            }
        case (tableSection.dangerZone.rawValue, _):
            guard let deleteCell = tableView.dequeueReusableCell(withIdentifier: R.Cells.administrateDeleteCell, for: indexPath) as? ButtonTableViewCell else { return UITableViewCell() }
            deleteCell.buttonTitle = R.Loc.deleteProejct
            deleteCell.action = {
                let userDefaults = UserDefaults.standard
                if userDefaults.lastProject() == self.currentProject {
                    userDefaults.resetLastProject()
                    userDefaults.resetLastSection()
                }

                do {
                    try FileManager.default.delete(self.currentProject)
                } catch {
                    self.administrateProjectViewController.handleError(error)
                }

                self.administrateProjectViewController.databaseService.delete(self.currentProject)
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
        return administrateProjectViewController.tableSectionHeaders[section]
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            administrateProjectViewController.insertNewSection {
                self.administrateProjectViewController.administrateProjectDelegate?.userDidAddSectionToProject($0)
            }

            administrateProjectViewController.tableRowValues.removeAll()
            for (index, sectionID) in currentProject.sectionIDs.enumerated() {
                // We're skipping the entries that have a title different
                // from the corresponding section title, because that means the
                // section was renamed. Without this check, if a section is renamed
                // and a section later added, the rename will be ignored.
                guard let section: Section = sectionID.correspondingComposifyObject(),
                    let existingTitle = administrateProjectViewController.tableRowValues[HashableTuple(1, index)], existingTitle == section.title else { continue }

                let projectSectionsSection = tableSection.projectSections.rawValue
                administrateProjectViewController.tableRowValues[HashableTuple(projectSectionsSection, index)] = section.title
            }

            // It's important that we reload the previously last row after we
            // insert the new row so there's no problem with indexes.
            let projectSectionsSection = tableSection.projectSections.rawValue
            let newIndexPath = IndexPath(row: currentProject.sections.count, section: projectSectionsSection)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .delete:
            guard currentProject.sections.hasElements else { return }
            guard let sectionToDelete = currentProject.getSection(at: indexPath.row) else { return }

            if UserDefaults.standard.lastSection() == sectionToDelete {
                UserDefaults.standard.resetLastSection()
            }

            administrateProjectViewController.deleteSection(sectionToDelete) {
                self.administrateProjectViewController.administrateProjectDelegate?.userDidDeleteSectionFromProject()
            }

            administrateProjectViewController.tableRowValues.removeAll()
            let projectSectionsSection = tableSection.projectSections.rawValue
            for section in currentProject.sections {
                let key = HashableTuple(projectSectionsSection, section.index)
                administrateProjectViewController.tableRowValues[key] = section.title
            }

            administrateProjectViewController.tableView.deleteRows(at: [indexPath], with: .automatic)
        case .none:
            break
        }
    }

    func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceRow = sourceIndexPath.row
        let destinationRow = destinationIndexPath.row
        var databaseService = administrateProjectViewController.databaseService
        guard let sourceSection = currentProject.getSection(at: sourceRow) else { return }
        guard let destinationSection = currentProject.getSection(at: destinationRow) else { return }

        databaseService.performOperation {
            sourceSection.index = destinationRow
            destinationSection.index = sourceRow
        }

        let sourceTuple = administrateProjectViewController.sectionRow(sourceRow)
        let destinationTuple = administrateProjectViewController.sectionRow(destinationRow)
        administrateProjectViewController.tableRowValues[destinationTuple] = sourceSection.title
        administrateProjectViewController.tableRowValues[sourceTuple] = destinationSection.title

        administrateProjectViewController.administrateProjectDelegate?.userDidReorderSections()
    }

    func tableView(_: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Only the section that contains sections should contain movable cells
        // Also we don't want to be able to reorder the last row in that section,
        // because that's the green adding row. Also it doesn't make sense to show
        // the re-ordering controls if there is only a single section.
        let numberOfSections = currentProject.sections.count
        let projectSectionsSection = tableSection.projectSections.rawValue
        return indexPath.section == projectSectionsSection &&
            indexPath.row < numberOfSections && numberOfSections > projectSectionsSection
    }
}
