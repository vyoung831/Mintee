# Application architecture
This document outlines Mintee's code components and their integration with one another.  

# Table of Contents
1. [Notable components](#notable-components)
    1. [Singletons](#singletons)
        1. [ThemeManager](#thememanager)

# Notable components

## Singletons

### ThemeManager
`ThemeManager` is a class used to handle changes to the app's UI color scheme.
`ThemeManager` defines a shared instance that observes NSUserDefaults for updates to the theme. When changes are observed, the shared instance informs other objects by:
* Updating its published vars. SwiftUI components which declare the shared `ThemeManager` with the `@ObservedObject` property wrapper automatically have their views updated.
* Posting to notification center for non-SwiftUI components to observe and handle.