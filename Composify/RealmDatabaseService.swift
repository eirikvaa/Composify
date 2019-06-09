//
//  RealmDatabaseService.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16.06.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

struct RealmDatabaseService: DatabaseService {
    private init() {}
    static var sharedInstance: DatabaseService?
    static var defaultService: DatabaseService {
        if sharedInstance == nil {
            sharedInstance = RealmDatabaseService()
        }

        return sharedInstance!
    }

    func save(_ object: ComposifyObject) {
        let realm = try! Realm()

        try! realm.write {
            switch object {
            case let section as Section:
                saveSection(section)
            case let recording as Recording:
                saveRecording(recording)
            default:
                break
            }

            if let realmObject = object as? Object {
                realm.add(realmObject, update: true)
            }
        }
    }

    func delete(_ object: ComposifyObject) {
        let realm = try! Realm()

        try! realm.write {
            switch object {
            case let project as Project:
                deleteProject(project)
            case let section as Section:
                deleteSection(section)
            case let recording as Recording:
                deleteRecording(recording)
            default:
                break
            }
        }
    }

    func rename(_ object: ComposifyObject, to newName: String) {
        let realm = try! Realm()

        try! realm.write {
            switch object {
            case let project as Project:
                project.title = newName
            case let section as Section:
                section.title = newName
            case let recording as Recording:
                recording.title = newName
            default:
                break
            }
        }
    }

    func performOperation(_ operation: () -> Void) {
        let realm = try! Realm()

        try! realm.write {
            operation()
        }
    }

    func objects(ofType type: ComposifyObject.Type) -> [ComposifyObject] {
        let realm = try! Realm()

        switch type {
        case is Project.Type:
            return Array(realm.objects(Project.self)) as [ComposifyObject]
        case is Section.Type:
            return Array(realm.objects(Section.self)) as [ComposifyObject]
        case is Recording.Type:
            return Array(realm.objects(Recording.self)) as [ComposifyObject]
        default:
            fatalError("Not supported!")
        }
    }
}

private extension RealmDatabaseService {
    func saveRecording(_ recording: Recording) {
        recording.section?.recordingIDs.append(recording.id)
    }

    func saveSection(_ section: Section) {
        section.project?.sectionIDs.append(section.id)
    }

    func deleteProject(_ project: Project) {
        let realm = try! Realm()

        project.sectionIDs
            .compactMap { realm.object(ofType: Section.self, forPrimaryKey: $0) }
            .forEach {
                realm.delete($0.recordings)
                realm.delete($0)
            }
        realm.delete(project)
    }

    func deleteSection(_ section: Section) {
        let realm = try! Realm()

        if let index = section.project?.sectionIDs.index(of: section.id) {
            section.project?.sectionIDs.remove(at: index)
        }
        realm.delete(section.recordings)
        realm.delete(section)
    }

    func deleteRecording(_ recording: Recording) {
        let realm = try! Realm()

        if let index = recording.section?.recordingIDs.index(of: recording.id) {
            recording.section?.recordingIDs.remove(at: index)
        }
        realm.delete(recording)
    }
}
