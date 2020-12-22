# Mu
Mu is a task and habit management application developed for iPhone and iPad.

For technotes on design and development guidelines, see the following
1. [Crash reporting](#crash-reporting)

# Crash reporting
Mu uses Firebase Crashlytics to report exceptions. More information can be found [here](https://firebase.google.com/docs/crashlytics/customize-crash-reports).  

## Non-fatal errors
For non-fatal error reporting, Mu implements `ErrorManager`, a struct that classes must use to handle non-fatal reporting.  
For non-fatal errors, Crashlytics APIs expect iOS applications to report instances of NSError. Firebase then groups NSErrors by their domains and codes.  
All non-fatal NSErrors in Mu are reported with the following attributes:  
| Domain | Code |
|-|-|
| `Leko.Mu` (Bundle identifier) | Depends on error type. Enum values defined in `ErrorManager` |

## Fatal crashes
For fatal crash reporting, `ErrorManager` is not used. Instead, code that detects the crash is expected to complete the following:  
* Log needed messages to Crashlytics.
* Set custom Crashlytics values.
* Issue `fatalError`

## Crashlytics configurations and projects
In order to separate testing and release data, Mu's usage is captured in 2 separate Firebase applications using the following build phases:  
1. The `Copy Bundle Resources` phase copies plists for the Firebase applications to the built product bundle.
1. The `Update GoogleService-Info.plist` build phase copies and renames the appropriate Firebase plist to `GoogleService-Info.plist` in the built `.app` product. The resulting app reports data to Firebase based on the following:  
* Builds that use `GoogleService-Info-Debug.plist` report to the Firebase application `Leko-Mu-Debug`
* Builds that use `GoogleService-Info-Release.plist` report to Firebase application `Leko-Mu`