# Description

Provide a summary of the changes.

## Type of change

Delete N/A options
- [ ] New feature
- [ ] Technical debt or bug fix
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Related issue(s)

List related zenhub issue(s)

# Development checklist

- [ ] New code adheres to [development principles](./doc/Development/development-principles.md).
    - [ ] New code for each application component:
        - [ ] Satisifies its responsibilities and maintains separation of concerns.
        - Integrates with notable components:
            - [ ] SaveFormatter
            - [ ] ThemeManager
    - New view components:
        - [ ] Use accessibility only for identification.
        - [ ] Define navigation views.
- [ ] Necessary comments and documentation are updated
- [ ] New AUT are implemented that comply with [test approach](./doc/Development/test-approach.md)
- [ ] New UIT are implemented that comply to [test approach](./doc/Development/test-approach.md)
- [ ] New and existing unit tests pass locally with my changes
