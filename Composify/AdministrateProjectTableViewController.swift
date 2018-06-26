//
//  AdministrateProjectTableViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.05.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit
import RealmSwift

class AdministrateProjectTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    private var tableView: UITableView? {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
            tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "AdministerCell")
            tableView?.register(ButtonTableViewCell.self, forCellReuseIdentifier: "DeleteCell")
            tableView?.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView?.setEditing(true, animated: false)
        }
    }
    var currentProject: Project? = nil
    private var fileManager = CFileManager()
    private lazy var rowCount = [
        0: 1,   // Meta Information
        1: (self.currentProject?.sections.sorted().count ?? 0) + 1,   // Sections
        2: 1    // Danger Zone
    ]
    private lazy var newValues: [T: String] = [:]
    private var headers = [
        "Meta Information",
        "Sections",
        "Danger Zone"
    ]
    let realmStore = RealmStore.shared
    var token: NotificationToken?
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = .localized(.administrate)
        
        tableView = UITableView(frame: view.frame, style: .grouped)
        
        newValues[T((0, 0))] = currentProject?.title ?? ""
        
        if let currentProject = currentProject {
            for (index, section) in (currentProject.sections.sorted().enumerated()) {
                newValues[T((1, index))] = section.title
            }
        }
        
        configureViews()
    }
    
    deinit {
        token?.invalidate()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView?.setEditing(editing, animated: animated)
    }
    
    // TODO: This should NOT happen on text field change. I think.
    @objc func textFieldChange(_ textField: UITextField) {
        var view: UIView? = textField
        
        while (view?.superview?.tag != 1234) {
            view = view?.superview
        }
        
        if let cell = view?.superview as? TextFieldTableViewCell {
            if let indexPath = tableView?.indexPath(for: cell) {
                newValues[T((indexPath.section, indexPath.row))] = cell.textField.text ?? ""
            }
        }
    }
}

// MARK: UITableViewDataSource

extension AdministrateProjectTableViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return rowCount.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return (currentProject?.sections.sorted().count ?? 0) + 1 }
        return rowCount[section] ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TextFieldTableViewCell
        cell.textField.returnKeyType = .done
        cell.tag = 1234
        cell.textField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        cell.textField.text = nil
        cell.textField.placeholder = nil
        cell.isUserInteractionEnabled = true
        let insertRowIndex = currentProject?.sections.sorted().count ?? 0
        
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            cell.textField.placeholder = currentProject?.title
        case (1, _):
            if indexPath.row == insertRowIndex {
                cell.textField.isUserInteractionEnabled = false
                cell.textField.text = "Add new section"
            } else {
                let section = currentProject?.sections.sorted()[indexPath.row]
                cell.textField.placeholder = section?.title
            }
        case (2, _):
            let deleteCell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell", for: indexPath) as! ButtonTableViewCell
            deleteCell.buttonTitle = "Delete Project"
            deleteCell.action = {
                self.fileManager.delete(self.currentProject!)
                self.realmStore.delete(self.currentProject!)
                self.realmStore.realm.refresh()
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

extension AdministrateProjectTableViewController {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard indexPath.section == 1 else { return .none }
        
        let endIndex = currentProject?.sections.sorted().count ?? 0
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            let section = Section()
            let sectionsCount = currentProject?.sections.count ?? 0
            section.title = "Section \(sectionsCount + 1)"
            section.project = currentProject
            
            try! realmStore.realm.write {
                self.currentProject?.sectionIDs.append(section.id)
            }
            
            fileManager.save(section)
            realmStore.save(section, update: true)
            
            if let currentProject = currentProject {
                for (index, section) in currentProject.sections.enumerated() {
                    newValues[T((1, index))] = section.title
                }
            }
            
            // It's important that we reload the previously last row after we
            // insert the new row so there's no problem with indexes.
            let newIndexPath = IndexPath(row: sectionsCount, section: 1)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else if editingStyle == .delete {
            guard let currentProject = currentProject else { return }
            guard !currentProject.sections.isEmpty else { return }
            let sectionToDelete = currentProject.sections[indexPath.row]
            
            try! realmStore.realm.write {
                if let index = currentProject.sectionIDs.index(of: sectionToDelete.id) {
                    self.currentProject?.sectionIDs.remove(at: index)
                }
            }
            
            fileManager.delete(sectionToDelete)
            realmStore.delete(sectionToDelete)
            
            for (index, section) in currentProject.sections.sorted().enumerated() {
                newValues[T((1, index))] = section.title
            }
            
            self.tableView?.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension AdministrateProjectTableViewController {
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
        
        dismiss(animated: true) {
            if let presenting = self.presentingViewController as? LibraryViewController {
                presenting.updateUI()
            }
        }
    }
}

extension AdministrateProjectTableViewController {
    func persistChanges() {
        if newValues[T((0, 0))] != currentProject?.title {
            if let newTitle = newValues[T((0, 0))], newTitle.count > 0 {
                fileManager.rename(currentProject!, from: currentProject?.title ?? "", to: newTitle, section: nil, project: nil)
                realmStore.rename(currentProject!, to: newTitle)
            }
        }
        
        for (index, section) in (currentProject?.sections.sorted().enumerated())! {
            if newValues[T((1, index))] != section.title {
                if let newTitle = newValues[T((1, index))], newTitle.count > 0 {
                    fileManager.rename(section, from: section.title, to: newTitle, section: section, project: currentProject)
                    realmStore.rename(section, to: newTitle)
                }
            }
        }
        
        realmStore.realm.refresh()
    }
}
