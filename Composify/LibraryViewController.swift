//
//  LibraryViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

/// The view controller for almost all of the functionality; shows projects, sections and recordings.

class LibraryViewController: UIViewController {

    // MARK: Lazy Properties
    lazy var projectCollectionViewDataSource: ProjectCollectionViewDataSource = {
        let dataSource = ProjectCollectionViewDataSource()
        dataSource.libraryViewController = self
        return dataSource
    }()
    lazy var projectCollectionViewDelegate: ProjectCollectionViewDelegate = {
        let delegate = ProjectCollectionViewDelegate()
        delegate.libraryViewController = self
        return delegate
    }()
    lazy var sectionCollectionViewDataSource: SectionCollectionViewDataSource = {
        let dataSource = SectionCollectionViewDataSource()
        dataSource.libraryViewController = self
        return dataSource
    }()
    lazy var sectionCollectionViewDelegate: SectionCollectionViewDelegate = {
        let delegate = SectionCollectionViewDelegate()
        delegate.libraryViewController = self
        return delegate
    }()
    lazy var recordingsTableDataSource: RecordingsTableViewDataSource = {
        let dataSource = RecordingsTableViewDataSource()
        dataSource.libraryViewController = self
        return dataSource
    }()
    lazy var recordingsTableViewDelegate: RecordingsTableViewDelegate = {
        let delegate = RecordingsTableViewDelegate()
        delegate.libraryViewController = self
        return delegate
    }()
    lazy var rootPageViewDelegate: RootPageViewDelegate = {
        let delegate = RootPageViewDelegate()
        delegate.libraryViewController = self
        return delegate
    }()
    lazy var rootPageViewDataSource: RootPageViewDataSource = {
        let dataSource = RootPageViewDataSource()
        dataSource.libraryViewController = self
        return dataSource
    }()
    var projects: [Project] = []
    
	// MARK: Regular Properties
    var rootPageViewController: UIPageViewController!
    let coreDataStack = CoreDataStack.sharedInstance
	private let center = NotificationCenter.default
    let pieFileManager = PIEFileManager()
    var currentProject: Project? {
        didSet {
            navigationItem.title = currentProject?.title ?? .localized(.appTitle)
			currentSection = currentProject?.sortedSections.first
        }
    }
    var currentSection: Section?
    var audioRecorder: AudioRecorder?
    var state: LibraryState = .noProjects {
        didSet {
            setState(state)
        }
    }
    
    func fetchProjects() -> [Project] {
        let fetchRequest: NSFetchRequest<Project> = NSFetchRequest(entityName: "Project")
        
        if let projects = try? coreDataStack.persistentContainer.viewContext.fetch(fetchRequest) {
            self.projects = projects
        }
        
        return projects
    }

