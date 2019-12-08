//
//  CreateNewProjectTableViewDataSource.swift
//  Composify
//
//  Created by Eirik Vale Aase on 08/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import UIKit

class CreateNewProjectTableViewDataSource: AdministrateProjectTableViewDataSource {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let administrateProjectViewController = administrateProjectViewController as? CreateNewProjectViewController else {
            return .init()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.Cells.administrateSectionCell, for: indexPath) as? TextFieldTableViewCell else {
            return .init()
        }

        cell.textField.returnKeyType = .done
        cell.tag = 1234
        cell.textField.addTarget(administrateProjectViewController, action: #selector(administrateProjectViewController.textFieldChange), for: .editingChanged)
        cell.textField.text = nil
        cell.textField.placeholder = nil
        cell.isUserInteractionEnabled = true
        let insertRowIndex = currentProject?.sectionIDs.count ?? 0

        switch (indexPath.section, indexPath.row) {
        case (0, _):
            configureCellTextField(textField: cell.textField, placeholder: currentProject?.title ?? "", delegate: administrateProjectViewController)
        case (1, _):
            if indexPath.row == insertRowIndex {
                cell.textField.isUserInteractionEnabled = false
                cell.textField.text = R.Loc.addSection
            } else {
                if let section = currentProject?.getSection(at: indexPath.row) {
                    configureCellTextField(textField: cell.textField, placeholder: section.title, delegate: administrateProjectViewController)
                }
            }
        case (2, _):
            guard let closeCell = tableView.dequeueReusableCell(withIdentifier: R.Cells.administrateDeleteCell, for: indexPath) as? ButtonTableViewCell else {
                return .init()
            }

            closeCell.buttonTitle = R.Loc.closeWithoutSaving
            closeCell.buttonTitleColor = .black
            closeCell.action = administrateProjectViewController.dismissWithoutSaving

            return closeCell
        default:
            break
        }

        return cell
    }
}
