# Test Approach
This document specifies the practices that Mintee uses towards implementing AUT/UIT and defining coverage.  
This document references the product development lifecycle outlined [here](../../README.md).  
The following acronyms and definitions are used in this document as follows:  
* __AUT__: Automated unit test/testing.
* __UIT__: Automated UI test/testing.

# Table of contents
1. [Tooling and environment](#tooling-and-environment)
    1. [AUT](#aut-structure)
    1. [UIT](#uit-structure)
    1. [SharedTestUtils](#sharedtestutils)
        1. [Data validators](#data-validators)
1. [AUT coverage](#aut-coverage)
1. [UIT coverage](#uit-coverage)

# Tooling and environment
Mintee uses XCTest to perform AUT on application code, and UIT on the application's user flows.  

## AUT structure
`Mintee_AUT_Function` and `Mintee_AUT_Performance` contain XCTestCases for Mintee's function and performance AUTs, respectively. Their structures are as follows:  
* `Mintee_AUT_Function`'s directory structure mirrors that of `Mintee`, with identical nested directory name(s) and `-tests` appended to each directory.
* `Mintee_AUT_Performance` does not contain subdirectories. Each performance XCTestCase is placed directly into the target's main dir and is named after one XCTestCase in `Mintee_AUT_Function`, with `-Performance` appended to its name.

## UIT structure
`Mintee_UIT` contains XCTestCases for Mintee's automated UITs.

## SharedTestUtils
`SharedTestUtils` contains utility classes used by all test targets. It includes the following functionality:
- Setup and helper functions for function and performance AUTs that correspond to the same test scenario.  
- [Data validators](#data-validators)

### Data validators
Data validators are used to examine the persistent store after each test case that touches persistent store data, ensuring that [business rules](https://github.com/vyoung831/Mintee/blob/master/doc/business-rules.md) for data storage are being followed. The following rules are followed:  
- Every test case that touches persistent store data must run the MOC validator as part of teardown.
- Separate data validator classes are defined for each entity or transformable defined in business rules. Custom classes used by transformables are validated in the transformable's validator.
- The validation of each business rule must be either:
    - Labeled in the comments of its validating function, OR
    - Pointed out in the class' comments that the rule is validated by another validator.

# AUT coverage
Development decides which new functions to include in AUT (and makes note of them in PRs), and makes and documents AUT coverage decisions in the comments of the XCTestCase(s) itself.  
AUTs are separated by the [component](./application-architecture.md) that is tested. In some cases, such as `Task` tests, AUTs are split further and multiple XCTestCases exist for one component.

# UIT coverage
Mintee UIT does __not__ cover UI appearance, including colors and sizing.  
Instead, Mintee's UIT coverage only tests for UI elements' interaction with the following types of data:  
* __PCD (Persistent container data):__ Data in the persistent container.
* __VD (View data):__ Data that exists outside of persistent container and is displayed by UI elements (__ex:__ data on forms like `AddAnalysis`).

Each UIT class defines, in comments, the following for each UI element to test: 
* VDI (VD input)
* PCDI (PCD input)
* VDO (VD output)
* PCDO (PCD output)
* Combinations of PCDI to use for test scenarios
* Combinations of VDI to use for test scenarios. If a VDI's value can be altered by user action (VDO from other UI elements), tests should use that UI element's tests as setup. 

In addition to listing inputs and outputs for test scenarios, the following questions should be considered when determining UIT coverage:  
| Characteristic of UI element | Considerations |
|-|-|
| Element displays PCD(PCDI) | <ul> <li/> Does the element successfully refresh after PCD is updated? </ul> |
| Element updates VD(VDO) | <ul> <li/> Does the updated view successfully refresh after VD is updated? <li/> Is the VD actually updated? Incorrect usage of SwiftUI property wrappers can cause Views to appear to be updated, even when the underlying value has not. </ul> |