//
//  LibraryViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit
import Parchment

/// The view controller for almost all of the functionality; shows projects, sections and recordings.

class LibraryViewController: UIViewController {
    
    @IBOutlet weak var administerBarButton: UIBarButtonItem!
    @IBOutlet weak var recordAudioButton: UIButton! {
        didSet {
            recordAudioButton.layer.cornerRadius = 5
            recordAudioButton.backgroundColor = R.Colors.secondaryColor
        }
    }
    @IBOutlet weak var recordAudioView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    // Properties
    private var errorViewController: ErrorViewController?
    private var state: LibraryViewController.State = .noSections {
        didSet {
            setState(state)
        }
    }
    var currentProject: Project? {
        guard let projectID = currentProjectID else { return nil }
        guard let project = projectID.correspondingProject else { return nil }
        return project
    }
    var currentSection: Section? {
        guard let sectionID = currentSectionID else { return nil }
        guard let section = sectionID.correspondingSection else { return nil }
        return section
    }
    var currentProjectID: String?
    var currentSectionID: String?
    private var databaseService = DatabaseServiceFactory.defaultService
    private let pagingViewController = PagingViewController<SectionPageItem>()
    private var audioRecorderDefaultService: AudioRecorderService?
    private var projects: [Project] {
        return Project.projects()
    }
    private var recording: Recording?
    let fileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentProjectID = databaseService.foundationStore?.projectIDs.first
        currentSectionID = currentProject?.sectionIDs.first
        
        configurePagingViewController()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        pagingViewController.pageViewController.selectedViewController?.setEditing(editing, animated: animated)
    }
}

// MARK: @IBActions
extension LibraryViewController {
    @IBAction func administrateProject(_ sender: UIBarButtonItem) {
        var administrate: UIAlertAction?
        let alert = UIAlertController(title: R.Loc.menu, message: nil, preferredStyle: .actionSheet)
        if let currentProject = currentProject {
            administrate = UIAlertAction(title: R.Loc.administrateProject, style: .default) { _ in
                self.presentAdministrateViewController(project: currentProject)
            }
        }
        
        let addProject = UIAlertAction(title: R.Loc.addProject, style: .default) { _ in
            let addProjectAlert = UIAlertController(title: R.Loc.addProject, message: nil, preferredStyle: .alert)
            addProjectAlert.addTextField { textField in
                textField.autocapitalizationType = .words
                textField.placeholder = R.Loc.projectTitle
                textField.returnKeyType = .done
                textField.clearButtonMode = .whileEditing
            }
            let save = UIAlertAction(title: R.Loc.save, style: .default, handler: { _ in
                if let projectTitle = addProjectAlert.textFields?.first?.text {
                    do {
                        try Project.createProject(withTitle: projectTitle, then: { project in
                            self.currentProjectID = project.id
                            self.currentSectionID = project.sectionIDs.first
                            self.updateUI()
                        })
                    } catch {
                        self.handleError(error)
                    }
                }
            })
            let cancel = UIAlertAction(title: R.Loc.cancel, style: .cancel)
            addProjectAlert.addAction(save)
            addProjectAlert.addAction(cancel)
            
            self.present(addProjectAlert, animated: true)
        }
        
        projects.forEach { project in
            if project != currentProject {
                let projectAction = UIAlertAction(title: R.Loc.showProject(named: project.title), style: .default) { _ in
                    self.setCurrentProject(project)
                }
                alert.addAction(projectAction)
            }
        }
        
        let cancel = UIAlertAction(title: R.Loc.cancel, style: .cancel)
        if let administrate = administrate {
            alert.addAction(administrate)
        }
        alert.addAction(addProject)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    @IBAction func recordAudio(_ sender: UIButton) {
        guard let recorder = audioRecorderDefaultService else {
            guard let currentProject = currentProject else { return }
            guard let currentSection = currentSection else { return }
            
            recording = Recording()
            recording?.title = R.Loc.recording
            recording?.project = currentProject
            recording?.section = currentSection
            recording?.fileExtension = "caf"
            
            if let recording = recording {
                do {
                    audioRecorderDefaultService = try AudioRecorderServiceFactory.defaultService(withURL: recording.url)
                } catch {
                    handleError(error)
                }
            }
            
            audioRecorderDefaultService?.record()
            recordAudioButton.setTitle(R.Loc.stopRecording, for: .normal)
            return
        }
        
        recorder.stop()
        
        if let recording = recording {
            do {
                try fileManager.save(recording)
            } catch {
                handleError(error)
            }
            databaseService.save(recording)
        }
        
        recording = nil
        audioRecorderDefaultService = nil
        recordAudioButton.setTitle(R.Loc.startRecording, for: .normal)
        
        updateUI()
    }
}

extension LibraryViewController {
    /// Set the new current project
    /// - parameter project: The project that should now be shown
    func setCurrentProject(_ project: Project) {
        self.currentProjectID = project.id
        self.currentSectionID = self.currentProject?.sectionIDs.first
        
        self.updateUI()
    }
    
    func setupUI() {
        navigationItem.leftBarButtonItem?.title = R.Loc.menu
    }
    
    /// Update the user interface, mainly concerned with updating the state
    func updateUI() {
        switch (currentProject, currentSection) {
        case (.some, .some):
            state = .notEmpty
        case (.some, .none):
            state = .noSections
        case (.none, _):
            state = .noProjects
        }
        
        // FIXME: Must figure out how to reload the width so that it adapts when adding/removing sections
        pagingViewController.reloadData()
        
        if let section = currentProject?.sectionIDs.first?.correspondingSection {
            navigationItem.rightBarButtonItem = section.recordings.hasElements ? editButtonItem : nil
        }
    }
    
    /// Set the state of the user interface
    /// - parameter state: The state that should be set
    func setState(_ state: State) {
        errorViewController?.remove()
        
        switch state {
        case .notEmpty:
            break
        case .noProjects:
            errorViewController = ErrorViewController(labelText: R.Loc.noProjects)
            if let errorViewController = errorViewController {
                add(errorViewController)
            }
        case .noSections:
            errorViewController = ErrorViewController(labelText: R.Loc.noSections)
            if let errorVieController = errorViewController {
                add(errorVieController)
            }
        }
        
        navigationItem.title = currentProject?.title ?? R.Loc.composify
    }
    
    /// State enum for the user interface
    enum State {
        case noProjects
        case noSections
        case notEmpty
    }
    
    /// Present the view controller for administrating a given project
    /// - parameter project: The project that should be administrated
    func presentAdministrateViewController(project: Project) {
        let administerVC = AdministrateProjectViewController()
        administerVC.currentProject = project
        administerVC.administrateProjectDelegate = self
        let nav = UINavigationController(rootViewController: administerVC)
        self.present(nav, animated: true)
    }
    
    /// Configure the paging view controller
    func configurePagingViewController() {
        pagingViewController.menuItemSource = .class(type: LibraryCollectionViewCell.self)
        pagingViewController.indicatorColor = R.Colors.mainColor
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        
        add(pagingViewController)
        containerView.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor)
        ])
    }
}

extension LibraryViewController: AdministrateProjectDelegate {
    func userDidAddSectionToProject(_ section: Section) {
        currentSectionID = section.id
    }
    
    func userDidDeleteSectionFromProject() {
        currentSectionID = currentProject?.sectionIDs.sorted().first
    }
    
    func userDidEditTitleOfObjects() {
    }
    
    func userDidDeleteProject() {
        currentProjectID = databaseService.foundationStore?.projectIDs.first
        currentSectionID = currentProject?.sectionIDs.first
    }
}
