# Description

### Type of change
- [ ] New feature
- [ ] Technical debt or bug fix
- [ ] Documentation update

### Related issue(s)

# Checklist
Check off boxes that are true or not applicable

## Development

### View components
- [ ] __Keyboard usability:__ Displayed keyboards are dismissed when a button is tapped that presents a new modal or popover.
- [ ] __Navigation:__ New/updated Views declare `NavigationView`s in their bodies (to prepare for additional navigation and ensure consistent UI).
- [ ] __Accessibility:__ New/updated Views use accessibility for UIT identification __only__.
- [ ] __UI appearance:__ New/updated Views use the shared [ThemeManager](./doc/dev-notes#thememanager) to color the UI.
- [ ] __Separation of concerns:__ The following are true:
    - Views only use helper functions from NSManagedObject subclass and CDCoordinator when updating and saving the model.
    - Views do not directly save or rollback any MOCs.

### Model components
- [ ] `NSManagedObject` subclasses declare all `@NSManaged` attributes and relationships as private and provide getters.
- [ ] Where appropriate, getters validate [business rules](#business-rules) when accessing backing vars and [throw](#separation-of-error-reporting-responsibilities) if business rules are violated.
- [ ] If business rules aren't violated, getters return the following values:
    - __Non-optionals__ for vars that are never nil.
    - __Optionals__ for vars that may be nil.
    - __An empty set__ for relationships (to-one or to-many) if the backing `Set` is nil.
- [ ] Private properties in `NSManagedObject` subclasses are __only__ accessed by the class' getters and `mergeDebugDictionary` helper functions.

### Transformables
More on transformable security [here](https://www.kairadiagne.com/2020/01/13/nssecurecoding-and-transformable-properties-in-core-data.html).  
- [ ] __Security:__ For new/updated Transformables, the following are true for the custom classes that back it:
    - The custom class is updated to conform to `NSSecureCoding`.
    - The custom class is specified under the transformable's attributes in the Core Data model, allowing Core Data codegen to automatically protect against object substitution.
    - A custom transformer is subclassed from `NSSecureUnarchiveFromDataTransformer` and specified under the transformable's attributes in the Core Data model. The custom transformer does the following:  
        * Includes the `@objc` attribute in order to be accessible to the objective-C runtime and to Core Data.
        * Includes the custom class in its allowed top-level classes.
    - SceneDelegate is updated to register the custom transformer before initializing the persistent container.  

### Misc.
- [ ] Code uses `CDCoordinator` to retrieve child MOCs and save and merge changes into the main MOC. No new `rollback` or `save` code is introduced.

## Failure handling

### Code health
- [ ] No fatal errors are introduced to the code.
- [ ] `if let` code is avoided, except for SwiftUI Views checking for optionals returns from their helper functions.

### Separation of error reporting responsibilities
- [ ] Functions that do any of the following report an error to Crashlytics using `ErrorManager`.
    - Calls a non-Mintee function that fails (can't be corrected by user action). ex: Calling `save()` on an NSManagedObjectContext fails.
    - Directly manipulates/converts model data. ex: Throwing getters in NSManagedObject subclasses.
- [ ] If calling a failable function that reports errors to Crashlytics, calling functions re-throw the error (unless returning an optional for a SwiftUI View to use). Only one error is reported to Crashlytics for each call stack that finds an error.
- [ ] Views do __not__ report any errors to Crashlytics.
- [ ] Where appropriate, Views post to NotificationCenter to alert the user of an error.
- [ ] Where appropriate, Views display an error graphic to inform the user of an error.

### Transformables
- [ ] For custom classes used as transformables, initializers only fail and return nil if problems occur while decoding properties.

## [Business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md)
Related: [AUT data validation](#business-rule-validation)
- [ ] Where appropriate, business rules are [validated](#model-data-access-and-validation) within getters.
- [ ] Changes to business rules include appropriate updates to NSManagedObject getters and helper functions.
- [ ] Changes to any of the following include appropriate updates to business rules:
    - The data model
    - NSManagedObject subclasses
    - Custom classes used as Transformables

## [Testing](https://github.com/vyoung831/Mintee/blob/master/doc/dev-notes.md#testing)

### Test coverage
- [ ] New and existing functional AUT pass.
- [ ] Functional AUT are implemented for new function that is deemed likely to fail.
- [ ] New and existing UIT pass locally with proposed changes.

### Business rule validation
Data validators are used to validate the MOC after each AUT to ensure that [business rules](../business-rules.md) are being followed.
- [ ] All AUT perform MOC validation (using [TestContainer](https://github.com/vyoung831/Mintee/blob/master/doc/dev-notes.md#sharedtestutils)) as part of teardown. This includes AUT that don't appear to touch the persistent store.
- [ ] Separate validators are defined for each entity and transformable that [business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md) define.
- [ ] In validators, business rules are either
    - Validated and labeled in the comments of its validating function, OR
    - Noted in comments that the rule is validated by another validator class, or enforced by the model editor or NSManagedObject subclasses.

# Exceptions
Document unchecked items here: