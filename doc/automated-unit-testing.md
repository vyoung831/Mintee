# Automated Unit Testing
This document specifies the development approach and practices that Mu uses towards defining automated unit tests.

# Table of contents
1. [Tooling and environment](#tooling-and-environment)
1. [Testing approach](#testing-approach)

# Tooling and environment
Mu uses XCTest to perform automated unit tests on application code.  

`Mu_AUT_Function` and `Mu_AUT_Performance` contain XCTestCases for Mu's function and performance unit tests, respectively. Their structures are as follows:  
* `Mu_AUT_Function`'s directory structure mirrors that of `Mu`, with identical nested directory name(s) and `-tests` appended to each directory.
* `Mu_AUT_Performance` does not contain subdirectories. Each performance XCTestCase is placed directly into the target's main dir and is named after one XCTestCase in `Mu_AUT_Function`, with `-Performance` appended to its name.

# Testing approach
XCTestCases are separated by the component that is tested. In some cases, such as `Task`'s tests, test cases are split further and multiple XCTestCases exist for one component.  
Each XCTestCase includes sufficient comments to explain how the following determine the happy and error paths that are tested:  
* The intended usage of the function(s) being tested.
* Possible combinations of input parameters, based on business rules.
* Possible configurations (combinations of properties) of the tested component, based on business rules.