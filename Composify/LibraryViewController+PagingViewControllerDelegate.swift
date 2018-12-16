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
    }

    func pagingViewController<T>(_: PagingViewController<T>, widthForPagingItem _: T, isSelected _: Bool) -> CGFloat? where T: PagingItem, T: Comparable, T: Hashable {
        let widthPerItem: CGFloat = 100
        let count = CGFloat(currentProject?.sections.count ?? 0)

        // Avoid having too small page items by constraining the width to 100 when the count is too high
        if widthPerItem * count > view.frame.width {
            return widthPerItem
        }

        return view.frame.width / CGFloat(count)
    }
}
