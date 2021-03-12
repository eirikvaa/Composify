//
//  AdministrateProjectViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

struct TableSection {
    let header: String
    var values: [String]
}

class AdministrateProjectViewController: UIViewController {
    // MARK: Properties

    weak var tableViewDelegate: AdministrateProjectTableViewDelegate? {
        AdministrateProjectTableViewDelegate(administrateProjectViewController: self)
    }

    weak var administrateProjectDelegate: AdministrateProjectDelegate?
    private(set) var tableView = AdministrateProjectTableView(frame: .zero, style: .plain) {
        didSet {
            tableView.delegate = tableViewDelegate
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: R.Cells.cell)
            tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: R.Cells.administrateDeleteCell)
            tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: R.Cells.administrateSectionCell)
            tableView.setEditing(true, animated: false)
        }
    }

    var tableSections: [TableSection] = [
        .init(header: R.Loc.metaInformationHeader, values: []),
        .init(header: R.Loc.sectionsHeader, values: []),
        .init(header: R.Loc.dangerZoneHeader, values: [])
    ]

    var project: Project?

    init(project _: Project? = nil) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("Not implemented!")
    }

    // MARK: View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        fillUnderlyingDataStorage()

        configureViews()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.setEditing(editing, animated: animated)
    }

    @objc
    func textFieldChange(_ textField: UITextField) {
        guard let (cell, indexPath) = getCellAndIndexPath(from: textField) else {
            return
        }

        guard let newTitle = cell.textField.text, newTitle.hasCharacters else {
            return
        }

        tableSections[indexPath.section].values[indexPath.row] = cell.textField.text ?? ""
    }

    func configureViews() {
        tableView = AdministrateProjectTableView(frame: view.frame, style: .grouped)
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.pinToEdges(of: view)
    }

    @objc
    func dismissAction() {
        resignFromAllTextFields()
    }

    func deleteSection(_ sectionToDelete: Section, then completionHandler: @escaping () -> Void) {
        project?.deleteSection(at: sectionToDelete.index)
        completionHandler()
    }
}

extension AdministrateProjectViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason _: UITextField.DidEndEditingReason) {
        guard let (_, indexPath) = getCellAndIndexPath(from: textField) else {
            return
        }

        guard let newTitle = textField.text, newTitle.hasCharacters else {
            return
        }

        guard var project = project else {
            return
        }

        switch indexPath.section {
        case 0:
            RealmRepository().update(object: &project, value: newTitle, keyPath: \.title)
        case 1:
            if var section = project.getSection(at: indexPath.row) {
                RealmRepository().update(object: &section, value: newTitle, keyPath: \.title)
            }
        default:
            return
        }

        administrateProjectDelegate?.userDidEditTitleOfObjects()
    }
}

extension AdministrateProjectViewController {
    func getCellAndIndexPath(from textField: UITextField) -> (TextFieldTableViewCell, IndexPath)? {
        guard let cell = UIView.findSuperView(
                withTag: 1_234,
                fromBottomView: textField
        ) as? TextFieldTableViewCell else {
            return nil
        }

        guard let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }

        return (cell, indexPath)
    }

    /// Insert a new section into the project
    /// - parameter completionHandler: What should be done after inserting the section, returns the inserted section
    func insertNewSection(_ completionHandler: (_ section: Section) -> Void) {
        guard let project = project else {
            return
        }
        
        let section = Section(title: R.Loc.section, project: project)
        RealmRepository().save(section: section, to: project)

        administrateProjectDelegate?.userDidAddSectionToProject(section)

        completionHandler(section)
    }

    func fillUnderlyingDataStorage() {
        tableSections[0].values = [project?.title ?? ""]
        tableSections[1].values = (project?.sections.map { $0.title } ?? [])
    }
}