    // MARK: @IBOutlet
    @IBOutlet weak var sectionsTitle: UILabel! {
        didSet {
            sectionsTitle.textColor = Colors.red
        }
    }
    @IBOutlet weak var projectsTitle: UILabel! {
        didSet {
            projectsTitle.textColor = Colors.red
        }
    }
    @IBOutlet var longHoldOnSectionGesture: UILongPressGestureRecognizer! {
        didSet {
            longHoldOnSectionGesture.addTarget(self, action: #selector(handleSectionsLongPress))
        }
    }
    @IBOutlet var longHoldOnProjectsGesture: UILongPressGestureRecognizer! {
        didSet {
            longHoldOnProjectsGesture.addTarget(self, action: #selector(handleProjectsLongPress))
        }
    }
    @IBOutlet weak var projectCollectionView: UICollectionView! {
        didSet {
            projectCollectionView.dataSource = projectCollectionViewDataSource
            projectCollectionView.delegate = projectCollectionViewDelegate
            projectCollectionView.allowsMultipleSelection = false

            if let flowLayout = projectCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.estimatedItemSize = CGSize(width: 100, height: 50)
            }
        }
    }
    @IBOutlet weak var sectionCollectionView: UICollectionView! {
        didSet {
            sectionCollectionView.dataSource = sectionCollectionViewDataSource
            sectionCollectionView.delegate = sectionCollectionViewDelegate
            sectionCollectionView.allowsMultipleSelection = false

            if let flowLayout = sectionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.estimatedItemSize = CGSize(width: 100, height: 50)
            }
        }
    }
    @IBOutlet weak var recordingsTableView: UITableView! {
        didSet {
            recordingsTableView.dataSource = recordingsTableDataSource
            recordingsTableView.delegate = recordingsTableViewDelegate
        }
    }
    @IBOutlet weak var recordAudioButton: UIButton! {
        didSet {
            recordAudioButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var recordAudioView: UIView!
    @IBOutlet weak var containerView: UIView!

    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        
        projects = fetchProjects()
        currentProject = projects.first

        navigationItem.rightBarButtonItem = editButtonItem
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
		
		configurePageViewController()
		
		if currentProject != nil {
			let indexPath = IndexPath(item: 0, section: 0)
			projectCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
			
			if currentSection != nil {
				sectionCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
			}
		}
        
        setEmptyState()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        rootPageViewController.viewControllers?.first?.setEditing(editing, animated: animated)
    }

    // MARK: Helper Methods
	@objc func add(sender: UIBarButtonItem) {
        var title: String? = .localized(.addProjectSectionTitle)
        if projects.count == 0 {
            title = nil
        }
        
        let mainAdd = UIAlertController(
                title: title,
                message: nil,
                preferredStyle: .actionSheet)
        let addProject = UIAlertAction(
                title: .localized(.addProject),
                style: .default) { _ in
            let addProject = UIAlertController(
                    title: .localized(.addProject),
                    message: nil,
                    preferredStyle: .alert)

            addProject.addTextField {
                $0.placeholder = .localized(.addProjectTextFieldTitle)
                $0.autocapitalizationType = .words
            }

            let done = UIAlertAction(title: .localized(.done), style: .default, handler: { _ in
                if let project = NSEntityDescription.insertNewObject(
                        forEntityName: Strings.CoreData.projectEntity,
                        into: self.coreDataStack.viewContext) as? Project,
                   let title = addProject.textFields?.first?.text {
                    project.title = title

                    self.pieFileManager.save(project)
                    self.coreDataStack.saveContext()

					self.projects = Project.retrieveCoreDataProjects()
                    self.currentProject = project
                    self.currentSection = nil

                    self.shouldRefresh(
                            projectCollectionView: true,
                            sectionCollectionView: true,
                            recordingsTableView: true)
                    self.setEmptyState()
                    self.navigationItem.title = self.currentProject?.title
					
					let lastIndex = self.projects.count - 1
					let indexPath = IndexPath(item: lastIndex, section: 0)
					self.projectCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
                }
            })
            let cancel = UIAlertAction(title: .localized(.cancel), style: .cancel, handler: nil)

            addProject.addAction(done)
            addProject.addAction(cancel)

            self.present(addProject, animated: true, completion: nil)
        }
        let addSection = UIAlertAction(title: .localized(.addSection), style: .default) { alertAction in
            let addSection = UIAlertController(title: .localized(.addSection), message: nil, preferredStyle: .alert)

            addSection.addTextField {
                $0.placeholder = .localized(.addSectionTextFieldTitle)
                $0.autocapitalizationType = .words
            }

            let done = UIAlertAction(title: .localized(.done), style: .default, handler: { alertAction in
                if let section = NSEntityDescription.insertNewObject(forEntityName: Strings.CoreData.sectionEntity, into: self.coreDataStack.viewContext) as? Section,
                   let currentProject = self.currentProject,
                   let title = addSection.textFields?.first?.text {
                    section.title = title
                    section.project = currentProject

                    self.pieFileManager.save(section)
                    self.coreDataStack.saveContext()

                    self.currentSection = section

                    if let index = self.currentProject?.sections.sorted().index(of: section),
                       let recordingViewController = self.rootPageViewDataSource.viewController(at: index, storyboard: self.storyboard!) {
                        self.rootPageViewController.setViewControllers([recordingViewController], direction: .forward, animated: false, completion: nil)
                    }

                    self.shouldRefresh(projectCollectionView: false, sectionCollectionView: true, recordingsTableView: true)
                    self.setEmptyState()
					
					if let currentProject = self.currentProject,
						let currentSection = self.currentSection,
						let index = currentProject.sortedSections.index(of: currentSection) {
						let indexPath = IndexPath(item: index, section: 0)
						self.sectionCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
					}
                }
            })
            let cancel = UIAlertAction(title: .localized(.cancel), style: .cancel, handler: nil)

            addSection.addAction(done)
            addSection.addAction(cancel)

            self.present(addSection, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: .localized(.cancel), style: .cancel, handler: nil)

        mainAdd.addAction(addProject)
        
        if projects.count > 0 {
            mainAdd.addAction(addSection)
        }
        
        mainAdd.addAction(cancel)
        
        let view = navigationItem.leftBarButtonItem?.value(forKey: Strings.KeyValues.view) as? UIView
        let frame = view?.frame
        
        // We need these two lines when the app is used on an iPad.
        mainAdd.popoverPresentationController?.sourceView = view
        mainAdd.popoverPresentationController?.sourceRect = frame ?? .zero
        
        present(mainAdd, animated: true, completion: nil)
    }
    
    @objc func handleProjectsLongPress(_ sender: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: .localized(.longPressTitle), message: nil, preferredStyle: .alert)
        
        let delete = UIAlertAction(title: .localized(.delete), style: .destructive) { _ in
            if let indexPath = self.projectCollectionView.indexPathsForSelectedItems?.first {
                let project = self.projects[indexPath.row]
                self.pieFileManager.delete(project)
                self.coreDataStack.viewContext.delete(project)
                self.projects.remove(at: indexPath.row)
                self.coreDataStack.saveContext()
                if self.projects.count == 0 { self.currentProject = nil }
                self.shouldRefresh(projectCollectionView: true, sectionCollectionView: true, recordingsTableView: true)
                
                self.setEmptyState()
            }
        }
        
        let rename = UIAlertAction(title: .localized(.rename), style: .default) { _ in
            let alertController = UIAlertController(title: .localized(.rename), message: nil, preferredStyle: .alert)
            alertController.addTextField(configurationHandler: { (textField) in
                if let indexPath = self.projectCollectionView.indexPathsForSelectedItems?.first {
                    let project = self.projects[indexPath.row]
                    textField.placeholder = project.title
                }
            })
            
            let save = UIAlertAction(title: .localized(.save), style: .default, handler: { _ in
                if let textField = alertController.textFields?.first,
                    let text = textField.text {
                    if let indexPath = self.projectCollectionView.indexPathsForSelectedItems?.first {
                        let project = self.projects[indexPath.row]
                        self.pieFileManager.rename(project, from: project.title, to: text, section: nil, project: nil)
                        project.title = text
                        self.coreDataStack.saveContext()
                        self.shouldRefresh(projectCollectionView: true, sectionCollectionView: false, recordingsTableView: false)
                    }
                }
            })
            
            let cancel = UIAlertAction(title: .localized(.cancel), style: .cancel, handler: nil)
            
            alertController.addAction(save)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: .localized(.cancel), style: .cancel, handler: nil)
        
        alert.addAction(delete)
        alert.addAction(rename)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleSectionsLongPress(_ sender: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: .localized(.longPressTitle), message: nil, preferredStyle: .alert)
        let delete = UIAlertAction(title: .localized(.delete), style: .destructive) { _ in
            if let indexPath = self.sectionCollectionView.indexPathsForSelectedItems?.first,
                let section = self.currentProject?.sortedSections[indexPath.row] {
                self.pieFileManager.delete(section)
                self.coreDataStack.viewContext.delete(section)
                self.coreDataStack.saveContext()
                if self.currentProject?.sections.count == 0 { self.currentSection = nil }
                
                if let index = self.currentProject?.sections.sorted().index(of: section),
                    let recordingViewController = self.rootPageViewDataSource.viewController(at: index, storyboard: self.storyboard!) {
                    self.rootPageViewController.setViewControllers([recordingViewController], direction: .forward, animated: false, completion: nil)
                }
                
                self.shouldRefresh(projectCollectionView: false, sectionCollectionView: true, recordingsTableView: true)
                self.setEmptyState()
                
                if let currentProject = self.currentProject,
                    let currentSection = self.currentSection,
                    let index = currentProject.sortedSections.index(of: currentSection) {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.sectionCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
                }
            }
        }
        
        let rename = UIAlertAction(title: .localized(.rename), style: .default) { _ in
            let alertController = UIAlertController(title: .localized(.rename), message: nil, preferredStyle: .alert)
            alertController.addTextField(configurationHandler: { (textField) in
                if let indexPath = self.sectionCollectionView.indexPathsForSelectedItems?.first {
                    let section = self.currentProject?.sortedSections[indexPath.row]
                    textField.placeholder = section?.title
                }
            })
            
            let save = UIAlertAction(title: .localized(.save), style: .default, handler: { _ in
                if let textField = alertController.textFields?.first,
                    let text = textField.text {
                    if let indexPath = self.sectionCollectionView.indexPathsForSelectedItems?.first {
                        if let section = self.currentProject?.sortedSections[indexPath.row] {
                            self.pieFileManager.rename(section, from: section.title, to: text, section: nil, project: nil)
                            section.title = text
                            self.coreDataStack.saveContext()
                            self.shouldRefresh(projectCollectionView: true, sectionCollectionView: true, recordingsTableView: false)
                        }
                        
                    }
                }
            })
            
            let cancel = UIAlertAction(title: .localized(.cancel), style: .cancel, handler: nil)
            
            alertController.addAction(save)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: .localized(.cancel), style: .cancel, handler: nil)
        
        alert.addAction(delete)
        alert.addAction(rename)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }

    func setEmptyState() {
        switch (currentProject, currentSection) {
        case (.some, .some):
            state = .notEmpty
       case (.some, .none):
            state = .noSections
        case (.none, .some):
            state = .noProjects
        case (.none, .none):
            state = .noProjects
        }
        
        if currentSection?.recordings.count == 0 {
            state = .noRecordings
        }
    }

    // MARK: @IBActions
    @IBAction func recordAudio(_ sender: UIButton) {
        guard let recorder = audioRecorder?.recorder else {
            if let currentProject = (rootPageViewController.viewControllers?.first as? RecordingsViewController)?.project,
               let currentSection = (rootPageViewController.viewControllers?.first as? RecordingsViewController)?.section,
               let recording = Recording.init(with: "\(currentSection.title) \(currentSection.recordings.count + 1)", section: currentSection, project: currentProject, fileExtension: .caf, insertIntoManagedObjectContext: coreDataStack.viewContext) {
                audioRecorder = AudioRecorder(url: recording.url)
                audioRecorder?.recorder.record()
                recordAudioButton.setTitle(.localized(.stopRecording), for: .normal)

                coreDataStack.saveContext()
            }

            return
        }

        recorder.stop()
        audioRecorder = nil
        recordAudioButton.setTitle(.localized(.startRecording), for: .normal)
        
        setEmptyState()

        // We refresh so that the pause button will turn to a play button.
        shouldRefresh(projectCollectionView: false, sectionCollectionView: false, recordingsTableView: true)
    }

}

extension LibraryViewController {
	func shouldRefresh(projectCollectionView: Bool, sectionCollectionView: Bool, recordingsTableView: Bool) {
		if projectCollectionView {
			self.projectCollectionView.dataSource = nil
			self.projectCollectionView.delegate = nil
			self.projectCollectionView.dataSource = projectCollectionViewDataSource
			self.projectCollectionView.delegate = projectCollectionViewDelegate
			self.projectCollectionView.reloadData()
			self.projectCollectionView.collectionViewLayout.invalidateLayout()
		}
		if sectionCollectionView {
			self.sectionCollectionView.dataSource = nil
			self.sectionCollectionView.delegate = nil
			self.sectionCollectionView.dataSource = sectionCollectionViewDataSource
			self.sectionCollectionView.delegate = sectionCollectionViewDelegate
			self.sectionCollectionView.reloadData()
			self.sectionCollectionView.collectionViewLayout.invalidateLayout()
		}
		
		if recordingsTableView {
			if let recordingsViewController = rootPageViewController.viewControllers?.first as? RecordingsViewController {
				recordingsViewController.tableView.reloadData()
			}
		}
	}
}

private extension LibraryViewController {
	func configurePageViewController() {
		rootPageViewController = UIPageViewController(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal,
			options: nil)
		rootPageViewController.dataSource = rootPageViewDataSource
		rootPageViewController.delegate = rootPageViewDelegate
		rootPageViewDelegate.libraryViewController = self
		
		let startingViewController = storyboard?.instantiateViewController(withIdentifier: Strings.StoryboardIDs.contentPageViewController) as! RecordingsViewController
		startingViewController.project = currentProject
		startingViewController.section = currentSection
		startingViewController.pageIndex = 0
		startingViewController.tableViewDelegate.libraryViewController = self
		startingViewController.tableViewDataSource.libraryViewController = self
		rootPageViewController.setViewControllers(
			[startingViewController],
			direction: .forward,
			animated: true,
			completion: nil)
		rootPageViewController.view.frame = containerView.bounds
		addChildViewController(rootPageViewController)
		containerView.addSubview(rootPageViewController.view)
		rootPageViewController.didMove(toParentViewController: self)
	}
}

extension LibraryViewController {
    typealias LibraryState = LibraryViewController.State
    
