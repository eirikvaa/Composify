//
//  AdministrateProjectViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

protocol AdministrateProjectDelegate: class {
    func userDidAddSectionToProject(_ section: Section)
    func userDidDeleteSectionFromProject()
    func userDidEditTitleOfObjects()
    func userDidDeleteProject()
}

class AdministrateProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    weak var administrateProjectDelegate: AdministrateProjectDelegate?
    private var tableView: UITableView? {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
            tableView?.register(UITableViewCell.self, forCellReuseIdentifier: Strings.Cells.administerCell)
            tableView?.register(ButtonTableViewCell.self, forCellReuseIdentifier: Strings.Cells.deleteCell)
            tableView?.register(TextFieldTableViewCell.self, forCellReuseIdentifier: Strings.Cells.cell)
            tableView?.setEditing(true, animated: false)
        }
    }
    var currentProject: Project?
    var databaseService = DatabaseServiceFactory.defaultService
    private var fileManager = FileManager.default
    private lazy var rowCount = [
        0: 1,   // Meta Information
        1: (self.currentProject?.sectionIDs.count ?? 0) + 1,   // Sections
        2: 1    // Danger Zone
    ]
    private lazy var newValues: [T: String] = [:]
    private var headers: [String] = [
        .localized(.metaInformationHeader),
        .localized(.sectionsHeader),
        .localized(.dangerZoneHeader)
    ]
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = .localized(.administrate)
        
        tableView = UITableView(frame: view.frame, style: .grouped)
        
        newValues[T((0, 0))] = currentProject?.title ?? ""
        
        if let currentProject = currentProject {
            for (index, sectionID) in currentProject.sectionIDs.enumerated() {
                if let section = sectionID.correspondingSection {
                    newValues[T((1, index))] = section.title
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
                newValues[T((indexPath.section, indexPath.row))] = cell.textField.text ?? ""
            }
        }
    }
}

// MARK: UITableViewDataSource

extension AdministrateProjectViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return rowCount.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return (currentProject?.sectionIDs.count ?? 0) + 1 }
        return rowCount[section] ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Strings.Cells.cell, for: indexPath) as? TextFieldTableViewCell else { return UITableViewCell() }
        
        cell.textField.returnKeyType = .done
        cell.tag = 1234
        cell.textField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        cell.textField.text = nil
        cell.textField.placeholder = nil
        cell.isUserInteractionEnabled = true
        let insertRowIndex = currentProject?.sectionIDs.count ?? 0
        
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            cell.textField.placeholder = currentProject?.title
            cell.textField.autocapitalizationType = .words
            cell.textField.clearButtonMode = .whileEditing
            cell.textField.returnKeyType = .done
        case (1, _):
            if indexPath.row == insertRowIndex {
                cell.textField.isUserInteractionEnabled = false
                cell.textField.text = .localized(.addSection)
            } else {
                if let section = currentProject?.sectionIDs[indexPath.row].correspondingSection {
                    cell.textField.placeholder = section.title
                    cell.textField.autocapitalizationType = .words
                    cell.textField.clearButtonMode = .whileEditing
                    cell.textField.returnKeyType = .done
                }
            }
        case (2, _):
            guard let deleteCell = tableView.dequeueReusableCell(withIdentifier: Strings.Cells.deleteCell, for: indexPath) as? ButtonTableViewCell else { return UITableViewCell() }
            deleteCell.buttonTitle = .localized(.deleteProejct)
            deleteCell.action = {
                guard let currentProject = self.currentProject else { return }
                
                let standard = UserDefaults.standard
                if standard.lastProject() == currentProject {
                    standard.resetLastProject()
                    standard.resetLastSection()
                }
                
                do {
                    try self.fileManager.delete(currentProject)
                } catch {
                    self.handleError(error)
                }
                
                self.databaseService.delete(currentProject)
                self.administrateProjectDelegate?.userDidDeleteProject()
                
                self.dismiss(animated: true)
            }
            return deleteCell
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
}

// MARK: UITableViewDelegate

extension AdministrateProjectViewController {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard indexPath.section == 1 else { return .none }
        
        let endIndex = currentProject?.sectionIDs.count ?? 0
        
        if indexPath.section == 1 && 0..<endIndex ~= indexPath.row {
            return .delete
        } else if indexPath.section == 1 && indexPath.row == endIndex {
            return .insert
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == 1 else { return false }
        
        if indexPath.row == rowCount[indexPath.section] ?? 0 { return false }
        
        return true
    }
    
    private func deleteSection(_ sectionToDelete: Section?, then completionHandler: () -> Void) {
        guard let sectionToDelete = sectionToDelete else { return }
        
        do {
            try self.fileManager.delete(sectionToDelete)
        } catch {
            self.handleError(error)
        }
        
        databaseService.delete(sectionToDelete)
        
        completionHandler()
    }
    
    private func insertNewSection(_ completionHandler: (_ section: Section) -> Void) {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            guard let currentProject = currentProject else { return }
            
            insertNewSection {
                self.administrateProjectDelegate?.userDidAddSectionToProject($0)
            }
            
            newValues.removeAll()
            for (index, sectionID) in currentProject.sectionIDs.enumerated() {
                // We're skipping the entries that have a title different
                // from the corresponding section title, because that means the
                // section was renamed. Without this check, if a section is renamed
                // and a section later added, the rename will be ignored.
                guard let section = sectionID.correspondingSection,
                    let existingTitle = newValues[T((1, index))], existingTitle == section.title else { continue }
                
                newValues[T((1, index))] = section.title
            }
            
            // It's important that we reload the previously last row after we
            // insert the new row so there's no problem with indexes.
            let newIndexPath = IndexPath(row: currentProject.sectionIDs.count, section: 1)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .delete:
            guard let currentProject = currentProject,
                currentProject.sectionIDs.hasElements else { return }
            let sectionToDelete = currentProject.sectionIDs[indexPath.row].correspondingSection
            
            if UserDefaults.standard.lastSection() == sectionToDelete {
                UserDefaults.standard.resetLastSection()
            }
            
            deleteSection(sectionToDelete) {
                self.administrateProjectDelegate?.userDidDeleteSectionFromProject()
            }
            
            newValues.removeAll()
            for (index, sectionID) in currentProject.sectionIDs.enumerated() {
                if let section = sectionID.correspondingSection {
                    newValues[T((1, index))] = section.title
                }
            }
            
            self.tableView?.deleteRows(at: [indexPath], with: .automatic)
        case .none:
            break
        }
    }
}

extension AdministrateProjectViewController {
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
}

extension AdministrateProjectViewController {
    func persistChanges() {
        var hadChanges = false
        if newValues[T((0, 0))] != currentProject?.title {
            if let newTitle = newValues[T((0, 0))], newTitle.hasPositiveCharacterCount {
                databaseService.rename(currentProject!, to: newTitle)
                hadChanges = true
            }
        }
        
        for (index, sectionID) in (currentProject?.sectionIDs.enumerated())! {
            guard let section = sectionID.correspondingSection else { continue }
            
            if newValues[T((1, index))] != section.title {
                if let newTitle = newValues[T((1, index))], newTitle.hasPositiveCharacterCount {
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
