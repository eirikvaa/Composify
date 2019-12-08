//
//  CreateNewProjectViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 07/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import UIKit

final class CreateNewProjectViewController: AdministrateProjectViewController {
    lazy var tableViewDataSource = CreateNewProjectTableViewDataSource(administrateProjectViewController: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = tableViewDataSource

        Project.createProject(withTitle: "") { [weak self] project in
            self?.project = project
        }

        navigationItem.title = R.Loc.addProject
    }

    override func configureViews() {
        super.configureViews()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: R.Loc.save,
            style: .done,
            target: self,
            action: #selector(saveAndDismiss)
        )
    }

    @objc func dismissWithoutSaving() {
        if let project = project {
            DatabaseServiceFactory.defaultService.delete(project)
        }

        dismissAction()
    }

    @objc func saveAndDismiss() {
        if let project = project {
            DatabaseServiceFactory.defaultService.save(project)
            administrateProjectDelegate?.userDidCreateProject(project)
        }

        dismissAction()
    }

    override func dismissAction() {
        super.dismissAction()

        dismiss(animated: true)
    }
}
