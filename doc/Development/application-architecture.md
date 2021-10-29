# Application architecture

# Table of Contents
1. [Notable components](#notable-components)
    1. [Singletons](#singletons)
        1. [ThemeManager](#thememanager)
1. [Testing](#testing)
    1. [SharedTestUtils](#sharedtestutils)

# Notable components

## Singletons

### ThemeManager
`ThemeManager` is a class used to handle changes to the app's UI color scheme.
`ThemeManager` defines a shared instance that observes NSUserDefaults for updates to the theme. When changes are observed, the shared instance informs other objects by:
* Updating its published vars. SwiftUI components which declare the shared `ThemeManager` with the `@ObservedObject` property wrapper automatically have their views updated.
* Posting to notification center for non-SwiftUI components to observe and handle.

# Testing

## SharedTestUtils
`SharedTestUtils` contains helper classes used by test targets. It includes the following:
- Setup and helper functions for function and performance AUTs that correspond to the same test scenario.  
- The `TestContainer` class, used for
    - Setting up a persistent container separate from `CDCoordinator`.
    - Performing [validation](#data-validators) of the test MOC.