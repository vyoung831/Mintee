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

### Model components
__Transformables__
- [ ] Custom objects for transformables conform to NSSecureCoding.
- [ ] Custom objects for transformables are specified in the Core Data model.
- [ ] Custom data transformers are implemented and registered.

### View components
- [ ] New SwiftUI `Views` define `NavigationViews`.
- [ ] View components use accessibility for UIT identification __only__.

# [Failure handling checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/failure-handling-and-error-reporting.md)

### Failure handling
- [ ] All failures are handled gracefully by view components via error messages/graphics on UI.
- [ ] New Swift code avoids `if let` blocks and handles errors via `guard let else` blocks.

### Failure detection and propagation
__Failable functions in non-model components__
- [ ] Return optionals if there is one (and only one) possible reason of failure.
- [ ] Throw if there are multiple possible reasons for failure.
- [ ] Re-throw if there are calls to other throwing functions.

__Failable functions in model components__
- [ ] Failable functions in model components are defined as throwing functions.

### Failure reporting
__Failure reporting responsibilities__
- [ ] If a failure is first detected in a throwing function, that function reports the failure.
- [ ] If a failure is first detected by a view component receiving a nil return value, that view component reports the failure.
- [ ] All failures are reported to Crashlytics via `ErrorManager`.

# [Testing checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md)
__Tests passing__
- [ ] New and existing functional AUT pass locally with proposed changes.
- [ ] New and existing UIT pass locally with proposed changes.

__Persistent store validation__
- [ ] Changes to the data model include appropriate updates to [business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md).
- [ ] Changes to business rules include appropriate updates to [data validators](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md#data-validators).
- [ ] New or updated test cases that touch the persistent store run the MOC validator as part of teardown.

### Functional AUT
- [ ] Functional AUT are implemented for new function that is deemed likely to fail.
- [ ] New function that is not included in AUT is specified in the below table.  
| AUT exception | Reasoning |
|-|-|

### UIT