# Testing Approaches
This document specifies the practices that Mu uses towards implementing AUT/UIT and defining coverage.  
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
Mu uses XCTest to perform AUT on application code, and UIT on the application's user flows.  

## AUT structure
`Mu_AUT_Function` and `Mu_AUT_Performance` contain XCTestCases for Mu's function and performance AUTs, respectively. Their structures are as follows:  
* `Mu_AUT_Function`'s directory structure mirrors that of `Mu`, with identical nested directory name(s) and `-tests` appended to each directory.
* `Mu_AUT_Performance` does not contain subdirectories. Each performance XCTestCase is placed directly into the target's main dir and is named after one XCTestCase in `Mu_AUT_Function`, with `-Performance` appended to its name.

## SharedTestUtils
Because performance AUTs are based on function AUTs, Mu defines a static library target named `SharedTestUtils`, which provides setup and helper functions for function and performance AUTs that correspond to the same test scenario.  
Both AUT targets list `SharedTestUtils` as a target dependency.

## UIT structure
`Mu_UI_Tests` contains XCTestCases for Mu's automated UITs. Each XCTestCase corresponds to one AUN or one PUN.

# AUT coverage
Development makes AUT coverage decisions and documents them in the comments of the XCTestCase(s) itself.  
AUTs are separated by the [component](./development-principles.md) that is tested. In some cases, such as `Task`'s tests, AUTs are split further and multiple XCTestCases exist for one component. 

# UIT coverage
UITs are separated for each AUN and PUN. For each, development documents test scenario/input decisions in the comments of the XCTestCase(s) itself.  
UIT test coverage adheres to the following principles:  
* PUN: Development determines coverage by reviewing the PUN and possible input combinations.
* AUN: Development determines coverage using notes that UI/UX gives development and/or decisions that development makes regarding UI interaction.
    * UI behaviour notes are documented [here](../UI-UX/user-need-notes.md).
    * UI interaction decisions made by development are documented in the corresponding [view component](./development-principles.md)'s comments.