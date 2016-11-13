//
//  TestInitializer.swift
//  Piece
//
//  Created by Eirik Vale Aase on 13.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import CoreData

class TestInitializer {
	
	private(set) var active = false
	private var arguments = [String]()
	
	init(arguments: [String]) {
		self.arguments = arguments
	}
	
	func setupTestingMode() {
		if arguments.contains("UI_TEST_MODE_PROJECTS") {
			active = true
			reset()
		} else if arguments.contains("UI_TEST_MODE_SECTIONS") {
			active = true
			reset()
			addProject()
		} else if arguments.contains("UI_TEST_MODE_RECORDINGS") {
			active = true
			reset()
			addProjectAndSection()
		}
	}
		
	func reset() {
		let fetchRequest = Project.fetchRequest()
		var projects = [Project]()
		
		do {
			projects = try CoreDataStack.sharedInstance.managedContext.fetch(fetchRequest) as! [Project]
		} catch {
			print(error.localizedDescription)
		}
		
		for project in projects {
			PIEFileManager().delete(project)
			CoreDataStack.sharedInstance.managedContext.delete(project)
		}
		
	}
	
	private func addProject() {
		let project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: CoreDataStack.sharedInstance.managedContext) as! Project
		project.title = "Something New"
		PIEFileManager().save(project)
		CoreDataStack.sharedInstance.saveContext()
	}
	
	private func addProjectAndSection() {
		let project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: CoreDataStack.sharedInstance.managedContext) as! Project
		project.title = "Something New"
		PIEFileManager().save(project)
		let section = NSEntityDescription.insertNewObject(forEntityName: "Section", into: CoreDataStack.sharedInstance.managedContext) as! Section
		section.title = "Intro"
		section.project = project
		PIEFileManager().save(section)
		CoreDataStack.sharedInstance.saveContext()
	}
}
