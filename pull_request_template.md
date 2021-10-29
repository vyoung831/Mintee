# Description

### Type of change
- [ ] New feature
- [ ] Technical debt or bug fix
- [ ] Documentation update

### Notes

# Checklist
Check off boxes that are true or not applicable

## Development

### View components
- [ ] __Keyboard usability:__ Displayed keyboards are dismissed when the following occurs:
    - A button is tapped that presents a new modal or popover.
- [ ] __Navigation:__ Every new/updated SwiftUI View declares a `NavigationView` in its body (to prepare for additional navigation and ensure consistent UI).
- [ ] __Accessibility:__ View components use accessibility for UIT identification __only__.
- [ ] __Separation of concerns:__ The following are true:
    - Views only use helper functions from NSManagedObject subclass and CDCoordinator when updating and saving the model.
    - Views do not directly save or rollback any MOCs.

### Transformables
More on transformable security [here](https://www.kairadiagne.com/2020/01/13/nssecurecoding-and-transformable-properties-in-core-data.html).  
- [ ] __Security:__ For new/updated Transformables, the following are true for the custom classes that back it:
    - The custom class is updated to conform to `NSSecureCoding`.
    - The custom class is specified under the transformable's attributes in the Core Data model, allowing Core Data codegen to automatically protect against object substitution.
    - A custom transformer is subclassed from `NSSecureUnarchiveFromDataTransformer` and specified under the transformable's attributes in the Core Data model. The custom transformer does the following:  
        * Includes the `@objc` attribute in order to be accessible to the objective-C runtime and to Core Data.
        * Includes the custom class in its allowed top-level classes.
    - SceneDelegate is updated to register the custom transformer before initializing the persistent container.  

## Failure handling

### Code health
- [ ] No fatal errors are introduced to the code.
- [ ] `if let` code is avoided, except for SwiftUI Views and their helper functions checking for optionals (see [error reporting responsibilities](#separation-of-error-reporting-responsibilities)).

### Separation of error reporting responsibilities
- [ ] Functions that do any of the following report an error to Crashlytics using `ErrorManager`.
    - Calls a non-Mintee function that fails (can't be corrected by user action). ex: Catching an error when saving an NSManagedObjectContext.
    - Directly manipulates/converts model data. ex: Throwing getters in NSManagedObject subclasses.
- [ ] Functions that call a failable function re-throw the error unless returning an optional for a SwiftUI View to use. Only one error is reported to crashlytics for each call stack that finds an error.
- [ ] Where appropriate, Views post to NotificationCenter to alert the user of an error.

## [Business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md)
- [ ] Changes to business rules include appropriate updates to
    - [Data validators](#business-rule-validation)
    - NSManagedObject APIs, including getters
- [ ] Changes to any of the following include appropriate updates to business rules:
    - The data model
    - NSManagedObject subclasses
    - Transformables used by NSManagedObject subclasses

## [Testing](https://github.com/vyoung831/Mintee/blob/master/doc/dev-notes.md#testing)

### Test coverage
- [ ] New and existing functional AUT pass.
- [ ] Functional AUT are implemented for new function that is deemed likely to fail.
- [ ] New and existing UIT pass locally with proposed changes.

### Business rule validation
Data validators are used to validate the MOC after each AUT to ensure that [business rules](../business-rules.md) are being followed.
- [ ] All AUT perform MOC validation (using [TestContainer](https://github.com/vyoung831/Mintee/blob/master/doc/dev-notes.md#sharedtestutils)) as part of teardown. This includes AUT that don't appear to touch the persistent store.
- [ ] Separate validators are defined for each entity and transformable that [business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md) define.
- [ ] In validators, business rules are validated in one of the following ways:
    - Validated and labeled in the comments of its validating function, OR
    - Not validated and noted in comments that the rule is:
        - Validated by another validator class, OR
        - [Enforced](https://github.com/vyoung831/Mintee/blob/master/doc/dev-notes.md#syncing-model-and-objects-with-business-rules) by the model or its subclassed objects.

# Exceptions
Document unchecked boxes here: