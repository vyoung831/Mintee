# Description
Provide a summary of the changes.

### Type of change
Delete N/A options
- [ ] New feature
- [ ] Technical debt or bug fix
- [ ] Documentation update

### Related issue(s)

# [Application architecture checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/application-architecture.md)
- [ ] Model, view, and utility components maintain separation of concerns.

| Area | N/A | Checks |
|-|-|-|
|__Model components - Transformables__|<ul><li/>- [ ] N/A</ul>|If changes include updates to or new transformables,<ul><li/>- [ ] Custom classes for transformables conform to NSSecureCoding.<li/>- [ ] Custom classes for transformables are specified in the model (`xcdatamodeld`).<li/>- [ ] Custom data transformers are implemented and registered during app startup.</ul>|
|__View components - New SwiftUI views__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] New SwiftUI Views define `NavigationViews`.<li/>- [ ] View components use accessibility for UIT identification __only__.</ul>|

# [Failure handling checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/failure-handling-and-error-reporting.md)
| Area | N/A | Checks |
|-|-|-|
|__Failure handling__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] All failures are handled gracefully by view components via error messages/graphics on UI.<li/>- [ ] New Swift code avoids `if let` blocks and handles errors via `guard let else` blocks.</ul>|
|__Failure detection and propagation - Failable functions in non-model components__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] Return optionals if there is one (and only one) possible reason of failure.<li/>- [ ] Throw if there are multiple possible reasons for failure.<li/>- [ ] Re-throw if there are calls to other throwing functions.</ul>|
|__Failure detection and propagation - Failable functions in model components__ |<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] Failable functions in model components are defined as throwing functions.</ul>|
|__Failure reporting - Failure reporting responsibilities__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] If a failure is first detected in a throwing function, that function reports the failure.<li>- [ ] If a failure is first detected by a view component receiving a nil return value, that view component reports the failure.<li/>- [ ] All failures are reported to Crashlytics via `ErrorManager`.</ul>|

# [Testing checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md)
| Area | N/A | Checks |
|-|-|-|
|__Persistent store validation__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] Changes to any of the following include appropriate updates to [business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md).<ul><li/>The data model<li/>NSManagedObject subclasses<li/>Transformables used by NSManagedObject subclasses.</ul><li/>- [ ] Changes to business rules include appropriate updates to [data validators](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md#data-validators).<li/>- [ ] New or updated AUT run the MOC validator as part of teardown.</ul>|
|__Functional AUT__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] New and existing functional AUT pass (via workflow).<li/>- [ ] Functional AUT are implemented for new function that is deemed likely to fail.<li/>- [ ] New function that is not included in AUT is specified in the below table.  </ul>|
|__UIT__|<ul><li/>- [ ] N/A</ul>|<ul><li/>- [ ] New and existing UIT pass locally with proposed changes.</ul>|

| AUT exception | Reasoning |
|-|-|