//
//  ProjectCollectionViewDataSourceDelegate.swift
//  Piece
//
//  Created by Eirik Vale Aase on 13.01.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

class ProjectCollectionViewDataSource: NSObject {
	var libraryViewController: LibraryViewController!
}

extension ProjectCollectionViewDataSource: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return libraryViewController.projects.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectCell", for: indexPath) as! LibraryCollectionViewCell
		
		cell.titleLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)

		cell.titleLabel.text = libraryViewController.projects[indexPath.row].title

		return cell
	}
}

