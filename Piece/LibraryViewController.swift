//
//  LibraryViewController.swift
//  Piece
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
	lazy var projects: [Project] = {
		return Project.retrieveCoreDataProjects()
	}()
	
	// MARK: Regular Properties
    var rootPageViewController: UIPageViewController!
    let coreDataStack = CoreDataStack.sharedInstance
	private let center = NotificationCenter.default
    let pieFileManager = PIEFileManager()
    var currentProject: Project? {
        didSet {
            let name = Notification.Name(rawValue: PieceNotifications.PickedProjectNotification)
            center.post(Notification(name: name))
			navigationItem.title = currentProject?.title ?? NSLocalizedString("Piece", comment: "Piece title")
			currentSection = currentProject?.sections.sorted().first
        }
    }
    var currentSection: Section? {
        didSet {
            let name = Notification.Name(rawValue: PieceNotifications.PickedSectionNotification)
            center.post(Notification(name: name))
        }
    }
	
    var audioRecorder: AudioRecorder?
    var state: LibraryState = .noProjects {
        didSet {
            state.setState(in: self)
        }
    }

    // MARK: @IBOutlet
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
    @IBOutlet weak var recordAudioButton: UIButton!
    @IBOutlet weak var recordAudioView: UIView!
    @IBOutlet weak var containerView: UIView!

    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        currentProject = projects.first
		
		rootPageViewDelegate.delegate = sectionCollectionViewDelegate

        navigationItem.rightBarButtonItem = editButtonItem
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
		
		configurePageViewController()

        // This must come last because it uses the page view controller.
        setEmptyState()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        rootPageViewController.viewControllers?.first?.setEditing(editing, animated: animated)
    }

    // MARK: Helper Methods
	@objc func add(sender: UIBarButtonItem) {
        let mainAdd = UIAlertController(
                title: NSLocalizedString("Add project or section", comment: ""),
                message: nil,
                preferredStyle: .actionSheet)
        let addProject = UIAlertAction(
                title: NSLocalizedString("Add project", comment: ""),
                style: .default) { _ in
            let addProject = UIAlertController(
                    title: NSLocalizedString("Add project", comment: ""),
                    message: nil,
                    preferredStyle: .alert)

            addProject.addTextField {
                $0.placeholder = NSLocalizedString("New project title", comment: "")
                $0.autocapitalizationType = .words
            }

            let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { _ in
                if let project = NSEntityDescription.insertNewObject(
                        forEntityName: "Project",
                        into: self.coreDataStack.viewContext) as? Project,
                   let title = addProject.textFields?.first?.text {
                    project.title = title

                    self.pieFileManager.save(project)
                    self.coreDataStack.saveContext()

                    self.currentProject = project
                    self.projects = Project.retrieveCoreDataProjects()
                    self.currentSection = nil

                    self.shouldRefresh(
                            projectCollectionView: true,
                            sectionCollectionView: true,
                            recordingsTableView: true)
                    self.setEmptyState()
                    self.navigationItem.title = self.currentProject?.title
                }
            })
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

            addProject.addAction(done)
            addProject.addAction(cancel)

            self.present(addProject, animated: true, completion: nil)
        }
        let addSection = UIAlertAction(title: NSLocalizedString("Add section", comment: ""), style: .default) { alertAction in
            let addSection = UIAlertController(title: NSLocalizedString("Add section", comment: ""), message: nil, preferredStyle: .alert)

            addSection.addTextField {
                $0.placeholder = NSLocalizedString("New section title", comment: "")
                $0.autocapitalizationType = .words
            }

            let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { alertAction in
                if let section = NSEntityDescription.insertNewObject(forEntityName: "Section", into: self.coreDataStack.viewContext) as? Section,
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
                }
            })
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

            addSection.addAction(done)
            addSection.addAction(cancel)

            self.present(addSection, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

        mainAdd.addAction(addProject)
        mainAdd.addAction(addSection)
        mainAdd.addAction(cancel)

        present(mainAdd, animated: true, completion: nil)
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
    }

    // MARK: @IBActions
    @IBAction func recordAudio(_ sender: UIButton) {
        guard let recorder = audioRecorder?.recorder else {
            if let currentProject = (rootPageViewController.viewControllers?.first as? RecordingsViewController)?.project,
               let currentSection = (rootPageViewController.viewControllers?.first as? RecordingsViewController)?.section,
               let recording = Recording.init(with: "\(currentSection.title) \(currentSection.recordings.count + 1)", section: currentSection, project: currentProject, fileExtension: .caf, insertIntoManagedObjectContext: coreDataStack.viewContext) {
                audioRecorder = AudioRecorder(url: recording.url)
                audioRecorder?.recorder.record()
                recordAudioButton.setTitle(NSLocalizedString("Stop recording", comment: ""), for: .normal)

                coreDataStack.saveContext()
            }

            return
        }

        recorder.stop()
        audioRecorder = nil
        recordAudioButton.setTitle(NSLocalizedString("Start recording", comment: ""), for: .normal)

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
		
		let startingViewController = storyboard?.instantiateViewController(withIdentifier: "contentPageViewController") as! RecordingsViewController
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
