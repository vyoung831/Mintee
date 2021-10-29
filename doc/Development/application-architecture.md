# Application architecture
This document outlines Mintee's code components and their integration with one another.  

# Table of Contents
1. [Application components](#application-components)
1. [Model development](#model-development)
    1. [Syncing model components with business rules](#syncing-model-components-with-business-rules)
1. [Notable components](#notable-components)
    1. [SaveFormatter](#persistent-store-data-conversion)
    1. [Singletons](#singletons)
        1. [ThemeManager](#thememanager)

# Application components
Mintee places all application code into 1 of the following 3 categories:  
1. Utility components. Stored in dirs named `utils` or their subdirs.
1. Model components. Stored in the `core-data` dir and comprised of the following:  
    1. NSManagedObject subclasses.
    1. Custom data types used as transformables.
1. View components. SwiftUI Views stored in the `views` dir.

To maintain separation of concerns, the following defines each component's responsibilities.
| Component | Responsibilities | What the component should __NEVER__ do |
|-|-|-|
| Model components | <ul> <li/> Implement and provide APIs for other components to use to execute business logic. <li/> Implement and provide APIs for other components to use to validate data against business rules. </ul> | <ul> <li/> Save or rollback MOC changes. </ul> |
| View components | <ul> <li/> Validate user input against business rules. <li/> Use model component APIs to execute business logic. <li/> Save or rollback MOC changes. </ul> | |
| Utility components | <ul> <li/> Provide helper functions. </ul> | <ul> <li/> Update the MOC. </ul> |

# Model development

__Notes__  
* To ensure that user experience of dates remain consistent across time zones, dates are stored as strings. This avoids a Date object being created and saved to user data, only to be accessed later using a different Calendar object and displaying a potentially different day.

## Syncing model components with business rules
Where appropriate, Mintee uses the Core Data model editor or generated NSManagedObject subclasses to enforce [business rules](../business-rules.md). See below:
| What the business rule states | Method of enforcing |
|-|-|
| Property is unique | Specify constraint in Core Data model editor. |
| Property is non-nil (including transformables) | Specify property as non-optional in NSManagedObject subclass. |
| To-one relationship is never nil | Specify property as non-optional in NSManagedObject subclass. |
| To-many relationship is never nil | Specify NSSet as non-optional in NSManagedObject subclass. |

# Notable components

## SaveFormatter
To maintain structured data conversion between view components, model components, and the persistent store, `SaveFormatter` defines enums for the following purposes:  
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

## Singletons

### ThemeManager
`ThemeManager` is a class used to handle changes to the app's theme (UI color scheme).
`ThemeManager` defines a shared instance that observes NSUserDefaults for updates to the theme. When changes are observed, the shared instance informs other objects by doing the following:
* Updates its published vars. SwiftUI components which declare the shared `ThemeManager` with the `@ObservedObject` property wrapper automatically have their views updated.
* Posts to notification center for non-SwiftUI components to observe and handle.