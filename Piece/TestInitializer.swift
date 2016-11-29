//
//  TestInitializer.swift
//  Piece
//
//  Created by Eirik Vale Aase on 13.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import CoreData

struct TestInitializer {
	
	private(set) var active = false
	private var arguments = [String]()
	private(set) var project: Project!
	private(set) var section: Section!
	
	init(arguments: [String]) {
		self.arguments = arguments
	}
	
	mutating func setupTestingMode() {
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
			projects = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest) as! [Project]
		} catch {
			print(error.localizedDescription)
		}
		
		for project in projects {
			PIEFileManager().delete(project)
			CoreDataStack.sharedInstance.persistentContainer.viewContext.delete(project)
		}
		
	}
	
	mutating private func addProject() {
		project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: CoreDataStack.sharedInstance.persistentContainer.viewContext) as! Project
		project.title = "Something New"
		PIEFileManager().save(project)
		CoreDataStack.sharedInstance.saveContext()
	}
	
	mutating private func addProjectAndSection() {
		project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: CoreDataStack.sharedInstance.persistentContainer.viewContext) as! Project
		project.title = "Something New"
		PIEFileManager().save(project)
		section = NSEntityDescription.insertNewObject(forEntityName: "Section", into: CoreDataStack.sharedInstance.persistentContainer.viewContext) as! Section
		section.title = "Intro"
		section.project = project
		PIEFileManager().save(section)
		CoreDataStack.sharedInstance.saveContext()
	}
}
