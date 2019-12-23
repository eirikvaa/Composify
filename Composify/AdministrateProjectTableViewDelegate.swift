//
//  AdministrateProjectTableVieDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

final class AdministrateProjectTableViewDelegate: NSObject {
    let administrateProjectViewController: AdministrateProjectViewController

    init(administrateProjectViewController: AdministrateProjectViewController) {
        self.administrateProjectViewController = administrateProjectViewController
    }

    var project: Project? {
        return administrateProjectViewController.project
    }
}

extension AdministrateProjectTableViewDelegate: UITableViewDelegate {
    func tableView(_: UITableView, shouldHighlightRowAt _: IndexPath) -> Bool {
        return false
    }

    func tableView(_: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard indexPath.section == 1 else { return .none }

        let endIndex = project?.sectionIDs.count ?? 0
        let sectionRowsRange = 0 ..< endIndex
        let shouldDelete = indexPath.section == 1 && sectionRowsRange.contains(indexPath.row)
        let shouldInsert = indexPath.section == 1 && indexPath.row == endIndex

        if shouldDelete {
            return .delete
        } else if shouldInsert {
            return .insert
        } else {
            return .none
        }
    }

    func tableView(_: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == 1 else { return false }

        let row = administrateProjectViewController.tableSections[indexPath.section].values.count
        if indexPath.row == row { return false }

        return true
    }
}
