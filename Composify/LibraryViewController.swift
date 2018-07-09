//
//  LibraryViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit
import RealmSwift

/// The view controller for almost all of the functionality; shows projects, sections and recordings.

class LibraryViewController: UIViewController {

    // MARK: Stored properties
    lazy var collectionViewDataSource: SectionCollectionViewDataSource = {
        let dataSource = SectionCollectionViewDataSource()
        dataSource.libraryViewController = self
        return dataSource
    }()
    lazy var collectionViewDelegate: SectionCollectionViewDelegate = {
        let delegate = SectionCollectionViewDelegate()
        delegate.libraryViewController = self
        return delegate
    }()
    lazy var tableViewDataSource: RecordingsTableViewDataSource = {
        let dataSource = RecordingsTableViewDataSource()
        dataSource.libraryViewController = self
        return dataSource
    }()
    lazy var tableViewDelegate: RecordingsTableViewDelegate = {
        let delegate = RecordingsTableViewDelegate()
        delegate.libraryViewController = self
        return delegate
    }()
    lazy var pageViewDelegate: RootPageViewDelegate = {
        let delegate = RootPageViewDelegate()
        delegate.libraryViewController = self
        return delegate
    }()
    lazy var pageViewDataSource: RootPageViewDataSource = {
        let dataSource = RootPageViewDataSource()
        dataSource.libraryViewController = self
        return dataSource
    }()
    var pageViewController: UIPageViewController!
    let fileManager = CFileManager()
    private var projects: [Project] {
        return Project.projects()
    }
    private let center = NotificationCenter.default
    var realmStore = RealmStore.shared
    private var audioRecorder: AudioRecorder?
    let realm = try! Realm()
    var token: NotificationToken?
    var currentProject: Project? {
        didSet {
            navigationItem.title = currentProject?.title ?? .localized(.composify)
            currentSectionID = currentProject?.sectionIDs.first
        }
    }
    var currentSection: Section? {
        guard let sectionID = currentSectionID else { return nil }
        guard let section = Section.object(withID: sectionID) else { return nil }
        return section
    }
    var currentSectionID: String?
    private var state: LibraryViewController.State = .noSections {
        didSet {
            setState(state)
        }
    }
    var errorViewController: ErrorViewController?
    
    // MARK: @IBOutlet
    @IBOutlet weak var pageControl: UIPageControl! {
        didSet {
            pageControl.numberOfPages = self.projects.count
        }
    }
    @IBOutlet weak var administerBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = collectionViewDataSource
            collectionView.delegate = collectionViewDelegate
            collectionView.allowsMultipleSelection = false

            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.estimatedItemSize = CGSize(width: 100, height: 50)
            }
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = tableViewDataSource
            tableView.delegate = tableViewDelegate
        }
    }
    @IBOutlet weak var recordAudioButton: UIButton! {
        didSet {
            recordAudioButton.layer.cornerRadius = 5
            recordAudioButton.backgroundColor = Colors.secondaryColor
        }
    }
    @IBOutlet weak var recordAudioView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        currentProject = projects.first
        UserDefaults.standard.persist(project: currentProject)
        
        configurePageViewController()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: .localized(.menu), style: .plain, target: self, action: #selector(showMenu))
        
        if let firstSectionID = currentProject?.sectionIDs.first,
            let section = Section.object(withID: firstSectionID) {
            navigationItem.rightBarButtonItem = section.recordings.isEmpty == true ? nil : editButtonItem
        }
        
        self.updateUI()
        
        token = realm.observe { _, _ in
            self.currentProject = self.projects.first
            
            DispatchQueue.main.async {
                if let viewController = self.pageViewDataSource.viewController(at: 0, storyboard: self.storyboard!) {
                    self.pageViewController.setViewControllers([viewController], direction: .forward, animated: false)
                }
                
                self.updateUI()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = self.currentProject?.title ?? .localized(.composify)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserDefaults.standard.persist(project: self.currentProject)
    }
    
    deinit {
        UserDefaults.standard.persist(project: self.currentProject)
        token?.invalidate()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        pageViewController.viewControllers?.first?.setEditing(editing, animated: animated)
    }
}

// MARK: @IBAction

extension LibraryViewController {
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        var administrate: UIAlertAction?
        let alert = UIAlertController(title: .localized(.menu), message: nil, preferredStyle: .actionSheet)
        if let currentProject = currentProject {
            administrate = UIAlertAction(title: .localized(.administrateProject), style: .default) { _ in
                let administerVC = AdministrateProjectTableViewController()
                administerVC.currentProject = currentProject
                let nav = UINavigationController(rootViewController: administerVC)
                self.present(nav, animated: true)
            }
        }
        
