//
//  LibraryViewController+PagingViewControllerDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 09.12.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Parchment
import UIKit

extension LibraryViewController: PagingViewControllerDelegate {
    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        guard let sectionPageItem = pagingItem as? SectionPageItem else { return }
        currentSection = sectionPageItem.section

        // We might scroll to a section without recordings, so must remember to set the edit button correctly
        setEditButton()
        configurePageControl()
    }
}
