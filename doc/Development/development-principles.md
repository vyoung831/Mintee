# Development Principles
This document outlines the development principles that Mu adheres to in implementing application code.  

# Table of Contents
1. [Application components](#application-components)
1. [Model development](#model-development)
1. [View development](#view-development)
    1. [Navigation](#navigation)
    1. [Accessibility](#accessibility)
1. [Notable components](#notable-components)
    1. [SaveFormatter](#persistent-store-data-conversion)
    1. [Singletons](#singletons)
        1. [ThemeManager](#thememanager)

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

To maintain separation of concerns between view, model, and utility components, the following table illustrates each component's responsibilities.
| Component | Responsibilities | What the component should __NEVER__ do |
|-|-|-|
| Model components | <ul> <li/> Implement and provide APIs for other components to use to execute business logic. <li/> Implement and provide APIs for other components to use to validate data against business rules. </ul> | |
| View components | <ul> <li/> Provide UI for data presentation and user input. <li/> Validate user input against business rules. <li/> Format user input to pass to model component APIs (see [SaveFormatter](#saveformatter)). <li/> Use model component APIs to execute business logic. <li/> Commit or rollback MOC changes based on results of calls to model components' APIs. </ul> | <ul> <li/> Update the MOC (except for instantiating NSManagedObjects and calling model component functions). </ul> |
| Utility components | <ul> <li/> Provide helper functions for other components. </ul> | <ul> <li/> Update the MOC. </ul> |

# Model development

__Notes__  
* To ensure that user experience of dates remain consistent across time zones, dates are stored as strings. This avoids a Date object being created and saved to user data, only to be accessed later using a different Calendar object and displaying a potentially different day.

# View development

## Navigation
Every view in Mu declares a `NavigationView` to prepare for additional navigation if decided upon by UI/UX.

## Accessibility
Accessibility is only used for identifying UI elements for UI testing.  
To ensure consistent user experience and test coverage, Mu doesn't currently use any accessibility attributes other than identifiers.

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