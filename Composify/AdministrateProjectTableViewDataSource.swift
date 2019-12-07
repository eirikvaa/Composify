//
//  AdministrateProjectTableViewDataSource.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

final class AdministrateProjectTableViewDataSource: NSObject {
    let administrateProjectViewController: AdministrateProjectViewController

    init(administrateProjectViewController: AdministrateProjectViewController) {
        self.administrateProjectViewController = administrateProjectViewController
    }

    var currentProject: Project? {
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

        if section == projectSectionsSection {
            return (currentProject?.sections.count ?? 0) + 1
        }

        return administrateProjectViewController.tableRowCount[section] ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.Cells.administrateSectionCell, for: indexPath) as? TextFieldTableViewCell else {
            return UITableViewCell()
        }

        cell.textField.returnKeyType = .done
        cell.tag = 1234
        cell.textField.addTarget(administrateProjectViewController, action: #selector(administrateProjectViewController.textFieldChange), for: .editingChanged)
        cell.textField.text = nil
        cell.textField.placeholder = nil
        cell.isUserInteractionEnabled = true
        let insertRowIndex = currentProject?.sectionIDs.count ?? 0

        switch (indexPath.section, indexPath.row) {
        case (tableSection.metInformation.rawValue, _):
            configureCellTextField(textField: cell.textField, placeholder: currentProject?.title ?? "", delegate: administrateProjectViewController)
        case (tableSection.projectSections.rawValue, _):
            if indexPath.row == insertRowIndex {
                cell.textField.isUserInteractionEnabled = false
                cell.textField.text = R.Loc.addSection
            } else {
                if let section = currentProject?.getSection(at: indexPath.row) {
                    configureCellTextField(textField: cell.textField, placeholder: section.title, delegate: administrateProjectViewController)
                }
            }
        case (tableSection.dangerZone.rawValue, _):
            guard let deleteCell = tableView.dequeueReusableCell(withIdentifier: R.Cells.administrateDeleteCell, for: indexPath) as? ButtonTableViewCell else {
                return UITableViewCell()
            }
            deleteCell.buttonTitle = administrateProjectViewController
                .creatingNewProject ?
                R.Loc.closeWithoutSaving :
                R.Loc.deleteProject

            deleteCell.action = {
                if self.administrateProjectViewController.creatingNewProject {
                    self.administrateProjectViewController.dismissWithoutSaving()
                } else {
                    let confirmation = UIAlertController.createConfirmationAlert(
                        title: R.Loc.deleteProjectConfirmationAlertTitle,
                        message: R.Loc.deleteProjectConfirmationAlertMessage,
                        completionHandler: { [weak self] _ in
                            self?.deleteProject()
                        }
                    )

                    self.administrateProjectViewController.present(confirmation, animated: true)
                }
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

            guard let currentProject = currentProject else {
                return
            }

            administrateProjectViewController.tableRowValues.removeAll()
            for (index, sectionID) in currentProject.sectionIDs.enumerated() {
                // We're skipping the entries that have a title different
                // from the corresponding section title, because that means the
                // section was renamed. Without this check, if a section is renamed
                // and a section later added, the rename will be ignored.
                guard let section: Section = sectionID.correspondingComposifyObject(),
                    let existingTitle = administrateProjectViewController.tableRowValues[HashableTuple(1, index)], existingTitle == section.title else {
                    continue
                }

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
        let databaseService = administrateProjectViewController.databaseService
        guard let sourceSection = currentProject?.getSection(at: sourceRow) else { return }
        guard let destinationSection = currentProject?.getSection(at: destinationRow) else { return }

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
        let numberOfSections = currentProject?.sections.count ?? 0
        let projectSectionsSection = tableSection.projectSections.rawValue
        return indexPath.section == projectSectionsSection &&
            indexPath.row < numberOfSections &&
            numberOfSections > projectSectionsSection
    }
}

private extension AdministrateProjectTableViewDataSource {
    func deleteSection(_ section: Section, indexPath: IndexPath) {
        administrateProjectViewController.deleteSection(section) { [weak self] in
            self?.administrateProjectViewController
                .administrateProjectDelegate?
                .userDidDeleteSectionFromProject()

            self?.administrateProjectViewController.tableRowValues.removeAll()
            let projectSectionsSection = self?.tableSection.projectSections.rawValue ?? 0
            let sections = self?.currentProject?.sections ?? []
            for section in sections {
                let key = HashableTuple(projectSectionsSection, section.index)
                self?.administrateProjectViewController.tableRowValues[key] = section.title
            }

            self?.administrateProjectViewController.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func deleteProject() {
        let userDefaults = UserDefaults.standard
        if userDefaults.lastProject() == currentProject {
            userDefaults.resetLastProject()
            userDefaults.resetLastSection()
        }

        DatabaseServiceFactory.defaultService.delete(currentProject!)
        administrateProjectViewController.administrateProjectDelegate?.userDidDeleteProject()
        administrateProjectViewController.dismiss(animated: true)
    }

    func configureCellTextField(textField: UITextField,
                                placeholder: String,
                                autocapitalizationType: UITextAutocapitalizationType = .words,
                                clearButtonMode: UITextField.ViewMode = .whileEditing,
                                returnKeyType: UIReturnKeyType = .done,
                                delegate: UITextFieldDelegate?) {
        textField.placeholder = placeholder
        textField.autocapitalizationType = autocapitalizationType
        textField.clearButtonMode = clearButtonMode
        textField.returnKeyType = returnKeyType
        textField.delegate = delegate
    }
}
