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
        guard let items = libraryViewController.currentProject?.sections.sorted() else { return 0 }
		
        return items.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Strings.Cells.sectionCell, for: indexPath) as! LibraryCollectionViewCell
        
        cell.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        cell.titleLabel.adjustsFontForContentSizeCategory = true
        
        if let sectionID = libraryViewController.currentProject?.sectionIDs[indexPath.row] {
            let section = RealmStore.shared.realm.object(ofType: Section.self, forPrimaryKey: sectionID)
            cell.titleLabel.text = section?.title
        }
		
		return cell		
	}
}
