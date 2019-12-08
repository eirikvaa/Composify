//
//  EditExistingProjectViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 07/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import UIKit

class EditExistingProjectViewController: AdministrateProjectViewController {
    override init(project: Project?) {
        super.init(project: project)
        self.project = project
    }

    lazy var tableViewDataSource = EditExistingProjectTableViewDataSource(administrateProjectViewController: self)

    required init?(coder _: NSCoder) {
        fatalError("Not implemented!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = tableViewDataSource

        navigationItem.title = R.Loc.administrate
    }

    override func configureViews() {
        super.configureViews()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissAction)
        )
    }

    override func dismissAction() {
        super.dismissAction()
        dismiss(animated: true)
    }
}
