# Crash reporting
Mu uses Firebase Crashlytics to report exceptions. More information on Crashlytics can be found [here](https://firebase.google.com/docs/crashlytics/customize-crash-reports).  
This document describes the development guidelines that must be adhered to in reporting errors.  

# Table of Contents
1. [Error handling approach](#error-handling-approach)
    1. [Non-fatal reporting](#non-fatal-reporting)
    1. [Fatal reporting](#fatal-reporting)
1. [Crashlytics configurations](#crashlytics-configurations)
1. [Build versioning](#build-versioning)
    1. [Notes](#build-versioning-notes)

# Error handling approach
Depending on the type of error scenario, Mu expects patterns to be followed in determining which class/struct report errors and what data should be reported, in order to . The following table details the expected development patterns:  
| Error scenario | Error type | Expected remediation | Class/struct that reports error | Additional data to report | \[Example(s)\] | Notes |
|-|-|-|-|-|-|-|
| Mu fails to convert persistent store data to valid data to use in-memory. | Non-fatal | Display `ErrorView` | The class/struct that reads the persistent store data. | <ul> <li> Persistent store objects whose properties contained the invalid data of interest. </li> <br/> <li> Related entities. </li> <ul/> | When `EditTaskHostingController` receives `nil` from calling `SaveFormatter.storedToTaskType` to convert a stored Int16 to SaveFormatter.TaskType, the error is reported by `EditTaskHostingController`. | Internal Mu classes that handle data conversion from persistent store to memory are expected to return optionals if there is input parameters could possibly be considered invalid. |

The steps to reporting errors are found in [non-fatal reporting](#non-fatal-reporting-process) and [fatal reporting](#fatal-reporting-process).

## Non-fatal reporting process
For non-fatal error reporting, Mu implements `ErrorManager`, a struct that classes must use to handle non-fatal reporting. Crashlytics APIs expect iOS applications to report non-fatals using instances of `NSError`.  
All non-fatal NSErrors in Mu are reported to Crashlytics with the following attributes:  
| Domain | Code |
|-|-|
| `Leko.Mu` (Bundle identifier) | Varies depending on error type. Enum values are defined in `ErrorManager` |

## Fatal reporting process
For fatal crash reporting, `ErrorManager` is not used. Instead, code that detects the crash is expected to complete the following:  
* Log needed messages to Crashlytics.
* Set custom Crashlytics values.
* Issue `fatalError`.  

# Crashlytics configurations and projects
In order to separate testing and release data, Mu uses the following build phase and configurations to capture data in 2 separate Firebase applications:  
1. The `Copy Bundle Resources` build phase copies plists for the 2 Firebase applications to the built product bundle.
1. The `Update GoogleService-Info.plist` build phase copies and renames the appropriate Firebase plist to `GoogleService-Info.plist` in the built bundle. The resulting `.app` reports data to Firebase based on the following:  
    * Builds that use `GoogleService-Info-Debug.plist` report to the Firebase application `Leko-Mu-Debug`
    * Builds that use `GoogleService-Info-Release.plist` report to Firebase application `Leko-Mu`

# Build versioning
To ensure that reported errors and crashes can be correlated back to the exact source code version, Mu follows a process of versioning builds based on [Twitch's iOS versioning practices](https://blog.twitch.tv/en/2016/09/20/ios-versioning-89e02f0a5146/).
Mu generates and updates the app's build version everytime the project is archived for distribution. This is achieved by the following build phases, targets, and scripts, and configurations:  
1. Mu preprocesses `Info.plist` by defining the following project-wide build settings:
    * `INFOPLIST_PREFIX_HEADER` = `${PROJECT_DIR}/Versions/versions.h`
    * `INFOPLIST_PREPROCESS` = `Yes`
1. Mu's `Info.plist` sets the property `CFBundleVersion` to value `MuBuildNumber` (to be preprocessed).
1. Mu's target dependency `Versions` is built before Mu is. `Versions` contains the `Update build versions` run script phase to generate a `versions.h` header file.
    * The `versions.h` contains a single preprocessor directive that defines the token `MuBuildNumber`, thus keeping up to date the `Info.plist` distributed with Mu.
    * `MuBuildNumber` is generated from the following steps:
        1. The short version of the git commit at the tip of the current branch is decimalized (max 9 characters).
        1. The current epoch is taken and converted to minutes (8 characters until 2160).
        1. The bundle version is constructed using the format `<decimalized-short-commit>.<epoch-minutes>`, satisfying the 18-character limit of `CFBundleVersion`.

## Build versioning notes
* Properties in `Info.plist` are updated every time for builds using the `Release` build configuration. XCode actions that use the `Debug` build configuration - such as `Build`, `Run`, `Test`, and `Analyze` - require a full build for the built product to include updated version numbers.
* For builds using the `Release` configuration, the `Check Git changes` build phase of `Versions` is used to verify that the current branch is up-to-date with and tracking from `master`, with no merge conflicts or uncommitted changes.
