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
    func pagingViewController<T>(_: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController _: UIViewController?, destinationViewController _: UIViewController, transitionSuccessful _: Bool) where T: PagingItem, T: Comparable, T: Hashable {
        guard let sectionPageItem = pagingItem as? SectionPageItem else { return }
        currentSectionID = sectionPageItem.section?.id
        
        // We might scroll to a section without recordings, so must remember to set the edit button correctly
        setEditButton()
    }
}
