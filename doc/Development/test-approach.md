# Test Approach
This document specifies the practices that Mintee uses towards implementing AUT/UIT and defining coverage.  
This document references the product development lifecycle outlined [here](../../README.md).  
The following acronyms and definitions are used in this document as follows:  
* __AUT__: Automated unit test/testing.
* __UIT__: Automated UI test/testing.

# Table of contents
1. [SharedTestUtils](#sharedtestutils)
1. [AUT coverage](#aut-coverage)
1. [UIT coverage](#uit-coverage)

# Guidelines
1. [Data validators](../../pull_request_template.md#moc_validation)

# SharedTestUtils
`SharedTestUtils` contains helper classes used by test targets. It includes the following:
- Setup and helper functions for function and performance AUTs that correspond to the same test scenario.  
- The `TestContainer` class, used for
    - Setting up a persistent container separate from `CDCoordinator`.
    - Performing [validation](#data-validators) of the test MOC.

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