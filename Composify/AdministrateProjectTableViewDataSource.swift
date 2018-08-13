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
    func numberOfSections(in tableView: UITableView) -> Int {
        return administrateProjectViewController.rowCount.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return (administrateProjectViewController.currentProject?.sectionIDs.count ?? 0) + 1 }
        return administrateProjectViewController.rowCount[section] ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Strings.Cells.cell, for: indexPath) as? TextFieldTableViewCell else { return UITableViewCell() }
        
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
                cell.textField.text = .localized(.addSection)
            } else {
                if let section = administrateProjectViewController.currentProject?.sectionIDs[indexPath.row].correspondingSection {
                    cell.textField.placeholder = section.title
                    cell.textField.autocapitalizationType = .words
                    cell.textField.clearButtonMode = .whileEditing
                    cell.textField.returnKeyType = .done
                }
            }
        case (2, _):
            guard let deleteCell = tableView.dequeueReusableCell(withIdentifier: Strings.Cells.deleteCell, for: indexPath) as? ButtonTableViewCell else { return UITableViewCell() }
            deleteCell.buttonTitle = .localized(.deleteProejct)
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return administrateProjectViewController.headers[section]
    }
}
