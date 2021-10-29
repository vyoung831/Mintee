# Description

### Type of change
- [ ] New feature
- [ ] Technical debt or bug fix
- [ ] Documentation update

### Related issue(s)

# [Application architecture checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/application-architecture.md)
- [ ] Model, view, and utility components maintain separation of concerns.

| Area | N/A | Checks |
|-|-|-|
|__Model components - Business rules syncing__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] Changes to any of the following include appropriate updates to [business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md):<ul><li/>- [ ] The data model<li/>- [ ] NSManagedObject subclasses<li/>- [ ] Transformables used by NSManagedObject subclasses</ul><li>- [ ] New/updated business rules that include any of the following include [appropriate](https://github.com/vyoung831/Mintee/blob/master/doc/Development/application-architecture.md#syncing-model-and-objects-with-business-rules) updates to the Core Data model or NSManagedObject subclasses:<ul><li/>Property is unique<li/>Property is non-nil (including transformables)<li/>To-one relationship is never nil<li/>To-many relationship is never nil</ul></ul>|
|__Model components - Transformables__|<ul><li/>- [ ] N/A</ul>|If changes include updates to or new transformables,<ul><li/>- [ ] Custom classes for transformables conform to NSSecureCoding.<li/>- [ ] Custom classes for transformables are specified in the model (`xcdatamodeld`).<li/>- [ ] Custom data transformers are implemented and registered during app startup.</ul>|
|__View components - Keyboard dismissal__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] If a control displays the keyboard, the keyboard is dismissed when any of the following occur:<ul><li/> A button is tapped that presents a new modal or popover.<li/> A button is tapped that dismisses the current modal or popover (handled automatically).</ul></ul>|
|__View components - New SwiftUI views__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] New SwiftUI Views define `NavigationViews`.<li/>- [ ] View components use accessibility for UIT identification __only__.</ul>|

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