    enum State {
        case noProjects
        case noSections
        case noRecordings
        case notEmpty
    }
    
    func setState(_ state: State) {
        guard let recordingsViewController = rootPageViewController.viewControllers?.first as? RecordingsViewController else { return }
        
        let emptyStateLabel = UILabel(frame: view.frame)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        
        navigationItem.rightBarButtonItem = nil
        projectsTitle.isHidden = false
        sectionsTitle.isHidden = false
        recordAudioButton.isHidden = false
        projectCollectionView.backgroundView = nil
        sectionCollectionView.backgroundView = nil
        recordingsViewController.tableView.backgroundView = nil
        recordingsViewController.tableView.separatorStyle = .singleLine
        recordingsViewController.tableView.isHidden = false
        
        switch state {
        case .noProjects:
            projectsTitle.isHidden = true
            sectionsTitle.isHidden = true
            recordAudioButton.isHidden = true
            emptyStateLabel.text = .localized(.noProjects)
            projectCollectionView.backgroundView = emptyStateLabel
            recordingsViewController.tableView.isHidden = true
        case .noSections:
            recordAudioButton.isHidden = true
            sectionsTitle.isHidden = true
            emptyStateLabel.text = .localized(.noSections)
            sectionCollectionView.backgroundView = emptyStateLabel
            recordingsViewController.tableView.isHidden = true
        case .noRecordings:
            emptyStateLabel.text = .localized(.noRecordings)
            recordingsViewController.tableView.backgroundView = emptyStateLabel
            recordingsViewController.tableView.separatorStyle = .none
        case .notEmpty:
            navigationItem.rightBarButtonItem = editButtonItem
        }
    }
}