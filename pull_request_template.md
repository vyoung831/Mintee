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