        let addProject = UIAlertAction(title: .localized(.addProject), style: .default) { _ in
            let addProjectAlert = UIAlertController(title: .localized(.addProject), message: nil, preferredStyle: .alert)
            addProjectAlert.addTextField { textField in
                textField.autocapitalizationType = .words
                textField.placeholder = .localized(.projectTitle)
                textField.returnKeyType = .done
                textField.clearButtonMode = .whileEditing
            }
            let save = UIAlertAction(title: .localized(.save), style: .default, handler: { _ in
                if let projectTitle = addProjectAlert.textFields?.first?.text {
                    
                    let project = Project()
                    project.title = projectTitle
                    self.currentProject = project
                    
                    self.realmStore.save(project)
                    self.fileManager.save(project)
                    
                    self.updateUI()
                }
            })
            let cancel = UIAlertAction(title: .localized(.cancel), style: .cancel)
            addProjectAlert.addAction(save)
            addProjectAlert.addAction(cancel)
            
            self.present(addProjectAlert, animated: true)
        }
        
        projects.forEach { project in
            let projectAction = UIAlertAction(title: String.localizedStringWithFormat(.localized(.showProject), project.title), style: .default) { _ in
                self.currentProject = project
                
                UserDefaults.standard.persist(project: self.currentProject)
                
                if let viewController = self.pageViewDataSource.viewController(at: 0, storyboard: self.storyboard!) {
                    self.pageViewController.setViewControllers([viewController], direction: .forward, animated: false)
                }
                
                self.updateUI()
            }
            alert.addAction(projectAction)
        }
        
        let cancel = UIAlertAction(title: .localized(.cancel), style: .cancel)
        if let administrate = administrate {
            alert.addAction(administrate)
        }
        alert.addAction(addProject)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    @IBAction func recordAudio(_ sender: UIButton) {
        defer {
            self.updateUI()
        }
        
        guard let recorder = audioRecorder?.recorder else {
            guard let recordingsViewController = pageViewController.viewControllers?.first as? RecordingsViewController
                else { return }
            guard let currentProject = recordingsViewController.project else { return }
            guard let currentSection = recordingsViewController.section else { return }
            
            let recording = Recording()
            recording.project = currentProject
            recording.section = currentSection
            recording.fileExtension = "caf"
            fileManager.save(recording)
            audioRecorder = AudioRecorder(url: recording.url)
            audioRecorder?.recorder.record()
            recordAudioButton.setTitle(.localized(.stopRecording), for: .normal)
            realmStore.save(recording)
            return
        }
        
        recorder.stop()
        audioRecorder = nil
        recordAudioButton.setTitle(.localized(.startRecording), for: .normal)
    }
}

extension LibraryViewController {
    func updateUI() {
        // Refresh collection view
        collectionView.dataSource = nil
        collectionView.delegate = nil
        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = collectionViewDelegate
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        
        // Refresh table view
        if let recordingsViewController = pageViewController.viewControllers?.first as? RecordingsViewController {
            recordingsViewController.tableView.reloadData()
        }
        
        switch (currentProject, currentSection) {
        case (.some, .some):
            state = .notEmpty
        case (.some, .none):
            state = .noSections
        case (.none, _):
            state = .noProjects
        }
    }
    
    enum State {
        case noProjects
        case noSections
        case notEmpty
    }
    
    func setState(_ state: State) {
        navigationItem.rightBarButtonItem = nil
        pageControl.numberOfPages = currentProject?.sections.count ?? 0
        errorViewController?.remove()
        
        switch state {
        case .notEmpty:
            navigationItem.rightBarButtonItem = editButtonItem
        case .noProjects:
            errorViewController = ErrorViewController(labelText: .localized(.noProjects))
            if let errorViewController = errorViewController {
                add(errorViewController)
            }
        case .noSections:
            errorViewController = ErrorViewController(labelText: .localized(.noSections))
            if let errorVieController = errorViewController {
                add(errorVieController)
            }
        }
    }
}

private extension LibraryViewController {
	func configurePageViewController() {
		pageViewController = UIPageViewController(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal,
			options: nil)
		
        pageViewController.dataSource = pageViewDataSource
		pageViewController.delegate = pageViewDelegate
		pageViewDelegate.libraryViewController = self
		
        guard let startingViewController = storyboard?.instantiateViewController(withIdentifier: Strings.StoryboardIDs.contentPageViewController) as? RecordingsViewController else { return }
        
        startingViewController.project = currentProject
        startingViewController.section = currentSection
        startingViewController.pageIndex = 0
        startingViewController.tableViewDelegate.libraryViewController = self
        startingViewController.tableViewDataSource.libraryViewController = self
        pageViewController.setViewControllers(
            [startingViewController],
            direction: .forward,
            animated: true,
            completion: nil)
        
        pageViewController.view.frame = containerView.bounds
        addChildViewController(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
	}
}
