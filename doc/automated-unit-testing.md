# Automated Unit Testing
This document specifies the development approach and practices that Mu uses towards defining automated unit tests.

# Table of contents
1. [Tooling and conventions](#tooling-and-conventions)

# Tooling and environment
Mu uses XCTest to perform automated unit tests on the application.  

`Mu_AUT_Function` and `Mu_AUT_Performance` contain XCTestCases for Mu's function and performance unit tests, respectively. Their structures are as follows:  
* `Mu_AUT_Function`'s directory structure mirrors that of `Mu`, with identical nested directory name(s) and `-tests` appended to each directory.
* `Mu_AUT_Performance` does not contain subdirectories. Each performance XCTestCase is placed directly into the target's main dir and is named after one XCTestCase in `Mu_AUT_Function`, with `-Performance` appended to its name.