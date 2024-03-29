//
//  TestContainer.swift
//  SharedTestUtils
//
//  Created by Vincent Young on 1/3/21.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

@testable import Mintee
import Foundation
import CoreData

public class TestContainer {
    
    static var testShared = TestContainer()
    static var testMoc = testShared.persistentContainer.viewContext
    
    public static func setUpTestContainer() {
        CDCoordinator.moc = TestContainer.testMoc
    }
    
    public static func tearDownTestContainer() {
        MOC_Validator.validate()
        CDCoordinator.moc.rollback()
    }
    
    /*
     A test NSPersistentContainer that saves to an in-memory store and who's MOC is used for unit testing.
     To avoid having multiple NSEntityDescriptions of the same NSManagedObject, this var uses the NSManagedObjectModel that CDCoordinator's static shared container had already loaded and registered
     */
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let mom = CDCoordinator.shared.persistentContainer.managedObjectModel
        let container = NSPersistentCloudKitContainer(name: "Mintee", managedObjectModel: mom)
        
        container.persistentStoreDescriptions.first?.type = NSInMemoryStoreType
        container.loadPersistentStores(completionHandler: { description, error in
            if error != nil {
                print(error.debugDescription)
            }
        })
        
        return container
    }()
    
}
