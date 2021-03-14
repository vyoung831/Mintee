# Description
Provide a summary of the changes.

## Type of change
Delete N/A options
- [ ] New feature
- [ ] Technical debt or bug fix
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Related issue(s)
List related issue(s)

# Development checklist
- [ ] New code adheres to [development principles](https://github.com/vyoung831/Mu/blob/master/doc/Development/development-principles.md).
    - New code for each application component:
        - [ ] Satisifies its responsibilities and maintains separation of concerns
        - Integrates with notable components:
            - [ ] SaveFormatter
            - [ ] ThemeManager
    - New model components:
        - Transformables:
            - [ ] Custom objects for transformables conform to NSSecureCoding
            - [ ] Custom objects for transformables are specified in the Core Data model
            - [ ] Custom data transformers are implemented and registered
    - New view components:
        - [ ] Use accessibility only for identification.
        - [ ] Define navigation views.
- [ ] Necessary comments and documentation are updated
- [ ] New AUT are implemented that comply with [test approach](https://github.com/vyoung831/Mu/blob/master/doc/Development/test-approach.md)
- [ ] New UIT are implemented that comply to [test approach](https://github.com/vyoung831/Mu/blob/master/doc/Development/test-approach.md)
- [ ] New and existing unit tests pass locally with my changes
