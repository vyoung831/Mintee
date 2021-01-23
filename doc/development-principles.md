# Development Principles
This document outlines the development principles that Mu adheres to in implementing application code.  
The following acronyms/definitions are used as follows in this document:  
* __MOC__: NSManagedObjectContext

# Table of Contents
1. [Application components](#application-components)
1. [Application architecture](#application-architecture)
    1. [Component responsibilities](#component-responsibilities)
    1. [Persistent store data conversion](#persistent-store-data-conversion)
1. [TDD](#tdd)

# Application components
Mu places all application code into 1 of the following 3 categories:  
1. Utility components. Stored in dirs named `utils` or their subdirs.
1. Model components. Stored in the `core-data` dir and comprised of the following:  
    1. NSManagedObject subclasses.
    1. Custom data types used as transformables.
1. View components. Stored in the `views` dir and comprised of the following:  
    1. SwiftUI Views.
    1. UIKit components (to be migrated to SwiftUI):  
        1. UIViewController subclasses.
        1. UIView subclasses.
    1. SwiftUI/UIKit bridging components (to be migrated to SwiftUI):  
        1. UIViewControllerRepresentable subclasses.
        1. UIHostingController subclasses.

# Application architecture

## Component responsibilities
To maintain separation of concerns between view, model, and utility components, the following table illustrates each component's responsibilities.
| Component | Responsibilities | What the component should __NEVER__ do |
|-|-|-|
| Model components | <ul> <li/> Implement and provide APIs for other components to use to execute business logic. <li/> Implement and provide APIs for other components to use to validate data against business rules. </ul> | |
| View components | <ul> <li/> Provide UI for data presentation and user input. <li/> Validate user input against business rules. <li/> Format user input to pass to model component APIs (see [data conversion](#persistent-store-data-conversion)). <li/> Use model component APIs to execute business logic. <li/> Commit or rollback MOC changes based on results of calls to model components' APIs. </ul> | <ul> <li/> Manipulate the persistent store. </ul> |
| Utility components | <ul> <li/> Provide helper functions for other components. </ul> | <ul> <li/> Manipulate the persistent store. </ul> |

## Persistent store data conversion
To maintain structured data conversion between view components, model components, and the persistent store. Mu implements `SaveFormatter`, which defines enums for the following purposes:  
* Restrict the persistent store format of data attributes to the range of possible values that business rules define.  
* Ensure that view components can restrict user input to values that can be converted to persistent store format. Removes need for additional validation by model components.

For each type that is defined in `SaveFormatter`, functions are implemented that provide the following functionality:  
* Convert data from persistent store format to enums (`storedTo*()` functions).
* Convert enums to persistent store save format (`*toStored()` functions).
* (As needed) Provide different formats for presentation by view components.

The following code blocks illustrate examples of the intended usage of `SaveFormatter` in converting data between model and view components.
```
// NSManagedObject subclass
func saveToStore(userVar: SaveFormatter.someEnum) {
    self.property = SaveFormatter.someEnumToStored(userVar)
}
```
```
// FetchRequest handled in view component
var userVar: SaveFormatter.someEnum
func readFromStore() {
    guard let memoryFormat = SaveFormatter.storedToEnum(modelObject.property) else {
        // Handle error
    }
    userVar = memoryFormat
}
```

# TDD
To ensure quality AUT coverage, Mu adheres to the following guidelines when breaking components into as many testable functions as needed:  
* View components break closure code into as many public helper functions as ideal. Where needed, helper functions are declared as static to avoid breaking the view components themselves.
* Model and utility components balance public functions and private helper functions as needed.