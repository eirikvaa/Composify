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

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, widthForPagingItem pageItem: T, isSelected _: Bool) -> CGFloat? where T: PagingItem, T: Comparable, T: Hashable {
        let item = pageItem as! SectionPageItem
        let title = item.section?.title ?? ""

        let font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let size = (title as NSString).size(withAttributes: [
            .font: font,
        ])

        // If I don't add enough margin, then the text will be truncated because the width will be too small,
        // so until I find a general solution here, this will do.
        return size.width + 50
    }
}
