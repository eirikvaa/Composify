//
//  EditExistingProjectTableViewDataSource.swift
//  Composify
//
//  Created by Eirik Vale Aase on 08/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import UIKit

final class EditExistingProjectTableViewDataSource: AdministrateProjectTableViewDataSource {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.Cells.administrateSectionCell, for: indexPath) as? TextFieldTableViewCell else {
            return .init()
        }

        cell.textField.addTarget(
            administrateProjectViewController,
            action: #selector(administrateProjectViewController.textFieldChange),
            for: .editingChanged
        )
        let insertRowIndex = currentProject?.sections.count ?? 0

        switch (indexPath.section, indexPath.row) {
        case (0, _):
            configureCellTextField(
                textField: cell.textField,
                placeholder: currentProject?.title ?? "",
                delegate: administrateProjectViewController
            )
        case (1, _):
            configureSectionsCell(indexPath: indexPath, insertRowIndex: insertRowIndex, cell: cell)
        case (2, _):
            guard let deleteCell = tableView.dequeueReusableCell(withIdentifier: R.Cells.administrateDeleteCell, for: indexPath) as? ButtonTableViewCell else {
                return .init()
            }
            configureDeleteCell(deleteCell: deleteCell)
            return deleteCell
        default:
            break
        }

        return cell
    }
}

private extension EditExistingProjectTableViewDataSource {
    func configureDeleteCell(deleteCell: ButtonTableViewCell) {
        deleteCell.buttonTitle = R.Loc.deleteProject

        deleteCell.action = {
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
}
