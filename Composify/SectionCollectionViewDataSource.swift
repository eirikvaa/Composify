//
//  SectionCollectionViewDataSource.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

class SectionCollectionViewDataSource: NSObject {
	var libraryViewController: LibraryViewController!
}

extension SectionCollectionViewDataSource: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let items = libraryViewController.currentProject?.sectionIDs else { return 0 }
		
        return items.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Strings.Cells.sectionCell, for: indexPath) as? LibraryCollectionViewCell else { return UICollectionViewCell() }
        
        cell.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        cell.titleLabel.adjustsFontForContentSizeCategory = true
        
        if let sectionID = libraryViewController.currentProject?.sectionIDs[indexPath.row] {
            let section = RealmStore.shared.realm.object(ofType: Section.self, forPrimaryKey: sectionID)
            
            if sectionID == libraryViewController.currentSectionID {
                cell.titleLabel.font = UIFont.preferredBoldFont(for: .body)
            }
            
            cell.titleLabel.text = section?.title
        }
		
		return cell		
	}
}
