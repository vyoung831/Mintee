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

# [Failure handling checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/failure-handling-and-error-reporting.md)
| Area | N/A | Checks |
|-|-|-|
|__Failure handling__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] All failures are handled gracefully by view components by presenting alerts to the user.<li/>- [ ] New Swift code avoids `if let` blocks and handles errors via `guard let else` blocks.</ul>|
|__Failure reporting responsibilities__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] A function reports an error to Crashlytics if it calls a non-Mintee function that returns a failure.<li>- [ ] A function reports an error to Crashlytics if it is directly manipulating/accessing/converting data.<li/>- [ ] A function does __NOT__ report an error if it calls a failable Mintee function.</ul>|

# [Testing checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md)
| Area | N/A | Checks |
|-|-|-|
|__MOC validation__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] Changes to [business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md) include appropriate updates to [data validators](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md#data-validators).<li/>- [ ] New or updated AUT run the MOC validator as part of teardown.</ul>|
|__Functional AUT__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] New and existing functional AUT pass (via workflow).<li/>- [ ] Functional AUT are implemented for new function that is deemed likely to fail.<li/>- [ ] New function that is not included in AUT is specified in the below table.  </ul>|
|__UIT__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] New and existing UIT pass locally with proposed changes.</ul>|

| AUT exception | Reasoning |
|-|-|