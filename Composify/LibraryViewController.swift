//
//  LibraryViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import Parchment
import UIKit

/// The view controller for almost all of the functionality; shows projects, sections and recordings.

class LibraryViewController: UIViewController {
    @IBOutlet var administerBarButton: UIBarButtonItem!
    @IBOutlet var recordAudioButton: UIButton! {
        didSet {
            recordAudioButton.layer.cornerRadius = 5
            recordAudioButton.backgroundColor = R.Colors.secondaryColor
            recordAudioButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            recordAudioButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    @IBOutlet var recordAudioView: UIView!
    @IBOutlet var containerView: UIView!

    // Properties
    private var errorViewController: ErrorViewController?
    private var state: LibraryViewController.State = .noSections

    var currentProject: Project? {
        guard let projectID = currentProjectID else { return nil }
        guard let project: Project = projectID.correspondingComposifyObject() else { return nil }
        return project
    }

    var currentSection: Section? {
        guard let sectionID = currentSectionID else { return nil }
        guard let section: Section = sectionID.correspondingComposifyObject() else { return nil }
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

        showOnboardingIfNeeded()

        currentProjectID = databaseService.foundationStore?.projectIDs.first
        currentSectionID = currentProject?.sectionIDs.first

        configurePagingViewController()
        setupUI()
        registerObservers()
        updateUI()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        pagingViewController.pageViewController.selectedViewController?.setEditing(editing, animated: animated)
    }
}

// MARK: @IBActions

extension LibraryViewController {
    @IBAction func administrateProject(_: UIBarButtonItem) {
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
                    } catch let FileManagerError.unableToSaveObject(object) {
                        let objectTitle = object.getTitle() ?? ""
                        let title = R.Loc.unableToSaveObjectTitle
                        let message = R.Loc.unableToSaveObjectMessage(withTitle: objectTitle)
                        let alert = UIAlertController.createErrorAlert(title: title, message: message)
                        self.present(alert, animated: true)
                    } catch {
                        print(error.localizedDescription)
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

    @IBAction func recordAudio(_: UIButton) {
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
                } catch AudioRecorderServiceError.unableToConfigureRecordingSession {
                    let title = R.Loc.unableToConfigureRecordingSessionTitle
                    let message = R.Loc.unableToConfigureRecordingSessionMessage
                    let alert = UIAlertController.createErrorAlert(title: title, message: message)
                    present(alert, animated: true)
                } catch {
                    print(error.localizedDescription)
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
            } catch let FileManagerError.unableToSaveObject(object) {
                let objectTitle = object.getTitle() ?? ""
                let title = R.Loc.unableToSaveObjectTitle
                let message = R.Loc.unableToSaveObjectMessage(withTitle: objectTitle)
                let alert = UIAlertController.createErrorAlert(title: title, message: message)
                present(alert, animated: true)
            } catch {
                print(error.localizedDescription)
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
    func registerObservers() {
        let notificationCenter = NotificationCenter.default

        let sizeChangeNotification = UIContentSizeCategory.didChangeNotification
        notificationCenter.addObserver(
            self,
            selector: #selector(adaptToDynamicSizeChange),
            name: sizeChangeNotification,
            object: nil
        )
    }

    @objc func adaptToDynamicSizeChange(_: Notification) {}

    /// Set the new current project
    /// - parameter project: The project that should now be shown
    func setCurrentProject(_ project: Project) {
        currentProjectID = project.id
        currentSectionID = currentProject?.sectionIDs.first

        updateUI()
    }

    func setupUI() {
        navigationItem.leftBarButtonItem?.title = R.Loc.menu
    }

    func setEditButton() {
        navigationItem.rightBarButtonItem = currentSection?.recordings.hasElements ?? false ? editButtonItem : nil
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

        setState(state)

        pagingViewController.reloadData()

        setEditButton()
    }

    /// Set the state of the user interface
    /// - parameter state: The state that should be set
    func setState(_ state: State) {
        errorViewController?.remove()

        switch state {
        case .notEmpty:
            break
        case .noProjects:
            errorViewController = ErrorViewController(text: R.Loc.noProjects)
            if let errorViewController = errorViewController {
                add(errorViewController)
            }
        case .noSections:
            errorViewController = ErrorViewController(text: R.Loc.noSections)
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
        let administerViewController = AdministrateProjectViewController(project: project)
        administerViewController.administrateProjectDelegate = self
        let navigationController = UINavigationController(rootViewController: administerViewController)
        present(navigationController, animated: true)
    }

    /// Configure the paging view controller
    func configurePagingViewController() {
        pagingViewController.menuItemSource = .class(type: LibraryCollectionViewCell.self)
        pagingViewController.indicatorColor = R.Colors.mainColor
        pagingViewController.menuHorizontalAlignment = .center
        pagingViewController.dataSource = self
        pagingViewController.delegate = self

        // Set the size for page items
        // 65 is a bit tall for the smallest font sizes, but it doesn't break,
        // so it's fine for now.
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 150, height: 65)

        add(pagingViewController)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
        ])
    }

    /// Possibly show onboarding
    func showOnboardingIfNeeded() {
        let userDefaults = UserDefaults.standard
        let hasSeenOnboarding = userDefaults.bool(forKey: R.UserDefaults.hasSeenOnboarding)

        if !hasSeenOnboarding {
            let onboardingRootViewController = UIViewController.onboardingRootViewController()
            present(onboardingRootViewController, animated: true)
        }
    }
}

extension LibraryViewController: AdministrateProjectDelegate {
    func userDidAddSectionToProject(_ section: Section) {
        currentSectionID = section.id

        updateUI()
    }

    func userDidDeleteSectionFromProject() {
        currentSectionID = currentProject?.sectionIDs.sorted().first

        updateUI()
    }

    func userDidEditTitleOfObjects() {
        updateUI()
    }

    func userDidDeleteProject() {
        currentProjectID = databaseService.foundationStore?.projectIDs.first
        currentSectionID = currentProject?.sectionIDs.first

        updateUI()
    }

    func userDidReorderSections() {
        updateUI()
    }
}
