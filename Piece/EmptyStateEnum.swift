//
//  EmptyStateEnum.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

/// Enum handling the empty state of the library portion of the application. Configures the view accordingly based on the case.
enum LibraryState {
	case noProjects
	case noSections
	case notEmpty
	
	func setState(in libraryViewController: LibraryViewController) {
		let emptyStateLabel = UILabel(frame: libraryViewController.projectCollectionView.frame)
		emptyStateLabel.textAlignment = .center
		emptyStateLabel.numberOfLines = 0
		
		var hideProjects = false,
			hideSections = false,
			hideRecordings = false,
			hideRecordButton = false,
			hideRecordView = false,
			removeProjectsEmptyLabel = false,
			removeSectionsEmptyLabel = false
		
		switch self {
		case .noProjects:
			hideProjects = true
			hideSections = true
			hideRecordings = true
			removeSectionsEmptyLabel = true
		case .noSections:
			hideRecordButton = true
			hideRecordView = true
			hideRecordings = true
			removeProjectsEmptyLabel = true
		case .notEmpty:
			removeProjectsEmptyLabel = true
			removeSectionsEmptyLabel = true
		}
		
		libraryViewController.projectCollectionView.isHidden = hideProjects
		libraryViewController.sectionCollectionView.isHidden = hideSections
		libraryViewController.recordAudioView.isHidden = hideRecordView
		libraryViewController.recordAudioButton.isHidden = hideRecordButton
		
		if removeProjectsEmptyLabel {
			libraryViewController.projectCollectionView.backgroundView = nil
		} else {
			libraryViewController.projectCollectionView.reloadData()
			emptyStateLabel.text = NSLocalizedString("You have no projects. Try adding one.", comment: "")
			libraryViewController.projectCollectionView.backgroundView = emptyStateLabel
		}
		
		if removeSectionsEmptyLabel {
			libraryViewController.sectionCollectionView.backgroundView = nil
		} else {
			libraryViewController.sectionCollectionView.reloadData()
			emptyStateLabel.text = NSLocalizedString("You have no sections. Try adding one.", comment: "")
			libraryViewController.sectionCollectionView.backgroundView = emptyStateLabel
		}
		
		if let recordingViewController = libraryViewController.rootPageViewController.viewControllers?.first as? RecordingsViewController {
			recordingViewController.tableView.isHidden = hideRecordings
		}
	}
}
