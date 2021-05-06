# Test Approach
This document specifies the practices that Mintee uses towards implementing AUT/UIT and defining coverage.  
This document references the product development lifecycle outlined [here](../../README.md).  
The following acronyms and definitions are used in this document as follows:  
* __AUT__: Automated unit test/testing.
* __UIT__: Automated UI test/testing.

# Table of contents
1. [Tooling and environment](#tooling-and-environment)
    1. [AUT](#aut-structure)
        1. [SharedTestUtils](#sharedtestutils)
    1. [UIT](#uit-structure)
1. [AUT coverage](#aut-coverage)
1. [UIT coverage](#uit-coverage)

# Tooling and environment
Mintee uses XCTest to perform AUT on application code, and UIT on the application's user flows.  

## AUT structure
`Mintee_AUT_Function` and `Mintee_AUT_Performance` contain XCTestCases for Mintee's function and performance AUTs, respectively. Their structures are as follows:  
* `Mintee_AUT_Function`'s directory structure mirrors that of `Mintee`, with identical nested directory name(s) and `-tests` appended to each directory.
* `Mintee_AUT_Performance` does not contain subdirectories. Each performance XCTestCase is placed directly into the target's main dir and is named after one XCTestCase in `Mintee_AUT_Function`, with `-Performance` appended to its name.

### SharedTestUtils
Because performance AUTs are based on function AUTs, Mintee defines the `SharedTestUtils` static library target, which provides setup and helper functions for function and performance AUTs that correspond to the same test scenario.  
Both AUT targets list `SharedTestUtils` as a target dependency.

## UIT structure
`Mintee_UIT` contains XCTestCases for Mintee's automated UITs.

# AUT coverage
Development makes AUT coverage decisions and documents them in the comments of the XCTestCase(s) itself.  
AUTs are separated by the [component](./application-architecture.md) that is tested. In some cases, such as `Task`'s tests, AUTs are split further and multiple XCTestCases exist for one component. 

# UIT coverage