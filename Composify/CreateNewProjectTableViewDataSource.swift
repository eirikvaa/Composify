//
//  CreateNewProjectTableViewDataSource.swift
//  Composify
//
//  Created by Eirik Vale Aase on 08/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import UIKit

final class CreateNewProjectTableViewDataSource: AdministrateProjectTableViewDataSource {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewController = administrateProjectViewController as? CreateNewProjectViewController else {
            return .init()
        }

        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: R.Cells.administrateSectionCell,
                for: indexPath
        ) as? TextFieldTableViewCell else {
            return .init()
        }

        cell.textField.addTarget(
            viewController,
            action: #selector(viewController.textFieldChange),
            for: .editingChanged
        )
        let insertRowIndex = currentProject?.sections.count ?? 0

        switch (indexPath.section, indexPath.row) {
        case (0, _):
            configureCellTextField(
                textField: cell.textField,
                placeholder: R.Loc.projectTitle,
                delegate: viewController
            )
        case (1, _):
            configureSectionsCell(indexPath: indexPath, insertRowIndex: insertRowIndex, cell: cell)
        case (2, _):
            guard let closeCell = tableView.dequeueReusableCell(
                    withIdentifier: R.Cells.administrateDeleteCell,
                    for: indexPath
            ) as? ButtonTableViewCell else {
                return .init()
            }

            configureCloseCell(closeCell, viewController)

            return closeCell
        default:
            break
        }

        return cell
    }
}

private extension CreateNewProjectTableViewDataSource {
    func configureCloseCell(
        _ closeCell: ButtonTableViewCell,
        _ administrateProjectViewController: CreateNewProjectViewController
    ) {
        closeCell.buttonTitle = R.Loc.closeWithoutSaving
        closeCell.buttonTitleColor = .black
        closeCell.action = administrateProjectViewController.dismissWithoutSaving
    }
}
