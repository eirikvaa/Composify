//
//  AdministrateProjectViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

protocol AdministrateProjectDelegate: class {
    /// User aded a section to a project
    /// - parameter section: The section that was added
    func userDidAddSectionToProject(_ section: Section)
    
    /// The user deleted a section from the project
    /// TODO: Possibly pass title of string that was deleted in case this should be used
    func userDidDeleteSectionFromProject()
    
    /// The user edited the title of one or more sections and/or the project itself
    /// TODO: Possibly provide the old value
    func userDidEditTitleOfObjects()
    
    /// The user deleted the project
    /// TODO: Possibly provide the title of the deleted project
    func userDidDeleteProject()
}

class AdministrateProjectViewController: UIViewController {
    
    // MARK: Properties
    lazy var tableViewDataSource = AdministrateProjectTableViewDataSource(administrateProjectViewController: self)
    lazy var tableViewDelegate = AdministrateProjectTableViewDelegate(administrateProjectViewController: self)
    weak var administrateProjectDelegate: AdministrateProjectDelegate?
    private(set) var tableView: UITableView? {
        didSet {
            tableView?.delegate = tableViewDelegate
            tableView?.dataSource = tableViewDataSource
            tableView?.register(UITableViewCell.self, forCellReuseIdentifier: Strings.Cells.administerCell)
            tableView?.register(ButtonTableViewCell.self, forCellReuseIdentifier: Strings.Cells.deleteCell)
            tableView?.register(TextFieldTableViewCell.self, forCellReuseIdentifier: Strings.Cells.cell)
            tableView?.setEditing(true, animated: false)
            tableView?.rowHeight = UIScreen.main.isSmall ? 44 : 55
        }
    }
    var currentProject: Project?
    var databaseService = DatabaseServiceFactory.defaultService
    private var fileManager = FileManager.default
    private(set) lazy var rowCount = [
        0: 1,                                                   // Meta Information
        1: (self.currentProject?.sectionIDs.count ?? 0) + 1,    // Sections
        2: 1                                                    // Danger Zone
    ]
    lazy var newValues: [HashableTuple: String] = [:]
    private(set) var headers: [String] = [
        .localized(.metaInformationHeader),
        .localized(.sectionsHeader),
        .localized(.dangerZoneHeader)
    ]
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = .localized(.administrate)
        
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
            try self.fileManager.delete(sectionToDelete)
        } catch {
            self.handleError(error)
        }
        
        databaseService.delete(sectionToDelete)
        
        completionHandler()
    }
    
    func insertNewSection(_ completionHandler: (_ section: Section) -> Void) {
        let section = Section()
        section.title = .localized(.section)
        section.project = currentProject
        
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
    func configureViews() {
        if let tableView = tableView {
            view.addSubview(tableView)
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
    }
    
    @objc func dismissVC(_ sender: UIBarButtonItem) {
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
