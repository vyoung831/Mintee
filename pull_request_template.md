# Description

### Type of change
- [ ] New feature
- [ ] Technical debt or bug fix
- [ ] Documentation update

### Notes

# [Application architecture checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/application-architecture.md)
- [ ] Model, view, and utility components maintain separation of concerns.

| Area | N/A | Checks |
|-|-|-|
|__Model components - Business rules syncing__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] Changes to any of the following include appropriate updates to [business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md):<ul><li/>- [ ] The data model<li/>- [ ] NSManagedObject subclasses<li/>- [ ] Transformables used by NSManagedObject subclasses</ul><li>- [ ] New/updated business rules that include any of the following include [appropriate](https://github.com/vyoung831/Mintee/blob/master/doc/Development/application-architecture.md#syncing-model-and-objects-with-business-rules) updates to the Core Data model or NSManagedObject subclasses:<ul><li/>Property is unique<li/>Property is non-nil (including transformables)<li/>To-one relationship is never nil<li/>To-many relationship is never nil</ul></ul>|

## View components
- [ ] __Keyboard usability:__ Displayed keyboards are dismissed when the following occurs:
    - A button is tapped that presents a new modal or popover.
- [ ] __Navigation:__ Every new/updated SwiftUI View declares a `NavigationView` in its body (to prepare for additional navigation and ensure consistent UI).
- [ ] __Accessibility:__ View components use accessibility for UIT identification __only__.

## Transformables (more on transformable security [here](https://www.kairadiagne.com/2020/01/13/nssecurecoding-and-transformable-properties-in-core-data.html))
- [ ] __Security:__ For new/updated Transformables, the following are true for the custom classes that back it:
    - The custom class is updated to conform to `NSSecureCoding`.
    - The custom class is specified under the transformable's attributes in the Core Data model, allowing Core Data codegen to automatically protect against object substitution.
    - A custom transformer is subclassed from `NSSecureUnarchiveFromDataTransformer` and specified under the transformable's attributes in the Core Data model. The custom transformer does the following:  
        * Includes the `@objc` attribute in order to be accessible to the objective-C runtime and to Core Data.
        * Includes the custom class in its allowed top-level classes.
    - SceneDelegate is updated to register the custom transformer before initializing the persistent container.  

# [Failure handling](https://github.com/vyoung831/Mintee/blob/master/doc/Development/failure-handling-and-error-reporting.md)

## General failure handling
- [ ] No fatal errors are introduced to the code.

## Error reporting responsibilities
- [ ] Functions that do any of the following report an error to Crashlytics using `ErrorManager`.
    - Calls a non-Mintee function that returns a failure. ex: Catching an error when saving an NSManagedObjectContext.
    - Directly manipulates/accesses/converts model data. ex:
        - Throwing getters in NSManagedObject subclasses.
- [ ] New/updated functions that call a failable function re-throw the error unless returning optional for a SwiftUI View to use. Only one error is reported to crashlytics for each call stack that finds an error.

## Failure handling by Views
- [ ] New `if let` code is avoided, except when Views check for optional returns.
- [ ] The following are true for new/updated Views:
    - Views do not directly report errors to Crashlytics.
    - When accessing optional data or calling throwing functions, View components use helper functions that report the error.  
    - Where appropriate, Views post to NotificationCenter to alert the user of an error.  

# [Testing checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md)
| Area | N/A | Checks |
|-|-|-|
|__MOC validation__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] Changes to [business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md) include appropriate updates to [data validators](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md#data-validators).<li/>- [ ] New or updated AUT run the MOC validator as part of teardown.</ul>|
|__Functional AUT__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] New and existing functional AUT pass (via workflow).<li/>- [ ] Functional AUT are implemented for new function that is deemed likely to fail.<li/>- [ ] New function that is not included in AUT is specified in the below table.  </ul>|
|__UIT__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] New and existing UIT pass locally with proposed changes.</ul>|

| AUT exception | Reasoning |
|-|-|