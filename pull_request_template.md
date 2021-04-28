# Description
Provide a summary of the changes.

## Type of change
Delete N/A options
- [ ] New feature
- [ ] Technical debt or bug fix
- [ ] Documentation update

## Related issue(s)

# [Development checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/development-principles.md)
- [ ] Model, view, and utility components maintain separation of concerns.

## Model components
- Transformables:
    - [ ] Custom objects for transformables conform to NSSecureCoding.
    - [ ] Custom objects for transformables are specified in the Core Data model.
    - [ ] Custom data transformers are implemented and registered.

## View components
- [ ] New SwiftUI `Views` define `NavigationViews`.
- [ ] View components use accessibility only for identification.

# [Failure handling checklist](https://github.com/vyoung831/Mintee/blob/master/doc/Development/failure-handling-and-error-reporting.md)

## Failure handling
- [ ] All failures are handled gracefully by view components via error messages/graphics on UI.
- [ ] New Swift code avoids `if let` blocks and handles errors via `guard let else` blocks.

## Failure detection and propagation
- [ ] Failable functions in model components are defined as throwing functions.
- Failable functions in non-model components:
    - [ ] Return optionals if there is one (and only one) possible reason of failure.
    - [ ] Throw if there are multiple possible failure detection.
    - [ ] Re-throw if there are calls to other throwing functions

## Failure reporting
- [ ] All failures are reported to Crashlytics via `ErrorManager`.
- Failure reporting responsibilities:
    - If a failure is first detected in a throwing function, that function reports the failure.
    - If a failure is first detected by a view component receiving a nil return value, that view component reports the failure.

# Testing checklist
- [ ] New AUT are implemented that comply with [test approach](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md)
- [ ] New UIT are implemented that comply to [test approach](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md)
- [ ] New and existing unit tests pass locally with my changes
