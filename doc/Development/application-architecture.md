# Application architecture
This document outlines Mintee's code components and their integration with one another.  

# Table of Contents
1. [Application components](#application-components)
1. [Model development](#model-development)
    1. [Transformables](#transformables)
1. [View development](#view-development)
    1. [Usability/UX](#usabilityux)
    1. [Navigation](#navigation)
    1. [Accessibility](#accessibility)
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
1. View components. Stored in the `views` dir and comprised of the following:  
    1. SwiftUI Views.
    1. UIKit components:  
        1. UIViewController subclasses.
        1. UIView subclasses.
    1. SwiftUI/UIKit bridging components:  
        1. UIViewControllerRepresentable subclasses.
        1. UIHostingController subclasses.

To maintain separation of concerns between view, model, and utility components, the following table illustrates each component's responsibilities.
| Component | Responsibilities | What the component should __NEVER__ do |
|-|-|-|
| Model components | <ul> <li/> Implement and provide APIs for other components to use to execute business logic. <li/> Implement and provide APIs for other components to use to validate data against business rules. </ul> | <ul> <li/> Save or rollback MOC changes. </ul> |
| View components | <ul> <li/> Validate user input against business rules. <li/> Use model component APIs to execute business logic. <li/> Save or rollback MOC changes. </ul> | |
| Utility components | <ul> <li/> Provide helper functions. </ul> | <ul> <li/> Update the MOC. </ul> |

# Model development

__Notes__  
* To ensure that user experience of dates remain consistent across time zones, dates are stored as strings. This avoids a Date object being created and saved to user data, only to be accessed later using a different Calendar object and displaying a potentially different day.

## Transformables
Mintee uses transformables to represent various custom objects. To allow for secure reading from persistent store, the following are implemented for each transformable:  
* The custom class is updated to conform to `NSSecureCoding`.
* The custom class is specified under the transformable's attributes in the Core Data model, allowing Core Data codegen to automatically protect against object substitution.
* A custom transformer is subclassed from `NSSecureUnarchiveFromDataTransformer` and specified under the transformable's attributes in the Core Data model. The custom transformer does the following:  
    * Includes the `@objc` attribute in order to be accessible to the objective-C runtime and to Core Data.
    * Includes the custom class in its allowed top-level classes.
* SceneDelegate is updated to register the custom transformer before initializing the persistent container.  

More on transformable properties [here](https://www.kairadiagne.com/2020/01/13/nssecurecoding-and-transformable-properties-in-core-data.html).

# View development

## Usability/UX
In following the scenarios, the keyboard must be dimissed:
- A button is tapped that presents a new modal or popover.
- A button is tapped that dismisses the current modal or popover.
- A tap is registered outside of the control that activated the keyboard. Ex: A tap is registered in the ScrollView of `AddTask`.

## Navigation
To prepare for additional navigation and ensure consistent UI, every SwiftUI View in Mintee declares a `NavigationView`.

## Accessibility
Accessibility is only used for identifying UI elements for UI testing.  
To ensure consistent user experience and test coverage, Mintee doesn't currently use any accessibility attributes other than identifiers.

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