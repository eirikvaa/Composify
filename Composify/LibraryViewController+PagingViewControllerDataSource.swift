//
//  LibraryViewController+PagingViewControllerDataSource
//  Composify
//
//  Created by Eirik Vale Aase on 06.12.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import Parchment

extension LibraryViewController: PagingViewControllerDataSource {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T where T : PagingItem, T : Comparable, T : Hashable {
        guard let currentProject = currentProject else {
            return SectionPageItem(section: nil) as! T
        }
        
        guard let section = currentProject.sectionIDs[index].correspondingSection else {
            return SectionPageItem(section: nil) as! T
        }
        
        return SectionPageItem(section: section) as! T
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T : PagingItem, T : Comparable, T : Hashable {
        guard let currentProject = currentProject else {
            return UIViewController()
        }
        
        guard let section = currentProject.sectionIDs[index].correspondingSection else {
            return UIViewController()
        }
        
        let sectionViewController = SectionViewController(section: section)
        sectionViewController.libraryViewController = self
        
        return sectionViewController
    }
    
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int where T : PagingItem, T : Comparable, T : Hashable {
        return currentProject?.sectionIDs.count ?? 0
    }
}
