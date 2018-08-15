//
//  AdministrateProjectTableVieDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

class AdministrateProjectTableViewDelegate: NSObject {
    let administrateProjectViewController: AdministrateProjectViewController
    
    init(administrateProjectViewController: AdministrateProjectViewController) {
        self.administrateProjectViewController = administrateProjectViewController
    }
}

extension AdministrateProjectTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard indexPath.section == 1 else { return .none }
        
        let endIndex = administrateProjectViewController.currentProject?.sectionIDs.count ?? 0
        
        if indexPath.section == 1 && 0..<endIndex ~= indexPath.row {
            return .delete
        } else if indexPath.section == 1 && indexPath.row == endIndex {
            return .insert
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == 1 else { return false }
        
        if indexPath.row == administrateProjectViewController.rowCount[indexPath.section] ?? 0 { return false }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
                guard let section = sectionID.correspondingSection,
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
            let sectionToDelete = currentProject.sectionIDs[indexPath.row].correspondingSection
            
            if UserDefaults.standard.lastSection() == sectionToDelete {
                UserDefaults.standard.resetLastSection()
            }
            
            administrateProjectViewController.deleteSection(sectionToDelete) {
                self.administrateProjectViewController.administrateProjectDelegate?.userDidDeleteSectionFromProject()
            }
            
            administrateProjectViewController.newValues.removeAll()
            for (index, sectionID) in currentProject.sectionIDs.enumerated() {
                if let section = sectionID.correspondingSection {
                    administrateProjectViewController.newValues[HashableTuple((1, index))] = section.title
                }
            }
            
            administrateProjectViewController.tableView?.deleteRows(at: [indexPath], with: .automatic)
        case .none:
            break
        }
    }
}
