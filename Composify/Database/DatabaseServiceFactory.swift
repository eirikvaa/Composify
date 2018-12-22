//
//  DatabaseServiceFactory.swift
//  Composify
//
//  Created by Eirik Vale Aase on 12.07.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// The class that returns the database service implementation.
/// If we every need to use another database, we just implement the
/// interface `DatabaseService` and return a different `defaultService()`
/// here. It's awesome.
class DatabaseServiceFactory {
    static var defaultService: DatabaseService {
        return RealmDatabaseService.defaultService
    }
}
