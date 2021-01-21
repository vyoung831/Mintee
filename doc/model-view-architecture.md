# Model-view Architecture
This document details the development guidelines that define model objects' and view objects' responsibilities.

1. [SaveFormatter](#saveformatter)

# SaveFormatter
Mu implements `SaveFormatter`, which defines enums, structs, and APIs to be used when converting data between persistent storage and memory.  
View objects that use values which will eventually be saved to persistent storage must use represent those values using types defined in `SaveFormatter`.  

For each type that is defined in `SaveFormatter`, functions must be implemented that provide the following functionality:  
* Convert data from persistent store form to enum/struct to use in-memory (`storedTo*()` functions).
* Convert in-memory enum/struct to persistent store save form (`*toStored()` functions).
* (As needed) Convert the enum/struct to different formats for UI to present.

The following code blocks illustrate examples of the intended usage of `SaveFormatter` in converting data between persistent store and memory.
```
var userVar: SaveFormatter.someEnum
func saveToStore() {
    modelObject.property = SaveFormatter.enumToStored(userVar)
}
```
```
var userVar: SaveFormatter.someEnum
func readFromStore() {
    guard let memoryFormat = SaveFormatter.storedToEnum(modelObject.property) else {
        // Handle error
    }
    userVar = memoryFormat
}
```