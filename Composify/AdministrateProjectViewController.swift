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

    lazy var tableViewDelegate = AdministrateProjectTableViewDelegate(administrateProjectViewController: self)

    weak var administrateProjectDelegate: AdministrateProjectDelegate?
    private(set) var tableView = UITableView(frame: .zero, style: .plain) {
        didSet {
            tableView.keyboardDismissMode = .onDrag
            tableView.delegate = tableViewDelegate
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: R.Cells.cell)
            tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: R.Cells.administrateDeleteCell)
            tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: R.Cells.administrateSectionCell)
            tableView.setEditing(true, animated: false)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 100
        }
    }

    enum TableSection: Int {
        case metInformation
        case projectSections
        case dangerZone
    }

    private(set) lazy var tableRowCount = [
        TableSection.metInformation.rawValue: 1, // Meta Information
        TableSection.projectSections.rawValue: self.project?.sectionIDs.count ?? 0 + 1, // Sections
        TableSection.dangerZone.rawValue: 1, // Danger Zone
    ]
    lazy var tableRowValues: [HashableTuple<Int>: String] = [:]
    var tableSectionHeaders: [String] {
        [
            R.Loc.metaInformationHeader,
            R.Loc.sectionsHeader,
            R.Loc.dangerZoneHeader,
        ]
    }

    var project: Project?
    var titleRow: HashableTuple<Int> {
        return HashableTuple(TableSection.metInformation.rawValue, 0)
    }

    init(project _: Project? = nil) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("Not implemented!")
    }

    // MARK: View Controller Life Cycle

    fileprivate func fillUnderlyingDataStorage() {
        tableRowValues[titleRow] = project?.title

        for section in project?.sections ?? [] {
            tableRowValues[sectionRow(section.index)] = section.title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fillUnderlyingDataStorage()

        configureViews()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.setEditing(editing, animated: animated)
    }

    @objc func textFieldChange(_ textField: UITextField) {
        guard let (cell, indexPath) = getCellAndIndexPath(from: textField) else { return }
        guard let newTitle = cell.textField.text, newTitle.hasPositiveCharacterCount else { return }

        let key = HashableTuple(indexPath.section, indexPath.row)
        tableRowValues[key] = cell.textField.text ?? ""
    }

    func configureViews() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.pinToEdges(of: view)
    }

    @objc func dismissAction() {
        resignFromAllTextFields()
    }

    func deleteSection(_ sectionToDelete: Section, then completionHandler: @escaping () -> Void) {
        normalizeSectionIndices(from: sectionToDelete.index)
        DatabaseServiceFactory.defaultService.delete(sectionToDelete)
        completionHandler()
    }
}

extension AdministrateProjectViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason _: UITextField.DidEndEditingReason) {
        guard let (_, indexPath) = getCellAndIndexPath(from: textField) else { return }
        guard let newTitle = textField.text, newTitle.hasPositiveCharacterCount else { return }

        DatabaseServiceFactory.defaultService.performOperation {
            switch indexPath.section {
            case TableSection.metInformation.rawValue:
                project?.title = newTitle
            case TableSection.projectSections.rawValue:
                let section = project?.getSection(at: indexPath.row)
                section?.title = newTitle
            default:
                return
            }
        }

        administrateProjectDelegate?.userDidEditTitleOfObjects()
    }
}

extension AdministrateProjectViewController {
    func getCellAndIndexPath(from textField: UITextField) -> (TextFieldTableViewCell, IndexPath)? {
        guard let cell = UIView.findSuperView(withTag: 1234, fromBottomView: textField) as? TextFieldTableViewCell else {
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
        let section = Section()
        section.title = R.Loc.section
        section.project = project
        section.index = project?.nextSectionIndex ?? 1

        DatabaseServiceFactory.defaultService.save(section)
        administrateProjectDelegate?.userDidAddSectionToProject(section)

        completionHandler(section)
    }

    /// Return a tuple used for subscripting the `tableRowValues` dictionary.
    /// - parameter index: The row in the section for project sections
    /// - returns: A hashable tuple with the row and section information
    func sectionRow(_ index: Int) -> HashableTuple<Int> {
        return HashableTuple(TableSection.projectSections.rawValue, index)
    }
}

private extension AdministrateProjectViewController {
    /// This will normalize the section indices such as when one is deleted, any
    /// holes in the counting is filled.
    /// If we delete a section, it will create a whole unless we delete the last one.
    /// Say we have indices 0 - 1 - 2 and delete the middle, then we have 0 - 2 and the
    /// application will crash, because it only goes from 0 - 1. Solve this by getting all sections with an
    /// index greater than the passed in index and subtract one to close the gap.
    /// - parameter index: The index that is off by one. We don't need to normalize section indices before this point.
    func normalizeSectionIndices(from index: Int) {
        for i in (index + 1) ..< (project?.sectionIDs.count ?? 0) {
            let section = project?.getSection(at: i)
            DatabaseServiceFactory.defaultService.performOperation {
                section?.index -= 1
            }
        }
    }
}
