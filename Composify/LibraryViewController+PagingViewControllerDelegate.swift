//
//  LibraryViewController+PagingViewControllerDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 09.12.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit
import Parchment

extension LibraryViewController: PagingViewControllerDelegate {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
        guard let sectionPageItem = pagingItem as? SectionPageItem else { return }
        currentSectionID = sectionPageItem.section?.id
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, widthForPagingItem pagingItem: T, isSelected: Bool) -> CGFloat? where T : PagingItem, T : Comparable, T : Hashable {
        let fullWidth = view.frame.width
        guard let sectionIDs = currentProject?.sectionIDs, sectionIDs.hasElements else {
            return fullWidth
        }
        return fullWidth / CGFloat(sectionIDs.count)
    }
}
