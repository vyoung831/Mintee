# Application architecture
This document outlines Mintee's code components and their integration with one another.  

# Table of Contents
1. [Application components](#application-components)
1. [Notable components](#notable-components)
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

# Notable components

## Singletons

### ThemeManager
`ThemeManager` is a class used to handle changes to the app's UI color scheme.
`ThemeManager` defines a shared instance that observes NSUserDefaults for updates to the theme. When changes are observed, the shared instance informs other objects by:
* Updating its published vars. SwiftUI components which declare the shared `ThemeManager` with the `@ObservedObject` property wrapper automatically have their views updated.
* Posting to notification center for non-SwiftUI components to observe and handle.