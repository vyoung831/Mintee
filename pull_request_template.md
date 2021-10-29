# Description

### Type of change
- [ ] New feature
- [ ] Technical debt or bug fix
- [ ] Documentation update

### Notes

# [Application architecture](https://github.com/vyoung831/Mintee/blob/master/doc/Development/application-architecture.md)
- [ ] __Separation of concerns:__ The following are true for new/updated code.
    - Views only use helper functions from NSManagedObject subclass and CDCoordinator when updating and saving the model.
    - Views do not directly save or rollback any MOCs.

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

# [Business rules and logic](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md)

## General checks
- [ ] Changes to business rules include appropriate updates to [data validators](#business-rule-checking).
- [ ] Changes to any of the following include appropriate updates to business rules:
    - The data model
    - NSManagedObject subclasses
    - Transformables used by NSManagedObject subclasses

## Enforcing business rules
- [ ] __Enforcing business rules in code:__ All new/updated business rules are enforced the following way:

| What the business rule states | Method of enforcing |
|-|-|
| Property is unique | Specify constraint in Core Data model editor. |
| Property is non-nil (including transformables) | Specify property as non-optional in NSManagedObject subclass. |
| To-one relationship is never nil | Specify property as non-optional in NSManagedObject subclass. |
| To-many relationship is never nil | Specify NSSet as non-optional in NSManagedObject subclass. |

# [Testing](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md)

## General checks
- [ ] New and existing functional AUT pass.
- [ ] Functional AUT are implemented for new function that is deemed likely to fail.
- [ ] New and existing UIT pass locally with proposed changes.

## Business rule checking
Data validators are used to validate the MOC after each AUT to ensure that [business rules](../business-rules.md) are being followed.
- [ ] All AUT perform MOC validation (using [TestContainer](https://github.com/vyoung831/Mintee/blob/master/doc/Development/test-approach.md#sharedtestutils)) as part of teardown. This includes AUT that don't appear to touch the persistent store.
- [ ] Separate validators are defined for each entity and transformable that [business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md) define.
- [ ] In validators, business rules are validated in one of the following ways:
    - Validated and labeled in the comments of its validating function, OR
    - Not validated and noted in comments that the rule is:
        - Validated by another validator class, OR
        - [Enforced](https://github.com/vyoung831/Mintee/blob/master/doc/Development/application-architecture.md#syncing-model-and-objects-with-business-rules) by the model or its subclassed objects.