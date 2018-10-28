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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
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
}
