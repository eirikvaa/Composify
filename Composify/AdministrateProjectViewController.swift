//
//  AdministrateProjectViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

class AdministrateProjectViewController: UIViewController {
    // MARK: Properties

    lazy var tableViewDataSource = AdministrateProjectTableViewDataSource(administrateProjectViewController: self)
    lazy var tableViewDelegate = AdministrateProjectTableViewDelegate(administrateProjectViewController: self)
    weak var administrateProjectDelegate: AdministrateProjectDelegate?
    private(set) var tableView: UITableView? {
        didSet {
            tableView?.delegate = tableViewDelegate
            tableView?.dataSource = tableViewDataSource
            tableView?.register(UITableViewCell.self, forCellReuseIdentifier: R.Cells.cell)
            tableView?.register(ButtonTableViewCell.self, forCellReuseIdentifier: R.Cells.administrateDeleteCell)
            tableView?.register(TextFieldTableViewCell.self, forCellReuseIdentifier: R.Cells.administrateSectionCell)
            tableView?.setEditing(true, animated: false)
            tableView?.rowHeight = UIScreen.main.isSmall ? 44 : 55
        }
    }

    var currentProject: Project?
    var databaseService = DatabaseServiceFactory.defaultService
    private var fileManager = FileManager.default
    private(set) lazy var rowCount = [
        0: 1, // Meta Information
        1: (self.currentProject?.sectionIDs.count ?? 0) + 1, // Sections
        2: 1, // Danger Zone
    ]
    lazy var newValues: [HashableTuple: String] = [:]
    private(set) var headers: [String] = [
        R.Loc.metaInformationHeader,
        R.Loc.sectionsHeader,
        R.Loc.dangerZoneHeader,
    ]

    // MARK: View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = R.Loc.administrate

        tableView = UITableView(frame: view.frame, style: .grouped)

        newValues[HashableTuple((0, 0))] = currentProject?.title ?? ""

        if let currentProject = currentProject {
            for (index, sectionID) in currentProject.sectionIDs.enumerated() {
                if let section = sectionID.correspondingSection {
                    newValues[HashableTuple((1, index))] = section.title
                }
            }
        }

        configureViews()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView?.setEditing(editing, animated: animated)
    }

    @objc func textFieldChange(_ textField: UITextField) {
        if let cell = UIView.findSuperView(withTag: 1234, fromBottomView: textField) as? TextFieldTableViewCell {
            if let indexPath = tableView?.indexPath(for: cell) {
                newValues[HashableTuple((indexPath.section, indexPath.row))] = cell.textField.text ?? ""
            }
        }
    }
}

extension AdministrateProjectViewController {
    func deleteSection(_ sectionToDelete: Section?, then completionHandler: () -> Void) {
        guard let sectionToDelete = sectionToDelete else { return }

        do {
            try fileManager.delete(sectionToDelete)
        } catch {
            handleError(error)
        }

        databaseService.delete(sectionToDelete)

        completionHandler()
    }

    func insertNewSection(_ completionHandler: (_ section: Section) -> Void) {
        guard let currentProject = currentProject else {
            // This will never happen, because a prerequisite for showing the administrate view
            // is that there has been created a project.
            return
        }

        let section = Section()
        section.title = R.Loc.section
        section.project = currentProject
        section.index = currentProject.nextSectionIndex

        do {
            try fileManager.save(section)
        } catch {
            handleError(error)
        }

        databaseService.save(section)
        administrateProjectDelegate?.userDidAddSectionToProject(section)

        completionHandler(section)
    }
}

private extension AdministrateProjectViewController {
    /// This will normalize the section indices such as when one is deleted, any
    /// holes in the counting is filled.
    func normalizeSectionIndices() {
        guard let currentProject = currentProject else { return }
        databaseService.performOperation {
            for (index, section) in currentProject.sections.enumerated() {
                section.index = index
            }
        }
    }

    func configureViews() {
        if let tableView = tableView {
            view.addSubview(tableView)

            tableView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
    }

    @objc func dismissVC(_: UIBarButtonItem) {
        persistChanges()
        dismiss(animated: true)
    }

    func persistChanges() {
        var hadChanges = false
        if newValues[HashableTuple((0, 0))] != currentProject?.title {
            if let newTitle = newValues[HashableTuple((0, 0))], newTitle.hasPositiveCharacterCount {
                databaseService.rename(currentProject!, to: newTitle)
                hadChanges = true
            }
        }

        for (index, sectionID) in (currentProject?.sectionIDs.enumerated())! {
            guard let section = sectionID.correspondingSection else { continue }

            if newValues[HashableTuple((1, index))] != section.title {
                if let newTitle = newValues[HashableTuple((1, index))], newTitle.hasPositiveCharacterCount {
                    databaseService.rename(section, to: newTitle)
                    hadChanges = true
                }
            }
        }

        if hadChanges {
            administrateProjectDelegate?.userDidEditTitleOfObjects()
        }
    }
}
