//
//  TestContainer.swift
//  MuTests
//
//  Created by Vincent Young on 6/21/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import Foundation
import CoreData

class TestContainer {
    
    static var testShared = TestContainer()
    static var testMoc = testShared.persistentContainer.viewContext
    
    /*
     A test NSPersistentContainer to be used for unit testing. This container does not load any persistent stores
     */
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Mu")
        return container
    }()
    
}
