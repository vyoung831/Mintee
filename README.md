# Mu
Mu is a task and habit management application developed for iPhone.  
This document provides an overview of Mu's working procedures between business units, steps to getting started, and links to additional documentation and resources.  
The following acronyms and definitions are used in this document as follows:  
* __User data__: Data that a user creates and owns in Mu (not including settings or preferences).

# Table of Contents
1. [Product development lifecycle](#product-development-lifecycle)
    1. [BM documents](#bm-documents)
    1. [UI/UX collaboration](#uiux-collaboration)
    1. [Development Technotes](#development-technotes)

# Product development lifecycle
Mu's product development lifecycle divides internal responsibilities between the following 3 business units:
1. Business management (BM)
1. UI/UX
1. Development

The following table outlines each step of the product design/delivery lifecycle and each business unit's responsibilities.
| Step | Description/results | Responsible business units |
|-|-|-|
| 1. BM forms class diagram. | With input from development and UI/UX, BM conceptualizes the structure of Mu's user data in the form of a class diagram. | <ul> <li/> BM <li/> Development <li/> UI/UX </ul> |
| 2. Proposed changes to the project are accepted and a PUN (primary user need) is formed. | <ol> <li/> BM identifies and writes PUN. <li/> (If applicable) BM's class diagram and development data model is updated. <ol/> | <ul> <li/> BM <li/> Development </ul> |
| 3. (If the PUN involves updates to user data) BM designs activity diagram. | BM designs an activity diagram to visualize the PUN in terms of the following: <ul> <li/> User action. <li/> UI logic/validation. <li/> Back-end logic/validation. </ul> | <ul> <li/> BM </ul>
| 4. BM identifies and writes AUNs (ancillary user needs). | From the PUN, AUNs are formed that either: <ul> <li/> Enable the user to execute the PUN flow, or <li/> Provide the user with additional functionality to the PUN. </ul> While a PUN can be conceptual and further explained by AUN and activity diagrams, AUNs must satisfy the following conditions: <ul> <li/> Is self-explanatory and represents a clearly defined unit of work. <li/> Does not require implementation of business logic that affects user data. </ul> | <ul> <li/> BM </ul> |
| 5. (In parallel) UI/UX updates UI mockups and flows. | <ol> <li/> BM delivers PUN and AUNs (and activity diagrams if applicable) to UI/UX. <li/> UX analysis is performed and UI mockups are created/updated. <li/> Interactive UI elements and flows between mockups are identified. <li/> UI behaviour notes are recorded. </ol> | <ul> <li/> BM <li/> UI/UX </ul> |
| 5. (In parallel) Development implements back-end logic. | <ol> <li/> BM delivers PUN and AUNs (and activity diagrams if applicable) to development. <li/> Development implements back-end logic and AUT. </ol> | <ul> <li> BM <li/> Development </ul> |
| 6. Development implements/updates UI. | <ol> <li/> UI/UX delivers UI mockups, flows, and notes to development. <li/> Development implements layout and behaviour of UI views and elements. <li/> Development implements UITs. </ol> | <ul> <li/> UI/UX <li/> Development </ul> |

## BM documents
For business documents, see the following:  
1. [PUN and AUN statements](./doc/BM/user-need-statements.md)
1. [BM diagrams](https://drive.google.com/drive/folders/1qk9_LARZoiEpTpNbNvMDjwYW_gfJQf29)

## UI/UX collaboration
For UI/UX resources, see the following:  
1. [UI mockups and flows](https://balsamiq.cloud/sqag6rb/pypv7pl/r8188)
1. [UI behaviour notes](./doc/UI-UX/user-need-notes.md)

# Development Technotes
For technotes on design and development guidelines, see the following:  
1. [Development principles](./doc/Development/development-principles.md)
1. [Test approach](./doc/Development/test-approach.md)
1. [Error reporting and failure handling](./doc/Development/error-reporting-and-handling.md)